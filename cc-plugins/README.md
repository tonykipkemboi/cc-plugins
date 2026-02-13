# CC Plugins

Personal marketplace of Claude Code plugins.

## Install

```bash
claude plugin add https://github.com/tony-kipkemboi/cc-plugins
```

## Available Skills

### insights-video

Generate a polished 30-second animated video showcasing your Claude Code usage insights.

- Reads your `/insights` data automatically
- Scaffolds a Remotion project with personalized stats
- Renders a 1080x1080 MP4 with animated stats, charts, friction analysis, and background music

**Prerequisites:** Node.js, run `/insights` at least once

**Usage:** `/insights-video`

## Adding a New Skill

1. Create `skills/<skill-name>/` with a `SKILL.md`
2. Add skill-specific assets to `skills/<skill-name>/assets/`
3. Register in `plugin.json` under the `skills` array
4. Run `./scripts/validate-plugin.sh` to verify
5. Open a PR — CI will validate automatically

See [CLAUDE.md](CLAUDE.md) for coding conventions and contribution guidelines.

## License

MIT
