import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/Stats";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/stats/$token")({
  component: Page,
  head: () => ({
    meta: [
      { title: "Statistieken | ROUT" },
      { name: "description", content: "Bekijk de statistieken van deze korte link of QR-code." },
      { property: "og:title", content: "Statistieken | ROUT" },
      { property: "og:description", content: "Bekijk de statistieken van deze korte link of QR-code." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
