import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/routes/go";
import { socialImageMeta } from "@/lib/site";

const str = (v: unknown) => (typeof v === "string" ? v : undefined);

export const Route = createFileRoute("/go")({
  component: Page,
  validateSearch: (s: Record<string, unknown>) => ({ i: str(s.i), a: str(s.a), w: str(s.w) }),
  head: () => ({
    meta: [
      { title: "Doorverwijzen… | ROUT" },
      { name: "description", content: "Je wordt doorgestuurd naar de juiste app-winkel of website." },
      { property: "og:title", content: "Doorverwijzen… | ROUT" },
      { property: "og:description", content: "Je wordt doorgestuurd naar de juiste app-winkel of website." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
