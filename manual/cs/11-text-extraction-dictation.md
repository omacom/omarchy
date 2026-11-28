# Extrakce textu a diktování

### Extrakce textu

Stiskněte `Super + Ctrl + PrtScr` a vyberte oblast na obrazovce pro extrakci textu. Open source OCR model tesseract pak výběr rychle převede na text a umístí jej do schránky. Potom už stačí stisknout `Super + V` pro vložení.

To je velmi užitečné pro získávání adres ze zápatí obrázků nebo telefonních čísel vložených do titulků na webových stránkách.

 ![text-extraction](images/text-extraction.webp)

### Diktování

Na čerstvých instalacích je [Superwhisper](https://superwhisper.com/) výchozím backendem pro diktování, který používá cloudové zpracování bez stahování offline modelů. Superwhisper, [Voxtype](https://voxtype.io/) nebo [Hex](https://anoma.ly/hex/) si vyberete přes _Nastavení > Výchozí > Diktování_ v nabídce Omarchy. Výběr backendu jej v případě potřeby nainstaluje a nastaví jako výchozí pro diktování. Voxtype načte základní anglický model, který zabírá 150 MB; model změníte pomocí `voxtype setup model` a další nastavení prostřednictvím `~/.config/voxtype/config.toml`. Superwhisper otevře své nastavení pro volbu cloudového nebo místního zpracování a OPR udržuje aplikaci aktualizovanou. Hex si během nastavení stáhne svůj model řeči pro zpracování přímo v zařízení a běží jako uživatelská služba `hex.service`; jeho okno otevřete z ikony v oznamovací oblasti na panelu nebo spuštěním `hex`, kde můžete změnit model a další nastavení.

Diktujete tak, že podržíte `Right Alt`, nebo diktování přepnete pomocí `Alt + Space`, a nadiktovaný text se objeví v aktivní vstupní oblasti. Tyto zkratky používají vybraný backend. Right Alt spustí diktování i při použití v kombinaci s modifikátorem; pro tyto kombinace použijte Left Alt. Na rozloženích klávesnice, kde Right Alt funguje jako AltGr, včetně případů, kdy na takové rozložení přepnete, jej pro diktování na chvíli podržte samostatně; AltGr stisknutý spolu s jinou klávesou stále zapíše svůj znak. Instalace z doby, než se `Alt + Space` stalo výchozím, si zachovávají `F9` pro push-to-talk a `Super + Ctrl + X` pro přepínání, přidané do `~/.config/hypr/bindings.lua`, kde toto `Super + Ctrl + X` nahrazuje panel agentů; odeberte je odtud, abyste tyto klávesy vrátili aplikacím a panelu.

Stejné zkratky fungují s každým backendem. Backend si vyberete přes Nastavení > Výchozí > Diktování. Instalační program backendu jej nakonfiguruje a výběr uloží. Spuštěním `omarchy default dictation` zjistíte, který backend je vybraný. Výběr se ukládá do `~/.config/omarchy/defaults/dictation`. Čerstvé instalace automaticky vyberou Superwhisper.

Omarchy automaticky načte integraci vybraného backendu do desktopového prostředí. V `~/.config/hypr/` není potřeba žádná konfigurace Superwhisperu.

Vlastní vazby a skripty mohou používat `omarchy dictation start`, `omarchy dictation stop` a `omarchy dictation toggle`. Vybraný backend zajišťuje nahrávání a přepis. Výběr Superwhisperu deaktivuje jeho nativní zkratku pro podržení a nastaví jeho nativní přepínání na `Ctrl + Alt + Space`, takže zůstává oddělené od nahrávacích kláves Omarchy. Superwhisper vyžaduje alespoň jednu nativní zkratku pro nahrávání a jeho zkratka pro zrušení zůstává k dispozici.

Další backendy se mohou integrovat bez změn v Omarchy. Poskytněte spustitelný soubor s názvem `omarchy-dictation-<backend>` v PATH, který přijímá `start`, `stop` a `toggle`, rychle se ukončí a při selhání vrátí nenulový stav. Jeho instalační program nakonfiguruje poskytovatele a po úspěšném nastavení zavolá `omarchy-dictation-use <backend>`. Tím se zastaví předchozí backend a výběr se uloží atomicky; `stop` musí uspět, i když je poskytovatel nečinný nebo nedostupný. Názvy backendů používají malá písmena, číslice a spojovníky. Pro nastavení poskytněte `omarchy-install-dictation-<backend>`; spustí jej `omarchy default dictation <backend>`. Položku do nabídky Výchozí přidejte prostřednictvím rozšíření nabídky Omarchy, aby volala tento výběr. Volitelná integrace do desktopového prostředí může být umístěna v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
