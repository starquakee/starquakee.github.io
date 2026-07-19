# Repository Guide for Agents

## Scope

This file applies to the entire repository.

## Project

This is Chenchen Feng's personal academic website. It is a GitHub Pages-compatible Jekyll site based on the Academic Pages theme.

The public navigation is defined in `_data/navigation.yml`. The current primary pages are:

- Home: `_pages/about.md`
- Publications: `_pages/publications.html` and `_publications/`
- Blog: `_pages/year-archive.html` and `_posts/`
- CV: `_pages/cv.md`

## Content Rules

- Keep public content focused on the site owner's academic profile, research, publications, projects, and technical writing.
- Preserve existing permalinks and `redirect_from` entries unless the user explicitly approves a route change.
- Keep factual biography, education, project, and publication details consistent between `_pages/about.md`, `_pages/cv.md`, and `_publications/`.
- Treat generic Academic Pages examples as template material, not verified facts about the site owner.
- Do not publish placeholder names, example institutions, sample talks, sample teaching records, or sample papers as real content.

## Repository Map

- `_config.yml`: site identity, author metadata, enabled collections, defaults, plugins, and build settings.
- `_data/navigation.yml`: visible header navigation.
- `_pages/`: standalone routes and archive pages.
- `_posts/`: dated blog posts.
- `_publications/`: real publication records.
- `_includes/` and `_layouts/`: shared Liquid rendering modules.
- `_sass/` and `assets/css/main.scss`: theme styles and Sass entry point.
- `assets/js/_main.js` and `assets/js/plugins/`: JavaScript sources.
- `assets/js/main.min.js`: generated browser bundle. Rebuild it with `npm run build:js`; do not hand-edit it.
- `images/` and `files/`: published static assets. Verify references before removing large or generically named files.
- `_site/` and `.sass-cache/`: generated output and cache. Never edit or commit them.

## Editing Workflow

1. Run `git status -sb` before editing and preserve unrelated user changes.
2. Search with `rg` or `rg --files` before changing routes, includes, collections, or assets.
3. Make the smallest change that satisfies the request.
4. For content removal, search for visible text, configuration fields, route entries, media references, and directly accessible static assets.
5. Do not remove a template module only because its current configuration is empty. Confirm whether the site still exposes its interface or may intentionally retain it.

## Validation

Run checks proportional to the change:

```powershell
git diff --check
bundle exec jekyll build
```

For configuration or Liquid changes, also parse the affected sources when a full build is unavailable:

```powershell
ruby -e "require 'yaml'; YAML.safe_load(File.read('_config.yml', encoding: 'UTF-8'), aliases: true); puts 'YAML OK'"
ruby -e "require 'liquid'; Liquid::Template.parse(File.read('_includes/author-profile.html', encoding: 'UTF-8'), error_mode: :lax); puts 'Liquid OK'"
```

When JavaScript sources change:

```powershell
npm run build:js
```

Report build failures precisely. Do not broaden a content-only task into an unrelated dependency or theme repair without user approval.

## Git

- Stage only files that belong to the requested change.
- Use concise, imperative commit messages.
- Do not commit `_site/`, `.sass-cache/`, `.idea/`, `node_modules/`, or local dependency artifacts.
- Never rewrite history or discard user changes unless explicitly instructed.
