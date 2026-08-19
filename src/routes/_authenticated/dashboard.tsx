import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/Dashboard";
import { noindexMeta } from "@/lib/site";

export const Route = createFileRoute("/_authenticated/dashboard")({
  component: Page,
  head: () => ({
    meta: [{ title: "Dashboard | ROUT" }, noindexMeta],
  }),
});
