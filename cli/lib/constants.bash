#!/usr/bin/env bash
# Core constants for sandcat

# User config directory. Function instead of variable so it respects
# HOME changes (e.g. in tests).
sct_home() { echo "$HOME/.config/sandcat"; }

export SCT_PROJECT_DIR='.sandcat'
