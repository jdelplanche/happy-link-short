import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/routes/auth_.callback";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/auth_/callback")({
  component: Page,
  head: () => ({
    meta: [
      { title: "Aanmelden afronden | ROUT" },
      { name: "description", content: "Je aanmelding wordt afgerond." },
      { property: "og:title", content: "Aanmelden afronden | ROUT" },
      { property: "og:description", content: "Je aanmelding wordt afgerond." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
