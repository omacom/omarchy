# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) és una alternativa encantadora a una cosa com l'aplicació GitHub Desktop, i s'executa dins del terminal.

Pots executar-lo directament, anant a qualsevol directori gestionat per git i executant `lazygit`. O pots executar-lo dins de Neovim, on es pot iniciar amb `Space G G`.

Saltes entre els diferents panells amb `Tab`. Al panell Files, selecciones els fitxers per preparar-los amb `Space`, i després pots crear un commit nou amb `c`. Pots veure totes les ordres disponibles amb `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) és un gestor de recursos preciós que mostra l'ús de memòria, CPU, disc i xarxa. També llista tots els processos actius i et permet gestionar-los.

Omarchy l'anomena Activity, i l'inicies prement `Super + Shift + T`. S'obre com una finestra flotant, que pots posar en mosaic amb `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) és un gestor d'espais de treball per al terminal que et dona espais de treball, pestanyes i panells, i els manté tots en execució en una sessió persistent de la qual pots desconnectar-te i a la qual pots tornar més tard.

L'inicies (o et tornes a connectar a la sessió existent) amb `Super + Ctrl + Return`. Omarchy inclou una configuració de Herdr que reflecteix la seva configuració de Tmux, així que aquí la tecla de prefix també és `Ctrl + Space`. Pots consultar totes les dreceres de teclat amb `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) mostra informació del sistema, com la versió del kernel, el temps de funcionament, el tema, la CPU, la memòria i molt més. És el successor de la popular eina neofetch.

Omarchy l'ha inclòs com a _About_ al menú d'Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) és un reproductor de música retro per al terminal inspirat en Winamp 2.x, amb emissores de ràdio integrades de ritmes lo-fi. Inicia'l amb `Super + Shift + Alt + M`, o des del menú d'Omarchy a _Apps_. Prem `?` per veure la llista completa de dreceres de teclat.

## I què passa amb el Wi-Fi i el Bluetooth?

No trobaràs TUI per al Wi-Fi i el Bluetooth: aquestes feines corresponen a la shell d'Omarchy. Fes clic a la icona de Wi-Fi de la barra superior (o prem `Super + Ctrl + N`) per veure les xarxes i connectar-t'hi, i fes clic a la icona de Bluetooth (o prem `Super + Ctrl + B`) per aparellar i connectar dispositius. Consulta [xarxes](35-networking.md) per saber-ne tota la història.

## Afegeix-hi els teus

Qualsevol programa de terminal pot rebre tot el tractament d'aplicació. Ves a _Install > TUI_ al menú d'Omarchy (`Super + Space`), dona-li un nom, una ordre d'inici, un estil de finestra i una icona, i apareixerà al llançador d'aplicacions com qualsevol altra aplicació. Pots tornar-lo a eliminar a _Remove > TUI_.
