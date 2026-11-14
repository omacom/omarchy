# Resolució de problemes

### He trencat el sistema amb una actualització!

Primer prova de [restaurar el sistema](47-system-snapshots.md) a la versió anterior a l'actualització recent. Si això no funciona, fes servir `omarchy-debug` per compartir el problema a #omarchy-help del Discord. I si tot això falla, pots reinstal·lar les configuracions i els paquets per defecte amb `omarchy-reinstall`.

### Per què algunes aplicacions es veuen tan grans a la pantalla?

Omarchy assumeix una pantalla d'alta resolució 2x, així que estableix `GDK_SCALE` a 2 fins que triïs una escala al panell del monitor. Si ets en una pantalla 1x i les aplicacions GTK o X11 surten sobredimensionades, tria 1x per a ella al panell del monitor, o afegeix `hl.env("GDK_SCALE", "1")` a `~/.config/hypr/monitors.lua` (i després reinicia qualsevol aplicació que es vegi sobredimensionada). Consulta [el manual sobre monitors](33-monitors.md).

Per a Spotify, pots fer servir `Ctrl + Minus` per reduir la interfície (i `Ctrl + Plus` per fer-la més gran).

### Per què han deixat de funcionar totes les dreceres amb Super?

En alguns portàtils ASUS ROG i TUF, `Fn + Super` és una combinació fàcil de passar per alt que activa o desactiva un bloqueig de la tecla Windows del firmware (pensat per jugar, perquè no surtis d'un joc per accident). Res a la pantalla t'indica que ha passat. Mentre el bloqueig està activat, Super no emet absolutament res — així que totes les dreceres d'Omarchy que fan servir Super simplement s'aturen, i sembla que Hyprland s'hagi trencat.

Prem `Fn + Super` una vegada abans de remenar a `~/.config/hypr/`, i si això no fa tornar Super, prem-la una altra vegada per no deixar el bloqueig activat. Això no és el Fn-lock, que només canvia el que fa la fila de tecles F.

### El Wi-Fi, el Bluetooth, l'àudio o el trackpad m'han deixat de funcionar de cop

Abans de reiniciar, prova de reiniciar per separat el subsistema que falla. _Update > Hardware_ al menú d'Omarchy té Wi-Fi, Bluetooth, Audio i Trackpad, i recarregar-ne un resol la majoria de situacions de «funcionava fa cinc minuts» — uns auriculars Bluetooth que no es tornen a connectar, un trackpad que ha quedat mort després d'una suspensió, un so que ha desaparegut quan has desconnectat un monitor.

### Per què no sonen els altaveus externs?

Probablement perquè no estan establerts com a sortida principal. Fes clic a la icona de l'altaveu a la part dreta de la barra i s'obrirà la finestra emergent de volum, on pots triar el dispositiu de sortida (i també barrejar els volums per aplicació).

### Els altaveus del portàtil sonen malament

En alguns portàtils, Omarchy aplica automàticament un ajust d'altaveus que corregeix la resposta en freqüència dels altaveus integrats. `omarchy audio tuning status` et diu si n'hi ha un d'actiu a la teva màquina, i `omarchy audio tuning off` el desactiva si prefereixes sentir els altaveus en brut.

### Per què no puc iniciar sessió ni fer sudo amb la contrasenya?

Probablement l'has escrit malament massa vegades i t'has quedat bloquejat. Si això passa a la pantalla de bloqueig, pots prémer `CTRL + ALT + F2` per iniciar una nova TTY on pots iniciar sessió com a root i després executar `faillock --reset --user [your-username]`. Això restablirà el bloqueig i ja estaràs llest.

### La contrasenya s'accepta, però torno a la pantalla d'inici de sessió

Un fitxer d'entorn de sessió trencat pot impedir que l'escriptori s'iniciï encara que la contrasenya sigui correcta. Val especialment la pena comprovar-ho després d'editar `~/.config/uwsm/env.d/`.

Prem `Ctrl + Alt + F2`, inicia sessió amb el teu nom d'usuari i la contrasenya habituals i inspecciona el diari d'usuari de l'arrencada actual:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Cerca un error que anomeni un dels teus fitxers d'entorn, com ara `bad substitution`, just abans d'un missatge que digui que no s'ha trobat la marca de sortida de l'entorn. Mou aquest fitxer fora d'`env.d` abans de tornar a provar d'iniciar sessió. Per exemple, si l'error anomena `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM omet un fitxer amb un error de sintaxi, però un error fatal que només apareix mentre el fitxer s'executa, com `bad substitution`, encara pot impedir que l'escriptori s'iniciï. Una restauració a una instantània del sistema no repara aquests fitxers, perquè `/home` no es restaura.

Un cop puguis iniciar sessió, corregeix la còpia desada abans de tornar-la a moure. `sh -n` detecta els errors de sintaxi sense executar el fitxer, però no pot detectar tots els errors que es produeixen quan se'n fa source. Mantén obert un terminal que funcioni mentre proves els canvis.

### Per què no apareixen les sol·licituds d'autorització de 1Password per a 1Password SSH Agent / CLI?

Això pot passar per 2 motius:

Perquè aparegui la sol·licitud d'aprovació completa, Settings > Advanced > Use Hardware Acceleration ha d'estar activat. _Nota: Això requereix un reinici per començar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

O, si no has obert 1Password des que has engegat la màquina, la sol·licitud no apareixerà.
