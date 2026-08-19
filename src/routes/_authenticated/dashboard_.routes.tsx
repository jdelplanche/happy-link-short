import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/RoutesManager";
import { noindexMeta } from "@/lib/site";

export const Route = createFileRoute("/_authenticated/dashboard/routes")({
  component: Page,
  head: () => ({
    meta: [{ title: "Links beheren | ROUT" }, ...noindexMeta],
  }),
});
