# Extracció de text i dictat

### Extracció de text

Prem `Super + Ctrl + PrtScr` per seleccionar una regió de la pantalla per a l'extracció de text. El model OCR de codi obert tesseract convertirà ràpidament aquesta selecció en text i la col·locarà al porta-retalls. Després només has de prémer `Super + V` per enganxar.

Això és molt útil per extreure adreces de peus d'imatge o números de telèfon incrustats en titulars de llocs web.

 ![text-extraction](images/text-extraction.webp)

### Dictat

En instal·lacions noves, [Superwhisper](https://superwhisper.com/) és el backend de dictat per defecte, que utilitza processament al núvol sense descàrregues de models fora de línia. Tria Superwhisper, [Voxtype](https://voxtype.io/) o [Hex](https://anoma.ly/hex/) a través de _Setup > Defaults > Dictation_ al menú d'Omarchy. En seleccionar un backend, s'instal·la si cal i esdevé el predeterminat per al dictat. Voxtype carrega un model base en anglès que ocupa 150MB; canvia el model amb `voxtype setup model` i altres ajustos a través de `~/.config/voxtype/config.toml`. Superwhisper obre els seus ajustos per triar el processament al núvol o local, i OPR manté l'aplicació actualitzada. Hex descarrega el seu model de veu en el dispositiu durant la configuració i s'executa com a servei d'usuari `hex.service`; obre la seva finestra des de la icona de la safata de la barra o executant `hex` per canviar el model i altres ajustos.

Dictes mantenint premuda `Right Alt`, o activant i desactivant amb `Alt + Space`, i el text dictat apareixerà a l'àrea d'entrada amb el focus. Aquestes dreceres utilitzen el backend seleccionat. Right Alt també inicia el dictat quan s'utilitza en una combinació amb modificador; utilitza Left Alt per a aquestes combinacions. En distribucions de teclat on Right Alt és AltGr, inclòs quan una distribució així és una a la qual canvies, mantén-lo premut tot sol un moment per dictar; AltGr premut juntament amb una altra tecla continua escrivint el seu caràcter. Les instal·lacions anteriors a quan Alt + Space va esdevenir el predeterminat conserven `F9` per a prémer per parlar i `Super + Ctrl + X` per activar i desactivar, afegits a `~/.config/hypr/bindings.lua`, on aquest `Super + Ctrl + X` ocupa el lloc del panell d'agents; elimina'ls allà per retornar aquestes tecles a les aplicacions i al panell.

Les mateixes dreceres funcionen amb tots els backends. Selecciona el teu backend a través de Setup > Defaults > Dictation. L'instal·lador del backend el configura i desa la selecció. Executa `omarchy default dictation` per veure quin està seleccionat. La selecció es desa a `~/.config/omarchy/defaults/dictation`. Les instal·lacions noves seleccionen Superwhisper automàticament.

Omarchy carrega automàticament la integració d'escriptori del backend seleccionat. No cal cap configuració de Superwhisper a `~/.config/hypr/`.

Els enllaços personalitzats i els scripts poden utilitzar `omarchy dictation start`, `omarchy dictation stop` i `omarchy dictation toggle`. El backend seleccionat s'encarrega de la gravació i la transcripció. En seleccionar Superwhisper es desactiva la seva drecera nativa de mantenir premut i s'estableix la seva activació i desactivació nativa a `Ctrl + Alt + Space`, de manera que queda separada de les tecles de gravació d'Omarchy. Superwhisper requereix com a mínim una drecera nativa de gravació, i la seva drecera de cancel·lació continua disponible.

Es poden integrar backends addicionals sense modificar Omarchy. Proporciona un executable anomenat `omarchy-dictation-<backend>` a PATH que accepti `start`, `stop` i `toggle` i que retorni immediatament, amb un estat no zero en cas d'error. El seu instal·lador configura el proveïdor i crida `omarchy-dictation-use <backend>` després d'una configuració correcta. Això atura el backend anterior i desa la selecció de manera atòmica; `stop` ha de tenir èxit quan el proveïdor està inactiu o no disponible. Els noms de backend utilitzen lletres minúscules, dígits i guionets. Proporciona `omarchy-install-dictation-<backend>` per a la configuració; `omarchy default dictation <backend>` l'inicia. Afegeix una entrada al menú Defaults a través d'una extensió del menú d'Omarchy per cridar aquest selector. La integració d'escriptori opcional pot residir a `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
