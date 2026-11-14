# Snímky obrazovky a nahrávání

Vše, co můžete sebrat z obrazovky, visí na klávese Print Screen. Samotná klávesa pořídí obrázek a modifikátory pořídí nahrávku, barvu nebo text uvnitř oblasti. Pokud vaše klávesnice klávesu Print Screen vůbec nemá, `Super + Ctrl + Alt + C` pořídí stejný snímek obrazovky a `Super + Ctrl + C` otevře celou sadu jako nabídku.

| Klávesová zkratka | Funkce |
| ------ | -------- |
| `Print Screen` | Snímek obrazovky |
| `Super + Ctrl + Alt + C` | Snímek obrazovky |
| `Alt + Print Screen` | Nahrávání obrazovky (nebo zastavení právě běžícího) |
| `Super + Print Screen` | Výběr barvy |
| `Super + Ctrl + Print Screen` | Extrahovat text z oblasti |
| `Super + Ctrl + C` | Nabídka zachytávání |
| `Super + Ctrl + .` | Překódovat obrázek nebo video |

## Snímky obrazovky

Stiskněte `Print Screen` (nebo `Super + Ctrl + Alt + C`) a Omasnap zachytí zaměřený monitor dřív, než se objeví jeho překryvná vrstva, takže se pod vámi nic neposune, zatímco míříte. Táhněte volnou oblast, klikněte na okno, abyste ho zachytili, nebo klikněte na prázdné místo, abyste zachytili celý monitor. Stiskněte `S` před kreslením, abyste zachytili posouvající se oblast. Změnili jste názor? Stiskněte stejnou klávesu znovu, abyste Omasnap zavřeli.

Po výběru oblasti Omasnap zachycení uloží, zkopíruje ho do schránky a zobrazí oznámení s jeho miniaturu, stejně jako to dělá uložené nahrávání obrazovky. Zvolte Open, abyste uložený snímek zobrazili v prohlížeči obrázků, nebo Edit, abyste ho anotovali.

Editor anotací umí kreslit šipky, čáry, tvary, zvýraznění, číslované značky, text a bezpečné redakce; oříznout nebo vyříznout část obrázku; provést OCR jeho textu; a přidat pozadí. V editoru stiskněte `Enter` pro zkopírování a uložení hotového PNG, `Ctrl + C` pro jeho zkopírování bez uložení nebo `Ctrl + S` pro jeho uložení bez kopírování.

Uložené snímky obrazovky končí ve výchozím nastavení v `~/Pictures/Screenshots`, s názvem jako `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavte `OMASNAP_SCREENSHOT_DIR`, abyste použili jiný adresář — viz [časté dotazy](46-faq.md), kam umístit proměnné prostředí relace. Omasnap adresář vytvoří, když ukládá první snímek. Nastavte `[output] autosave = false` v `~/.config/omasnap/omasnap.conf`, abyste zakázali automatické ukládání; zachycení jsou pak pouze kopírována a zobrazena v náhledu po dobu 10 sekund, který můžete nechat na obrazovce pomocí jeho tlačítka pro připnutí nebo `Ctrl + P`.

Z terminálu `omarchy screenshot` otevře stejnou překryvnou vrstvu a můžete zvolit její počáteční režim: `omarchy capture screenshot region`, `windows`, `fullscreen` nebo `scroll`. Druhý argument `copy` nebo `save` pošle snímek rovnou do daného cíle. Pro úpravu před výstupem použijte `omarchy screenshot --editor=overlay` pro editor na celou obrazovku nebo `omarchy screenshot --editor=window` pro samostatné okno.

### Ovládání výběru z klávesnice

Když je výběr otevřený, vůbec nemusíte používat myš:

| Klávesa | Funkce |
| --- | -------- |
| `S` | Přepnout režim posouvající se oblasti |
| `Super + Arrow keys` | Přesouvat se mezi okny v režimu Window |
| `Return` | Zachytit zvýrazněné okno |
| `Ctrl + A` | Zachytit celý zaměřený monitor |
| `R` | Obnovit poslední oblast nakreslenou v této relaci |
| `Esc` | Zavřít Omasnap |

Tato přiřazení existují pouze tehdy, když je Omasnap otevřený, takže nemohou kolidovat s ničím ve vaší vlastní konfiguraci.

## Nahrávání obrazovky

`Alt + Print Screen` otevře _Trigger > Capture > Screenrecord_, které se zeptá, co chcete na zvukové stopě: žádný zvuk, zvuk plochy, plochu plus mikrofon, nebo plochu plus mikrofon plus webkameru. Ta poslední možnost se zobrazí pouze tehdy, pokud máte skutečně připojenou kameru. Vyberte jednu a výběr nahrávání v Omarchy vám umožní táhnout oblast nebo kliknout na okno či monitor.

Nahrávání běží na gpu-screen-recorder, který kóduje na GPU při 60fps a v případě nutnosti se vrátí k CPU. Výsledkem je MP4 v `~/Videos` s názvem `screenrecording-2026-08-13_14-22-05.mp4`. Nastavte `OMARCHY_SCREENRECORD_DIR`, abyste to změnili — ale všimněte si, že na rozdíl od adresáře pro snímky obrazovky musí tento již existovat, jinak nahrávání odmítne začít.

Když nahráváte, objeví se v liště malý indikátor. Klikněte na něj pro zastavení. Můžete také zastavit znovu pomocí `Alt + Print Screen` nebo pomocí položky _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, která se zobrazí pouze tehdy, když něco skutečně nahrává.

Zastavení provede trochu úklidu, než vám předá soubor: první snímek se ořízne, a pokud je přítomen zvuk, je normalizován na -14 LUFS, přičemž prasknutí zachytávání PipeWire na úplném začátku je ztlumeno. Pak se objeví oznámení s miniaturu z nahrávky. Klikněte na něj, abyste soubor přehráli v mpv.

### Překryvná vrstva webkamery

Když nahráváte s webkamerou, kamera se objeví jako připnuté, oříznuté okno na výšku v pravém dolním rohu čehokoli, co nahráváte. Pokud sedí na něčem, co potřebujete, změňte její velikost za chodu:

| Klávesová zkratka | Funkce |
| ------ | -------- |
| `Super + Alt + [` | Zmenšit překryvnou vrstvu webkamery |
| `Super + Alt + ]` | Zvětšit překryvnou vrstvu webkamery |

Existují tři velikosti — malá, střední a velká — a klávesové zkratky mezi nimi krokuje. Střední je výchozí. Jsou proporcionální k nahrávce, takže kamera zabírá stejný podíl snímku, ať už nahráváte monitor 1080p, nebo 6K. A pokud jste nahrávali oblast místo celé obrazovky, překryvná vrstva se ukotví k rohu dané oblasti místo rohu monitoru, takže zůstane uvnitř záběru.

Můžete ji také volat přímo pomocí `omarchy-capture-webcam-resize small`, nebo `reset` pro návrat ke střední.

## Text, QR kódy a barvy

`Super + Ctrl + Print Screen` vybere oblast a provede její OCR do schránky. To je řádně popsáno v [Extrakce textu a diktování](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ dělá stejný trik pro QR kódy. Vyberte oblast s kódem a dekódovaná hodnota se dostane do schránky. Hledá pouze QR kódy — hustý obsah obrazovky má jinak ve zvyku falešně pozitivně vycházet jako čárový kód. Stojí za to vědět: dekódovaná hodnota jde do schránky a nikam jinam. Není vytištěna, není v oznámení a je označena jako citlivá, takže nezůstává v [historii schránky](08-unified-clipboard-history.md). QR kódy běžně nesou tajemství — například `otpauth://` URI za nastavovacím kódem 2FA — a to v logu nechcete. Vkládání stále funguje dobře.

`Super + Print Screen` (nebo _Trigger > Capture > Color_) promění kurzor v kapátko. Klikněte na cokoli na obrazovce a barva přistane ve schránce. Stiskněte klávesovou zkratku znovu, abyste se vrátili zpět bez výběru.

## Překódování před sdílením

Nahrávka obrazovky ve 4K nebo syrové HEIC z vašeho telefonu je často příliš velká na to, abyste ji jen tak poslali. `Super + Ctrl + .` (nebo _Trigger > Transcode_) to napraví. Nabídne vám fuzzy výběr souboru nad `~/Pictures` a `~/Videos`, pak se zeptá na formát a velikost.

Obrázky jdou do jpg nebo png ve vysoké, střední nebo nízké kvalitě, které omezují šířku na 3160, 2160 a 1080 pixelů. Videa jdou do mp4 nebo animovaného gif v 4k, 1080p nebo 720p. Převedený soubor je zapsán vedle originálu s rozlišením v názvu — `demo-1080p.mp4` — a cesta je zkopírována do schránky jako souborové URI, takže ji můžete vložit přímo do aplikace, která přijímá přetažení souborů.

Funguje to i z terminálu, pokud už víte, co chcete: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Existuje také `omarchy transcode ascii`, které promění obrázek v ASCII art — to je většinou pro [branding](41-branding.md).

## Poslání někam

Jakmile máte soubor, `Super + Ctrl + S` otevře nabídku Share a pošle ho na jiné zařízení ve vaší síti přes LocalSend. Viz [GUI](22-guis.md) pro to.
