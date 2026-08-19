import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/routes/_authenticated-dashboard.bluesky";
import { noindexMeta } from "@/lib/site";

export const Route = createFileRoute("/_authenticated/dashboard_/bluesky")({
  component: Page,
  head: () => ({
    meta: [{ title: "Bluesky handle | ROUT" }, noindexMeta],
  }),
});
