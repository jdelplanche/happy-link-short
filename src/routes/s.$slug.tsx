import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/ShortLink";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/s/$slug")({
  component: Page,
  head: () => ({
    meta: [
      { title: "Doorverwijzen… | ROUT" },
      { name: "description", content: "Deze korte link brengt je naar de bestemming." },
      { property: "og:title", content: "Doorverwijzen… | ROUT" },
      { property: "og:description", content: "Deze korte link brengt je naar de bestemming." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
