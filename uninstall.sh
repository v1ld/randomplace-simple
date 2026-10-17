#!/usr/bin/env bash
# Disables, unloads and removes the RandomPlace KWin script.
set -euo pipefail

ID=randomplace

kwriteconfig6 --file kwinrc --group Plugins --key "${ID}Enabled" false
busctl --user call org.kde.KWin /Scripting org.kde.kwin.Scripting \
  unloadScript s "$ID" >/dev/null 2>&1 || true
kpackagetool6 --type=KWin/Script --remove "$ID" || true

echo "Removed '$ID'."
