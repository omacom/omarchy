# Snímky obrazovky a nahrávání

Vše, co můžete sebrat z obrazovky, visí na klávese Print Screen. Samotná klávesa pořídí obrázek a modifikátory pořídí nahrávku, barvu nebo text uvnitř oblasti. Pokud vaše klávesnice klávesu Print Screen vůbec nemá, `Super + Ctrl + Alt + C` pořídí stejný snímek obrazovky a `Super + Ctrl + C` otevře celou sadu jako nabídku.

| Hotkey | Function |
| ------ | -------- |
| `Print Screen` | Snímek obrazovky |
| `Super + Ctrl + Alt + C` | Snímek obrazovky |
| `Alt + Print Screen` | Nahrávání obrazovky (nebo zastavení právě běžícího) |
| `Super + Print Screen` | Výběr barvy |
| `Super + Ctrl + Print Screen` | Extrahovat text z oblasti |
| `Super + Ctrl + C` | Nabídka zachytávání |
| `Super + Ctrl + .` | Překódovat obrázek nebo video |

## Snímky obrazovky

Stiskněte `Print Screen` (nebo `Super + Ctrl + Alt + C`) a Omasnap zachytí monitor s fokusem dříve, než se objeví jeho překryvná vrstva, takže se pod vámi nic neposune, zatímco míříte. Přetáhněte volnou oblast, kliknutím na okno ho zachyťte, nebo kliknutím na volné místo zachyťte celý monitor. Před kreslením stiskněte `S`, chcete-li zachytit posouvající se oblast. Změnili jste názor? Stejnou klávesou Omasnap znovu zavřete.

Po výběru oblasti Omasnap snímek uloží, zkopíruje ho do schránky a zobrazí oznámení s jeho miniaturou, stejně jako to dělá uložená nahrávka obrazovky. Vyberte Open, chcete-li uložený snímek zobrazit v prohlížeči obrázků, nebo Edit, chcete-li ho opatřit poznámkami.

Editor poznámek umí kreslit šipky, čáry, tvary, zvýraznění, číslované značky, text a bezpečné redakce; oříznout nebo vyříznout část obrázku; rozpoznat jeho text pomocí OCR; a přidat pozadí. V editoru stiskněte `Enter` pro zkopírování a uložení hotového PNG, `Ctrl + C` pro zkopírování bez uložení, nebo `Ctrl + S` pro uložení bez kopírování.

Uložené snímky obrazovky končí ve výchozím nastavení v `~/Pictures/Screenshots` pod názvem jako `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavte `OMASNAP_SCREENSHOT_DIR`, chcete-li použít jiný adresář — viz [časté dotazy](46-faq.md), kam patří proměnné prostředí relace. Omasnap adresář vytvoří, když ukládá první snímek. Nastavte `[output] autosave = false` v `~/.config/omasnap/omasnap.conf`, chcete-li automatické ukládání vypnout; snímky se pak pouze kopírují a zobrazují v náhledu po dobu 7 sekund, který můžete nechat na obrazovce pomocí jeho tlačítka připnutí nebo `Ctrl + P`.

Z terminálu `omarchy screenshot` otevře stejnou překryvnou vrstvu a můžete si zvolit její počáteční režim: `omarchy capture screenshot region`, `windows`, `fullscreen` nebo `scroll`. Druhý argument `copy` nebo `save` odešle snímek rovnou do daného cíle. Chcete-li před výstupem upravovat, použijte `omarchy screenshot --editor=overlay` pro editor přes celou obrazovku nebo `omarchy screenshot --editor=window` pro samostatné okno.

### Ovládání výběru z klávesnice

Dokud je výběr otevřený, myš vůbec nemusíte používat:

| Key | Function |
| --- | -------- |
| `S` | Přepnout režim posouvající se oblasti |
| `Super + Arrow keys` | Přesouvat se mezi okny v režimu oken |
| `Return` | Zachytit zvýrazněné okno |
| `Ctrl + A` | Zachytit celý monitor s fokusem |
| `R` | Obnovit poslední nakreslenou oblast v této relaci |
| `Esc` | Zavřít Omasnap |

Tyto vazby existují pouze, dokud je Omasnap otevřený, takže nemohou kolidovat s ničím ve vaší vlastní konfiguraci.

## Nahrávání obrazovky

`Alt + Print Screen` otevře _Trigger > Capture > Screenrecord_, které se zeptá, co chcete na zvukové stopě: žádný zvuk, zvuk plochy, plochu plus mikrofon, nebo plochu plus mikrofon plus webkameru. Ta poslední možnost se zobrazí pouze tehdy, pokud máte skutečně připojenou kameru. Vyberte jednu a výběr nahrávání v Omarchy vám umožní přetáhnout oblast nebo kliknout na okno či monitor.

Nahrávání běží na gpu-screen-recorder, který kóduje na GPU při 60fps a v případě potřeby se vrátí k CPU; na GPU, které nepodporuje, například Apple Silicon, Omarchy místo toho nahrává pomocí wf-recorder. Výsledkem je MP4 v `~/Videos` s názvem `screenrecording-2026-08-13_14-22-05.mp4`. Nastavte `OMARCHY_SCREENRECORD_DIR`, chcete-li to změnit — ale všimněte si, že na rozdíl od adresáře pro snímky obrazovky musí tento již existovat, jinak nahrávání odmítne začít.

Během nahrávání se v liště objeví malý indikátor. Kliknutím ho zastavíte. Zastavit můžete také znovu pomocí `Alt + Print Screen` nebo pomocí položky _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, která se zobrazí pouze, dokud se skutečně něco nahrává.

Zastavení před předáním souboru provede trochu úklidu: první snímek se ořízne, a pokud je přítomen zvuk, normalizuje se na -14 LUFS, přičemž prasknutí zachycení PipeWire na samém začátku se ztlumí. Poté se objeví oznámení s miniaturou z nahrávky. Vyberte _Open_, chcete-li soubor přehrát v Omaview, nebo _Cut_, chcete-li ho oříznout v Omacut.

### Překryvná vrstva webkamery

Když nahráváte s webkamerou, kamera se objeví jako připnuté, oříznuté okno na výšku v pravém dolním rohu toho, co nahráváte. Pokud sedí na něčem, co potřebujete, změňte jeho velikost za běhu:

| Hotkey | Function |
| ------ | -------- |
| `Super + Alt + [` | Zmenšit překryvnou vrstvu webkamery |
| `Super + Alt + ]` | Zvětšit překryvnou vrstvu webkamery |

Existují tři velikosti — malá, střední a velká — a klávesové zkratky mezi nimi krokuje. Střední je výchozí. Jsou úměrné nahrávce, takže kamera zabírá stejný podíl záběru, ať nahráváte 1080p monitor nebo 6K monitor. A pokud jste nahrávali oblast, a ne celou obrazovku, překryvná vrstva se ukotví k rohu dané oblasti, a ne monitoru, takže zůstane uvnitř záběru.

Můžete ji také volat přímo pomocí `omarchy-capture-webcam-resize small`, nebo `reset` pro návrat ke střední.

## Text, QR kódy a barvy

`Super + Ctrl + Print Screen` vybere oblast a její text rozpozná pomocí OCR do schránky. Tomu se řádně věnuje [Extrakce textu a diktování](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ dělá stejný trik pro QR kódy. Vyberte oblast s kódem a dekódovaná hodnota půjde do schránky. Hledá pouze QR kódy — hustý obsah obrazovky má jinak ve zvyku falešně se tvářit jako čárový kód. Stojí za to vědět: dekódovaná hodnota jde do schránky a nikam jinam. Nevypisuje se, není v oznámení a je označena jako citlivá, takže nezůstane v [historii schránky](08-unified-clipboard-history.md). QR kódy běžně nesou tajemství — například URI `otpauth://` za nastavovacím kódem 2FA — a to v logu nechcete. Vkládání stále funguje normálně.

`Super + Print Screen` (nebo _Trigger > Capture > Color_) promění kurzor v kapátko. Klikněte na cokoli na obrazovce a barva skončí ve schránce. Stejnou klávesovou zkratkou akci zrušíte, aniž byste něco vybrali.

## Překódování před sdílením

Nahrávka obrazovky v 4K nebo surový HEIC z telefonu je často příliš velký na to, abyste ho jen tak poslali. `Super + Ctrl + .` (nebo _Trigger > Transcode_) to řeší. Nabídne vám fuzzy výběr souboru nad `~/Pictures` a `~/Videos` a poté se zeptá na formát a velikost.

Obrázky jdou do jpg nebo png ve vysoké, střední nebo nízké úrovni, které omezují šířku na 3160, 2160 a 1080 pixelů. Videa jdou do mp4 nebo animovaného gif v 4k, 1080p nebo 720p. Převedený soubor se zapíše vedle originálu s rozlišením v názvu — `demo-1080p.mp4` — a cesta se zkopíruje do schránky jako URI souboru, takže ho můžete vložit přímo do aplikace, která přijímá přetažení souborů.

Funguje to i z terminálu, pokud už víte, co chcete: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Existuje také `omarchy transcode ascii`, které promění obrázek v ASCII art — to je většinou pro [branding](41-branding.md).

## Odeslání jinam

Jakmile máte soubor, `Super + Ctrl + S` otevře nabídku Share a odešle ho na jiné zařízení ve vaší síti přes LocalSend. Viz [grafická rozhraní](22-guis.md).
