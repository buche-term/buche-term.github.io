doctype :: html
html %
  head %
    meta %
      charset = utf-8
    meta %
      name = viewport
      content = width=device-width, initial-scale=1
    title %
      meta::title !! buche
    meta %
      name = description
      content = buche: a terminal where panes show more than text. With coquille (cq), its structured shell, and carreau, its layout engine.
    link %
      rel = icon
      type = image/svg+xml
      href = /assets/buche.svg
    link %
      rel = stylesheet
      href = /assets/style.css
    script %
      src = /assets/site.js
      defer = defer
  body %
    header.top %
      a.brand %
        href = /
        img.logo %
          src = /assets/buche.svg
          alt = buche
        span %
          buche
      nav %
        a %
          href = https://github.com/buche-term/buche
          GitHub
    main %
      {body}
    footer %
      Made with love by Olivier Breuleux
