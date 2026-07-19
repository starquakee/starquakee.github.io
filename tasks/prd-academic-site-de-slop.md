# PRD: Academic Site De-slop

## Introduction

Remove the four confirmed generic or decorative remnants identified by the `kill-ai-slop` audit while preserving the site's restrained Academic Pages visual language, factual academic content, and public routes.

## References

- `AGENTS.md`
- `_config.yml`
- `_pages/404.md`
- `_pages/about.md`
- `_pages/cv.md`
- `_publications/2025-02-13-MetaDE.md`
- `_includes/author-profile.html`

## Decisions

- Apply all four confirmed audit groups.
- Replace the decorative 404 message with plain, useful recovery copy.
- Replace the sidebar slogan with the factual label `Master's student in Computer Science`.
- Reduce the home page to a concise introduction and direct links to Publications and CV; detailed education, experience, projects, publications, and contact information remain available through those existing routes and the sidebar.
- Remove the repeated inline SUSTech logos and delete `images/校徽.png` once no source references remain.
- Rewrite the MetaDE page in direct technical language while preserving its title, venue, date, permalink, paper URL, code URL, method, benchmark, and robot-control claims.
- Keep Ralph orchestration artifacts in the repository but exclude them from Jekyll output.
- Treat the existing Windows Sass import failure as a known pre-existing limitation, not part of this run.

## Goals

- Remove the remaining ACG-style 404 copy and decorative emoji.
- Make the sidebar description factual rather than slogan-like.
- Eliminate duplicated home-page content and non-informative imagery.
- Replace inflated MetaDE prose with specific technical writing.
- Preserve navigation, routes, academic facts, and the existing restrained theme.

## Non-Goals

- No theme redesign, palette change, typography replacement, layout-system refactor, or new dependency.
- No changes to CV facts, publication metadata, author identity, navigation labels, or collection permalinks.
- No repair of the Jekyll/Sass load-path problem.
- No reintroduction of ACG, Bangumi, GalGame, anime-list, or related media content.
- No publication of Ralph PRD, progress, runner, or archive files in generated Jekyll output.

## User Stories

### US-001: Replace decorative copy with factual copy

**Description:** As a visitor, I want the 404 page and sidebar description to use direct language so the site feels intentional and professional.

**Acceptance Criteria:**

- [ ] `_pages/404.md` contains a plain not-found explanation and a working link to `/`.
- [ ] `_pages/404.md` contains no `Ciallo`, kaomoji, or decorative emoji.
- [ ] `_config.yml` sets `author.bio` to `Master's student in Computer Science`.
- [ ] YAML and Markdown source checks pass.
- [ ] Typecheck passes via the repository-equivalent YAML, Markdown, and Liquid source checks.

### US-002: Simplify the home page

**Description:** As a visitor, I want a concise home page so I can understand the owner's current focus without rereading the CV and sidebar.

**Acceptance Criteria:**

- [ ] `_pages/about.md` preserves its existing front matter, `/` permalink, and redirects.
- [ ] The body contains a concise introduction, current Moonshot AI role, and direct links to `/publications/` and `/cv/`.
- [ ] The body no longer repeats contact bullets or full Education, Work Experience, Projects, Publications, and Links sections.
- [ ] `images/校徽.png` is deleted and no source file references it.
- [ ] Markdown source checks and `git diff --check` pass.
- [ ] Typecheck passes via the repository-equivalent YAML, Markdown, and Liquid source checks.
- [ ] Verify the integrated result in a browser using the browser skill during final aggregate validation.

### US-003: Rewrite the MetaDE description

**Description:** As a reader, I want the MetaDE page to state the research problem, method, implementation, and evidence directly so I can assess the work quickly.

**Acceptance Criteria:**

- [ ] `_publications/2025-02-13-MetaDE.md` preserves all front-matter metadata and factual technical claims.
- [ ] The body directly explains DE configuration sensitivity, MetaDE's meta-level evolution, dynamic parameterization, GPU parallelism, CEC2022 evaluation, and robot-control application.
- [ ] The body links to `https://github.com/EMI-Group/metade` using Markdown link syntax.
- [ ] The body contains none of `As a cornerstone`, `pivotal aspect`, `peak performance`, or repeated `promising performance` phrasing.
- [ ] Markdown source checks and `git diff --check` pass.
- [ ] Typecheck passes via the repository-equivalent YAML, Markdown, and Liquid source checks.

### US-004: Run residue and production visual validation

**Description:** As the site owner, I want the integrated changes checked for residue and visually verified so removed patterns do not survive in source or production.

**Acceptance Criteria:**

- [ ] All earlier stories have `passes: true` with validation evidence in `progress.txt`.
- [ ] The forbidden-copy scan returns no source hits for the removed 404 and MetaDE phrases or the old sidebar slogan.
- [ ] All remaining static assets under `images/` and `files/` have source references.
- [ ] YAML, Markdown, Liquid, JSON, dependency, and `git diff --check` validations pass.
- [ ] The feature branch is integrated into `master` and pushed without rewriting history.
- [ ] The production home page and 404 page are visually verified in a browser after GitHub Pages deployment.
- [ ] Typecheck passes via the repository-equivalent YAML, Markdown, and Liquid source checks.

## Functional Requirements

- FR-1: The 404 page must provide a clear explanation and home-page recovery link without decorative media-language remnants.
- FR-2: The sidebar biography must use a factual role description.
- FR-3: The home page must not duplicate detailed content owned by CV, Publications, or the sidebar.
- FR-4: The MetaDE description must retain research facts while removing inflated framing.
- FR-5: Ralph workflow artifacts must be excluded from generated Jekyll output.
- FR-6: Existing public permalinks and redirects must remain unchanged.

## Validation

- `bundle exec ruby -e "require 'yaml'; YAML.load_file('_config.yml'); puts 'YAML OK'"`
- `bundle exec ruby -e "require 'kramdown'; Dir.glob('**/*.{md,markdown}').reject { |f| f.start_with?('_site/', 'vendor/') }.each { |f| Kramdown::Document.new(File.read(f, encoding: 'UTF-8')).to_html }; puts 'Markdown OK'"`
- `bundle exec ruby -e "require 'liquid'; Dir.glob('{_includes,_layouts,_pages}/**/*.{html,md}').each { |f| Liquid::Template.parse(File.read(f, encoding: 'UTF-8'), error_mode: :lax) }; puts 'Liquid OK'"`
- `ruby -rjson -e "JSON.parse(File.read('prd.json')); JSON.parse(File.read('package.json')); puts 'JSON OK'"`
- `bundle check`
- `git diff --check`
- `rg -n -i "Ciallo|EC researcher \\+ systems builder|As a cornerstone|pivotal aspect|peak performance|promising performance|bangumi|\\bacg\\b|galgame|anime-list" _config.yml _pages _posts _publications _includes AGENTS.md`
- Run the `kill-ai-slop` scanner and manually classify the known theme false positives.
- After integration and deployment, inspect the production home and 404 pages in a browser.

The full local `bundle exec jekyll build` is expected to fail on this Windows environment because Jekyll 3.10/Sass 3.7 cannot resolve `_sass/vendor/breakpoint/breakpoint`. Record this honestly; do not mark other validation as failed when the focused source checks pass.

## Risks

- Removing too much from the home page could hide useful information. Mitigation: retain the current focus plus explicit Publications and CV links.
- Rewriting research copy could alter scientific meaning. Mitigation: preserve every named method, implementation detail, evaluation setting, and application claim already present.
- The Ralph runner may not find the packaged Windows Codex executable from Git Bash. Mitigation: support `RALPH_CODEX_BIN` and stop before stories if the executable cannot launch.
- GitHub Pages deployment is asynchronous. Mitigation: do not complete US-004 until production visibly reflects the pushed `master` commit.

## Open Questions

- None. The user approved applying all confirmed audit groups.
