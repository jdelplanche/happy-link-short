import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/routes/privacy";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/privacy")({
  component: Page,
  head: () => ({
    meta: [
      { title: "Privacybeleid | ROUT" },
      { name: "description", content: "Hoe ROUT persoonsgegevens verwerkt en beschermt." },
      { property: "og:title", content: "Privacybeleid | ROUT" },
      { property: "og:description", content: "Hoe ROUT persoonsgegevens verwerkt en beschermt." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
