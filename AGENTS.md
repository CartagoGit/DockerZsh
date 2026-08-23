# Agent rules — cartagodocker/zsh

## xAI / Grok HTTP 400 (this workspace)

xAI rejects the chat body with:

`Failed to parse the request body as JSON: messages[N].content: lone leading surrogate in hex escape`

This is **not** a repo bug. The tree is valid UTF-8. The Grok provider serializes the whole thread as JSON; a supplementary-plane character (the prompt icon is the **whale emoji**, codepoint **🐳**) becomes a UTF-16 surrogate pair. If a tool argument, grep pattern, truncated dump, or retry re-sends a **lone high surrogate**, xAI returns 400 and the session is poisoned.

### If that 400 appears

1. **Stop.** Do not retry in the same chat.
2. Tell the user to **open a new chat**.
3. Do not paste the error payload, do not quote JSON `\u` hex in the D800–DFFF range, do not grep the whale glyph.

### Never (tool args, shell, grep, file writes you invent)

- The whale glyph itself.
- JSON unicode hex for UTF-16 surrogate halves (high or low).
- Regex that ORs the glyph with those hex escapes.
- Full dumps of `config/.p10k.zsh` (~90 KiB) or the whole `scripts/dockerzsh` catalogue into a tool result.

### Do

- Call the icon **whale emoji** or **🐳**.
- Grep ASCII: `os_icon`, `🐳`, `Nerd Font`, `eza`.
- Read files by line range. Quote only the lines you need.

## Remaining work (zsh)

Tracker: `FIXES.md`. Working tree is **1.0.6**, not on Hub yet.

Open (do not invent extra scope):

| # | What |
|---|---|
| 29 | Tag + publish `v1.0.6` to Hub (blocker for NodeBun). |
| 30 | Pin GitHub Actions to SHAs. |
| 31 | `:latest` vs README “do not use latest”. |
| 32 | `share_config_globally` `shift 2` without checking `$2`. |
| 33 | `useradd` wrapper last non-flag arg. |
| 34 | `fzf` binary present; key-bindings not sourced in `.zshrc`. |

Dirty tree on `fixes-pre-1.0.6` may include SSH wrappers, `config/ssh/`, catalogue text — continue that work; do not revert `FROM`/VERSION to 1.0.5. No Docker CLI in this image (install in a child if needed).

**Publish order:** Hub zsh `v1.0.6` first, then NodeBun (already pins `zsh:v1.0.6`).
