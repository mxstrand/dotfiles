#!/usr/bin/env bash
set -euo pipefail
# SessionStart hook: remind Claude to offer /echo at the start of every session.
echo "BEFORE doing anything else, ask the user if they would like to run /echo to load their working patterns for this session. Do this even if the user has already given you a task — ask first, then proceed."
