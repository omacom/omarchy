# Extrakcia textu a diktovanie

### Extrakcia textu

Stlačte `Super + Ctrl + PrtScr` a vyberte oblasť na obrazovke na extrakciu textu. Open source OCR model tesseract potom tento výber rýchlo prevedie na text a umiestni ho do schránky. Potom už len stlačíte `Super + V` na prilepenie.

Toto je veľmi užitočné na získavanie adries z pätičiek obrázkov alebo telefónnych čísel vložených do nadpisov webových stránok.

 ![text-extraction](images/text-extraction.webp)

### Diktovanie

Pri nových inštaláciách je [Superwhisper](https://superwhisper.com/) predvoleným backendom pre diktovanie, ktorý používa cloudové spracovanie bez sťahovania offline modelov. Medzi Superwhisper a [Voxtype](https://voxtype.io/) si vyberiete cez _Nastavenie > Predvolené > Diktovanie_ v ponuke Omarchy. Výber backendu ho v prípade potreby nainštaluje a nastaví ho ako predvolený pre diktovanie. Voxtype načíta základný anglický model, ktorý zaberá 150MB; model zmeníte pomocou `voxtype setup model` a ďalšie nastavenia cez `~/.config/voxtype/config.toml`. Superwhisper otvorí svoje nastavenia, kde si vyberiete cloudové alebo lokálne spracovanie, a OPR udržiava aplikáciu aktualizovanú.

Diktujete podržaním `Right Alt`, alebo prepínaním pomocou `Alt + Space`, a nadiktovaný text sa zobrazí v aktuálne zameranej vstupnej oblasti. Tieto skratky používajú vybratý backend. Right Alt spustí diktovanie aj vtedy, keď ho použijete v kombinácii modifikátorov; na takéto kombinácie použite Left Alt. Na rozloženiach klávesnice, kde Right Alt funguje ako AltGr, používajte `Alt + Space`, aby AltGr zostal dostupný na písanie. Inštalácie z obdobia, než sa `Alt + Space` stalo predvolenou možnosťou, si zachovávajú `F9` pre push-to-talk a `Super + Ctrl + X` na prepínanie, pridané do `~/.config/hypr/bindings.lua`; odstráňte ich tam, aby ste tieto klávesy vrátili aplikáciám.

Rovnaké skratky fungujú s oboma backendmi. Backend si vyberiete cez Nastavenie > Predvolené > Diktovanie. Inštalátor backendu ho nakonfiguruje a uloží výber. Spustením `omarchy default dictation` zistíte, ktorý je vybratý. Výber sa ukladá do `~/.config/omarchy/defaults/dictation`. Nové inštalácie vyberú Superwhisper automaticky.

Omarchy automaticky načíta integráciu vybratého backendu s pracovnou plochou. V `~/.config/hypr/` nie je potrebná žiadna konfigurácia Superwhisper.

Vlastné väzby a skripty môžu používať `omarchy dictation start`, `omarchy dictation stop` a `omarchy dictation toggle`. Vybratý backend sa postará o nahrávanie a prepis. Výber Superwhisper vypne jeho natívnu skratku na podržanie a nastaví jeho natívne prepínanie na `Ctrl + Alt + Space`, čím ho udrží oddelene od nahrávacích klávesov Omarchy. Superwhisper vyžaduje aspoň jednu natívnu skratku na nahrávanie a jeho skratka na zrušenie zostáva dostupná.

Ďalšie backendy sa môžu integrovať bez zmien v Omarchy. Poskytnite spustiteľný súbor s názvom `omarchy-dictation-<backend>` na PATH, ktorý prijíma `start`, `stop` a `toggle`, okamžite sa vráti a pri zlyhaní vráti nenulový stav. Jeho inštalátor nakonfiguruje poskytovateľa a po úspešnom nastavení zavolá `omarchy-dictation-use <backend>`. Tým sa zastaví predchádzajúci backend a výber sa uloží atomicky; `stop` musí uspieť aj vtedy, keď je poskytovateľ nečinný alebo nedostupný. Názvy backendov používajú malé písmená, číslice a spojovníky. Na nastavenie poskytnite `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` ho spustí. Položku do ponuky Predvolené pridáte cez rozšírenie ponuky Omarchy, ktoré zavolá tento selektor. Voliteľná integrácia s pracovnou plochou môže byť v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
