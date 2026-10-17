#!/usr/bin/env bash
# Installs (or upgrades) the RandomPlace KWin script, enables it and loads it
# into the running KWin so no logout is needed.
set -euo pipefail

ID=randomplace
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$ID"
MAIN="${XDG_DATA_HOME:-$HOME/.local/share}/kwin/scripts/$ID/contents/code/main.js"

[ -f "$SRC/metadata.json" ] || { echo "Missing $SRC/metadata.json" >&2; exit 1; }
command -v kpackagetool6 >/dev/null || { echo "kpackagetool6 not found" >&2; exit 1; }
command -v kwriteconfig6 >/dev/null || { echo "kwriteconfig6 not found" >&2; exit 1; }
command -v busctl >/dev/null || { echo "busctl not found" >&2; exit 1; }

# Upgrade if already installed, otherwise install.
kpackagetool6 --type=KWin/Script --upgrade "$SRC" >/dev/null 2>&1 \
  || kpackagetool6 --type=KWin/Script --install "$SRC"

# Enable it (same thing the KWin Scripts page in System Settings does).
kwriteconfig6 --file kwinrc --group Plugins --key "${ID}Enabled" true

# Load it into the running KWin right now: unload any old copy, load, start.
kwin() { busctl --user call org.kde.KWin /Scripting org.kde.kwin.Scripting "$@"; }
kwin unloadScript s "$ID" >/dev/null 2>&1 || true
kwin loadScript ss "$MAIN" "$ID" >/dev/null
kwin start >/dev/null

echo "Installed to: $MAIN"
echo "kwinrc enabled flag: $(kreadconfig6 --file kwinrc --group Plugins --key "${ID}Enabled")"
echo "Loaded in KWin:      $(kwin isScriptLoaded s "$ID")"   # expect: b true
cat <<EOF

Shortcut: Meta+Ctrl+Shift+R (rebind in System Settings > Keyboard > Shortcuts, group "KWin").
Log:      journalctl --user -b -f | grep randomplace
EOF
