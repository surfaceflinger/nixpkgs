#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3

import json, os, re, subprocess, sys, tempfile, urllib.request
from pathlib import Path

PAGE = "https://www.geeks3d.com/furmark/downloads/"
PACKAGE = "pkgs/by-name/fu/furmark/package.nix"
PLATFORMS = {"x86_64-linux": "linux64", "aarch64-linux": "arm64"}
ENTRY = re.compile(r'href="/dl/show/(\d+)"[^>]*>v([0-9.]+) - (linux64|arm64)')
# i686-linux stays at 2.0.16: upstream no longer ships 32-bit Linux builds.


def get(url):
    try:
        return urllib.request.urlopen(url, timeout=30)
    except Exception as error:
        sys.exit(f"error: {url}: {error}")


root = subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True)
path = Path(root.strip()) / PACKAGE
old = path.read_text()
new = old
with get(PAGE) as response:
    page = response.read().decode()
entries = {}
for match in ENTRY.finditer(page):
    entries.setdefault(match[3], (match[1], match[2]))

for system, arch in PLATFORMS.items():
    if arch not in entries:
        sys.exit(f"error: no {arch} download on {PAGE}")
    show_id, release = entries[arch]
    current = re.search(rf'"{system}" = "([0-9.]+)";', new)
    if current is None:
        sys.exit(f"error: no version for {system}")
    current = current[1]
    if current == release:
        print(f"{system}: already at {release}")
        continue
    if tuple(map(int, release.split("."))) <= tuple(map(int, current.split("."))):
        print(f"{system}: {release} <= {current}, skipping", file=sys.stderr)
        continue
    with get(f"https://www.geeks3d.com/dl/get/{show_id}") as response:
        url = response.geturl()
    if not url.startswith("https://gpumagick.com/"):
        sys.exit(f"error: unexpected URL for {arch}: {url}")

    cmd = ["nix", "store", "prefetch-file", "--json", "--hash-type", "sha256", url]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode:
        sys.exit(f"error: prefetch {url}:\n{proc.stderr.strip()}")
    digest = json.loads(proc.stdout)["hash"]

    print(f"{system}: {current} -> {release}")
    new = new.replace(f'"{system}" = "{current}";', f'"{system}" = "{release}";', 1)
    pattern = rf'("{system}" = \{{.*?url = ")[^"]*";\s*hash = "[^"]*";'
    new, count = re.subn(
        pattern,
        lambda match: f'{match[1]}{url}";\n      hash = "{digest}";',
        new,
        count=1,
        flags=re.DOTALL,
    )
    if count != 1:
        sys.exit(f"error: no sources for {system}")

if new != old:
    with tempfile.NamedTemporaryFile("w", dir=path.parent, delete=False) as temp:
        temp.write(new)
    os.chmod(temp.name, path.stat().st_mode)
    os.replace(temp.name, path)
