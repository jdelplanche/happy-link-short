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