# Xarxes

Les xarxes a Omarchy les gestiona NetworkManager, i les controleu des de la icona de xarxa de la [barra superior](05-the-top-bar.md) o amb `Super + Ctrl + N`.

Aquest tauler cerca xarxes Wi-Fi, mostra la força del senyal i s'hi connecta. Ethernet no necessita res de res: connecteu-lo i funciona. Si preferiu quedar-vos al terminal, `nmtui` us ofereix els mateixos controls, i també hi ha un grup d'ordres `omarchy network`.

## Compartir la vostra Wi-Fi

En lloc de llegir en veu alta una contrasenya llarga, executeu _Configuració > Xarxa > Codi QR_ mentre estigueu connectats a la Wi-Fi. Això mostra a la pantalla un codi QR que qualsevol càmera de telèfon pot escanejar per unir-s'hi. És una d'aquelles coses que fareu servir més del que espereu un cop sabeu que hi és.

Si realment necessiteu la contrasenya en si, `omarchy network password <interface>` la mostra.

## DNS

Omarchy utilitza el DNS que la vostra xarxa li proporciona per DHCP. Podeu canviar-ho per a tota la màquina a _Configuració > Xarxa > DNS_, on Cloudflare i Google són a un clic de distància. Trieu _Personalitzat_ per introduir els vostres propis servidors.

Des del terminal, `omarchy dns` mostra el proveïdor actual i `omarchy dns Cloudflare` en defineix un.

## Fixar la banda de la Wi-Fi

Si el vostre encaminador posa 2.4GHz, 5GHz i 6GHz amb el mateix nom de xarxa, de vegades el portàtil s'aferrarà a la lenta. `omarchy network band` mostra en quina banda sou, i `omarchy network band 5` la fixa. Utilitzeu `auto` perquè torni a triar automàticament.

Això fixa la banda, no un punt d'accés concret, de manera que continueu itinerant entre APs amb normalitat.

## A quina velocitat va?

_Activador > Prova de velocitat > Prova de velocitat de la xarxa_ mesura la vostra velocitat real de pujada i baixada amb un parell d'indicadors. Des del terminal és `omarchy network speedtest down` o `up`. Mesura respecte al servei propi d'Omarchy i només compta les seves transferències de prova. Altres descàrregues poden competir per l'amplada de banda, però no s'afegeixen al resultat de la prova de velocitat. (Hi ha una prova de velocitat de disc just al costat en aquest menú, si voleu mesurar l'altre coll d'ampolla.)

## El tallafoc

El tallafoc està activat per defecte i bloqueja tot el trànsit entrant, amb una excepció: el port 53317, perquè [LocalSend](22-guis.md) funcioni des del primer moment.

SSH està desactivat fins que l'activeu amb _Configuració > Seguretat > SSHD_, que inicia el dimoni, obre el port 22 amb limitació de freqüència contra la força bruta i autoritza una clau. Docker també està protegit, de manera que els contenidors no es puguin exposar accidentalment al món. Vegeu [seguretat](48-security.md) per a tota la història.

## Tailscale

[Tailscale](https://tailscale.com/) és una VPN en malla que fa que arribar a tots els vostres ordinadors i servidors per internet sigui senzill i segur. Instal·leu-la amb _Instal·la > Servei > Tailscale_.

Això us proporciona un tauler de Tailscale a la barra, que connecta i desconnecta la tailnet, canvia de compte i tria un node de sortida: tant les vostres pròpies màquines com les regions de Mullvad apareixen a la llista. També explora les vostres màquines, i és on viu Taildrop: seleccioneu una màquina i premeu `s` per enviar-li fitxers, o `c`, `n` i `d` per copiar-ne l'IP, el nom o el nom DNS complet. L'equivalent al terminal és `omarchy tailscale send <machine> [file...]`, i els fitxers que us envien arriben a `~/Downloads` automàticament. La notificació que anuncia una arribada espera fins que hi feu clic per obrir-la o la descarteu, de manera que un fitxer que arribi mentre sou fora de la màquina encara hi serà per respondre quan torneu.

Instal·lar-la també afegeix una aplicació web per a la consola d'administració de Tailscale.

## Quan deixa de funcionar

Abans de reiniciar, proveu de reiniciar només la part problemàtica. _Actualització > Maquinari_ té Wi-Fi, Bluetooth, Àudio i Trackpad, i recarregar-ne un aclareix la majoria de situacions d'«funcionava fa cinc minuts». Vegeu [resolució de problemes](45-troubleshooting.md).
