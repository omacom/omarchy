# Resolució de problemes

### He trencat el meu sistema amb una actualització!

Primer prova de [revertir el teu sistema](47-system-snapshots.md) a la versió anterior a l'actualització recent. Si això no funciona, utilitza `omarchy-debug` per compartir el teu problema a #omarchy-help al Discord. I si tot això falla, pots reinstal·lar les configuracions i els paquets per defecte amb `omarchy-reinstall`.

### Per què algunes aplicacions es veuen tan grans a la meva pantalla?

Omarchy assumeix una pantalla d'alta resolució 2x, cosa que requereix establir `GDK_SCALE` a 2 a `~/.config/hypr/monitors.lua`. Però si tens una pantalla 1x, pots canviar `local omarchy_gdk_scale = 2` a 1 (i després reiniciar qualsevol aplicació que es vegi sobredimensionada). Consulta [el manual sobre monitors](33-monitors.md).

Per a Spotify, pots utilitzar `Ctrl + Minus` per reduir la interfície d'usuari (i `Ctrl + Plus` per fer-la més gran).

### Per què han deixat de funcionar totes les meves dreceres amb la tecla Super?

En alguns portàtils ASUS ROG i TUF, `Fn + Super` és una combinació fàcil de passar per alt que activa i desactiva un bloqueig de la tecla Windows del microprogramari (pensat per jugar perquè no surtis d'un joc per accident). Res a la pantalla no t'indica que ha passat. Mentre el bloqueig està activat, Super no emet absolutament res, de manera que totes les dreceres d'Omarchy que utilitzen Super simplement deixen de funcionar, i sembla que Hyprland s'hagi trencat.

Prem `Fn + Super` una vegada abans d'endinsar-te a `~/.config/hypr/`, i si això no fa que Super torni, prem-ho una altra vegada per no deixar el bloqueig activat. Això no és el Fn-lock, que només canvia el que fa la fila de tecles F.

### El meu Wi-Fi, Bluetooth, àudio o trackpad acaba de deixar de funcionar

Abans de reiniciar, prova de reiniciar el subsistema problemàtic per separat. _Actualitza > Maquinari_ al menú d'Omarchy té Wi-Fi, Bluetooth, Àudio i Trackpad, i tornar a carregar-ne un aclareix la majoria de situacions de "funcionava fa cinc minuts": uns auriculars Bluetooth que no es volen tornar a connectar, un trackpad que ha quedat mort després d'una suspensió, un so que ha desaparegut quan has desconnectat un monitor.

### Per què els meus altaveus externs no sonen?

Probablement perquè no estan establerts com a sortida principal. Fes clic a la icona de l'altaveu a la part dreta de la barra i s'obrirà la finestra emergent de volum, on pots triar el dispositiu de sortida (i també barrejar els volums per aplicació).

### Els altaveus del meu portàtil sonen malament

En alguns portàtils, Omarchy aplica automàticament un ajust dels altaveus que corregeix la resposta de freqüència dels altaveus integrats. `omarchy audio tuning status` t'indica si n'hi ha un d'actiu a la teva màquina, i `omarchy audio tuning off` el desactiva si prefereixes sentir els altaveus sense cap correcció.

### Per què no puc iniciar sessió ni utilitzar sudo amb la meva contrasenya?

Probablement l'has escrit malament massa vegades i has quedat bloquejat. Si això passa a la pantalla de bloqueig, pots prémer `CTRL + ALT + F2` per iniciar una TTY nova on pots iniciar sessió com a root i després executar `faillock --reset --user [your-username]`. Això restablirà el bloqueig i ja podràs continuar.

### Per què no apareixen les meves sol·licituds d'autorització de 1Password per a 1Password SSH Agent / CLI?

Això pot passar per 2 motius:

Perquè aparegui la sol·licitud d'aprovació completa, Configuració > Avançat > Utilitza l'acceleració per maquinari ha d'estar activat. _Nota: Això requereix un reinici per començar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

O, si no has obert 1Password des que has arrencat, la sol·licitud no apareixerà.
