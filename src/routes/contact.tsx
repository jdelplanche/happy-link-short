import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/Contact";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/contact")({
  component: Page,
  head: () => ({
    meta: [
      { title: "Contact | ROUT" },
      { name: "description", content: "Neem contact op met het ROUT-team voor vragen en support." },
      { property: "og:title", content: "Contact | ROUT" },
      { property: "og:description", content: "Neem contact op met het ROUT-team voor vragen en support." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
