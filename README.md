# buche.sh

The [buche.sh](https://buche.sh) website, written in [quaint](https://breuleux.github.io/quaint/)
and deployed to GitHub Pages.

```sh
npm install
npx quaint          # build into output/
npx quaint --serve 8080   # (with watch; enable server in quaint.json first)
```

Pushes to `main` build and deploy with `.github/workflows/deploy.yml`. The site
hosts the canonical installer — `content/buche.sh`, a copy of the [buche
repo's](https://github.com/buche-term/buche) `install.sh` — so the documented
install line is `curl -fsSL buche.sh/buche.sh | sh`. When the upstream copy
changes, re-sync it (`cp ../buche/install.sh content/buche.sh`) and push; the deploy
warns if the two have drifted.

Layout:

- `content/index.q` — the landing page
- `content/assets/` — static assets (css, js, logos), copied verbatim
- `templates/default.q` — the HTML boilerplate every page gets
- `quaint.json` — quaint configuration (`content/` → `output/`)

Code blocks use the [quaint-highlight](https://github.com/breuleux/quaint-highlight)
plugin (`&` operator, default language: bash), themed by
`content/assets/hljs-buche.css` — the build copies it to
`resources/style/highlight/` and links it in the page head automatically.
Note: it bundles highlight.js 8, so the language vocabulary is from 2017
(`curl` gets no tokens, `echo` does).

To add a page, drop a `.q` file in `content/`; it compiles to the matching
`.html` with the same template.
