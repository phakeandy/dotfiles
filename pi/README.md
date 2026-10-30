# Pi

Personal [Pi](https://pi.dev) configuration for `~/.pi/agent`.

## Deploy

```sh
cd ~/dotfiles
stow -t ~ pi
```

Stow links tracked files into `~/.pi/agent`; runtime state (`sessions/`, `npm/`,
`subagents/`, `tmp/`, caches) stays local.

## Tracked

| Path | Purpose |
| --- | --- |
| `settings.json` | Default provider/model, packages, TUI options |
| `models.json` | Custom `keylights` provider and model list (no credentials) |
| `keybindings.json` | Personal key bindings |
| `APPEND_SYSTEM.md` | Extra system-prompt instructions |
| `extensions/alias.ts` | Shell-style aliases inside Pi |
| `extensions/my-powerline.ts` | Status line / editor chrome |

## Not tracked

- `auth.json` — credentials. Add the KeyLights key on each machine and keep the
  file `chmod 600`:

  ```json
  {
    "keylights": {
      "type": "api_key",
      "key": "<key>"
    }
  }
  ```

  Verify with `pi auth check --provider keylights`.

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

Because `settings.json` is a symlink, Pi updates such as
`lastChangelogVersion` show up as changes in this repo.
