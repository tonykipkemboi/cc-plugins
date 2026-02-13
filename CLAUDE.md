# CC Plugins

Personal marketplace of Claude Code plugins. Each plugin lives in its own directory at the repo root with a `plugin.json` manifest.

## Repo Structure

```
cc-plugins/
├── plugin.json              # Root manifest (registers all plugins)
├── scripts/                 # Validation and CI scripts
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md         # Skill instructions for Claude
│       └── assets/          # Skill-specific assets (audio, images, fonts)
├── commands/                # Slash commands (if any)
├── hooks/                   # Lifecycle hooks (if any)
└── agents/                  # Subagent definitions (if any)
```

## Adding a New Skill

1. Create a directory under `skills/<skill-name>/`
2. Write a `SKILL.md` with clear step-by-step instructions
3. Update `plugin.json` to register the new skill in the `skills` array
4. Add any required assets to `skills/<skill-name>/assets/`
5. Update `README.md` with the new skill's description

## Writing Good Skills

- **Be explicit**: Include complete code templates inline in the SKILL.md. Do NOT tell Claude to "write a function that does X" - give it the exact code with placeholders for user data.
- **Fail early**: Always check prerequisites (files exist, tools installed) before doing work. If something is missing, tell the user what to do and stop.
- **Minimize interaction**: The goal is one-shot execution. Only ask the user a question if there's a genuine choice to make (e.g., output location). Never ask for confirmation mid-pipeline.
- **Use `${CLAUDE_PLUGIN_ROOT}`**: Reference bundled assets relative to the plugin root, not hardcoded paths.
- **No hardcoded user data**: All user-specific values must be read from a data source or parameterized. Never leave example data from testing in the templates.

## Coding Conventions

- Use TypeScript for any generated code
- Follow the existing patterns in the repo (check similar skills first)
- Keep assets small - compress audio/images before committing
- Use `.gitignore` to exclude build artifacts, `node_modules`, and `.DS_Store`

## Plugin.json Schema

```json
{
  "name": "plugin-name",
  "description": "What this plugin does",
  "version": "1.0.0",
  "skills": [
    {
      "name": "skill-name",
      "path": "skills/skill-name",
      "description": "What this skill does - used for matching trigger phrases"
    }
  ]
}
```

## Testing

Before pushing a new skill:
1. Test the full pipeline end-to-end in a fresh Claude Code session
2. Verify all file paths resolve correctly
3. Check that generated code compiles/runs without errors
4. Confirm no user-specific data is hardcoded in templates

## Commit Messages

- Use imperative mood: "Add insights-video skill" not "Added insights-video skill"
- Keep the first line under 72 characters
- Include a body describing what and why if the change is non-trivial
