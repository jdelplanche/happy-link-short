
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
