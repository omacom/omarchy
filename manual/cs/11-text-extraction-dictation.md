# Extrakce textu a diktování

### Extrakce textu

Stiskněte `Super + Ctrl + PrtScr` a vyberte oblast na obrazovce pro extrakci textu. Open source OCR model tesseract pak tento výběr rychle převede na text a umístí jej do schránky. Pak už jen stisknete `Super + V` pro vložení.

To je velmi užitečné pro získávání adres ze zápatí obrázků nebo telefonních čísel vložených do nadpisů webových stránek.

 ![text-extraction](images/text-extraction.webp)

### Diktování

Na čerstvých instalacích je [Superwhisper](https://superwhisper.com/) výchozím backendem pro diktování, který používá cloudové zpracování bez stahování offline modelů. Superwhisper nebo [Voxtype](https://voxtype.io/) vyberete přes _Setup > Defaults > Dictation_ v menu Omarchy. Výběr backendu jej v případě potřeby nainstaluje a nastaví jako výchozí pro diktování. Voxtype načte základní anglický model, který zabírá 150MB; model změníte pomocí `voxtype setup model` a další nastavení přes `~/.config/voxtype/config.toml`. Superwhisper otevře své nastavení pro volbu cloudového nebo lokálního zpracování a OPR udržuje aplikaci aktualizovanou.

Diktujete podržením `Right Alt`, nebo přepínáním pomocí `Alt + Space`, a nadiktovaný text se objeví v aktivní vstupní oblasti. Tyto zkratky používají vybraný backend. Right Alt také spouští diktování, když je použit v akordu modifikátorů; pro tyto akordy použijte Left Alt. Na rozloženích klávesnice, kde je Right Alt AltGr, použijte `Alt + Space`, aby AltGr zůstal dostupný pro psaní. Instalace z doby, než se Alt + Space stal výchozím, si ponechávají `F9` pro push-to-talk a `Super + Ctrl + X` pro přepínání, přidané do `~/.config/hypr/bindings.lua`; odstraňte je tam, abyste tyto klávesy vrátili aplikacím.

Stejné zkratky fungují s oběma backendy. Backend vyberete přes Setup > Defaults > Dictation. Instalační program backendu jej nakonfiguruje a výběr uloží. Spusťte `omarchy default dictation`, abyste zjistili, který je vybraný. Výběr je uložen v `~/.config/omarchy/defaults/dictation`. Čerstvé instalace automaticky vyberou Superwhisper.

Omarchy automaticky načte desktopovou integraci vybraného backendu. V `~/.config/hypr/` není potřeba žádná konfigurace Superwhisper.

Vlastní vazby a skripty mohou používat `omarchy dictation start`, `omarchy dictation stop` a `omarchy dictation toggle`. Vybraný backend zajišťuje nahrávání a přepis. Výběr Superwhisper deaktivuje jeho nativní zkratku pro podržení a nastaví jeho nativní přepínač na `Ctrl + Alt + Space`, čímž jej udrží oddělený od nahrávacích kláves Omarchy. Superwhisper vyžaduje alespoň jednu nativní zkratku pro nahrávání a jeho zkratka pro zrušení zůstává dostupná.

Další backendy se mohou integrovat bez změny Omarchy. Poskytněte spustitelný soubor s názvem `omarchy-dictation-<backend>` v PATH, který přijímá `start`, `stop` a `toggle` a rychle se vrací, při selhání s nenulovým stavem. Jeho instalační program nakonfiguruje poskytovatele a po úspěšném nastavení zavolá `omarchy-dictation-use <backend>`. Tím se zastaví předchozí backend a výběr se uloží atomicky; `stop` musí uspět, když je poskytovatel nečinný nebo nedostupný. Názvy backendů používají malá písmena, číslice a spojovníky. Pro nastavení poskytněte `omarchy-install-dictation-<backend>`; spustí jej `omarchy default dictation <backend>`. Přidejte položku menu Defaults přes rozšíření menu Omarchy, která zavolá tento selektor. Volitelná desktopová integrace může být v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
