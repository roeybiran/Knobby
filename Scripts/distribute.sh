#!/bin/bash

node ~/Developer/distribute-macos-app/src/index.ts release \
  --scheme Knobby \
  --keychain-profile roey \
  --team-id "$TEAM_ID"

