# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) és una alternativa deliciosa a alguna cosa com l'aplicació GitHub Desktop, i s'executa dins del terminal.

El pots executar directament, anant a qualsevol directori gestionat per git i executant `lazygit`. O el pots executar dins de Neovim, on es pot iniciar amb `Space G G`.

Saltes entre els diferents panells amb `Tab`. Al panell Files, selecciones els fitxers que vols preparar amb `Space`, i després pots crear un commit nou amb `c`. Pots veure totes les ordres disponibles amb `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) és un bonic gestor de recursos que mostra l'ús de memòria, CPU, disc i xarxa. També llista tots els processos actius i et permet gestionar-los.

Omarchy l'anomena Activity Monitor, i l'inicies des del llançador d'aplicacions o prement `Super + Shift + T`. S'obre com una finestra flotant, que pots posar en mosaic amb `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) és un gestor d'espais de treball de terminal que et dona espais de treball, pestanyes i panells, i els manté tots en funcionament en una sessió persistent de la qual et pots desconnectar i a la qual pots tornar més tard.

L'inicies (o et tornes a connectar a la teva sessió existent) des del llançador d'aplicacions o amb `Super + Ctrl + Return`. Omarchy inclou una configuració de Herdr que reflecteix la seva configuració de Tmux, de manera que la tecla de prefix també és `Ctrl + Space` aquí. Pots consultar totes les combinacions de tecles amb `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) mostra informació del sistema, com la versió del nucli, el temps d'activitat, el tema, la CPU, la memòria i molt més. És el successor de la popular eina neofetch.

Omarchy ho ha empaquetat com a _About_ al menú d'Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) és un reproductor de música de terminal retro inspirat en Winamp 2.x, amb emissores de ràdio integrades de ritmes lo-fi. Llança'l amb `Super + Shift + Alt + M`, o des del menú d'Omarchy a _Apps_. Prem `?` per veure la llista completa de combinacions de tecles.

## I què passa amb el Wi-Fi i el Bluetooth?

No trobaràs TUIs per al Wi-Fi i el Bluetooth — aquestes feines corresponen a la shell d'Omarchy. Fes clic a la icona del Wi-Fi a la barra superior (o prem `Super + Ctrl + N`) per veure les xarxes i connectar-t'hi, i fes clic a la icona del Bluetooth (o prem `Super + Ctrl + B`) per emparellar i connectar dispositius. Consulta [xarxes](35-networking.md) per saber-ne tots els detalls.

## Afegir els teus propis

Qualsevol programa de terminal pot rebre el tractament complet d'aplicació. Vés a _Install > TUI_ al menú d'Omarchy (`Super + Space`), dona-li un nom, una ordre de llançament, un estil de finestra i una icona, i apareixerà al llançador d'aplicacions com qualsevol altra aplicació. El pots tornar a eliminar a _Remove > TUI_.
