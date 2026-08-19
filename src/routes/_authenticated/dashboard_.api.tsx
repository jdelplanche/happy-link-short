import { createFileRoute, redirect } from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated/dashboard_/api")({
  beforeLoad: () => {
    throw redirect({ to: "/api" });
  },
});
