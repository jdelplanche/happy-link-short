import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/Admin";
import { noindexMeta } from "@/lib/site";

export const Route = createFileRoute("/_authenticated/admin")({
  component: Page,
  head: () => ({
    meta: [{ title: "Beheer | ROUT" }, ...noindexMeta],
  }),
});
