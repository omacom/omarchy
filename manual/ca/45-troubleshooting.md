# Resolució de problemes

### He trencat el sistema amb una actualització!

Primer prova de [retrocedir el sistema](47-system-snapshots.md) a la versió anterior a l'actualització recent. Si això no funciona, fes servir `omarchy-debug` per compartir el teu problema a #omarchy-help del Discord. I si tot això falla, pots reinstal·lar les configuracions i els paquets per defecte fent servir `omarchy-reinstall`.

### Per què algunes aplicacions són tan grans a la meva pantalla?

Omarchy assumeix una pantalla d'alta resolució de 2x, que requereix definir `GDK_SCALE` a 2 a `~/.config/hypr/monitors.lua`. Però si ets en una pantalla d'1x, pots canviar `local omarchy_gdk_scale = 2` a 1 (i després reiniciar qualsevol aplicació que sigui massa gran). Consulta [el manual sobre monitors](33-monitors.md).

Per a Spotify, pots fer servir `Ctrl + Minus` per encongir la interfície (i `Ctrl + Plus` per fer-la més gran).

### La Wi-Fi, el Bluetooth, l'àudio o el panell tàctil acaben de deixar de funcionar

Abans de reiniciar, prova de reiniciar el subsistema que falla pel seu compte. _Actualitza > Maquinari_ al menú d'Omarchy té Wi-Fi, Bluetooth, Àudio i Panell tàctil, i recarregar-ne un resol la majoria de situacions de «funcionava fa cinc minuts»: uns auriculars Bluetooth que no es volen reconnectar, un panell tàctil que ha mort després d'una suspensió, un so que ha desaparegut quan has desconnectat un monitor.

### Per què no sonen els altaveus externs?

Probablement perquè no estan definits com la sortida principal. Fes clic a la icona d'altaveu de la part dreta de la barra i s'obrirà la finestra emergent de volum on pots triar el dispositiu de sortida (i també barrejar volums per aplicació).

### Els altaveus del portàtil sonen estranys

En alguns portàtils, Omarchy aplica automàticament una sintonia d'altaveu que corregeix la resposta en freqüència dels altaveus integrats. `omarchy audio tuning status` et diu si n'hi ha una d'activa a la teva màquina, i `omarchy audio tuning off` la desactiva si prefereixes sentir els altaveus a pèl.

### Per què no puc iniciar sessió ni fer sudo amb la meva contrasenya?

Probablement l'has escrita malament massa vegades i t'ha bloquejat. Si això passa a la pantalla de bloqueig, pots prémer `CTRL + ALT + F2` per engegar una TTY nova on pots iniciar sessió com a root i després executar `faillock --reset --user [your-username]`. Això restablirà el bloqueig, i ja podràs continuar.

### Per què les sol·licituds d'autorització de 1Password per a l'agent SSH / la CLI de 1Password no apareixen?

Això pot passar per 2 motius:

Perquè aparegui la sol·licitud d'aprovació completa, cal que Settings > Advanced > Use Hardware Acceleration estigui activat. _Nota: això requereix un reinici per començar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

O bé, si no has posat en marxa 1Password des d'arrencar, la sol·licitud no apareixerà.
