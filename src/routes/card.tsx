import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/routes/card";
import { socialImageMeta } from "@/lib/site";

const str = (v: unknown) => (typeof v === "string" ? v : undefined);

export const Route = createFileRoute("/card")({
  component: Page,
  validateSearch: (s: Record<string, unknown>) => ({ d: typeof s.d === "string" ? s.d : undefined }),
  head: () => ({
    meta: [
      { title: "Digitaal visitekaartje | ROUT" },
      { name: "description", content: "Bekijk en download dit digitale visitekaartje." },
      { property: "og:title", content: "Digitaal visitekaartje | ROUT" },
      { property: "og:description", content: "Bekijk en download dit digitale visitekaartje." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
