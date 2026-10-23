# Xarxa

A Omarchy, la xarxa la gestiona NetworkManager, i la controles des de la icona de xarxa de la [barra superior](05-the-top-bar.md) o amb `Super + Ctrl + W`.

Aquest panell cerca xarxes Wi-Fi, mostra la intensitat del senyal i s'hi connecta. Ethernet no necessita res de res: connecta el cable i funciona. Si prefereixes quedar-te al terminal, `nmtui` et dona els mateixos controls, i també hi ha un grup d'ordres `omarchy network`.

## Compartir la teva Wi-Fi

En comptes de llegir una contrasenya llarga en veu alta, executa _Configuració > Xarxa > Codi QR_ mentre estiguis connectat per Wi-Fi. Això posa a pantalla un codi QR que qualsevol càmera de telèfon pot escanejar per unir-s'hi. És una d'aquelles coses que faràs servir més del que t'esperes un cop saps que hi és.

Si el que et cal és la contrasenya en si, `omarchy network password <interface>` la mostra.

## DNS

Omarchy fa servir el DNS que la teva xarxa reparteix per DHCP. Pots substituir-lo per a tota la màquina a _Configuració > Xarxa > DNS_, on Cloudflare i Google són a un clic de distància. Tria _Custom_ per escriure els teus propis servidors.

Des del terminal, `omarchy dns` mostra el proveïdor actual i `omarchy dns Cloudflare` en defineix un.

## Fixar la banda de la Wi-Fi

Si el teu encaminador posa 2,4 GHz, 5 GHz i 6 GHz al mateix nom de xarxa, de vegades el portàtil s'aferra a la lenta. `omarchy network band` mostra en quina banda ets, i `omarchy network band 5` la fixa. Fes servir `auto` perquè torni a triar sola.

Això fixa la banda i no un punt d'accés concret, de manera que continues itinerant entre punts d'accés com sempre.

## A quina velocitat va?

_Activa > Prova de velocitat > Prova de velocitat de xarxa_ mesura la teva velocitat real de pujada i baixada amb un parell d'esferes. Des del terminal és `omarchy network speedtest down` o `up`. (En aquest menú hi ha una prova de velocitat de disc just al costat, per si el coll d'ampolla que estàs mesurant és l'altre.)

## El tallafoc

El tallafoc està activat per defecte i bloqueja tot el trànsit entrant, amb una sola excepció: el port 53317, perquè [LocalSend](22-guis.md) funcioni des del primer moment.

SSH està desactivat fins que l'actives amb _Configuració > Seguretat > SSHD_, que engega el dimoni, obre el port 22 amb limitació de taxa contra la força bruta i autoritza una clau. Docker també està tancat amb clau i forrellat, perquè els contenidors no puguin exposar-se al món per accident. Consulta [seguretat](48-security.md) per conèixer tota la història.

## Tailscale

[Tailscale](https://tailscale.com/) és una VPN en malla que fa que arribar a tots els teus ordinadors i servidors per internet sigui senzill i segur. Instal·la'l amb _Instal·la > Servei > Tailscale_.

Això et dona un panell de Tailscale a la barra, que connecta i desconnecta la tailnet, canvia de compte i tria un node de sortida: tant les teves pròpies màquines com les regions de Mullvad apareixen a la llista. També explora les teves màquines, i és on viu Taildrop: selecciona una màquina i prem `s` per enviar-li fitxers, o `c`, `n` i `d` per copiar-ne la IP, el nom o el nom DNS complet. L'equivalent al terminal és `omarchy tailscale send <machine> [file...]`, i els fitxers que t'envien aterren automàticament a `~/Downloads`. La notificació que anuncia una arribada espera fins que la cliquis per obrir-la o la descartis, de manera que un fitxer que apareix mentre no ets davant de la màquina encara hi serà per respondre-hi quan tornis.

Instal·lar-lo també afegeix una aplicació web per a la consola d'administració de Tailscale.

## Quan deixa de funcionar

Abans de reiniciar, prova de reiniciar pel seu compte la peça que falla. _Actualitza > Maquinari_ té Wi-Fi, Bluetooth, Àudio i Panell tàctil, i recarregar-ne un resol la majoria de situacions de «funcionava fa cinc minuts». Consulta [resolució de problemes](45-troubleshooting.md).
