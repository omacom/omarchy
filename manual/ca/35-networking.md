# Xarxa

La xarxa a Omarchy la gestiona NetworkManager, i la controles des de la icona de xarxa de la [barra superior](05-the-top-bar.md) o amb `Super + Ctrl + N`.

Aquest tauler cerca xarxes Wi-Fi, mostra la intensitat del senyal i s'hi connecta. Ethernet no necessita res de res: connecta'l i funciona. Si prefereixes quedar-te al terminal, `nmtui` et dona els mateixos controls, i també hi ha un grup d'ordres `omarchy network`.

## Compartir la teva Wi-Fi

En lloc de llegir una contrasenya llarga en veu alta, executa _Configuració > Xarxa > Codi QR_ mentre estiguis en una Wi-Fi. Això posa a la pantalla un codi QR que qualsevol càmera de telèfon pot escanejar per unir-s'hi. És una d'aquelles coses que faràs servir més del que t'esperaries un cop saps que hi és.

Si realment necessites la contrasenya en si, `omarchy network password <interface>` la mostra.

## DNS

Omarchy fa servir el DNS que la teva xarxa li lliura per DHCP. Pots substituir-lo per a tota la màquina a _Configuració > Xarxa > DNS_, on Cloudflare i Google són a un clic de distància. Tria _Personalitzat_ per escriure els teus propis servidors.

Des del terminal, `omarchy dns` mostra el proveïdor actual i `omarchy dns Cloudflare` en defineix un.

## Fixar la banda de la Wi-Fi

Si el teu encaminador posa els 2.4GHz, els 5GHz i els 6GHz amb el mateix nom de xarxa, de vegades el portàtil s'aferrarà a la lenta. `omarchy network band` mostra en quina banda ets, i `omarchy network band 5` la fixa. Fes servir `auto` perquè torni a triar ell.

Això fixa la banda i no un punt d'accés concret, així que continues canviant entre AP amb normalitat.

## A quina velocitat va?

_Activador > Prova de velocitat > Prova de velocitat de la xarxa_ mesura la teva velocitat real de pujada i baixada amb un parell d'indicadors. Des del terminal és `omarchy network speedtest down` o `up`. (Hi ha una prova de velocitat del disc just al costat en aquest menú, per si vols mesurar l'altre coll d'ampolla.)

## El tallafoc

El tallafoc està activat per defecte i bloqueja tot el trànsit entrant, amb una excepció: el port 53317, perquè [LocalSend](22-guis.md) funcioni des del primer moment.

SSH està desactivat fins que l'actives amb _Configuració > Seguretat > SSHD_, que inicia el dimoni, obre el port 22 amb limitació de velocitat contra els atacs de força bruta i autoritza una clau. Docker també està restringit, així que els contenidors no es poden exposar accidentalment al món. Consulta [seguretat](48-security.md) per conèixer tota la història.

## Tailscale

[Tailscale](https://tailscale.com/) és una VPN en malla que fa que arribar a tots els teus ordinadors i servidors per internet sigui senzill i segur. Instal·la-la amb _Instal·la > Servei > Tailscale_.

Això et dona un tauler de Tailscale a la barra, que connecta i desconnecta la tailnet, canvia de comptes i tria un node de sortida: tant les teves pròpies màquines com les regions de Mullvad apareixen a la llista. També explora les teves màquines, i és on viu Taildrop: selecciona una màquina i prem `s` per enviar-li fitxers, o `c`, `n` i `d` per copiar-ne la IP, el nom o el nom DNS complet. L'equivalent al terminal és `omarchy tailscale send <machine> [file...]`, i els fitxers que t'envien arriben automàticament a `~/Downloads`. La notificació que anuncia una arribada espera fins que hi fas clic per obrir-la o la descartes, així que un fitxer que arriba mentre ets lluny de la màquina encara hi és per respondre-hi quan tornes.

Instal·lar-la també afegeix una aplicació web per a la consola d'administració de Tailscale.

## Quan deixa de funcionar

Abans de reiniciar, prova de reiniciar només la peça problemàtica. _Actualitza > Maquinari_ té Wi-Fi, Bluetooth, Àudio i Trackpad, i recarregar-ne una aclareix la majoria de situacions de «funcionava fa cinc minuts». Consulta [resolució de problemes](45-troubleshooting.md).
