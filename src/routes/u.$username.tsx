import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/routes/u.username";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/u/$username")({
  component: Page,
  head: () => ({
    meta: [
      { title: "Profiel | ROUT" },
      { name: "description", content: "Een publiek ROUT-profiel met links en contactgegevens." },
      { property: "og:title", content: "Profiel | ROUT" },
      { property: "og:description", content: "Een publiek ROUT-profiel met links en contactgegevens." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
