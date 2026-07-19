# Chenchen Feng's Academic Website

Personal academic website built with Jekyll and the Academic Pages theme. The site is published at [starquakee.github.io](https://starquakee.github.io).

## Content

- Home and biography: `_pages/about.md`
- CV: `_pages/cv.md`
- Blog posts: `_posts/`
- Publications: `_publications/`
- Navigation: `_data/navigation.yml`

## Local development

Install Ruby, Bundler, and Node.js, then run:

```powershell
bundle install
bundle exec jekyll serve
```

The local site is available at `http://localhost:4000`.

When JavaScript sources change, install the npm dependencies and rebuild the browser bundle:

```powershell
npm install
npm run build:js
```
