# Extracció de text i dictat

### Extracció de text

Prem `Super + Ctrl + PrtScr` per seleccionar una regió de la pantalla per extreure'n el text. El model OCR de codi obert tesseract convertirà ràpidament aquesta selecció en text i el col·locarà al porta-retalls. Després només has de prémer `Super + V` per enganxar.

Això és molt útil per capturar adreces dels peus d'imatge o números de telèfon incrustats en titulars de llocs web.

 ![text-extraction](images/text-extraction.webp)

### Dictat

En les instal·lacions noves, [Superwhisper](https://superwhisper.com/) és el motor de dictat predeterminat, amb processament al núvol sense descàrregues de models fora de línia. Tria Superwhisper, [Voxtype](https://voxtype.io/) o [Hex](https://anoma.ly/hex/) a través de _Setup > Defaults > Dictation_ al menú d'Omarchy. En seleccionar un motor, s'instal·la si cal i esdevé el predeterminat per al dictat. Voxtype carrega un model base en anglès que ocupa 150MB; canvia el model amb `voxtype setup model` i altres paràmetres a través de `~/.config/voxtype/config.toml`. Superwhisper obre els seus paràmetres per triar entre processament al núvol o local, i OPR manté l'aplicació actualitzada. Hex descarrega el seu model de veu al dispositiu durant la configuració i s'executa com a servei d'usuari `hex.service`; obre la seva finestra des de la icona de la safata de la barra o executant `hex` per canviar el model i altres paràmetres.

Dictes mantenint premut `Right Alt`, o activant-lo i desactivant-lo amb `Alt + Space`, i el text dictat apareixerà a l'àrea d'entrada que tingui el focus. Aquestes dreceres fan servir el motor seleccionat. Right Alt també inicia el dictat quan es fa servir en una combinació amb modificadors; fes servir Left Alt per a aquestes combinacions. En les distribucions de teclat en què Right Alt és AltGr, fes servir `Alt + Space` per mantenir AltGr disponible per escriure. Les instal·lacions anteriors a quan Alt + Space va esdevenir l'opció predeterminada mantenen `F9` per prémer per parlar i `Super + Ctrl + X` per activar i desactivar, afegits a `~/.config/hypr/bindings.lua`, on aquest `Super + Ctrl + X` ocupa el lloc del tauler d'agents; elimina'ls allà per tornar aquestes tecles a les aplicacions i al tauler.

Les mateixes dreceres funcionen amb tots els motors. Selecciona el teu motor a través de Setup > Defaults > Dictation. L'instal·lador del motor el configura i desa la selecció. Executa `omarchy default dictation` per veure quin està seleccionat. La selecció es desa a `~/.config/omarchy/defaults/dictation`. Les instal·lacions noves seleccionen Superwhisper automàticament.

Omarchy carrega automàticament la integració d'escriptori del motor seleccionat. No cal cap configuració de Superwhisper a `~/.config/hypr/`.

Les assignacions i els scripts personalitzats poden fer servir `omarchy dictation start`, `omarchy dictation stop` i `omarchy dictation toggle`. El motor seleccionat s'encarrega de l'enregistrament i la transcripció. En seleccionar Superwhisper, es desactiva la seva drecera nativa de mantenir premut i la seva activació nativa es defineix com a `Ctrl + Alt + Space`, separada de les tecles d'enregistrament d'Omarchy. Superwhisper requereix almenys una drecera nativa d'enregistrament, i la seva drecera de cancel·lació es manté disponible.

Es poden integrar motors addicionals sense canviar Omarchy. Proporciona un executable anomenat `omarchy-dictation-<backend>` a PATH que accepti `start`, `stop` i `toggle` i respongui ràpidament, amb un estat diferent de zero en cas d'error. El seu instal·lador configura el proveïdor i crida `omarchy-dictation-use <backend>` després d'una configuració correcta. Això atura el motor anterior i desa la selecció de manera atòmica; `stop` ha de tenir èxit quan el proveïdor està inactiu o no està disponible. Els noms dels motors fan servir lletres minúscules, dígits i guionets. Proporciona `omarchy-install-dictation-<backend>` per a la configuració; `omarchy default dictation <backend>` l'inicia. Afegeix una entrada al menú Defaults a través d'una extensió del menú d'Omarchy per cridar aquest selector. La integració d'escriptori opcional pot residir a `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
