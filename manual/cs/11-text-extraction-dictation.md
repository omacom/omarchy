# Extrakce textu a diktování

### Extrakce textu

Stiskněte `Super + Ctrl + PrtScr` a vyberte oblast na obrazovce pro extrakci textu. Open source OCR model tesseract poté rychle převede tento výběr na text a umístí ho do schránky. Pak stačí stisknout `Super + V` pro vložení.

To je velmi užitečné pro získávání adres ze zápatí obrázků nebo telefonních čísel vložených do nadpisů webových stránek.

 ![text-extraction](images/text-extraction.webp)

### Diktování

Při čerstvých instalacích je výchozím backendem diktování [Superwhisper](https://superwhisper.com/), který používá cloudové zpracování bez stahování offline modelů. Vyberte si Superwhisper nebo [Voxtype](https://voxtype.io/) přes _Nastavení > Výchozí > Diktování_ v nabídce Omarchy. Výběr backendu ho v případě potřeby nainstaluje a nastaví jako výchozí pro diktování. Voxtype načte základní anglický model, který zabírá 150 MB; model změníte pomocí `voxtype setup model` a další nastavení přes `~/.config/voxtype/config.toml`. Superwhisper otevře svá nastavení pro výběr cloudového nebo místního zpracování a OPR udržuje aplikaci aktualizovanou.

Diktujete podržením `Right Alt` nebo `F9`, nebo přepínáním pomocí `Super + Ctrl + X`, a nadiktovaný text se objeví ve zaměřené vstupní oblasti. Tyto zkratky používají vybraný backend. Right Alt také spustí diktování, když se použije v akordu s modifikátorem; pro tyto akordy používejte Left Alt. Na rozloženích klávesnice, kde je Right Alt klávesou AltGr, používejte `F9`, aby AltGr zůstal k dispozici pro psaní.

Tytéž zkratky fungují s oběma backendy. Backend si vyberte přes Nastavení > Výchozí > Diktování. Instalátor backendu ho nakonfiguruje a uloží výběr. Spusťte `omarchy default dictation` a zjistěte, který je vybrán. Výběr je uložen v `~/.config/omarchy/defaults/dictation`. Čerstvé instalace vybírají Superwhisper automaticky.

Omarchy automaticky načte integraci s plochou vybraného backendu. V `~/.config/hypr/` není potřeba žádná konfigurace Superwhisperu.

Vlastní zkratky a skripty mohou používat `omarchy dictation start`, `omarchy dictation stop` a `omarchy dictation toggle`. Vybraný backend zajišťuje nahrávání a přepis. Výběr Superwhisperu zakáže jeho nativní zkratku pro podržení a nastaví jeho nativní přepínání na `Alt + Space`, čímž ho udrží oddělený od nahrávacích kláves Omarchy. Superwhisper vyžaduje alespoň jednu nativní zkratku pro nahrávání a jeho zkratka pro zrušení zůstává k dispozici.

Další backendy se mohou integrovat beze změny Omarchy. Poskytněte spustitelný soubor s názvem `omarchy-dictation-<backend>` na PATH, který přijímá `start`, `stop` a `toggle` a vrací se rychle, při selhání s nenulovým stavem. Jeho instalátor nakonfiguruje poskytovatele a po úspěšném nastavení zavolá `omarchy-dictation-use <backend>`. Tím se zastaví předchozí backend a výběr se uloží atomicky; `stop` musí uspět, když je poskytovatel nečinný nebo nedostupný. Názvy backendů používají malá písmena, číslice a pomlčky. Pro nastavení poskytněte `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` ho spustí. Přidejte položku nabídky Výchozí přes rozšíření nabídky Omarchy pro volání tohoto výběru. Volitelná integrace s plochou může žít v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
