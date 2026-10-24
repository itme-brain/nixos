"""Run inside the crawler to verify the authenticated API's actual TLS behavior.

Uses public certificate-test sites; never prints credentials or page contents.
"""
import json
import os
import time
import urllib.error
import urllib.request

deadline = time.monotonic() + 60
while True:
    try:
        with urllib.request.urlopen("http://127.0.0.1:11235/health", timeout=3) as response:
            assert response.status == 200
        break
    except (urllib.error.URLError, TimeoutError):
        if time.monotonic() >= deadline:
            raise
        time.sleep(2)


def crawl(url, insecure_request=False):
    body = {"urls": [url + "?infra_tls_check=" + str(time.time_ns())]}
    if insecure_request:
        body["browser_config"] = {
            "type": "BrowserConfig", "params": {"ignore_https_errors": True}
        }
    request = urllib.request.Request(
        "http://127.0.0.1:11235/crawl",
        data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json", "Authorization":
                 "Bearer " + os.environ["CRAWL4AI_API_TOKEN"]},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        return error.code, json.loads(error.read())


status, result = crawl("https://example.com/")
assert status == 200 and result.get("success"), "Valid HTTPS crawl failed"
assert result["results"][0].get("success"), "Valid HTTPS result failed"
print("PASS: valid HTTPS certificate accepted")

for url, marker in [
    ("https://self-signed.badssl.com/", "ERR_CERT_AUTHORITY_INVALID"),
    ("https://expired.badssl.com/", "ERR_CERT_DATE_INVALID"),
]:
    status, result = crawl(url)
    assert marker in json.dumps(result), "Expected certificate rejection absent: " + url
    assert not any(r.get("success") for r in result.get("results", []))
    print("PASS: certificate rejected:", marker)

status, result = crawl("https://self-signed.badssl.com/", insecure_request=True)
assert not any(r.get("success") for r in result.get("results", []))
assert status in (400, 403, 422) or "ERR_CERT_AUTHORITY_INVALID" in json.dumps(result)
print("PASS: API caller cannot override deployment TLS policy")
