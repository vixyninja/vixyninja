#!/usr/bin/env bash
set -euo pipefail

GO_VERSION="${GO_VERSION:-1.25.5}"
ARCHIVE="go${GO_VERSION}.linux-amd64.tar.gz"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

curl -fsSL "https://go.dev/dl/${ARCHIVE}" -o "$tmpdir/$ARCHIVE"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "$tmpdir/$ARCHIVE"

mkdir -p "$HOME/go/bin"
