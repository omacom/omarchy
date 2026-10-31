# Extracció de text i dictat

### Extracció de text

Premeu `Super + Ctrl + PrtScr` per seleccionar una regió de la pantalla per a l'extracció de text. El model OCR de codi obert tesseract convertirà ràpidament aquesta selecció en text i la col·locarà al porta-retalls. Després només heu de prémer `Super + V` per enganxar-ho.

Això és molt útil per agafar adreces de peus d'imatge o números de telèfon integrats en titulars de llocs web.

 ![text-extraction](images/text-extraction.webp)

### Dictat

En instal·lacions noves, [Superwhisper](https://superwhisper.com/) és el motor de dictat per defecte, amb processament al núvol sense baixades de models fora de línia. Trieu Superwhisper o [Voxtype](https://voxtype.io/) a _Configuració > Per defecte > Dictat_ al menú d'Omarchy. Seleccionar un motor l'instal·la si cal i el converteix en el predeterminat per al dictat. Voxtype carrega un model base d'anglès que ocupa 150 MB; canvieu el model amb `voxtype setup model` i altres paràmetres a `~/.config/voxtype/config.toml`. Superwhisper obre la seva configuració per triar processament al núvol o local, i OPR manté l'aplicació actualitzada.

Dicteu mantenint premuda `Right Alt` o `F9`, o commutant amb `Super + Ctrl + X`, i el text dictat apareixerà a l'àrea d'entrada enfocada. Aquestes dreceres fan servir el motor seleccionat. Right Alt també inicia el dictat quan es fa servir en un acord de modificadors; feu servir Left Alt per a aquests acords. En disposicions de teclat on Right Alt és AltGr, feu servir `F9` perquè AltGr continuï disponible per escriure.

Les mateixes dreceres funcionen amb qualsevol dels dos motors. Seleccioneu el vostre motor a Configuració > Per defecte > Dictat. L'instal·lador del motor el configura i desa la selecció. Executeu `omarchy default dictation` per veure quin està seleccionat. La selecció es desa a `~/.config/omarchy/defaults/dictation`. Les instal·lacions noves seleccionen Superwhisper automàticament.

Omarchy carrega automàticament la integració d'escriptori del motor seleccionat. No cal cap configuració de Superwhisper a `~/.config/hypr/`.

Les assignacions i els scripts personalitzats poden fer servir `omarchy dictation start`, `omarchy dictation stop` i `omarchy dictation toggle`. El motor seleccionat gestiona la gravació i la transcripció. Seleccionar Superwhisper desactiva la seva drecera nativa de mantenir premut i defineix el seu commutador natiu a `Alt + Space`, mantenint-lo separat de les tecles de gravació d'Omarchy. Superwhisper requereix com a mínim una drecera nativa de gravació, i la seva drecera de cancel·lació continua disponible.

Motors addicionals es poden integrar sense canviar Omarchy. Proporcioneu un executable anomenat `omarchy-dictation-<backend>` al PATH que accepti `start`, `stop` i `toggle` i retorni ràpidament, amb un estat diferent de zero en cas d'error. El seu instal·lador configura el proveïdor i crida `omarchy-dictation-use <backend>` després d'una configuració correcta. Això atura el motor anterior i desa la selecció atòmicament; `stop` ha de tenir èxit quan el proveïdor està inactiu o no disponible. Els noms dels motors fan servir lletres minúscules, dígits i guions. Proporcioneu `omarchy-install-dictation-<backend>` per a la configuració; `omarchy default dictation <backend>` el llança. Afegiu una entrada al menú Per defecte mitjançant una extensió del menú d'Omarchy per cridar aquest selector. La integració d'escriptori opcional pot viure a `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
