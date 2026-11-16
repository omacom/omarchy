# FAQ

### Com puc canviar entre distribucions de teclat?

Edita el teu fitxer `~/.config/hypr/input.lua` i afegeix-hi això per canviar entre distribucions amb `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

La barra mostrarà automàticament la teva distribució de teclat actual tan bon punt en tinguis diverses de configurades (i també hi pots fer clic per canviar-la).

### Com puc canviar el format del rellotge a 12 hores?

Fes clic amb el botó dret al rellotge de la barra per anar passant pels formats habituals, inclosos els de 12 hores. També pots configurar el format directament:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Això mostrarà Diumenge 10:55 AM.

### Com puc canviar la meva zona horària?

Executa _Actualitza > Zona horària_ al menú d'Omarchy i tria'n una de la llista. Si la zona horària és correcta però el rellotge s'ha desviat, _Actualitza > Hora_ reinicia la sincronització de l'hora per tu.

### Com puc canviar el meu DNS, compartir el meu Wi-Fi o comprovar la velocitat de la meva connexió?

Tot això ho trobaràs a [xarxes](35-networking.md).

### Com puc comprovar com de ràpid és el meu disc?

_Activa > Prova de velocitat > Prova de velocitat del disc_ mesura en directe la velocitat de lectura i escriptura de la teva unitat, o `omarchy disk speedtest` des del terminal.

### Com puc afegir una impressora?

La impressió ja està configurada i funciona des del primer moment, i cada impressora l'afegeixes tu mateix des de _Configuració d'impressió_ al llançador d'aplicacions (`Super + Space`).

Tria _Afegeix_ i dona-li un moment perquè cerqui: una impressora connectada per USB, i la majoria d'impressores de xarxa, es troben automàticament. Si la teva no apareix a la llista, tria _Impressora de xarxa > Internet Printing Protocol (ipp)_ i introdueix-ne l'adreça — la pantalla de la mateixa impressora o la seva pàgina web et diran quina és, normalment alguna cosa com `192.168.1.50` amb una cua `ipp/print`. Llavors _Endavant_ t'ofereix un controlador, on una impressora moderna funciona millor amb el perfil sense controlador _IPP Everywhere_ i una de més antiga vol el controlador propi del model.

Fes clic amb el botó dret en una impressora i tria _Estableix com a predeterminada_ per triar quina faran servir primer les teves aplicacions, i _Propietats_ per configurar la mida del paper, la impressió a doble cara i la qualitat.

La descoberta automàtica, amb la qual les impressores de la xarxa apareixen sense haver-les d'afegir, està desactivada temporalment mentre es refà, i per això el primer pas anterior l'has de fer tu en lloc de ser automàtic. Imprimir a un fitxer PDF funciona sense cap impressora.

### Com puc canviar on es desen les captures de pantalla o els enregistraments de pantalla?

Les captures de pantalla desades van a `~/Pictures/Screenshots` per defecte. Per fer servir un altre directori, afegeix això a un fitxer dins de `~/.config/uwsm/env.d/` (com ara `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Pots fer el mateix amb els enregistraments de pantalla fent servir `OMARCHY_SCREENRECORD_DIR`.

Omasnap crea el seu directori de captures de pantalla automàticament. Crea tu mateix el directori d'enregistraments de pantalla i després reinicia Omarchy perquè qualsevol dels dos canvis d'entorn tingui efecte.

### Com faig que funcionin els altaveus + la càmera web al meu Apple Studio Display?

Pensaries que tot hauria de funcionar només connectant l'USB C, però malauradament no és així. La solució que he trobat perquè funcioni de manera fiable és fer servir [the WJESOG DisplayPort + USB-A => USB-C cable](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Llavors els altaveus i la càmera web funcionen de meravella.

Recorda que tens control de brillantor integrat a Omarchy per als Apple Displays (tant l'Studio com l'XDR) amb els botons normals de brillantor del teclat.

### Com em desfaig de tot el programari extra?

Si no vols programes com Obsidian o LibreOffice ni cap de la resta de coses preinstal·lades, pots eliminar-ho molt fàcilment.

Executa _Elimina > Paquet_ per veure tots els paquets instal·lats. Llavors pots seleccionar qualsevol paquet que vulguis eliminar amb tab, i començar a eliminar tot el que hagis seleccionat amb return.

I pots fer servir _Elimina > Aplicació web_ des del menú d'Omarchy per eliminar qualsevol de les aplicacions web preinstal·lades que no vulguis.

O executa _Elimina > Preinstal·lats_ per escombrar tots els extres preinstal·lats — aplicacions web, TUIs i aplicacions opcionals — d'una sola vegada. Les tecles d'accés ràpid que les obrien desapareixen amb elles, així que et queda una pissarra neta de dreceres per omplir amb les teves a `~/.config/hypr/bindings.lua`.

---

Per a errors i coses trencades, consulta [la secció de resolució de problemes](45-troubleshooting.md).
