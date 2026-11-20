# Preguntes freqüents

### Com puc canviar entre distribucions de teclat?

Edita el fitxer `~/.config/hypr/input.lua` i afegeix-hi això per canviar entre distribucions amb `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

La barra mostrarà automàticament la distribució de teclat actual un cop tinguis diverses distribucions configurades (i també hi pots fer clic per canviar).

### Com puc canviar el format del rellotge a 12 hores?

Fes clic amb el botó dret al rellotge de la barra per recórrer els formats habituals, inclosos els de 12 hores. També pots definir el format directament:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Això mostrarà Diumenge 10:55 AM.

### Com puc canviar la meva zona horària?

Executa _Setup > Region > Timezone_ al menú d'Omarchy i tria de la llista. Si la zona horària és correcta però el rellotge en si s'ha desfasat, _Update > Time_ reinicia la sincronització de l'hora per tu.

### Com puc canviar el meu DNS, compartir el meu Wi-Fi o comprovar la velocitat de la meva connexió?

Tot això és a [xarxes](35-networking.md).

### Com puc comprovar com de ràpid és el meu disc?

_Trigger > Speed Test > Disk Speed Test_ mesura la velocitat de lectura i escriptura en directe de la teva unitat, o `omarchy disk speedtest` des del terminal.

### Com puc afegir una impressora?

La impressió està configurada i funciona des del primer moment, i afegeixes cada impressora tu mateix des de _Print Settings_ a l'iniciador d'aplicacions (`Super + Space`).

Tria _Add_ i dona-li un moment per buscar: una impressora connectada per USB, i la majoria d'impressores de xarxa, es troben per tu. Si la teva no apareix a la llista, tria _Network Printer > Internet Printing Protocol (ipp)_ i introdueix-ne l'adreça — la pantalla de la mateixa impressora o la seva pàgina web et dirà quina és, normalment una cosa com `192.168.1.50` amb una cua de `ipp/print`. Després, _Forward_ ofereix un controlador, on una impressora moderna funciona millor amb el perfil sense controlador _IPP Everywhere_ i una de més antiga vol el controlador propi del model.

Fes clic amb el botó dret en una impressora i tria _Set as Default_ per triar quina fan servir primer les teves aplicacions, i _Properties_ per definir la mida del paper, el dúplex i la qualitat.

La descoberta automàtica, on les impressores de la xarxa apareixen sense afegir-les, està desactivada temporalment mentre es refà, i per això el primer pas anterior depèn de tu i no és automàtic. Imprimir en un fitxer PDF funciona sense cap impressora.

### Com puc canviar on es desen les captures de pantalla o les gravacions de pantalla?

Les captures de pantalla desades van a `~/Pictures/Screenshots` per defecte. Per utilitzar un altre directori, afegeix això a un fitxer dins de `~/.config/uwsm/env.d/` (com `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Pots fer el mateix per a les gravacions de pantalla amb `OMARCHY_SCREENRECORD_DIR`.

Omasnap crea automàticament el seu directori de captures de pantalla. Crea tu mateix el directori de gravacions de pantalla i després reinicia Omarchy perquè qualsevol dels dos canvis d'entorn tingui efecte.

### Com puc fer que funcionin els altaveus + la càmera web al meu Apple Studio Display?

Et pensaries que tot hauria de funcionar només connectant l'USB C, però malauradament no és així. La solució que he trobat perquè funcioni de manera fiable és utilitzar [el cable WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Aleshores els altaveus i la càmera web funcionen de meravella.

Recorda que tens control de brillantor integrat a Omarchy per als Apple Displays (tant l'Studio com l'XDR) amb els botons habituals de brillantor del teclat.

### Com puc desfer-me de tot el programari extra?

Si no vols programes com Obsidian o LibreOffice ni cap de la resta de coses preinstal·lades, els pots eliminar molt fàcilment.

Executa _Remove > Package_ per veure tots els paquets instal·lats. Aleshores pots seleccionar amb tab qualsevol paquet que vulguis eliminar i començar a eliminar tot el que hagis seleccionat amb return.

I pots utilitzar _Remove > Web App_ des del menú d'Omarchy per eliminar qualsevol de les aplicacions web preinstal·lades que no vulguis.

O executa _Remove > Preinstalls_ per escombrar tots els extres preinstal·lats — aplicacions web, TUI i aplicacions opcionals — d'una sola vegada. Les dreceres de teclat que les obrien desapareixen amb elles, de manera que et quedes amb una pissarra neta d'assignacions per omplir amb les teves a `~/.config/hypr/bindings.lua`.

---

Per a errors i coses trencades, vegeu [la secció de resolució de problemes](45-troubleshooting.md).
