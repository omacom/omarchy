# Preguntes freqüents

### Com puc alternar entre distribucions de teclat?

Edita el fitxer `~/.config/hypr/input.lua` i afegeix-hi això per alternar entre distribucions amb `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

La barra mostrarà automàticament la distribució de teclat actual un cop hagis configurat diverses distribucions (i també hi pots fer clic per canviar-la).

### Com puc canviar el format del rellotge a 12 hores?

Fes clic amb el botó dret al rellotge de la barra per recórrer els formats habituals, inclosos els de 12 hores. També pots definir el format directament:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Això mostrarà diumenge 10:55 AM.

### Com puc canviar la meva zona horària?

Executa _Setup > Region > Timezone_ al menú d'Omarchy i tria'n un de la llista. Si la zona horària és correcta però el rellotge s'ha desviat, _Update > Time_ reinicia la sincronització horària per tu.

### Com puc canviar el meu DNS, compartir el meu Wi-Fi o comprovar la velocitat de la meva connexió?

Tot això és a [xarxes](35-networking.md).

### Com puc comprovar com de ràpid és el meu disc?

_Trigger > Speed Test > Disk Speed Test_ mesura en directe la velocitat de lectura i escriptura de la teva unitat, o `omarchy disk speedtest` des del terminal.

### Com puc afegir una impressora?

La impressió ja està configurada i en marxa de sèrie, i afegeixes cada impressora tu mateix des de _Print Settings_ al llançador d'aplicacions (`Super + Alt + Space`).

Tria _Add_ i deixa-li un moment per cercar: una impressora connectada per USB, i la majoria d'impressores de xarxa, es troben per tu. Si la teva no és a la llista, tria _Network Printer > Internet Printing Protocol (ipp)_ i introdueix-ne l'adreça — la pantalla de la mateixa impressora o la seva pàgina web et diran quina és, normalment una cosa com `192.168.1.50` amb una cua de `ipp/print`. _Forward_ ofereix tot seguit un controlador, en què una impressora moderna funciona millor amb el perfil sense controlador _IPP Everywhere_ i una d'antiga vol el controlador propi del model.

Fes clic amb el botó dret en una impressora i tria _Set as Default_ per triar quina faran servir primer les teves aplicacions, i _Properties_ per definir la mida del paper, el dúplex i la qualitat.

La descoberta automàtica, per la qual les impressores de la xarxa apareixen sense haver-les d'afegir, està desactivada temporalment mentre es refà, i per això el primer pas anterior depèn de tu i no és automàtic. Imprimir a un fitxer PDF funciona sense cap impressora.

### Com puc canviar on es desen les captures de pantalla o els enregistraments de pantalla?

Les captures de pantalla desades van a `~/Pictures/Screenshots` per defecte. Per fer servir un altre directori, afegeix això a un fitxer dins de `~/.config/uwsm/env.d/` (com ara `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Pots fer el mateix per als enregistraments de pantalla amb `OMARCHY_SCREENRECORD_DIR`.

Omasnap crea el seu directori de captures de pantalla automàticament. Crea tu mateix el directori d'enregistraments de pantalla i després reinicia Omarchy perquè qualsevol dels dos canvis d'entorn tingui efecte.

### Com puc fer que funcionin els altaveus + la càmera web al meu Apple Studio Display?

Pensaries que tot hauria de funcionar només connectant l'USB C, però malauradament no és així. La solució que he trobat perquè funcioni de manera fiable és fer servir [el cable WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Llavors els altaveus i la càmera web funcionen de meravella.

Recorda que tens control de brillantor integrat a Omarchy per als Apple Displays (tant Studio com XDR) amb els botons normals de brillantor del teclat.

### Com puc desfer-me de tot el programari extra?

Si no vols programes com Obsidian o LibreOffice o cap de la resta de coses preinstal·lades, pots eliminar-ho molt fàcilment.

Executa _Remove > Package_ per veure tots els paquets instal·lats. Llavors pots seleccionar qualsevol paquet que vulguis eliminar amb tab, i començar a eliminar tot el que hagis seleccionat amb return.

I pots fer servir _Remove > Web App_ des del menú d'Omarchy per eliminar qualsevol de les aplicacions web preinstal·lades que no vulguis.

O executa _Remove > Preinstalls_ per escombrar tots els extres preinstal·lats — aplicacions web, TUIs i aplicacions opcionals — d'un sol cop. Les tecles d'accés ràpid que les engegaven desapareixen amb elles, així que et queda una pissarra neta de dreceres per omplir amb les teves a `~/.config/hypr/bindings.lua`.

---

Per a errors i coses que no funcionen, consulta [la secció de resolució de problemes](45-troubleshooting.md).
