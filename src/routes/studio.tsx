import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/Studio";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/studio")({
  component: Page,
  head: () => ({
    meta: [
      { title: "QR Studio — ontwerp je QR-code | ROUT" },
      { name: "description", content: "Ontwerp QR-codes met eigen kleuren, vormen en frames in de ROUT Studio." },
      { property: "og:title", content: "QR Studio — ontwerp je QR-code | ROUT" },
      { property: "og:description", content: "Ontwerp QR-codes met eigen kleuren, vormen en frames in de ROUT Studio." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
