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