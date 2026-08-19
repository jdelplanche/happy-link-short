import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/AccountSettings";
import { noindexMeta } from "@/lib/site";

export const Route = createFileRoute("/_authenticated/settings")({
  component: Page,
  head: () => ({
    meta: [{ title: "Accountinstellingen | ROUT" }, noindexMeta],
  }),
});
