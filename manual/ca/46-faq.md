# PMF

### Com canvio entre disposicions de teclat?

Edita el fitxer `~/.config/hypr/input.lua` i afegeix-hi això per canviar entre disposicions amb `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

La barra mostrarà automàticament la teva disposició de teclat actual un cop tinguis múltiples disposicions configurades (i també pots clicar-la per canviar).

### Com canvio el format del rellotge a 12 hores?

Fes clic amb el botó dret al rellotge de la barra per anar passant pels formats habituals, inclosos els de 12 hores. També pots definir el format directament:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Això mostrarà Sunday 10:55 AM.

### Com canvio la zona horària?

Executa _Actualitza > Zona horària_ al menú d'Omarchy i tria de la llista. Si la zona horària és correcta però el rellotge mateix s'ha desviat, _Actualitza > Hora_ reinicia la sincronització horària per tu.

### Com canvio el DNS, comparteixo la Wi-Fi o comprovo la velocitat de la connexió?

Tot això viu a [xarxa](35-networking.md).

### Com comprovo a quina velocitat va el meu disc?

_Activa > Prova de velocitat > Prova de velocitat de disc_ mesura la velocitat de lectura i escriptura en directe de la teva unitat, o `omarchy disk speedtest` des del terminal.

### Per què no puc iniciar sessió al meu compte de Google a Chromium?

La versió de codi obert i a pèl de Chromium no ve amb les credencials OAuth que Google requereix per iniciar sessió en un compte. Executa _Instal·la > Servei > Chromium Account_ al menú d'Omarchy per afegir-les, reinicia el navegador i l'inici de sessió funcionarà.

### Com afegeixo una impressora?

La impressió ja està configurada i en funcionament des del primer moment, i cada impressora l'afegeixes tu mateix des de _Print Settings_ al llançador d'aplicacions (`Super + Space`).

Tria _Add_ i dona-li un moment per mirar: una impressora connectada per USB, i la majoria d'impressores de xarxa, es troben per tu. Si la teva no és a la llista, tria _Network Printer > Internet Printing Protocol (ipp)_ i introdueix-ne l'adreça: la pantalla de la mateixa impressora o la seva pàgina web et diran quina és, normalment alguna cosa com `192.168.1.50` amb una cua d'`ipp/print`. _Forward_ ofereix aleshores un controlador, on una impressora moderna funciona millor amb el perfil _IPP Everywhere_ sense controladors i una de més antiga vol el controlador propi del model.

Fes clic amb el botó dret a una impressora i tria _Set as Default_ per triar a quina van a parar primer les teves aplicacions, i _Properties_ per definir la mida del paper, el dúplex i la qualitat.

El descobriment automàtic, on les impressores de la xarxa apareixen sense haver-les d'afegir, està temporalment desactivat mentre es reelabora, i per això el primer pas anterior és cosa teva més que no pas automàtic. Imprimir a un fitxer PDF funciona sense cap impressora.

### Com canvio on es desen les captures de pantalla o els enregistraments de pantalla?

Les captures de pantalla desades van a `~/Pictures/Screenshots` per defecte. Per fer servir un altre directori, afegeix això a un fitxer de `~/.config/uwsm/env.d/` (com ara `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Pots fer el mateix per als enregistraments de pantalla fent servir `OMARCHY_SCREENRECORD_DIR`.

Omasnap crea automàticament el seu directori de captures de pantalla. Crea tu mateix el directori d'enregistrament de pantalla i després reinicia Omarchy perquè qualsevol dels dos canvis d'entorn tingui efecte.

### Com faig funcionar els altaveus i la càmera web de l'Apple Studio Display?

Et pensaries que tot hauria de funcionar només connectant l'USB C, però malauradament no és el cas. La solució que he trobat perquè funcioni de manera fiable és fer servir [el cable WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Aleshores els altaveus i la càmera web funcionen com un encant.

Recorda que a Omarchy tens control de brillantor integrat per a les pantalles Apple (tant la Studio com la XDR) fent servir els botons de brillantor habituals del teclat.

### Com em desfaig de tot el programari extra?

Si no vols programes com Obsidian o LibreOffice o qualsevol altra cosa preinstal·lada, pots eliminar-la molt fàcilment.

Executa _Elimina > Paquet_ per veure tots els paquets que hi ha instal·lats. Aleshores pots seleccionar amb el tabulador qualsevol paquet que vulguis eliminar i començar a eliminar tot el que hagis seleccionat amb retorn.

I pots fer servir _Elimina > Aplicació web_ des del menú d'Omarchy per eliminar qualsevol de les aplicacions web preinstal·lades que no vulguis.

O bé executa _Elimina > Preinstal·la_ per escombrar totes les extres preinstal·lades —aplicacions web, TUIs i aplicacions opcionals— d'una sola passada. Les dreceres que les engegaven se'n van amb elles, de manera que et quedarà una pissarra neta d'enllaços per omplir amb els teus a `~/.config/hypr/bindings.lua`.

---

Per a errors i coses trencades, consulta [la secció de resolució de problemes](45-troubleshooting.md).
