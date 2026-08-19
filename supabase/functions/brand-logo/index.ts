/**
 * Brand logo proxy.
 *
 * Favicon CDNs do not send CORS headers, so the browser cannot inline their
 * bytes into a QR code (canvas/SVG export needs same-origin-safe image data).
 * This function fetches the icon server-side and re-serves it with permissive
 * CORS headers. It only ever touches public favicon endpoints for a validated
 * hostname — no user data, no credentials.
 */
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const HOST_RE = /^(?!-)[a-z0-9-]{1,63}(?<!-)(\.(?!-)[a-z0-9-]{1,63}(?<!-))+$/;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: cors });

  const domain = (new URL(req.url).searchParams.get("domain") ?? "").toLowerCase().trim();
  if (!HOST_RE.test(domain)) {
    return new Response(JSON.stringify({ error: "invalid domain" }), {
      status: 400,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  const sources = [
    `https://icons.duckduckgo.com/ip3/${domain}.ico`,
    `https://www.google.com/s2/favicons?sz=128&domain=${domain}`,
  ];

  for (const src of sources) {
    try {
      const res = await fetch(src, { redirect: "follow" });
      if (!res.ok) continue;
      const type = res.headers.get("content-type") ?? "image/png";
      if (!type.startsWith("image/")) continue;
      const bytes = new Uint8Array(await res.arrayBuffer());
      if (bytes.byteLength < 64) continue;
      return new Response(bytes, {
        headers: { ...cors, "Content-Type": type, "Cache-Control": "public, max-age=86400" },
      });
    } catch {
      // try the next source
    }
  }

  return new Response(JSON.stringify({ error: "no logo" }), {
    status: 404,
    headers: { ...cors, "Content-Type": "application/json" },
  });
});
