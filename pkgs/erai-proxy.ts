const TARGET_URL = Deno.env.get("TARGET_URL") ?? null;
const FS_URL = Deno.env.get("FS_URL") ?? "http://127.0.0.1:8191/v1";

interface FlareSolverrResponse {
	solution?: {
		response?: string;
	};
}

export async function handler(req: Request): Promise<Response> {
	const url = new URL(req.url);

	if (url.pathname !== "/feed") {
		return Response.json({ error: "Not Found" }, { status: 404 });
	}
	if (req.method !== "GET") {
		return Response.json({ error: "Method Not Allowed" }, { status: 405 });
	}

	const payload = { cmd: "request.get", url: TARGET_URL, "maxTimeout": 60000 };
	const controller = new AbortController();
	const timeoutId = setTimeout(() => controller.abort(), 65000);
	try {
		const resp = await fetch(FS_URL, {
			method: "POST",
			headers: { "content-type": "application/json" },
			body: JSON.stringify(payload),
			signal: controller.signal,
		});
		if (!resp.ok) {
			return Response.json(
				{ error: resp.statusText },
				{ status: resp.status },
			);
		}
		const data = (await resp.json()) as FlareSolverrResponse;
		const raw = data?.solution?.response || "";
		const match = raw.match(/(<\?xml.*?<\/rss>|<rss.*?<\/rss>)/si);
		let clean_xml;
		if (match) {
			clean_xml = match[0];
			if (!clean_xml.trim().startsWith("<?xml")) {
				const xml_prelude = '<?xml version="1.0" encoding="UTF-8"?>\n';
				clean_xml = xml_prelude + clean_xml;
			}
		} else {
			clean_xml = raw;
		}
		return new Response(clean_xml, {
			headers: { "content-type": "application/rss+xml" },
		});
	} catch (error) {
		return new Response(
			`Error: ${error instanceof Error ? error.message : String(error)}`,
			{
				status: 500,
			},
		);
	} finally {
		clearTimeout(timeoutId);
	}
}

if (import.meta.main) {
	Deno.serve({ port: Number(Deno.env.get("PORT") ?? 5000) }, handler);
}
