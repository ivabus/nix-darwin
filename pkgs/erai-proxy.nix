{
  pkgs ? import <nixpkgs> { system = builtins.currentSystem; },
}:
pkgs.writers.writePython3Bin "erai-proxy"
  {
    libraries = with pkgs; [
      python3Packages.flask
      python3Packages.requests
      python3Packages.waitress
    ];
  }
  ''
    import os
    import re

    import requests
    from flask import Flask, Response
    from waitress import serve

    app = Flask(__name__)
    FS_URL = os.environ.get("FS_URL")
    TARGET_URL = os.environ.get("TARGET_URL")
    PORT = int(os.environ.get("PORT", 5000))


    @app.route("/feed")
    def get_feed():
        payload = {"cmd": "request.get", "url": TARGET_URL, "maxTimeout": 60000}

        try:
            res = requests.post(FS_URL, json=payload, timeout=65)
            res.raise_for_status()
            data = res.json()

            raw_html = data.get("solution", {}).get("response", "")

            r_mode = re.DOTALL | re.IGNORECASE

            match = re.search(r"(<\?xml.*?</rss>|<rss.*?</rss>)", raw_html, r_mode)

            if match:
                clean_xml = match.group(1)
                if not clean_xml.strip().startswith("<?xml"):
                    xml_prelude = '<?xml version="1.0" encoding="UTF-8"?>\n'
                    clean_xml = xml_prelude + clean_xml
            else:
                clean_xml = raw_html

            return Response(clean_xml, mimetype="application/rss+xml")

        except Exception as e:
            return Response(f"Error: {str(e)}", status=500)


    if __name__ == "__main__":
        serve(app, host="0.0.0.0", port=PORT)
  ''
