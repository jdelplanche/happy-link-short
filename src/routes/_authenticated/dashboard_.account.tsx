import { createFileRoute, redirect } from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated/dashboard_/account")({
  beforeLoad: () => {
    throw redirect({ to: "/settings" });
  },
});
