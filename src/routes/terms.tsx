import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/routes/terms";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/terms")({
  component: Page,
  head: () => ({
    meta: [
      { title: "Algemene voorwaarden | ROUT" },
      { name: "description", content: "De voorwaarden voor het gebruik van ROUT." },
      { property: "og:title", content: "Algemene voorwaarden | ROUT" },
      { property: "og:description", content: "De voorwaarden voor het gebruik van ROUT." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
