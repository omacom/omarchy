# Extrakcia textu a diktovanie

### Extrakcia textu

Stlačte `Super + Ctrl + PrtScr` a vyberte oblasť na obrazovke na extrakciu textu. Open source OCR model tesseract potom tento výber rýchlo prevedie na text a umiestni ho do schránky. Potom už len stlačíte `Super + V` na vloženie.

Je to veľmi užitočné na získavanie adries z pätičiek obrázkov alebo telefónnych čísel vložených do nadpisov na webových stránkach.

 ![text-extraction](images/text-extraction.webp)

### Diktovanie

Pri čerstvých inštaláciách je predvoleným backendom na diktovanie [Superwhisper](https://superwhisper.com/), ktorý používa cloudové spracovanie bez sťahovania offline modelov. Superwhisper, [Voxtype](https://voxtype.io/) alebo [Hex](https://anoma.ly/hex/) si vyberiete cez _Setup > Defaults > Dictation_ v ponuke Omarchy. Výber backendu ho v prípade potreby nainštaluje a nastaví ako predvolený na diktovanie. Voxtype načíta základný anglický model, ktorý zaberá 150MB; model zmeníte príkazom `voxtype setup model` a ďalšie nastavenia cez `~/.config/voxtype/config.toml`. Superwhisper otvorí svoje nastavenia, kde si vyberiete cloudové alebo lokálne spracovanie, a OPR udržiava aplikáciu aktualizovanú. Hex si počas nastavenia stiahne svoj model reči na spracovanie na zariadení a beží ako používateľská služba `hex.service`; jeho okno otvoríte z ikony v systémovej lište na paneli alebo spustením `hex`, kde môžete zmeniť model a ďalšie nastavenia.

Diktujete podržaním `Right Alt` alebo prepínaním pomocou `Alt + Space` a nadiktovaný text sa zobrazí v aktívnom poli na zadávanie textu. Tieto skratky používajú vybraný backend. Right Alt spustí diktovanie aj pri použití v kombinácii modifikačných klávesov; na takéto kombinácie používajte Left Alt. Na rozloženiach klávesnice, kde je Right Alt klávesom AltGr, vrátane prípadov, keď je takéto rozloženie jedným z tých, na ktoré prepínate, ho na diktovanie na chvíľu podržte samostatne; AltGr stlačený spolu s iným klávesom stále napíše jeho znak. Inštalácie z obdobia predtým, než sa `Alt + Space` stalo predvoleným, si zachovávajú `F9` na push-to-talk a `Super + Ctrl + X` na prepínanie, pridané do `~/.config/hypr/bindings.lua`, kde toto `Super + Ctrl + X` zastupuje panel agentov; odstráňte ich odtiaľ, aby ste tieto klávesy vrátili aplikáciám a panelu.

Rovnaké skratky fungujú s každým backendom. Backend si vyberiete cez Setup > Defaults > Dictation. Inštalátor backendu ho nakonfiguruje a výber uloží. Spustením `omarchy default dictation` zistíte, ktorý je vybraný. Výber je uložený v `~/.config/omarchy/defaults/dictation`. Pri čerstvých inštaláciách sa Superwhisper vyberie automaticky.

Omarchy automaticky načíta integráciu vybraného backendu do desktopového prostredia. V `~/.config/hypr/` nie je potrebná žiadna konfigurácia Superwhisper.

Vlastné klávesové väzby a skripty môžu používať `omarchy dictation start`, `omarchy dictation stop` a `omarchy dictation toggle`. Vybraný backend zabezpečuje nahrávanie a prepis. Výber Superwhisper vypne jeho natívnu skratku na podržanie a nastaví jeho natívne prepínanie na `Ctrl + Alt + Space`, čím ho udrží oddelené od klávesov Omarchy na nahrávanie. Superwhisper vyžaduje aspoň jednu natívnu skratku na nahrávanie a jeho skratka na zrušenie zostáva k dispozícii.

Ďalšie backendy sa môžu integrovať bez zmien v Omarchy. Poskytnite spustiteľný súbor s názvom `omarchy-dictation-<backend>` v PATH, ktorý prijíma `start`, `stop` a `toggle` a okamžite sa vráti, pri zlyhaní s nenulovým stavom. Jeho inštalátor nakonfiguruje poskytovateľa a po úspešnom nastavení zavolá `omarchy-dictation-use <backend>`. Tým sa zastaví predchádzajúci backend a výber sa uloží atomicky; `stop` musí uspieť, keď je poskytovateľ nečinný alebo nedostupný. Názvy backendov používajú malé písmená, číslice a spojovníky. Na nastavenie poskytnite `omarchy-install-dictation-<backend>`; spustí ho `omarchy default dictation <backend>`. Cez rozšírenie ponuky Omarchy pridajte položku ponuky Defaults, ktorá tento výber zavolá. Voliteľná integrácia do desktopového prostredia môže byť umiestnená v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
