import { createFileRoute, redirect } from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated/dashboard/account")({
  beforeLoad: () => {
    throw redirect({ to: "/settings" });
  },
});
