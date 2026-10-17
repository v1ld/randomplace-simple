# RandomPlace – KWin script for Plasma 6

Spreads window positions around to reduce OLED burn-in.

- **New windows** get a random position.
- **Open space first:** candidates that avoid other windows are preferred. If overlap can't be avoided, the script covers the *least used* windows (a blend of how recently and how long each window was focused).
- **Reshuffle on demand:** `Meta+Ctrl+Shift+R` re-places every movable window on the current desktop. Most-used windows are placed first, so they claim open space and the least-used ones end up overlapped.

## Install

```bash
chmod +x install.sh uninstall.sh
./install.sh
```

This installs the package with `kpackagetool6` into `~/.local/share/kwin/scripts/randomplace/`, enables it via `kwinrc` (`[Plugins] randomplaceEnabled=true`) and asks KWin to reconfigure. You can also enable or disable it in **System Settings → Window Management → KWin Scripts**.

## Shortcut

The default is `Meta+Ctrl+Shift+R`. Change it in **System Settings → Keyboard → Shortcuts**, under the **KWin** group, entry "RandomPlace: Reshuffle windows".

## Settings (optional)

Set keys in the `[Script-randomplace]` group of `~/.config/kwinrc`:

```bash
kwriteconfig6 --file kwinrc --group Script-randomplace --key candidates 800
```

| Key | Default | Meaning |
|---|---|---|
| `candidates` | 600 | Random positions sampled per placement |
| `tolerance` | 0.15 | Accept positions within this fraction of the best cost, then pick randomly |
| `recencyWeight` | 0.6 | 0–1 balance between "recently focused" and "total focus time" |
| `recencyHalfLifeSec` | 600 | Seconds for the recency score to halve |
| `baseOverlapCost` | 0.15 | Cost of covering even an unused window |
| `margin` | 0 | Pixels kept clear of the usable-area edges |
| `excludeClasses` | krunner,plasmashell,… | Comma-separated window classes never moved |
| `debug` | false | Log decisions |

Settings are read when the script loads, so toggle the script off and on (or log out and in) after changing them. Find a window's class with `kdotool getactivewindow getwindowclassname` or the KWin debug console.

## Troubleshooting

```bash
# Is it loaded in the running KWin? (expect: b true)
busctl --user call org.kde.KWin /Scripting org.kde.kwin.Scripting isScriptLoaded s randomplace

# Watch what it logs (the load line and any errors are always printed):
journalctl --user -b -f | grep randomplace
```

Press the shortcut: you should see `randomplace: reshuffle triggered` and a "reshuffled N of M window(s)" line. For per-window decisions (why a window was skipped or where it was placed) set `debug=true`:

```bash
kwriteconfig6 --file kwinrc --group Script-randomplace --key debug true
./install.sh   # reloads the script
```

## Notes and limits

- Windows that are fullscreen, maximized, tiled, minimized, dialogs or transients are left alone.
- Usage statistics are kept per window and reset when the session restarts.
- Window rules that force a position take precedence over this script.
- Some applications set their own geometry after the window appears. If one keeps snapping back, add its class to `excludeClasses` or use a window rule for it.
