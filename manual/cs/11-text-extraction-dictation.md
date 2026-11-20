# Extrakce textu a diktování

### Extrakce textu

Stiskněte `Super + Ctrl + PrtScr` a vyberte oblast na obrazovce pro extrakci textu. Open source OCR model tesseract pak výběr rychle převede na text a umístí ho do schránky. Pak už jen stisknete `Super + V` pro vložení.

Tohle je velmi užitečné pro získávání adres ze zápatí obrázků nebo telefonních čísel vložených do nadpisů webových stránek.

 ![text-extraction](images/text-extraction.webp)

### Diktování

Na čerstvých instalacích je výchozím backendem pro diktování [Superwhisper](https://superwhisper.com/), který používá cloudové zpracování bez stahování offline modelů. Superwhisper, [Voxtype](https://voxtype.io/) nebo [Hex](https://anoma.ly/hex/) si vyberete přes _Setup > Defaults > Dictation_ v nabídce Omarchy. Výběr backendu ho v případě potřeby nainstaluje a nastaví jako výchozí pro diktování. Voxtype načte základní anglický model, který zabírá 150MB; model změníte příkazem `voxtype setup model` a další nastavení přes `~/.config/voxtype/config.toml`. Superwhisper otevře své nastavení pro volbu cloudového nebo lokálního zpracování a OPR udržuje aplikaci aktualizovanou. Hex si během nastavení stáhne svůj model řeči běžící přímo na zařízení a běží jako uživatelská služba `hex.service`; jeho okno otevřete z ikony v systémové liště panelu nebo spuštěním `hex`, kde můžete změnit model a další nastavení.

Diktujete podržením `Right Alt`, nebo přepínáním pomocí `Alt + Space`, a nadiktovaný text se objeví ve zaměřené vstupní oblasti. Tyto zkratky používají vybraný backend. Right Alt spustí diktování i při použití v kombinaci s modifikátorem; pro tyto kombinace použijte Left Alt. Na rozloženích klávesnice, kde je Right Alt zároveň AltGr, používejte `Alt + Space`, aby AltGr zůstal k dispozici pro psaní. Instalace z doby, než se `Alt + Space` stalo výchozím, si zachovávají `F9` pro push-to-talk a `Super + Ctrl + X` pro přepínání, přidané do `~/.config/hypr/bindings.lua`, kde toto `Super + Ctrl + X` nahrazuje panel agentů; odtud je odstraňte, abyste tyto klávesy vrátili aplikacím a panelu.

Stejné zkratky fungují s každým backendem. Backend si vyberete přes Setup > Defaults > Dictation. Instalační program backendu ho nakonfiguruje a uloží výběr. Spuštěním `omarchy default dictation` zjistíte, který je vybraný. Výběr se ukládá do `~/.config/omarchy/defaults/dictation`. Čerstvé instalace automaticky vyberou Superwhisper.

Omarchy automaticky načte integraci vybraného backendu do desktopu. V `~/.config/hypr/` není potřeba žádná konfigurace Superwhisperu.

Vlastní vazby a skripty mohou používat `omarchy dictation start`, `omarchy dictation stop` a `omarchy dictation toggle`. Vybraný backend zajistí nahrávání a přepis. Výběr Superwhisperu deaktivuje jeho nativní zkratku pro podržení a nastaví jeho nativní přepínač na `Ctrl + Alt + Space`, aby zůstal oddělený od nahrávacích kláves Omarchy. Superwhisper vyžaduje alespoň jednu nativní zkratku pro nahrávání a jeho zkratka pro zrušení zůstává k dispozici.

Další backendy se mohou integrovat bez úprav Omarchy. Poskytněte spustitelný soubor s názvem `omarchy-dictation-<backend>` na PATH, který přijímá `start`, `stop` a `toggle`, okamžitě se vrací a při selhání vrací nenulový stav. Jeho instalační program nakonfiguruje poskytovatele a po úspěšném nastavení zavolá `omarchy-dictation-use <backend>`. Tím se zastaví předchozí backend a výběr se uloží atomicky; `stop` musí uspět, i když je poskytovatel nečinný nebo nedostupný. Názvy backendů používají malá písmena, číslice a spojovníky. Pro nastavení poskytněte `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` ho spustí. Přidejte položku nabídky Defaults prostřednictvím rozšíření nabídky Omarchy, které tento výběr zavolá. Volitelná integrace do desktopu může být v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
