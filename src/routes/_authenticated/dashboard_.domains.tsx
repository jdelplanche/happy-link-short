import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/Domains";
import { noindexMeta } from "@/lib/site";

export const Route = createFileRoute("/_authenticated/dashboard/domains")({
  component: Page,
  head: () => ({
    meta: [{ title: "Domeinen | ROUT" }, ...noindexMeta],
  }),
});
