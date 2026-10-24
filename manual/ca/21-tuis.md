# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) és una alternativa deliciosa a alguna cosa com l'aplicació GitHub Desktop, i s'executa dins del terminal.

El pots executar directament anant a qualsevol directori gestionat per git i executant `lazygit`. O el pots executar dins de Neovim, on es pot iniciar amb `Space G G`.

Saltes entre els diferents panells amb `Tab`. Al panell de fitxers, selecciones els fitxers per posar a l'àrea de preparació amb `Space`, i després pots crear un nou commit amb `c`. Pots veure totes les ordres disponibles amb `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) és un bonic gestor de recursos que mostra l'ús de memòria, CPU, disc i xarxa. També llista tots els processos actius i et permet gestionar-los.

Omarchy l'anomena Activity, i l'inicies prement `Super + Ctrl + T`. S'obre com a finestra flotant, que pots posar en mosaic amb `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) és un gestor d'espais de treball de terminal que et dona espais de treball, pestanyes i panells, i els manté tots en funcionament en una sessió persistent de la qual et pots desconnectar i a la qual pots tornar més tard.

L'inicies (o et reconnectes a la sessió que ja tens) amb `Super + Ctrl + Return`. Omarchy inclou una configuració de Herdr que reflecteix la seva configuració de Tmux, de manera que aquí la tecla de prefix també és `Ctrl + Space`. Pots consultar totes les dreceres de teclat amb `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) mostra informació del sistema, com ara la versió del nucli, el temps d'activitat, el tema, la CPU, la memòria i més coses. És el successor de la popular eina neofetch.

Omarchy ho ha empaquetat com a _Quant a_ al menú d'Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) és un reproductor de música de terminal retro inspirat en Winamp 2.x, complet amb emissores de ràdio integrades de ritmes lo-fi. Llança'l amb `Super + Shift + Alt + M`, o des del menú d'Omarchy a _Aplicacions_. Prem `?` per veure la llista completa de dreceres.

## I què passa amb la Wi-Fi i el Bluetooth?

No hi trobaràs TUI per a la Wi-Fi i el Bluetooth: aquestes feines corresponen a l'intèrpret d'ordres d'escriptori d'Omarchy. Fes clic a la icona de Wi-Fi de la barra de menú (o prem `Super + Ctrl + W`) per veure les xarxes i connectar-t'hi, i fes clic a la icona de Bluetooth (o prem `Super + Ctrl + B`) per aparellar i connectar dispositius. Consulta [xarxes](35-networking.md) per a la història completa.

## Afegir les teves pròpies

Qualsevol programa de terminal pot rebre el tracte complet d'aplicació. Ves a _Instal·la > TUI_ al menú d'Omarchy (`Super + Space`), dona-li un nom, una ordre d'inici, un estil de finestra i una icona, i apareixerà al llançador d'aplicacions com qualsevol altra aplicació. La pots tornar a eliminar a _Elimina > TUI_.
