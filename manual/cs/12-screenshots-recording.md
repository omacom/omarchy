# Snímky obrazovky a nahrávání

Vše, co můžete sebrat z obrazovky, visí na klávese Print Screen. Samotná klávesa pořídí obrázek a modifikátory pořídí nahrávku, barvu nebo text uvnitř oblasti. Pokud vaše klávesnice vůbec nemá klávesu Print Screen, `Super + Ctrl + Alt + C` pořídí stejný snímek obrazovky a `Super + Ctrl + C` otevře celou sadu jako nabídku.

| Klávesová zkratka | Funkce |
| ------ | -------- |
| `Print Screen` | Snímek obrazovky |
| `Super + Ctrl + Alt + C` | Snímek obrazovky |
| `Alt + Print Screen` | Nahrávání obrazovky (nebo zastavení toho, které právě běží) |
| `Super + Print Screen` | Výběr barvy |
| `Super + Ctrl + Print Screen` | Extrahovat text z oblasti |
| `Super + Ctrl + C` | Nabídka zachytávání |
| `Super + Ctrl + .` | Překódovat obrázek nebo video |

## Snímky obrazovky

Stiskněte `Print Screen` (nebo `Super + Ctrl + Alt + C`) a Omasnap zachytí zaměřený monitor dřív, než se objeví jeho překryvná vrstva, takže se pod vámi nic neposune, zatímco míříte. Přetáhněte volnou oblast, klikněte na okno, abyste ho zachytili, nebo klikněte na prázdné místo, abyste zachytili celý monitor. Před kreslením stiskněte `S`, abyste zachytili posouvající se oblast. Změnili jste názor? Stiskněte stejnou klávesu znovu a Omasnap zavřete.

Po vybrání oblasti Omasnap snímek uloží, zkopíruje ho do schránky a na 10 sekund zobrazí náhled. Pomocí tlačítka pro připnutí v náhledu nebo `Ctrl + P` ho udržíte na obrazovce, nebo zvolte Edit a anotujte ho.

Editor anotací umí kreslit šipky, čáry, tvary, zvýraznění, číslované značky, text a bezpečné redakce; oříznout nebo vyříznout část obrázku; provést OCR jeho textu; a přidat pozadí. V editoru stiskněte `Enter` pro zkopírování a uložení hotového PNG, `Ctrl + C` pro jeho zkopírování bez uložení nebo `Ctrl + S` pro jeho uložení bez kopírování.

Uložené snímky obrazovky ve výchozím nastavení končí v `~/Pictures/Screenshots` s názvem jako `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavte `OMASNAP_SCREENSHOT_DIR`, abyste použili jiný adresář — kam umístit proměnné prostředí relace, najdete v [častých dotazech](46-faq.md). Omasnap adresář vytvoří, když ukládá první snímek. Nastavte `[output] autosave = false` v `~/.config/omasnap/omasnap.conf`, abyste automatické ukládání zakázali.

Z terminálu otevře `omarchy screenshot` stejnou překryvnou vrstvu a můžete si zvolit její výchozí režim: `omarchy capture screenshot region`, `windows`, `fullscreen` nebo `scroll`. Druhý argument `copy` nebo `save` přeskočí náhled a pošle snímek rovnou do daného cíle. Pro úpravu před výstupem použijte `omarchy screenshot --editor=overlay` pro editor na celou obrazovku nebo `omarchy screenshot --editor=window` pro samostatné okno.

### Ovládání výběru z klávesnice

Dokud je výběr otevřený, vůbec nemusíte používat myš:

| Klávesa | Funkce |
| --- | -------- |
| `S` | Přepnout režim posouvající se oblasti |
| `Super + Arrow keys` | Přesouvat se mezi okny v režimu oken |
| `Return` | Zachytit zvýrazněné okno |
| `Ctrl + A` | Zachytit celý zaměřený monitor |
| `R` | Obnovit poslední oblast nakreslenou v této relaci |
| `Esc` | Zavřít Omasnap |

Tyto vazby existují jen tehdy, když je Omasnap otevřený, takže nemohou kolidovat s ničím ve vaší vlastní konfiguraci.

## Nahrávání obrazovky

`Alt + Print Screen` otevře _Trigger > Capture > Screenrecord_, které se zeptá, co chcete mít na zvukové stopě: žádné audio, audio plochy, plochu plus mikrofon, nebo plochu plus mikrofon plus webkameru. Ta poslední možnost se zobrazí jen tehdy, pokud máte skutečně připojenou kameru. Vyberte jednu a výběr nahrávání v Omarchy vám umožní přetáhnout oblast nebo kliknout na okno či monitor.

Nahrávání běží na gpu-screen-recorder, který kóduje na GPU při 60fps a v případě potřeby se vrátí na CPU. Výsledkem je MP4 v `~/Videos` s názvem `screenrecording-2026-08-13_14-22-05.mp4`. Nastavte `OMARCHY_SCREENRECORD_DIR`, abyste to změnili — ale mějte na paměti, že na rozdíl od adresáře pro snímky obrazovky musí tento už existovat, jinak se nahrávání odmítne spustit.

Během nahrávání se v liště objeví malý indikátor. Kliknutím na něj nahrávání zastavíte. Zastavit ho můžete také znovu pomocí `Alt + Print Screen` nebo pomocí položky _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, která se zobrazuje jen tehdy, když se skutečně něco nahrává.

Zastavení před předáním souboru provede trochu úklidu: první snímek se ořízne, a pokud je přítomné audio, normalizuje se na -14 LUFS, přičemž prasknutí ze zachytávání PipeWire na úplném začátku se ztlumí. Poté se objeví oznámení s miniaturkou z nahrávky. Klikněte na něj a soubor se přehraje v mpv.

### Překryvná vrstva webkamery

Když nahráváte s webkamerou, kamera se objeví jako připnuté, oříznuté okno na výšku v pravém dolním rohu čehokoli, co nahráváte. Pokud leží na něčem, co potřebujete, změňte jeho velikost za chodu:

| Klávesová zkratka | Funkce |
| ------ | -------- |
| `Super + Alt + [` | Zmenšit překryvnou vrstvu webkamery |
| `Super + Alt + ]` | Zvětšit překryvnou vrstvu webkamery |

Existují tři velikosti — malá, střední a velká — a klávesové zkratky mezi nimi přeskakují. Střední je výchozí. Jsou úměrné nahrávce, takže kamera zabírá stejný podíl snímku, ať už nahráváte 1080p monitor, nebo 6K monitor. A pokud jste nahrávali oblast místo celé obrazovky, překryvná vrstva se ukotví do rohu této oblasti místo rohu monitoru, takže zůstane uvnitř záběru.

Můžete ji také volat přímo pomocí `omarchy-capture-webcam-resize small` nebo `reset` pro návrat na střední velikost.

## Text, QR kódy a barvy

`Super + Ctrl + Print Screen` vybere oblast a provede OCR do schránky. Tomu se pořádně věnuje [Extrakce textu a diktování](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ dělá stejný trik pro QR kódy. Vyberte oblast s kódem a dekódovaná hodnota se dostane do schránky. Hledá pouze QR kódy — hustý obsah obrazovky má jinak ve zvyku falešně se tvářit jako čárový kód. Stojí za to vědět: dekódovaná hodnota jde do schránky a nikam jinam. Nevytiskne se, není v oznámení a je označená jako citlivá, takže nezůstane v [historii schránky](08-unified-clipboard-history.md). QR kódy běžně nesou tajemství — například URI `otpauth://` za nastavovacím kódem pro 2FA — a to v logu nechcete. Vkládání přesto funguje v pohodě.

`Super + Print Screen` (nebo _Trigger > Capture > Color_) promění kurzor v kapátko. Klikněte na cokoli na obrazovce a barva skončí ve schránce. Stiskněte klávesovou zkratku znovu, abyste se vrátili zpět bez výběru.

## Překódování před sdílením

Nahrávka obrazovky ve 4K nebo syrový HEIC z telefonu je často příliš velká na to, abyste ji jen tak poslali. `Super + Ctrl + .` (nebo _Trigger > Transcode_) to vyřeší. Nabídne vám fuzzy výběr souboru nad `~/Pictures` a `~/Videos` a poté se zeptá na formát a velikost.

Obrázky jdou do jpg nebo png ve vysoké, střední nebo nízké kvalitě, které omezují šířku na 3160, 2160 a 1080 pixelů. Videa jdou do mp4 nebo animovaného gif ve 4k, 1080p nebo 720p. Převedený soubor se zapíše vedle originálu s rozlišením v názvu — `demo-1080p.mp4` — a cesta se zkopíruje do schránky jako URI souboru, takže ho můžete vložit přímo do aplikace, která přijímá soubory přetažením.

Funguje to i z terminálu, pokud už víte, co chcete: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Existuje také `omarchy transcode ascii`, které promění obrázek v ASCII art — to je hlavně pro [branding](41-branding.md).

## Poslání někam dál

Jakmile máte soubor, `Super + Ctrl + S` otevře nabídku Share a pošle ho na jiné zařízení ve vaší síti přes LocalSend. Podrobnosti najdete v [GUIs](22-guis.md).
