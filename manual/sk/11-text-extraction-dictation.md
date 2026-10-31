# Extrakcia textu a diktovanie

### Extrakcia textu

Stlačte `Super + Ctrl + PrtScr` a vyberte oblasť na obrazovke na extrakciu textu. Open source OCR model tesseract potom túto vybratú oblasť rýchlo prevedie na text a umiestni ho do schránky. Potom už len stlačíte `Super + V` na vloženie.

Je to veľmi užitočné na získavanie adries z pätičiek obrázkov alebo telefónnych čísel vložených do nadpisov webových stránok.

 ![text-extraction](images/text-extraction.webp)

### Diktovanie

Pri čerstvých inštaláciách je [Superwhisper](https://superwhisper.com/) predvoleným backendom diktovania, ktorý používa cloudové spracovanie bez sťahovania offline modelov. Superwhisper, [Voxtype](https://voxtype.io/) alebo [Hex](https://anoma.ly/hex/) si vyberiete cez _Setup > Defaults > Dictation_ v ponuke Omarchy. Výber backendu ho v prípade potreby nainštaluje a nastaví ako predvolený pre diktovanie. Voxtype načíta základný anglický model, ktorý zaberá 150MB; model zmeníte príkazom `voxtype setup model` a ďalšie nastavenia cez `~/.config/voxtype/config.toml`. Superwhisper otvorí svoje nastavenia, kde si môžete vybrať cloudové alebo lokálne spracovanie, a OPR udržiava aplikáciu aktualizovanú. Hex si počas nastavenia stiahne svoj model reči bežiaci na zariadení a beží ako používateľská služba `hex.service`; jeho okno otvoríte z ikony v systémovej lište na paneli alebo spustením príkazu `hex`, kde môžete zmeniť model a ďalšie nastavenia.

Diktujete podržaním klávesu `Right Alt` alebo prepínaním pomocou `Alt + Space` a nadiktovaný text sa zobrazí v zameranej vstupnej oblasti. Tieto skratky používajú vybratý backend. `Right Alt` spustí diktovanie aj pri použití v akorde modifikátorov; na takéto akordy používajte `Left Alt`. Pri rozloženiach klávesnice, kde je `Right Alt` klávesom AltGr, používajte `Alt + Space`, aby AltGr zostal dostupný na písanie. Inštalácie z obdobia, keď sa `Alt + Space` ešte nestalo predvoleným nastavením, si zachovávajú `F9` na push-to-talk a `Super + Ctrl + X` na prepínanie, pridané do `~/.config/hypr/bindings.lua`; odstráňte ich odtiaľ, aby ste tieto klávesy vrátili aplikáciám.

Rovnaké skratky fungujú s každým backendom. Backend si vyberte cez Setup > Defaults > Dictation. Inštalátor backendu ho nakonfiguruje a uloží výber. Spustite `omarchy default dictation`, aby ste videli, ktorý je vybratý. Výber je uložený v `~/.config/omarchy/defaults/dictation`. Čerstvé inštalácie vyberú Superwhisper automaticky.

Omarchy načíta desktopovú integráciu vybratého backendu automaticky. V `~/.config/hypr/` nie je potrebná žiadna konfigurácia Superwhisper.

Vlastné väzby a skripty môžu používať `omarchy dictation start`, `omarchy dictation stop` a `omarchy dictation toggle`. Vybratý backend sa postará o nahrávanie a prepis. Výber Superwhisper zakáže jeho natívnu skratku na podržanie a nastaví jeho natívne prepínanie na `Ctrl + Alt + Space`, čím ho udrží oddelene od nahrávacích klávesov Omarchy. Superwhisper vyžaduje aspoň jednu natívnu skratku nahrávania a jeho skratka na zrušenie zostáva dostupná.

Ďalšie backendy sa môžu integrovať bez zmien v Omarchy. Poskytnite spustiteľný súbor s názvom `omarchy-dictation-<backend>` v PATH, ktorý prijíma `start`, `stop` a `toggle` a okamžite sa vráti, pri zlyhaní s nenulovým stavom. Jeho inštalátor nakonfiguruje poskytovateľa a po úspešnom nastavení zavolá `omarchy-dictation-use <backend>`. Tým sa zastaví predchádzajúci backend a výber sa uloží atomicky; `stop` musí uspieť, keď je poskytovateľ nečinný alebo nedostupný. Názvy backendov používajú malé písmená, číslice a spojovníky. Na nastavenie poskytnite `omarchy-install-dictation-<backend>`; spustí ho `omarchy default dictation <backend>`. Pridajte položku ponuky Defaults prostredníctvom rozšírenia ponuky Omarchy, ktorá bude volať tento výber. Voliteľná desktopová integrácia môže byť umiestnená v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
