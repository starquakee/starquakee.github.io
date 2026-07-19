# Ralph Agent Instructions

You are an autonomous coding agent working in the `starquakee.github.io` Jekyll repository.

## Your Task

1. Read `AGENTS.md`, `tasks/prd-academic-site-de-slop.md`, root `prd.json`, and `progress.txt`.
2. Treat the PRD's Decisions, Non-Goals, Validation, and Risks as already accepted. Do not reopen them unless the repository directly contradicts them.
3. Confirm the current branch is `ralph/academic-site-de-slop`.
4. Pick the highest-priority story where `passes` is `false`.
5. Implement exactly that one story. Do not opportunistically start later stories.
6. Run every focused validation required by that story.
7. Update the matching source-PRD checkboxes and set that story's `passes` to `true` in `prd.json` only after validation succeeds.
8. Append an honest entry to `progress.txt` using the format below.
9. Stage only the files changed for the story plus `tasks/prd-academic-site-de-slop.md`, `prd.json`, and `progress.txt`.
10. Commit with `feat: [Story ID] - [Story Title]`.
11. Push the current branch. If it has no upstream, use `git push -u origin ralph/academic-site-de-slop`.

## Current Run Constraints

- Preserve all existing permalinks, redirects, publication metadata, and factual career information.
- Do not change CSS, theme tokens, JavaScript, navigation, CV facts, or dependencies.
- Do not add new visual decoration while removing generic decoration.
- Do not reintroduce ACG, Bangumi, GalGame, anime-list, or related media content.
- Do not attempt to repair the known Jekyll/Sass load-path failure.
- Do not mark US-004 passing; it requires the root supervisor to integrate to `master` and verify the deployed production site.
- Preserve unrelated user changes.

## Required Validation

Use these repository-equivalent type checks for every story:

```powershell
bundle exec ruby -e "require 'yaml'; YAML.load_file('_config.yml'); puts 'YAML OK'"
bundle exec ruby -e "require 'kramdown'; Dir.glob('**/*.{md,markdown}').reject { |f| f.start_with?('_site/', 'vendor/') }.each { |f| Kramdown::Document.new(File.read(f, encoding: 'UTF-8')).to_html }; puts 'Markdown OK'"
bundle exec ruby -e "require 'liquid'; Dir.glob('{_includes,_layouts,_pages}/**/*.{html,md}').each { |f| Liquid::Template.parse(File.read(f, encoding: 'UTF-8'), error_mode: :lax) }; puts 'Liquid OK'"
ruby -rjson -e "JSON.parse(File.read('prd.json')); JSON.parse(File.read('package.json')); puts 'JSON OK'"
bundle check
git diff --check
```

Run story-specific residue checks from the PRD. A failing full `bundle exec jekyll build` caused only by `vendor/breakpoint/breakpoint` is the documented pre-existing Windows limitation; record it but do not broaden the story.

## Progress Report Format

Append to `progress.txt`:

```text
## [Date/Time] - [Story ID]
- Implemented ...
- Files changed:
  - `path/to/file`
- Validation:
  - `command`: pass/fail
- **Learnings for future iterations:**
  - Durable gotcha or reusable pattern.
---
```

## Stop Condition

After completing one story, check whether all stories in `prd.json` have `passes: true`.

Only if every story is complete and validated, reply with:

```text
<promise>COMPLETE</promise>
```

Otherwise end normally so the next fresh iteration can continue.
