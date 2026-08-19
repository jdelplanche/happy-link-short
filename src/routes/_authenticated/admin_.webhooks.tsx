import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/AdminWebhooks";
import { noindexMeta } from "@/lib/site";

export const Route = createFileRoute("/_authenticated/admin/webhooks")({
  component: Page,
  head: () => ({
    meta: [{ title: "Webhooks | ROUT" }, ...noindexMeta],
  }),
});
