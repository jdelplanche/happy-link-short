import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/Index";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/")({
  component: Page,
  head: () => ({
    meta: [
      { title: "ROUT — QR codes en korte links" },
      { name: "description", content: "Maak stijlvolle QR-codes en korte links met ROUT, het Europese platform voor jouw digitale identiteit." },
      { property: "og:title", content: "ROUT — QR codes en korte links" },
      { property: "og:description", content: "Maak stijlvolle QR-codes en korte links met ROUT, het Europese platform voor jouw digitale identiteit." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
