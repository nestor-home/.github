#!/usr/bin/env bash
# Runs on the server, next to compose.prod.yaml: pulls the image and starts it.
#
#   printf '%s\n' "$GHCR_TOKEN" | bash deploy.sh ghcr.io/owner/name@sha256:... <registry user>
#
# The image is written to .env (IMAGE=...), which compose.prod.yaml reads: a later
# `docker compose up` or a reboot keeps the deployed version. To roll back, deploy an older image.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

image="${1:?Missing image reference}"
registry_user="${2:?Missing registry user}"

# The workflow's short-lived token comes through stdin. Keep the server's Docker credentials
# untouched and drop this login on exit.
DOCKER_CONFIG="$(mktemp -d)"
export DOCKER_CONFIG
trap 'rm -rf -- "$DOCKER_CONFIG"' EXIT
docker login ghcr.io --username "$registry_user" --password-stdin

# .env may hold the app's secrets too: keep it private to this user.
umask 077
touch .env
{ grep -v '^IMAGE=' .env || true; printf 'IMAGE=%s\n' "$image"; } > .env.next
mv .env.next .env

docker compose -f compose.prod.yaml pull
docker compose -f compose.prod.yaml up -d --remove-orphans --wait --wait-timeout 120
docker image prune --force --filter "label=org.opencontainers.image.source" >/dev/null
echo "Running $image"
