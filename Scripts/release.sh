#!/usr/bin/env bash
set -euo pipefail

npx -y @roeybiran/distribute-macos-app@latest release --out-dir ~/Desktop --keychain-profile roey
