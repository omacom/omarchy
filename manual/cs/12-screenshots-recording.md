# Snímky obrazovky a nahrávání

Vše, co můžete sejmout z obrazovky, visí na klávese Print Screen. Samotná klávesa pořídí snímek a modifikátory se postarají o nahrávku, barvu nebo text uvnitř oblasti. Pokud vaše klávesnice klávesu Print Screen vůbec nemá, `Super + Ctrl + Alt + C` pořídí stejný snímek obrazovky a `Super + Ctrl + C` otevře celou sadu jako nabídku.

| Klávesová zkratka | Funkce |
| ------ | -------- |
| `Print Screen` | Snímek obrazovky |
| `Super + Ctrl + Alt + C` | Snímek obrazovky |
| `Alt + Print Screen` | Nahrávání obrazovky (nebo zastavení právě běžícího) |
| `Super + Print Screen` | Výběr barvy |
| `Super + Ctrl + Print Screen` | Extrahovat text z oblasti |
| `Super + Ctrl + C` | Nabídka snímání |
| `Super + Ctrl + .` | Překódovat obrázek nebo video |

## Snímky obrazovky

Stiskněte `Print Screen` (nebo `Super + Ctrl + Alt + C`) a Omasnap zachytí monitor ve fokusu ještě předtím, než se objeví jeho překryvná vrstva, takže se vám při míření nic neposune. Přetažením vyberte libovolnou oblast, kliknutím na okno zachyťte okno, nebo kliknutím na volné místo zachyťte celý monitor. Před kreslením stiskněte `S`, chcete-li zachytit posouvající se oblast. Rozmysleli jste si to? Stiskněte stejnou klávesu znovu a Omasnap zavřete.

Po výběru oblasti Omasnap snímek uloží, zkopíruje do schránky a zobrazí oznámení s jeho miniaturu, podobně jako to dělá uložená nahrávka obrazovky. Zvolte Open, chcete-li uložený snímek zobrazit v prohlížeči obrázků, nebo Edit, chcete-li jej anotovat.

Editor anotací umí kreslit šipky, čáry, tvary, zvýraznění, číslované značky, text a bezpečná začernění; oříznout nebo vyříznout část obrázku; provést OCR jeho textu; a přidat pozadí. V editoru stiskněte `Enter` pro zkopírování a uložení hotového PNG, `Ctrl + C` pro zkopírování bez uložení, nebo `Ctrl + S` pro uložení bez kopírování.

Uložené snímky obrazovky končí ve výchozím nastavení v `~/Pictures/Screenshots` se jménem jako `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavte `OMASNAP_SCREENSHOT_DIR`, chcete-li použít jiný adresář — viz [FAQ](46-faq.md), kam umístit proměnné prostředí relace. Omasnap adresář vytvoří při uložení prvního snímku. Nastavením `[output] autosave = false` v `~/.config/omasnap/omasnap.conf` vypnete automatické ukládání; snímky se pak pouze kopírují a zobrazují v náhledu po dobu 10 sekund, který můžete nechat na obrazovce jeho tlačítkem připnutí nebo pomocí `Ctrl + P`.

Z terminálu otevře `omarchy screenshot` stejnou překryvnou vrstvu a můžete si zvolit její výchozí režim: `omarchy capture screenshot region`, `windows`, `fullscreen`, nebo `scroll`. Druhý argument `copy` nebo `save` pošle snímek rovnou do daného cíle. Chcete-li před výstupem upravovat, použijte `omarchy screenshot --editor=overlay` pro editor na celou obrazovku nebo `omarchy screenshot --editor=window` pro samostatné okno.

### Ovládání výběru z klávesnice

Když je výběr zobrazený, myš vůbec používat nemusíte:

| Klávesa | Funkce |
| --- | -------- |
| `S` | Přepnout režim posouvající se oblasti |
| `Super + Arrow keys` | Přesouvat se mezi okny v režimu oken |
| `Return` | Zachytit zvýrazněné okno |
| `Ctrl + A` | Zachytit celý monitor ve fokusu |
| `R` | Obnovit poslední oblast nakreslenou v této relaci |
| `Esc` | Zavřít Omasnap |

Tyto vazby existují pouze po dobu, kdy je Omasnap otevřený, takže nemohou kolidovat s ničím ve vaší vlastní konfiguraci.

## Nahrávání obrazovky

`Alt + Print Screen` otevře _Trigger > Capture > Screenrecord_, které se zeptá, co chcete mít ve zvukové stopě: žádný zvuk, zvuk plochy, plochu plus mikrofon, nebo plochu plus mikrofon plus webkameru. Ta poslední možnost se zobrazí pouze tehdy, máte-li skutečně připojenou kameru. Vyberte jednu a výběr nahrávání v Omarchy vám umožní přetažením vybrat oblast nebo kliknout na okno či monitor.

Nahrávání běží na gpu-screen-recorder, který kóduje na GPU při 60fps a v případě potřeby se vrátí k CPU. Výsledkem je MP4 v `~/Videos` s názvem `screenrecording-2026-08-13_14-22-05.mp4`. To změníte nastavením `OMARCHY_SCREENRECORD_DIR` — ale všimněte si, že na rozdíl od adresáře pro snímky obrazovky musí tento již existovat, jinak se nahrávání odmítne spustit.

Během nahrávání se v liště objeví malý indikátor. Kliknutím na něj nahrávání zastavíte. Zastavit můžete také opětovným stisknutím `Alt + Print Screen` nebo položkou _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, která se zobrazuje pouze tehdy, když se skutečně něco nahrává.

Zastavení před předáním souboru provede trochu úklidu: první snímek se ořízne a je-li přítomen zvuk, normalizuje se na -14 LUFS, přičemž lupnutí záznamu PipeWire na samém začátku se ztlumí. Poté se objeví oznámení s miniaturu z nahrávky. Kliknutím na něj soubor přehrajete v Omaview.

### Překryvná vrstva webkamery

Když nahráváte s webkamerou, kamera se objeví jako připnuté, oříznuté okno na výšku v pravém dolním rohu čehokoli, co nahráváte. Pokud sedí na něčem, co potřebujete, změňte jeho velikost za běhu:

| Klávesová zkratka | Funkce |
| ------ | -------- |
| `Super + Alt + [` | Zmenšit překryvnou vrstvu webkamery |
| `Super + Alt + ]` | Zvětšit překryvnou vrstvu webkamery |

Existují tři velikosti — malá, střední a velká — a klávesové zkratky mezi nimi přecházejí. Střední je výchozí. Jsou úměrné nahrávce, takže kamera zabírá stejnou část snímku, ať nahráváte 1080p monitor, nebo 6K monitor. A pokud jste nahrávali oblast, a ne celou obrazovku, překryvná vrstva se ukotví k rohu dané oblasti, a ne monitoru, takže zůstane uvnitř záběru.

Můžete ji také volat přímo pomocí `omarchy-capture-webcam-resize small`, nebo pomocí `reset` vrátit se ke střední.

## Text, QR kódy a barvy

`Super + Ctrl + Print Screen` vybere oblast a provede její OCR do schránky. To je řádně popsáno v [Extrakce textu a diktování](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ dělá stejný trik pro QR kódy. Vyberte oblast s kódem a dekódovaná hodnota se dostane do schránky. Hledá pouze QR kódy — hustý obsah obrazovky má jinak tendenci být falešně pozitivně detekován jako čárový kód. Stojí za to vědět: dekódovaná hodnota jde do schránky a nikam jinam. Nevypisuje se, není v oznámení a je označena jako citlivá, takže nezůstane v [historii schránky](08-unified-clipboard-history.md). QR kódy běžně nesou tajemství — například URI `otpauth://` za nastavovacím kódem 2FA — a to v logu nechcete. Vkládání stále funguje bez problémů.

`Super + Print Screen` (nebo _Trigger > Capture > Color_) promění kurzor v kapátko. Klikněte na cokoli na obrazovce a barva skončí ve schránce. Stiskněte klávesovou zkratku znovu, chcete-li odejít bez výběru.

## Překódování před sdílením

Nahrávka obrazovky ve 4K nebo surové HEIC z telefonu je často příliš velká na pouhé odeslání. `Super + Ctrl + .` (nebo _Trigger > Transcode_) to vyřeší. Nabídne vám fuzzy výběr souboru nad `~/Pictures` a `~/Videos` a poté se zeptá na formát a velikost.

Obrázky se převádějí do jpg nebo png ve vysoké, střední nebo nízké kvalitě, které omezují šířku na 3160, 2160 a 1080 pixelů. Videa se převádějí do mp4 nebo animovaného gif v rozlišení 4k, 1080p nebo 720p. Převedený soubor se zapíše vedle originálu s rozlišením v názvu — `demo-1080p.mp4` — a cesta se zkopíruje do schránky jako URI souboru, takže ji můžete vložit přímo do aplikace, která přijímá přetažené soubory.

Funguje to i z terminálu, pokud už víte, co chcete: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Existuje také `omarchy transcode ascii`, které promění obrázek v ASCII art — to je hlavně pro [branding](41-branding.md).

## Odeslání někam

Jakmile máte soubor, `Super + Ctrl + S` otevře nabídku Share a odešle jej na jiné zařízení ve vaší síti přes LocalSend. Viz [GUIs](22-guis.md) pro podrobnosti.
