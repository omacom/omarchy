# Extracció de text i dictat

### Extracció de text

Prem `Super + Ctrl + PrtScr` per seleccionar una regió de la pantalla per a l'extracció de text. A continuació, el model OCR de codi obert tesseract convertirà ràpidament aquesta selecció en text i la col·locarà al porta-retalls. Després només has de prémer `Super + V` per enganxar.

Això és molt útil per capturar adreces dels peus de pàgina d'imatges o números de telèfon incrustats en titulars de llocs web.

 ![text-extraction](images/text-extraction.webp)

### Dictat

En instal·lacions noves, [Superwhisper](https://superwhisper.com/) és el backend de dictat per defecte, amb processament al núvol sense descàrregues de models fora de línia. Tria Superwhisper o [Voxtype](https://voxtype.io/) mitjançant _Configuració > Valors predeterminats > Dictat_ al menú d'Omarchy. En seleccionar un backend, s'instal·la si cal i es converteix en el predeterminat per al dictat. Voxtype carrega un model base en anglès que ocupa 150MB; canvia el model amb `voxtype setup model` i altres ajustos mitjançant `~/.config/voxtype/config.toml`. Superwhisper obre els seus ajustos per triar el processament al núvol o local, i OPR manté l'aplicació actualitzada.

Dictes mantenint premut `Right Alt`, o bé commutes amb `Alt + Space`, i el text dictat apareixerà a l'àrea d'entrada enfocada. Aquestes dreceres utilitzen el backend seleccionat. Right Alt també inicia el dictat quan s'utilitza en una combinació de modificadors; utilitza Left Alt per a aquestes combinacions. En distribucions de teclat on Right Alt és AltGr, utilitza `Alt + Space` per mantenir AltGr disponible per escriure. Les instal·lacions anteriors a quan Alt + Space es va convertir en el valor predeterminat mantenen `F9` per a prémer per parlar i `Super + Ctrl + X` per commutar, afegits a `~/.config/hypr/bindings.lua`; elimina'ls allà per retornar aquestes tecles a les aplicacions.

Les mateixes dreceres funcionen amb qualsevol dels dos backends. Selecciona el teu backend mitjançant Configuració > Valors predeterminats > Dictat. L'instal·lador del backend el configura i desa la selecció. Executa `omarchy default dictation` per veure quin està seleccionat. La selecció es desa a `~/.config/omarchy/defaults/dictation`. Les instal·lacions noves seleccionen Superwhisper automàticament.

Omarchy carrega automàticament la integració d'escriptori del backend seleccionat. No cal cap configuració de Superwhisper a `~/.config/hypr/`.

Els enllaços personalitzats i els scripts poden utilitzar `omarchy dictation start`, `omarchy dictation stop` i `omarchy dictation toggle`. El backend seleccionat s'encarrega de l'enregistrament i la transcripció. En seleccionar Superwhisper es desactiva la seva drecera nativa de mantenir premut i s'estableix la seva commutació nativa a `Ctrl + Alt + Space`, mantenint-la separada de les tecles d'enregistrament d'Omarchy. Superwhisper requereix almenys una drecera d'enregistrament nativa, i la seva drecera de cancel·lació es manté disponible.

Es poden integrar backends addicionals sense canviar Omarchy. Proporciona un executable anomenat `omarchy-dictation-<backend>` al PATH que accepti `start`, `stop` i `toggle` i retorni ràpidament, amb un estat diferent de zero en cas d'error. El seu instal·lador configura el proveïdor i crida `omarchy-dictation-use <backend>` després d'una configuració correcta. Això atura el backend anterior i desa la selecció de manera atòmica; `stop` ha de tenir èxit quan el proveïdor està inactiu o no disponible. Els noms de backend utilitzen lletres minúscules, dígits i guionets. Proporciona `omarchy-install-dictation-<backend>` per a la configuració; `omarchy default dictation <backend>` l'inicia. Afegeix una entrada al menú Valors predeterminats mitjançant una extensió del menú d'Omarchy per cridar aquest selector. La integració d'escriptori opcional pot residir a `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
