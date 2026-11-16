meta ::
  title = buche — a terminal where panes show more than text

.hero %
  h1 %
    buche

.install-box %
  code %
    curl -fsSL buche.sh/buche.sh | sh
  button %
    onclick = copyInstall(this)
    Copy


[// \x] => [span.mauve % {x}]

= What

//Buche is a graphical terminal. You can use it like normal. BUT. Every command
gets its own dockable pane, and you can embed HTML interfaces. It's cool!

Installing Buche also installs //cq, a shell that can speak the Buche protocol.

This is __[span.reddish % VERY BETA].
