import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/DeveloperHub";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/api")({
  component: Page,
  head: () => ({
    meta: [
      { title: "Developer Hub & API | ROUT" },
      { name: "description", content: "Documentatie voor de ROUT API: links, QR-codes en statistieken automatiseren." },
      { property: "og:title", content: "Developer Hub & API | ROUT" },
      { property: "og:description", content: "Documentatie voor de ROUT API: links, QR-codes en statistieken automatiseren." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
