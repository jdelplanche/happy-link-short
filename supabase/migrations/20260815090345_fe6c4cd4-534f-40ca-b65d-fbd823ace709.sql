CREATE TABLE IF NOT EXISTS public.badge_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  badge_slug text NOT NULL,
  action text NOT NULL DEFAULT 'granted',
  source text NOT NULL DEFAULT 'system',
  details jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT ON public.badge_events TO authenticated;
GRANT ALL ON public.badge_events TO service_role;

ALTER TABLE public.badge_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own badge events"
  ON public.badge_events FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Admins read all badge events"
  ON public.badge_events FOR SELECT TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Members log own badge events"
  ON public.badge_events FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id OR public.has_role(auth.uid(), 'admin'));

CREATE INDEX IF NOT EXISTS badge_events_user_created_idx
  ON public.badge_events (user_id, created_at DESC);

-- Admins need to read the security log to support members; members see their own.
CREATE POLICY "Admins read security events"
  ON public.security_events FOR SELECT TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Users read own security events"
  ON public.security_events FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

GRANT SELECT ON public.security_events TO authenticated;
GRANT ALL ON public.security_events TO service_role;

-- Verification status history, written automatically.
CREATE OR REPLACE FUNCTION public.log_verification_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.verified IS DISTINCT FROM OLD.verified
     OR NEW.is_paid IS DISTINCT FROM OLD.is_paid
     OR NEW.is_early_believer IS DISTINCT FROM OLD.is_early_believer
     OR NEW.status IS DISTINCT FROM OLD.status THEN
    INSERT INTO public.security_events (user_id, kind, severity, message, details)
    VALUES (
      NEW.id,
      'verification_status_changed',
      'info',
      'Verification status changed.',
      jsonb_build_object(
        'verified', jsonb_build_array(OLD.verified, NEW.verified),
        'is_paid', jsonb_build_array(OLD.is_paid, NEW.is_paid),
        'is_early_believer', jsonb_build_array(OLD.is_early_believer, NEW.is_early_believer),
        'status', jsonb_build_array(OLD.status, NEW.status)
      )
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS profiles_log_verification_status ON public.profiles;
CREATE TRIGGER profiles_log_verification_status
  AFTER UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.log_verification_status_change();

-- Realtime: the dashboard listens to these tables.
ALTER TABLE public.profiles REPLICA IDENTITY FULL;
ALTER TABLE public.user_badges REPLICA IDENTITY FULL;
ALTER TABLE public.badge_events REPLICA IDENTITY FULL;
ALTER TABLE public.verification_payments REPLICA IDENTITY FULL;

ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_badges;
ALTER PUBLICATION supabase_realtime ADD TABLE public.badge_events;
ALTER PUBLICATION supabase_realtime ADD TABLE public.verification_payments;