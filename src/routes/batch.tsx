import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/Batch";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/batch")({
  component: Page,
  head: () => ({
    meta: [
      { title: "Batch QR-codes genereren | ROUT" },
      { name: "description", content: "Genereer honderden QR-codes in één keer vanuit een CSV-bestand." },
      { property: "og:title", content: "Batch QR-codes genereren | ROUT" },
      { property: "og:description", content: "Genereer honderden QR-codes in één keer vanuit een CSV-bestand." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
