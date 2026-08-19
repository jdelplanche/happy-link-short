import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/ProfileSettings";
import { noindexMeta } from "@/lib/site";

export const Route = createFileRoute("/_authenticated/dashboard/profile")({
  component: Page,
  head: () => ({
    meta: [{ title: "Profielinstellingen | ROUT" }, ...noindexMeta],
  }),
});
