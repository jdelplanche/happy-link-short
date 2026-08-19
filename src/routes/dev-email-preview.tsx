import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/routes/dev-email-preview";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/dev-email-preview")({
  component: Page,
  head: () => ({
    meta: [
      { title: "E-mail preview | ROUT" },
      { name: "description", content: "Interne preview van de transactionele e-mailtemplates." },
      { property: "og:title", content: "E-mail preview | ROUT" },
      { property: "og:description", content: "Interne preview van de transactionele e-mailtemplates." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
