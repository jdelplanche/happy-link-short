import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/Claim";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/claim")({
  component: Page,
  head: () => ({
    meta: [
      { title: "Claim je handle | ROUT" },
      { name: "description", content: "Reserveer je persoonlijke ROUT-handle en profielpagina." },
      { property: "og:title", content: "Claim je handle | ROUT" },
      { property: "og:description", content: "Reserveer je persoonlijke ROUT-handle en profielpagina." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
