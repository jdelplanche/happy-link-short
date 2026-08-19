ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS verified_legal_name text,
  ADD COLUMN IF NOT EXISTS forwarding_email_verified boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS forwarding_email_token text,
  ADD COLUMN IF NOT EXISTS forwarding_email_token_expires_at timestamptz;

REVOKE UPDATE (verified_legal_name, forwarding_email_verified, forwarding_email_token, forwarding_email_token_expires_at) ON public.profiles FROM authenticated;
REVOKE SELECT (forwarding_email_token) ON public.profiles FROM authenticated, anon;

-- Unique short codes: the resolver relies on one row per slug.
CREATE UNIQUE INDEX IF NOT EXISTS tracked_qrs_slug_key ON public.tracked_qrs (slug);

-- Resolve a short code to its destination. SECURITY DEFINER on purpose: the
-- table stays fully locked (no anon SELECT policy) so nobody can enumerate
-- other people's links; this function reveals only the row that was asked for.
CREATE OR REPLACE FUNCTION public.resolve_short_link(_slug text)
RETURNS TABLE (id uuid, target_url text, status text)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  r record;
  o record;
BEGIN
  SELECT t.id, t.target_url, t.is_active, t.expires_at, t.user_id
    INTO r
    FROM public.tracked_qrs t
   WHERE t.slug = _slug;

  IF NOT FOUND THEN
    RETURN QUERY SELECT NULL::uuid, NULL::text, 'not_found'::text;
    RETURN;
  END IF;

  IF r.is_active IS FALSE THEN
    RETURN QUERY SELECT r.id, NULL::text, 'disabled'::text;
    RETURN;
  END IF;

  IF r.expires_at IS NOT NULL AND r.expires_at < now() THEN
    RETURN QUERY SELECT r.id, NULL::text, 'expired'::text;
    RETURN;
  END IF;

  IF r.user_id IS NOT NULL THEN
    SELECT p.is_suspended, p.is_banned INTO o FROM public.profiles p WHERE p.id = r.user_id;
    IF o.is_suspended IS TRUE OR o.is_banned IS TRUE THEN
      RETURN QUERY SELECT r.id, NULL::text, 'suspended'::text;
      RETURN;
    END IF;
  END IF;

  RETURN QUERY SELECT r.id, r.target_url, 'ok'::text;
END;
$$;

-- Count a scan/click. Only accepts an id that actually exists; no read access.
CREATE OR REPLACE FUNCTION public.log_qr_scan(
  _tracked_qr_id uuid,
  _device text DEFAULT NULL,
  _country text DEFAULT NULL,
  _user_agent text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.tracked_qrs t WHERE t.id = _tracked_qr_id) THEN
    RETURN;
  END IF;
  INSERT INTO public.qr_scans (tracked_qr_id, device, country, user_agent)
  VALUES (_tracked_qr_id, left(_device, 32), left(_country, 8), left(_user_agent, 500));
END;
$$;

-- Private stats link: the unguessable dashboard token is the credential.
CREATE OR REPLACE FUNCTION public.short_link_stats(_token text)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  r record;
  scans jsonb;
BEGIN
  IF _token IS NULL OR length(_token) < 12 THEN
    RETURN NULL;
  END IF;

  SELECT t.id, t.slug, t.label, t.target_type, t.target_url, t.kind, t.custom_domain,
         t.is_active, t.expires_at, t.created_at
    INTO r
    FROM public.tracked_qrs t
   WHERE t.dashboard_token = _token;

  IF NOT FOUND THEN
    RETURN NULL;
  END IF;

  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'scanned_at', s.scanned_at,
           'country', s.country,
           'device', s.device,
           'user_agent', s.user_agent
         ) ORDER BY s.scanned_at DESC), '[]'::jsonb)
    INTO scans
    FROM public.qr_scans s
   WHERE s.tracked_qr_id = r.id;

  RETURN jsonb_build_object(
    'qr', to_jsonb(r),
    'scans', scans
  );
END;
$$;

REVOKE ALL ON FUNCTION public.resolve_short_link(text) FROM public;
REVOKE ALL ON FUNCTION public.log_qr_scan(uuid, text, text, text) FROM public;
REVOKE ALL ON FUNCTION public.short_link_stats(text) FROM public;
GRANT EXECUTE ON FUNCTION public.resolve_short_link(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.log_qr_scan(uuid, text, text, text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.short_link_stats(text) TO anon, authenticated;

-- Token-authorised management of a single link. SECURITY DEFINER because the
-- holder of the unguessable dashboard token is not necessarily signed in; every
-- statement is scoped to the one row that matches the token.
CREATE OR REPLACE FUNCTION public.manage_short_link(
  _token text,
  _action text,
  _target_url text DEFAULT NULL,
  _is_active boolean DEFAULT NULL,
  _expires_at timestamptz DEFAULT NULL,
  _slug text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  r record;
BEGIN
  IF _token IS NULL OR length(_token) < 12 THEN
    RAISE EXCEPTION 'Not found';
  END IF;

  SELECT t.id, t.slug INTO r FROM public.tracked_qrs t WHERE t.dashboard_token = _token;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Not found';
  END IF;

  IF _action = 'set_active' THEN
    UPDATE public.tracked_qrs SET is_active = coalesce(_is_active, true) WHERE id = r.id;

  ELSIF _action = 'set_target' THEN
    IF _target_url IS NULL OR _target_url !~* '^https?://' THEN
      RAISE EXCEPTION 'Invalid target URL';
    END IF;
    UPDATE public.tracked_qrs SET target_url = _target_url WHERE id = r.id;

  ELSIF _action = 'set_expiry' THEN
    UPDATE public.tracked_qrs SET expires_at = _expires_at WHERE id = r.id;

  ELSIF _action = 'regenerate_slug' THEN
    IF _slug IS NULL OR _slug !~ '^[a-z0-9][a-z0-9-]{1,31}$' THEN
      RAISE EXCEPTION 'Invalid slug';
    END IF;
    IF EXISTS (SELECT 1 FROM public.tracked_qrs WHERE slug = _slug AND id <> r.id) THEN
      RAISE EXCEPTION 'Slug already taken';
    END IF;
    UPDATE public.tracked_qrs SET slug = _slug WHERE id = r.id;

  ELSE
    RAISE EXCEPTION 'Unknown action';
  END IF;

  RETURN jsonb_build_object('ok', true);
END;
$$;

REVOKE ALL ON FUNCTION public.manage_short_link(text, text, text, boolean, timestamptz, text) FROM public;
GRANT EXECUTE ON FUNCTION public.manage_short_link(text, text, text, boolean, timestamptz, text) TO anon, authenticated;

create or replace function public.grant_signup_badges(_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_badges (user_id, badge_id)
  select _user_id, b.id from public.badges b where b.slug = 'early_believer'
  on conflict do nothing;
exception when others then
  null;
end;
$$;

REVOKE ALL ON FUNCTION public.grant_signup_badges(uuid) FROM public, anon, authenticated;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $function$
DECLARE
  existing_admins INT;
  new_handle text;
BEGIN
  new_handle := public.generate_unique_handle(
    coalesce(NEW.raw_user_meta_data->>'username', NEW.email, NEW.id::text)
  );

  INSERT INTO public.profiles (id, display_name, username)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
    new_handle
  )
  ON CONFLICT (id) DO NOTHING;

  SELECT count(*) INTO existing_admins FROM public.user_roles WHERE role = 'admin';

  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, CASE WHEN existing_admins = 0 THEN 'admin'::app_role ELSE 'user'::app_role END)
  ON CONFLICT (user_id, role) DO NOTHING;

  PERFORM public.grant_signup_badges(NEW.id);

  BEGIN
    PERFORM public.seed_demo_content(NEW.id);
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;

  RETURN NEW;
END;
$function$;

insert into public.user_badges (user_id, badge_id)
select p.id, b.id
from public.profiles p
cross join public.badges b
where b.slug = 'early_believer'
on conflict do nothing;

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

REVOKE ALL ON FUNCTION public.log_verification_status_change() FROM public, anon, authenticated;

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