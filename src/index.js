const json = (data, status = 200) => new Response(JSON.stringify(data), {
 status, headers: {
  "content-type":"application/json; charset=utf-8","cache-control":"no-store",
  "x-content-type-options":"nosniff","referrer-policy":"no-referrer",
  "content-security-policy":"default-src 'self'; img-src 'self' data: blob:; media-src 'self' blob:; style-src 'self'; script-src 'self'; connect-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'"
 }
});
export default {
 async fetch(request, env) {
  const url = new URL(request.url);
  if (url.pathname.startsWith("/api/")) {
   if (url.pathname === "/api/health" && request.method === "GET") {
    let database = "not_configured";
    try { if (env.DB?.prepare) { await env.DB.prepare("SELECT 1 AS ok").first(); database = "connected"; } }
    catch { database = "error"; }
    return json({name:env.APP_NAME || "الکی‌پلکی",status:database==="connected"?"ok":"setup_required",database,phase:"foundation"});
   }
   return json({error:"not_found",message:"این قابلیت هنوز در مرحله پیاده‌سازی است."},404);
  }
  if (env.ASSETS) return env.ASSETS.fetch(request);
  return new Response("Assets binding is not configured.",{status:503});
 }
};
