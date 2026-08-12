const TARGET_URL = Deno.env.get("TARGET_URL")!;

export interface FlareSolverrCookie {
	name: string;
	value: string;
	domain: string;
	path: string;
	expires: number;
	httpOnly: boolean;
	secure: boolean;
	session: boolean;
	sameSite: string;
}

export interface FlareSolverrSolution {
	status: number;
	response?: string;
	url?: string;
	userAgent?: string;
	headers: Record<string, string>;
	cookies: FlareSolverrCookie[];
}

export interface FlareSolverrResponse {
	solution?: FlareSolverrSolution;
	status: string;
	message: string;
	startTimestamp: number;
	endTimestamp: number;
	version: string;
}

export type FlareSolverrResult =
	| {
		type: "ok";
		output: FlareSolverrResponse;
	}
	| { type: "error"; error: string };

export interface FlareSolverr {
	endpoint: URL;
	get(url: URL): Promise<FlareSolverrResult>;
}

export const defaultFlareSolverr: FlareSolverr = {
	endpoint: new URL(Deno.env.get("FS_URL") ?? "http://127.0.0.1:8191/v1"),
	async get(url: URL): Promise<FlareSolverrResult> {
		const controller = new AbortController();
		const timeoutId = setTimeout(() => controller.abort(), 65000);

		try {
			const payload = {
				cmd: "request.get",
				url: url,
				"maxTimeout": 60000,
			};

			const resp = await fetch(this.endpoint, {
				method: "POST",
				headers: { "content-type": "application/json" },
				body: JSON.stringify(payload),
				signal: controller.signal,
			});
			if (!resp.ok) {
				return {
					type: "error",
					error: `Status: ${resp.status}; ${resp.statusText}`,
				};
			}
			const data = (await resp.json()) as FlareSolverrResponse;
			return { type: "ok", output: data };
		} catch (e) {
			const errorMessage = e instanceof Error ? e.message : String(e);
			return { type: "error", error: errorMessage };
		} finally {
			clearTimeout(timeoutId);
		}
	},
};

export function createHandler(flareSolverr: FlareSolverr) {
	return async function handler(req: Request): Promise<Response> {
		const url = new URL(req.url);

		if (url.pathname !== "/feed") {
			return Response.json({ error: "Not Found" }, { status: 404 });
		}
		if (req.method !== "GET") {
			return Response.json({ error: "Method Not Allowed" }, { status: 405 });
		}

		const resp = await flareSolverr.get(new URL(TARGET_URL));
		if (resp.type === "ok") {
			const raw = resp.output?.solution?.response || "";
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
		} else {
			return Response.json({ error: resp.error }, { status: 500 });
		}
	};
}

if (import.meta.main) {
	const handler = createHandler(defaultFlareSolverr);
	Deno.serve({ port: Number(Deno.env.get("PORT") ?? 5000) }, handler);
}
