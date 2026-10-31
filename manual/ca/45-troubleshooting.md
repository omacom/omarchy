# Resolució de problemes

### He trencat el sistema amb una actualització!

Primer prova de [revertir el sistema](47-system-snapshots.md) a la versió anterior a la teva actualització recent. Si això no funciona, utilitza `omarchy-debug` per compartir el teu problema a #omarchy-help del Discord. I si tot això falla, pots reinstal·lar les configuracions i els paquets per defecte amb `omarchy-reinstall`.

### Per què algunes aplicacions es veuen tan grans a la meva pantalla?

Omarchy pressuposa una pantalla d'alta resolució a 2x, així que estableix `GDK_SCALE` a 2 fins que triïs una escala al panell del monitor. Si estàs en una pantalla 1x i les aplicacions GTK o X11 surten sobredimensionades, tria 1x per a ella al panell del monitor, o afegeix `hl.env("GDK_SCALE", "1")` a `~/.config/hypr/monitors.lua` (i després reinicia qualsevol aplicació que es vegi sobredimensionada). Consulta [el manual sobre monitors](33-monitors.md).

Per a Spotify, pots utilitzar `Ctrl + Minus` per reduir la interfície (i `Ctrl + Plus` per fer-la més gran).

### Per què han deixat de funcionar totes les meves dreceres amb la tecla Super?

En alguns portàtils ASUS ROG i TUF, `Fn + Super` és una combinació fàcil de passar per alt que activa o desactiva un bloqueig de la tecla Windows del firmware (pensat per jugar, perquè no surtis d'una partida per accident). Res a la pantalla t'indica que ha passat. Mentre el bloqueig està activat, Super no emet absolutament res — així que totes les dreceres d'Omarchy que fan servir Super deixen de funcionar, i sembla que s'hagi trencat Hyprland.

Prem `Fn + Super` una vegada abans de posar-te a remenar `~/.config/hypr/`, i si això no fa tornar Super, prem-ho una altra vegada perquè no deixis el bloqueig activat. Això no és el bloqueig Fn, que només canvia el comportament de la fila de tecles F.

### El meu Wi-Fi, Bluetooth, àudio o trackpad acaba de deixar de funcionar

Abans de reiniciar, prova de reiniciar només el subsistema afectat. _Update > Hardware_ al menú d'Omarchy té Wi-Fi, Bluetooth, Audio i Trackpad, i recarregar-ne un resol la majoria de situacions de "funcionava fa cinc minuts" — uns auriculars Bluetooth que no es tornen a connectar, un trackpad que ha deixat de respondre després d'una suspensió, un so que ha desaparegut en desconnectar un monitor.

### Per què no sonen els meus altaveus externs?

Probablement perquè no estan establerts com a sortida principal. Fes clic a la icona de l'altaveu a la part dreta de la barra i s'obrirà la finestra emergent de volum, on pots triar el dispositiu de sortida (i també ajustar el volum per aplicació).

### Els altaveus del meu portàtil sonen malament

En alguns portàtils, Omarchy aplica automàticament un ajust d'altaveus que corregeix la resposta en freqüència dels altaveus integrats. `omarchy audio tuning status` et diu si n'hi ha un d'actiu a la teva màquina, i `omarchy audio tuning off` el desactiva si prefereixes escoltar els altaveus sense correcció.

### Per què no puc iniciar sessió ni fer sudo amb la meva contrasenya?

Probablement l'has escrita malament massa vegades i t'has quedat bloquejat. Si això passa a la pantalla de bloqueig, pots prémer `CTRL + ALT + F2` per iniciar un nou TTY on pots iniciar sessió com a root i després executar `faillock --reset --user [your-username]`. Això restablirà el bloqueig i ja podràs continuar.

### Per què no apareixen les sol·licituds d'autorització d'1Password per a 1Password SSH Agent / CLI?

Això pot passar per 2 motius:

Perquè aparegui la sol·licitud d'aprovació enriquida, Settings > Advanced > Use Hardware Acceleration ha d'estar activat. _Nota: Això requereix reiniciar perquè comenci a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

O si no has obert 1Password des que has engegat l'equip, la sol·licitud no apareixerà.
