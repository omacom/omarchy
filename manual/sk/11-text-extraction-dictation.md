# Extrakcia textu a diktovanie

### Extrakcia textu

Stlačením `Super + Ctrl + PrtScr` vyberiete oblasť na obrazovke na extrakciu textu. Open source OCR model tesseract potom rýchlo prevedie tento výber na text a umiestni ho do schránky. Potom stačí stlačiť `Super + V` na prilepenie.

To je veľmi užitočné na získavanie adries z pätičiek obrázkov alebo telefónnych čísel vložených do nadpisov webových stránok.

 ![text-extraction](images/text-extraction.webp)

### Diktovanie

Pri čerstvých inštaláciách je [Superwhisper](https://superwhisper.com/) predvoleným backendom diktovania, ktorý používa cloudové spracovanie bez sťahovania offline modelov. Superwhisper alebo [Voxtype](https://voxtype.io/) si vyberte cez _Nastavenie > Predvolené > Diktovanie_ v menu Omarchy. Výber backendu ho v prípade potreby nainštaluje a urobí z neho predvolený pre diktovanie. Voxtype načítava základný anglický model, ktorý zaberá 150 MB; model zmeníte pomocou `voxtype setup model` a ďalšie nastavenia cez `~/.config/voxtype/config.toml`. Superwhisper otvorí svoje nastavenia na výber cloudového alebo lokálneho spracovania a OPR udržiava aplikáciu aktuálnu.

Diktujete podržaním `Right Alt` alebo `F9`, alebo prepínaním pomocou `Super + Ctrl + X`, a diktovaný text sa objaví v zaostrenej vstupnej oblasti. Tieto skratky používajú vybraný backend. Right Alt tiež spustí diktovanie, keď sa použije v akorde s modifikátorom; pre tieto akordy použite Left Alt. Na rozloženiach klávesnice, kde je Right Alt zároveň AltGr, použite `F9`, aby AltGr zostalo k dispozícii na písanie.

Rovnaké skratky fungujú s oboma backendmi. Backend si vyberiete cez Nastavenie > Predvolené > Diktovanie. Inštalátor backendu ho nakonfiguruje a výber uloží. Spustite `omarchy default dictation`, aby ste videli, ktorý je vybraný. Výber sa ukladá do `~/.config/omarchy/defaults/dictation`. Čerstvé inštalácie automaticky vyberú Superwhisper.

Omarchy automaticky načítava integráciu vybraného backendu s pracovnou plochou. V `~/.config/hypr/` nie je potrebná žiadna konfigurácia Superwhisper.

Vlastné väzby a skripty môžu používať `omarchy dictation start`, `omarchy dictation stop` a `omarchy dictation toggle`. Vybraný backend spracúva nahrávanie a prepis. Výber Superwhisper zakáže jeho natívnu skratku na podržanie a nastaví jeho natívne prepínanie na `Alt + Space`, čím ho udrží oddelené od nahrávacích klávesov Omarchy. Superwhisper vyžaduje aspoň jednu natívnu nahrávaciu skratku a jeho skratka na zrušenie zostáva k dispozícii.

Ďalšie backendy sa môžu integrovať bez zmeny Omarchy. Poskytnite spustiteľný súbor s názvom `omarchy-dictation-<backend>` na PATH, ktorý prijíma `start`, `stop` a `toggle` a rýchlo sa vracia, pri zlyhaní s nenulovým stavom. Jeho inštalátor nakonfiguruje poskytovateľa a po úspešnom nastavení zavolá `omarchy-dictation-use <backend>`. To zastaví predchádzajúci backend a atomicky uloží výber; `stop` musí uspieť, keď je poskytovateľ nečinný alebo nedostupný. Názvy backendov používajú malé písmená, číslice a pomlčky. Na nastavenie poskytnite `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` ho spustí. Položku menu Predvolené pridajte cez rozšírenie menu Omarchy, aby zavolalo tento výber. Voliteľná integrácia s pracovnou plochou môže žiť v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
