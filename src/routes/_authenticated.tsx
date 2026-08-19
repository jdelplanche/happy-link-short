import { Outlet, createFileRoute, useLocation, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";

import { RoutePendingSkeleton } from "@/components/RouteFallbacks";
import { supabase } from "@/integrations/supabase/client";

/**
 * Session gate for every signed-in surface. The session lives in the browser,
 * so the check happens client-side; the blocked URL is preserved so the member
 * lands back where they intended after signing in.
 */
function AuthenticatedLayout() {
  const location = useLocation();
  const navigate = useNavigate();
  const [state, setState] = useState<"checking" | "in" | "out">("checking");

  useEffect(() => {
    let active = true;
    supabase.auth.getUser().then(({ data, error }) => {
      if (!active) return;
      setState(error || !data.user ? "out" : "in");
    });
    return () => {
      active = false;
    };
  }, [location.pathname]);

  useEffect(() => {
    if (state !== "out") return;
    const target = `${location.pathname}${location.searchStr ?? ""}`;
    navigate({
      to: "/auth",
      search: { redirect: target },
      replace: true,
    });
  }, [state, location.pathname, location.searchStr, navigate]);

  if (state !== "in") return <RoutePendingSkeleton />;

  return <Outlet />;
}

export const Route = createFileRoute("/_authenticated")({
  component: AuthenticatedLayout,
});