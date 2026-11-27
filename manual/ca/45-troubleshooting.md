# Resolució de problemes

### He trencat el meu sistema amb una actualització!

Primer, prova de [revertir el teu sistema](47-system-snapshots.md) a la versió anterior a la teva actualització recent. Si això no funciona, utilitza `omarchy-debug` per compartir el teu problema a #omarchy-help al Discord. I si tot això falla, pots reinstal·lar les configuracions i els paquets per defecte amb `omarchy-reinstall`.

### Per què algunes aplicacions es veuen tan grans a la meva pantalla?

Omarchy assumeix que tens una pantalla d'alta resolució 2x, així que estableix `GDK_SCALE` a 2 fins que triïs una escala al panell del monitor. Si tens una pantalla 1x i les aplicacions GTK o X11 es veuen sobredimensionades, tria 1x per a ella al panell del monitor, o afegeix `hl.env("GDK_SCALE", "1")` a `~/.config/hypr/monitors.lua` (i després reinicia qualsevol aplicació que es vegi sobredimensionada). Consulta [el manual sobre monitors](33-monitors.md).

Per a Spotify, pots utilitzar `Ctrl + Minus` per reduir la interfície (i `Ctrl + Plus` per fer-la més gran).

### Per què han deixat de funcionar totes les meves dreceres amb la tecla Super?

En alguns portàtils ASUS ROG i TUF, `Fn + Super` és una combinació fàcil de passar per alt que activa o desactiva un bloqueig de la tecla Windows del firmware (pensat per jugar perquè no surtis d'un joc per accident). Res a la pantalla t'indica que ha passat. Mentre el bloqueig està activat, Super no emet absolutament res — així que totes les dreceres d'Omarchy que utilitzen Super simplement deixen de funcionar, i sembla que Hyprland s'hagi trencat.

Prem `Fn + Super` una vegada abans de remenar a `~/.config/hypr/`, i si això no fa que Super torni, prem-la una altra vegada perquè no deixis el bloqueig activat. Això no és el Fn-lock, que només canvia què fa la fila de tecles F.

### El meu Wi-Fi, Bluetooth, àudio o trackpad acaba de deixar de funcionar

Abans de reiniciar, prova de reiniciar per separat el subsistema que falla. _Update > Hardware_ al menú d'Omarchy té Wi-Fi, Bluetooth, Audio, i Trackpad, i recarregar-ne un resol la majoria de situacions de "funcionava fa cinc minuts" — uns auriculars Bluetooth que no es volen reconnectar, un trackpad que va deixar de funcionar després d'una suspensió, un so que va desaparèixer quan vas desconnectar un monitor.

### Per què no sonen els meus altaveus externs?

Probablement perquè no estan establerts com a sortida principal. Fes clic a la icona de l'altaveu a la part dreta de la barra, i s'obrirà la finestra emergent de volum on pots triar el dispositiu de sortida (i també barrejar els volums per aplicació).

### Els altaveus del meu portàtil sonen malament

En alguns portàtils, Omarchy aplica automàticament un ajust d'altaveus que corregeix la resposta en freqüència dels altaveus integrats. `omarchy audio tuning status` et diu si n'hi ha un d'actiu a la teva màquina, i `omarchy audio tuning off` el desactiva si prefereixes sentir els altaveus sense processar.

### Per què no puc iniciar sessió ni fer sudo amb la meva contrasenya?

Probablement l'has escrit malament deu vegades i t'han bloquejat. El bloqueig es desbloqueja sol al cap de dos minuts. Si no pots esperar, i això està passant a la pantalla de bloqueig, pots prémer `CTRL + ALT + F2` per iniciar un nou TTY on pots iniciar sessió com a root, i després executar `faillock --reset --user [your-username]`. Això restablirà el bloqueig, i ja podràs continuar.

### La meva contrasenya és acceptada, però torno a la pantalla d'inici de sessió

Un fitxer d'entorn de sessió fet malbé pot impedir que l'escriptori s'iniciï fins i tot quan la teva contrasenya és correcta. Això val especialment la pena comprovar-ho després d'editar `~/.config/uwsm/env.d/`.

Prem `Ctrl + Alt + F2`, inicia sessió amb el teu nom d'usuari i contrasenya habituals, i inspecciona el journal d'usuari de l'arrencada actual:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Cerca un error que esmenti un dels teus fitxers d'entorn, com ara `bad substitution`, just abans d'un missatge que digui que no s'ha trobat la marca de sortida de l'entorn. Mou aquest fitxer fora d'`env.d` abans de tornar a provar d'iniciar sessió. Per exemple, si l'error esmenta `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM omet un fitxer amb un error de sintaxi, però un error fatal que només apareix mentre el fitxer s'executa, com `bad substitution`, encara pot impedir que l'escriptori s'iniciï. Una reversió a una instantània del sistema no repara aquests fitxers, perquè `/home` no es reverteix.

Un cop puguis iniciar sessió, corregeix la còpia desada abans de tornar-la a moure al seu lloc. `sh -n` detecta errors de sintaxi sense executar el fitxer, però no pot detectar tots els errors que es produeixen quan es carrega. Mantén obert un terminal que funcioni mentre proves els canvis.

### Per què no apareixen les meves sol·licituds d'autorització d'1Password per a 1Password SSH Agent / CLI?

Això pot passar per 2 motius:

Perquè aparegui la sol·licitud d'aprovació completa, cal que Settings > Advanced > Use Hardware Acceleration estigui activat. _Nota: Això requereix un reinici per començar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

O si no has obert 1Password des que has arrencat, la sol·licitud no apareixerà.
