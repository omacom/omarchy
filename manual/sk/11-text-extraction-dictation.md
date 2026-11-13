# Extrakcia textu a diktovanie

### Extrakcia textu

Stlačte `Super + Ctrl + PrtScr`, ak chcete vybrať oblasť na obrazovke na extrakciu textu. Open-source OCR model tesseract potom tento výber rýchlo prevedie na text a umiestni ho do schránky. Potom už len stlačte `Super + V` na prilepenie.

Je to veľmi užitočné na získavanie adries z pätičiek obrázkov alebo telefónnych čísel vložených do nadpisov na webových stránkach.

 ![text-extraction](images/text-extraction.webp)

### Diktovanie

Pri čerstvých inštaláciách je [Superwhisper](https://superwhisper.com/) predvoleným backendom pre diktovanie, ktorý využíva cloudové spracovanie bez sťahovania offline modelov. Superwhisper, [Voxtype](https://voxtype.io/) alebo [Hex](https://anoma.ly/hex/) si vyberiete cez _Nastavenie > Predvolené > Diktovanie_ v ponuke Omarchy. Výber backendu ho v prípade potreby nainštaluje a nastaví ho ako predvolený pre diktovanie. Voxtype načítava základný anglický model, ktorý zaberá 150MB; model zmeníte pomocou `voxtype setup model` a ďalšie nastavenia cez `~/.config/voxtype/config.toml`. Superwhisper otvorí svoje nastavenia, kde si môžete vybrať cloudové alebo lokálne spracovanie, a OPR udržiava aplikáciu aktualizovanú. Hex si počas nastavenia stiahne svoj model reči do zariadenia a beží ako používateľská služba `hex.service`; jeho okno otvoríte z ikony v systémovej oblasti panela alebo spustením príkazu `hex`, kde môžete zmeniť model a ďalšie nastavenia.

Diktujete podržaním klávesu `Right Alt` alebo prepínaním pomocou `Alt + Space` a nadiktovaný text sa zobrazí v aktívnej oblasti na zadávanie textu. Tieto skratky používajú vybratý backend. Right Alt spustí diktovanie aj vtedy, keď sa použije v kombinácii s modifikačným klávesom; pre tieto kombinácie použite Left Alt. Pri rozloženiach klávesnice, kde je Right Alt zároveň AltGr, používajte `Alt + Space`, aby AltGr zostal dostupný na písanie. Inštalácie z obdobia pred tým, než sa Alt + Space stal predvoleným, si zachovávajú `F9` pre push-to-talk a `Super + Ctrl + X` na prepínanie, pridané do `~/.config/hypr/bindings.lua`, kde toto `Super + Ctrl + X` zaberá miesto panela agentov; odstráňte ich tam, aby ste tieto klávesy vrátili aplikáciám a panelu.

Rovnaké skratky fungujú s každým backendom. Backend si vyberiete cez Nastavenie > Predvolené > Diktovanie. Inštalátor backendu ho nakonfiguruje a výber uloží. Spustite `omarchy default dictation`, ak chcete zistiť, ktorý je vybratý. Výber sa ukladá do `~/.config/omarchy/defaults/dictation`. Pri čerstvých inštaláciách sa Superwhisper vyberie automaticky.

Omarchy automaticky načítava integráciu vybratého backendu do pracovného prostredia. V `~/.config/hypr/` nie je potrebná žiadna konfigurácia Superwhisper.

Vlastné klávesové skratky a skripty môžu používať `omarchy dictation start`, `omarchy dictation stop` a `omarchy dictation toggle`. Vybratý backend sa stará o nahrávanie a prepis. Výber Superwhisper zakáže jeho natívnu skratku na podržanie a nastaví jeho natívne prepínanie na `Ctrl + Alt + Space`, čím zostane oddelené od nahrávacích klávesov Omarchy. Superwhisper vyžaduje aspoň jednu natívnu skratku na nahrávanie a jeho skratka na zrušenie zostáva dostupná.

Ďalšie backendy sa môžu integrovať bez zmien v Omarchy. Poskytnite spustiteľný súbor s názvom `omarchy-dictation-<backend>` v PATH, ktorý prijíma `start`, `stop` a `toggle`, okamžite sa vráti a pri zlyhaní vráti nenulový stav. Jeho inštalátor nakonfiguruje poskytovateľa a po úspešnom nastavení zavolá `omarchy-dictation-use <backend>`. Tým sa zastaví predchádzajúci backend a výber sa uloží atomicky; `stop` musí uspieť, keď je poskytovateľ nečinný alebo nedostupný. Názvy backendov používajú malé písmená, číslice a spojovníky. Na nastavenie poskytnite `omarchy-install-dictation-<backend>`; spustí ho `omarchy default dictation <backend>`. Pridajte položku ponuky Predvolené prostredníctvom rozšírenia ponuky Omarchy, ktorá bude volať tento selektor. Voliteľná integrácia do pracovného prostredia môže byť umiestnená v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
