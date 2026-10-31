# Extrakce textu a diktování

### Extrakce textu

Stiskněte `Super + Ctrl + PrtScr` a vyberte oblast na obrazovce pro extrakci textu. Otevřený OCR model tesseract pak výběr rychle převede na text a umístí ho do schránky. Pak už jen stiskněte `Super + V` pro vložení.

To se velmi hodí pro získávání adres z patiček obrázků nebo telefonních čísel vložených do nadpisů webových stránek.

 ![text-extraction](images/text-extraction.webp)

### Diktování

Na čerstvých instalacích je [Superwhisper](https://superwhisper.com/) výchozím backendem pro diktování, který používá cloudové zpracování bez stahování offline modelů. Superwhisper, [Voxtype](https://voxtype.io/) nebo [Hex](https://anoma.ly/hex/) si vyberete přes _Setup > Defaults > Dictation_ v nabídce Omarchy. Výběr backendu ho v případě potřeby nainstaluje a nastaví jako výchozí pro diktování. Voxtype načte základní anglický model, který zabírá 150MB; model změníte příkazem `voxtype setup model` a další nastavení přes `~/.config/voxtype/config.toml`. Superwhisper otevře svá nastavení pro volbu cloudového nebo lokálního zpracování a OPR udržuje aplikaci aktualizovanou. Hex si během nastavení stáhne svůj model řeči v zařízení a běží jako uživatelská služba `hex.service`; jeho okno otevřete z ikony v liště na panelu nebo spuštěním příkazu `hex`, kde můžete změnit model a další nastavení.

Diktujete podržením `Right Alt`, nebo přepínáním pomocí `Alt + Space`, a nadiktovaný text se objeví v zaměřené vstupní oblasti. Tyto zkratky používají vybraný backend. Right Alt také spustí diktování, když se použije v kombinaci modifikátorů; pro tyto kombinace použijte Left Alt. Na rozloženích klávesnice, kde je Right Alt AltGr, použijte `Alt + Space`, aby AltGr zůstal dostupný pro psaní. Instalace z doby, než se `Alt + Space` stalo výchozím, si ponechávají `F9` pro push-to-talk a `Super + Ctrl + X` pro přepínání, přidané do `~/.config/hypr/bindings.lua`; odstraňte je tam, abyste tyto klávesy vrátili aplikacím.

Stejné zkratky fungují s každým backendem. Backend si vyberte přes Setup > Defaults > Dictation. Instalační program backendu ho nakonfiguruje a uloží výběr. Spuštěním `omarchy default dictation` zjistíte, který je vybraný. Výběr se ukládá do `~/.config/omarchy/defaults/dictation`. Čerstvé instalace automaticky vyberou Superwhisper.

Omarchy načte desktopovou integraci vybraného backendu automaticky. V `~/.config/hypr/` není potřeba žádná konfigurace Superwhisper.

Vlastní vazby a skripty mohou používat `omarchy dictation start`, `omarchy dictation stop` a `omarchy dictation toggle`. Vybraný backend zajišťuje nahrávání a přepis. Výběr Superwhisper zakáže jeho nativní zkratku pro podržení a nastaví jeho nativní přepínání na `Ctrl + Alt + Space`, takže zůstane oddělené od nahrávacích kláves Omarchy. Superwhisper vyžaduje alespoň jednu nativní zkratku pro nahrávání a jeho zkratka pro zrušení zůstává dostupná.

Další backendy se mohou integrovat bez změn Omarchy. Poskytněte spustitelný soubor s názvem `omarchy-dictation-<backend>` v PATH, který přijímá `start`, `stop` a `toggle` a vrací se okamžitě, při selhání s nenulovým stavem. Jeho instalační program nakonfiguruje poskytovatele a po úspěšném nastavení zavolá `omarchy-dictation-use <backend>`. Tím se zastaví předchozí backend a výběr se uloží atomicky; `stop` musí uspět, když je poskytovatel nečinný nebo nedostupný. Názvy backendů používají malá písmena, číslice a spojovníky. Pro nastavení poskytněte `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` ho spustí. Položku nabídky Defaults přidejte přes rozšíření nabídky Omarchy, které zavolá tento selektor. Volitelná desktopová integrace může být v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
