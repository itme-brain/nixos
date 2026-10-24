#!/usr/bin/env python3
"""Smoke-test curl builds against a temporary, local TLS/HTTP2 upload endpoint.

Usage: verify-curl-http2.py NGINX_BINARY CURL_BINARY [CURL_BINARY ...]
No production configuration is changed. Requires openssl on PATH.
"""
import concurrent.futures
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import socket
import subprocess
import sys
import tempfile
import threading
import time


class Upload(BaseHTTPRequestHandler):
    def do_POST(self):
        data = self.rfile.read(int(self.headers["Content-Length"]))
        self.send_response(200)
        self.end_headers()
        self.wfile.write(str(len(data)).encode())

    def log_message(self, *_args):
        pass


nginx, *curls = sys.argv[1:]
assert curls
backend = ThreadingHTTPServer(("127.0.0.1", 0), Upload)
threading.Thread(target=backend.serve_forever, daemon=True).start()
with tempfile.TemporaryDirectory(prefix="curl-security-check-") as directory:
    root = Path(directory)
    with socket.socket() as reservation:
        reservation.bind(("127.0.0.1", 0))
        port = reservation.getsockname()[1]
    subprocess.run([
        "openssl", "req", "-x509", "-newkey", "rsa:2048", "-nodes",
        "-keyout", str(root / "key.pem"), "-out", str(root / "cert.pem"),
        "-days", "1", "-subj", "/CN=localhost", "-addext", "subjectAltName=DNS:localhost"
    ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    (root / "nginx.conf").write_text(f"""
worker_processes 1;
pid {root}/nginx.pid;
error_log stderr error;
events {{ worker_connections 64; }}
http {{
  access_log off;
  client_body_temp_path {root}/body;
  proxy_temp_path {root}/proxy;
  server {{
    listen 127.0.0.1:{port} ssl;
    http2 on;
    ssl_certificate {root}/cert.pem;
    ssl_certificate_key {root}/key.pem;
    location / {{
      proxy_pass http://127.0.0.1:{backend.server_port};
      proxy_http_version 1.1;
    }}
  }}
}}
""")
    server = subprocess.Popen([nginx, "-e", "stderr", "-p", directory + "/", "-c",
                               str(root / "nginx.conf"), "-g", "daemon off;"])
    try:
        for attempt in range(50):
            try:
                with socket.create_connection(("127.0.0.1", port), timeout=1):
                    break
            except OSError:
                assert server.poll() is None, "Test NGINX exited"
                time.sleep(0.1)
        else:
            raise RuntimeError("Test NGINX did not start")

        def upload(binary, protocol):
            result = subprocess.run([
                binary, "--silent", "--show-error", "--fail", "--noproxy", "*",
                "--" + protocol, "--cacert", str(root / "cert.pem"),
                "--resolve", f"localhost:{port}:127.0.0.1", "--max-time", "15",
                "--data-binary", "@-", "--write-out", "|%{http_version}",
                f"https://localhost:{port}/upload"
            ], input=b"a" * 65536, capture_output=True, check=True)
            expected = b"65536|" + (b"2" if protocol == "http2" else b"1.1")
            assert result.stdout == expected, result.stdout

        for binary in curls:
            version = subprocess.check_output([binary, "--version"]).decode().splitlines()[0]
            assert "curl 8.23.0 " in version and "libcurl/8.23.0 " in version
            with concurrent.futures.ThreadPoolExecutor(2) as pool:
                futures = [pool.submit(upload, binary, protocol)
                           for protocol in ("http1.1", "http2")]
                for future in futures:
                    future.result()
            print("PASS: verified TLS and HTTP/1.1 + HTTP/2 uploads:", binary)
    finally:
        server.terminate()
        server.wait(timeout=10)
        backend.shutdown()
