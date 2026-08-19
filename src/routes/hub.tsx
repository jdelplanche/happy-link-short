import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/routes/hub";
import { socialImageMeta } from "@/lib/site";

const str = (v: unknown) => (typeof v === "string" ? v : undefined);

export const Route = createFileRoute("/hub")({
  component: Page,
  validateSearch: (s: Record<string, unknown>) => ({ ...(s as Record<string, string | undefined>) }),
  head: () => ({
    meta: [
      { title: "Linkhub | ROUT" },
      { name: "description", content: "Alle links van dit ROUT-profiel op één plek." },
      { property: "og:title", content: "Linkhub | ROUT" },
      { property: "og:description", content: "Alle links van dit ROUT-profiel op één plek." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
