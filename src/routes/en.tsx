import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/routes/en";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/en")({
  component: Page,
  head: () => ({
    meta: [
      { title: "ROUT in English" },
      { name: "description", content: "ROUT in English: QR codes, short links and your own profile page." },
      { property: "og:title", content: "ROUT in English" },
      { property: "og:description", content: "ROUT in English: QR codes, short links and your own profile page." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
