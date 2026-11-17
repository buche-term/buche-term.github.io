meta ::
  title = The buche terminal

.hero %
  h1 %
    ;; buche
    b[.insert % [img % [src = /assets/buche.svg] [alt = u]]]che

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

= Skill

To make a program using the Buche protocol, you can install these skills for your
agent:

bash &
  # Raw Buche protocol
  npx skills add buche-term/buche

  # To develop Buche apps in Python
  npx skills add buche-term/buchelib.py

There will be human docs later, in the meantime your agent can explain the protocol
and buchelib to you. That's the world we live in.
