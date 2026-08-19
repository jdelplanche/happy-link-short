import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/routes/r.username";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/r/$username")({
  component: Page,
  head: () => ({
    meta: [
      { title: "Uitnodiging | ROUT" },
      { name: "description", content: "Je bent uitgenodigd om ROUT te gebruiken." },
      { property: "og:title", content: "Uitnodiging | ROUT" },
      { property: "og:description", content: "Je bent uitgenodigd om ROUT te gebruiken." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
