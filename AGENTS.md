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

Tracker: `FIXES.md` — **No planned fixes** in the tree.

No Docker CLI in this image (install in a child if needed).

**Publish order:** Hub zsh `v2.0.0` first, then NodeBun (`FROM cartagodocker/zsh:v2.0.0`).
