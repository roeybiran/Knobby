#!/usr/bin/env bash
set -euo pipefail

npx -y @roeybiran/distribute-macos-app@latest release --scheme Knobby --out-dir ~/Desktop --keychain-profile roey
