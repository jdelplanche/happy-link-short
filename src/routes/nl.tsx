import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/routes/nl";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/nl")({
  component: Page,
  head: () => ({
    meta: [
      { title: "ROUT in het Nederlands" },
      { name: "description", content: "ROUT in het Nederlands: QR-codes, korte links en je eigen profielpagina." },
      { property: "og:title", content: "ROUT in het Nederlands" },
      { property: "og:description", content: "ROUT in het Nederlands: QR-codes, korte links en je eigen profielpagina." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
