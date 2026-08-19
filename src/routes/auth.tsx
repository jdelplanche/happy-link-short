import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/Auth";
import { socialImageMeta } from "@/lib/site";

const str = (v: unknown) => (typeof v === "string" ? v : undefined);

export const Route = createFileRoute("/auth")({
  component: Page,
  validateSearch: (s: Record<string, unknown>) => ({ redirect: str(s.redirect), mode: str(s.mode) }),
  head: () => ({
    meta: [
      { title: "Inloggen of registreren | ROUT" },
      { name: "description", content: "Meld je aan bij ROUT om je links, QR-codes en profiel te beheren." },
      { property: "og:title", content: "Inloggen of registreren | ROUT" },
      { property: "og:description", content: "Meld je aan bij ROUT om je links, QR-codes en profiel te beheren." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
