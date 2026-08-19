import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/Manifesto";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/manifesto")({
  component: Page,
  head: () => ({
    meta: [
      { title: "Manifesto | ROUT" },
      { name: "description", content: "Waarom ROUT bestaat: Europese digitale soevereiniteit, privacy en eigendom." },
      { property: "og:title", content: "Manifesto | ROUT" },
      { property: "og:description", content: "Waarom ROUT bestaat: Europese digitale soevereiniteit, privacy en eigendom." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
