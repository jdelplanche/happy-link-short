import { createFileRoute } from "@tanstack/react-router";

import Page from "@/pages/routes/sovereignty";
import { socialImageMeta } from "@/lib/site";

export const Route = createFileRoute("/sovereignty")({
  component: Page,
  head: () => ({
    meta: [
      { title: "Digitale soevereiniteit | ROUT" },
      { name: "description", content: "Wat Europese digitale soevereiniteit betekent voor jouw links en data." },
      { property: "og:title", content: "Digitale soevereiniteit | ROUT" },
      { property: "og:description", content: "Wat Europese digitale soevereiniteit betekent voor jouw links en data." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      ...socialImageMeta,
    ],
  }),
});
