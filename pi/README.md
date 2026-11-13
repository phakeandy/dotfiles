# Pi

Personal [Pi](https://pi.dev) configuration for `~/.pi/agent`.

## Deploy

On a personal machine:

```sh
cd ~/dotfiles
stow -t ~ pi
```

Stow links tracked files into `~/.pi/agent`; runtime state (`sessions/`, `npm/`,
`subagents/`, `tmp/`, caches) stays local.

## Tracked

| Path | Purpose |
| --- | --- |
| `settings.json` | Personal defaults, packages, TUI options |
| `keybindings.json` | Personal key bindings |
| `APPEND_SYSTEM.md` | Extra system-prompt instructions |
| `extensions/alias.ts` | Shell-style aliases inside Pi |
| `extensions/my-powerline.ts` | Status line / editor chrome: output speed (`⚡ 42.0 tok/s`, whole-response average, `POWERLINE_SPEED=0` hides it); collapses the composer while scrolled and steps the transcript with `shift+↑` / `shift+↓` (fullscreen) |
| `extensions/thinking-step.ts` | `alt+,` / `alt+.` step the thinking level up/down |
| `extensions/quiet-tools.ts` | Collapsed tool output: intent + count instead of raw text (`ctrl+o` expands) |
| `extensions/multi-skill.ts` | `/skill:a /skill:b …` expands several skills in one message; pi itself only expands the first |
| `tests/quiet-tools.test.mjs` | Renderer tests for quiet-tools (`node tests/quiet-tools.test.mjs`) |
| `tests/multi-skill.test.mjs` | Chain parsing / expansion tests for multi-skill (`node tests/multi-skill.test.mjs`) |
| `tests/my-powerline.test.mjs` | Collapse-decision and output-speed tests for my-powerline (`node tests/my-powerline.test.mjs`) |

## Company relay (KeyLights)

`models.json` and the `keylights` `defaultProvider`/`defaultModel` only exist
because of the company LLM relay. They are intentionally **not tracked** here.

On the company machine, keep `~/.pi/agent/settings.json` and
`~/.pi/agent/models.json` as local files (do not link them to this repo) and add
the credential to the untracked `auth.json`:

```json
{
  "keylights": {
    "type": "api_key",
    "key": "<key>"
  }
}
```

Keep `auth.json` at `chmod 600` and verify with
`pi auth check --provider keylights`. Set `defaultProvider` to `keylights` and
`defaultModel` to `code-deepseek-flash` in the local `settings.json`.

Because `settings.json` is not linked there, keep the local copy aside while
stowing the remaining files:

```sh
cd ~/dotfiles
mv ~/.pi/agent/settings.json ~/.pi/agent/settings.local.json
stow -t ~ pi
mv ~/.pi/agent/settings.local.json ~/.pi/agent/settings.json
```

## Not tracked

- `auth.json` — credentials (see above).
- `models.json` — company relay provider (see above).
- `trust.json`, `sessions/`, `subagents/`, `npm/`, `pi-web-access/`, `tmp/`,
  `web-search-cache/`, `models-store.json`, `*.bak-*` — machine state.
- `extensions/herdr-agent-state.ts` — installed and overwritten by the Herdr
  integration, not by hand.
- `extensions/subagent/` and `bin/subagent` — upstream clone, pinned at
  `4fc1fe5` (`earendil-works/pi-subagent`):

  ```sh
  git clone git@github.com:earendil-works/pi-subagent.git \
    ~/.pi/agent/extensions/subagent
  ln -sfn ../extensions/subagent/subagent.ts ~/.pi/agent/bin/subagent
  ```

- `~/.agents/skills/` — managed separately by the skills CLI.

## Tip

On machines where `settings.json` is linked, Pi updates such as
`lastChangelogVersion` show up as changes in this repo.
