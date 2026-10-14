# Snímky obrazovky a nahrávání

Všechno, co můžete z obrazovky získat, visí na klávese Print Screen. Jedna klávesa sama o sobě pořídí obrázek a modifikátory pořídí nahrávání, barvu nebo text uvnitř oblasti. Pokud vaše klávesnice vůbec nemá klávesu Print Screen, `Super + Ctrl + C` otevře stejnou sadu jako nabídku.

| Klávesová zkratka | Funkce |
| ------ | -------- |
| `Print Screen` | Snímek obrazovky |
| `Alt + Print Screen` | Nahrávání obrazovky (nebo zastavit to spuštěné) |
| `Super + Print Screen` | Výběr barvy |
| `Super + Ctrl + Print Screen` | Extrahovat text z oblasti |
| `Super + Ctrl + C` | Nabídka Zachytit |
| `Super + Ctrl + .` | Překódovat obrázek nebo video |

## Snímky obrazovky

Stiskněte `Print Screen` a Omasnap zachytí zaměřený monitor dříve, než se objeví jeho překryv, takže se pod vámi nic nepohne, zatímco míříte. Přetáhněte volnou oblast, klikněte na okno a zachyťte ho, nebo klikněte na prázdné místo a zachyťte celý monitor. Před kreslením stiskněte `S` pro zachycení posouvací oblasti. Změnili jste názor? Stiskněte znovu `Print Screen` a Omasnap zavřete.

Po výběru oblasti Omasnap uloží snímek, zkopíruje ho do schránky a ukáže náhled po dobu 10 sekund. Pomocí tlačítka připnutí v náhledu nebo `Ctrl + P` ho ponecháte na obrazovce, nebo vyberte Upravit a opatřete ho poznámkami.

Editační editor umí kreslit šipky, čáry, tvary, zvýraznění, číslované značky, text a bezpečné redakce; oříznout nebo vyříznout část obrázku; provést OCR jeho textu; a přidat pozadí. V editoru stiskněte `Enter` pro kopírování a uložení hotového PNG, `Ctrl + C` pro kopírování bez uložení, nebo `Ctrl + S` pro uložení bez kopírování.

Uložené snímky obrazovky ve výchozím nastavení končí v `~/Pictures/Screenshots` s názvem jako `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavte `OMASNAP_SCREENSHOT_DIR` pro použití jiného adresáře — kde umístit proměnné prostředí relace, viz [FAQ](46-faq.md). Omasnap adresář vytvoří, když ukládá první snímek. Nastavte `[output] autosave = false` v `~/.config/omasnap/omasnap.conf` pro zakázání automatického ukládání.

Z terminálu `omarchy screenshot` otevře tentýž překryv a můžete si vybrat jeho počáteční režim: `omarchy capture screenshot region`, `windows`, `fullscreen`, nebo `scroll`. Druhý argument `copy` nebo `save` přeskočí náhled a pošle snímek přímo do tohoto cíle. Chcete-li před výstupem upravovat, použijte `omarchy screenshot --editor=overlay` pro editor na celou obrazovku nebo `omarchy screenshot --editor=window` pro samostatné okno.

### Ovládání výběru z klávesnice

Zatímco je výběr nahoře, vůbec nemusíte používat myš:

| Klávesa | Funkce |
| --- | -------- |
| `S` | Přepnout režim posouvací oblasti |
| `Super + Arrow keys` | Pohybovat se mezi okny v režimu oken |
| `Return` | Zachytit zvýrazněné okno |
| `Ctrl + A` | Zachytit celý zaměřený monitor |
| `R` | Obnovit poslední oblast nakreslenou v této relaci |
| `Esc` | Zavřít Omasnap |

Tyto zkratky existují, jen dokud je Omasnap otevřený, takže nemohou kolidovat s ničím ve vaší vlastní konfiguraci.

## Nahrávání obrazovky

`Alt + Print Screen` otevře _Akce > Zachytit > Nahrávání obrazovky_, které se zeptá, co chcete mít na zvukové stopě: žádný zvuk, zvuk plochy, plochu plus mikrofon, nebo plochu plus mikrofon plus webovou kameru. Poslední možnost se ukáže, jen pokud máte skutečně připojenou kameru. Vyberte jednu a nahrávací výběr Omarchy vám umožní přetáhnout oblast nebo kliknout na okno či monitor.

Nahrávání běží na gpu-screen-recorder, který kóduje na GPU při 60 fps a v případě potřeby se vrátí k CPU. Výsledkem je MP4 v `~/Videos` s názvem `screenrecording-2026-08-13_14-22-05.mp4`. Nastavte `OMARCHY_SCREENRECORD_DIR` a změňte to — ale všimněte si, že na rozdíl od adresáře snímků obrazovky tento už musí existovat, jinak se nahrávání odmítne spustit.

Během nahrávání se na panelu objeví malý ukazatel. Klikněte na něj pro zastavení. Zastavit můžete také opětovným stisknutím `Alt + Print Screen` nebo položkou _Zastavit nahrávání_ v _Akce > Zachytit > Nahrávání obrazovky_, která se objeví, jen když se něco skutečně nahrává.

Zastavení provede trochu úklidu, než vám předá soubor: první snímek se ořízne, a pokud je přítomný zvuk, normalizuje se na -14 LUFS přičemž pop zachycení PipeWire na úplném začátku je ztlumen. Poté se objeví oznámení s miniaturu z nahrávání. Klikněte na něj a soubor přehrajte v mpv.

### Překryv webové kamery

Když nahráváte s webovou kamerou, kamera se objeví jako připnuté, oříznuté okno na výšku v pravém dolním rohu toho, co nahráváte. Pokud sedí na něčem, co potřebujete, změňte jeho velikost za běhu:

| Klávesová zkratka | Funkce |
| ------ | -------- |
| `Super + Alt + [` | Zmenšit překryv webové kamery |
| `Super + Alt + ]` | Zvětšit překryv webové kamery |

Existují tři velikosti — malá, střední a velká — a klávesové zkratky mezi nimi krokují. Výchozí je střední. Jsou úměrné nahrávání, takže kamera zabírá stejný podíl snímku, ať už nahráváte monitor 1080p nebo 6K. A pokud jste nahrávali oblast místo celého displeje, překryv se ukotví do rohu této oblasti místo rohu monitoru, takže zůstane uvnitř záběru.

Můžete ho také volat přímo pomocí `omarchy-capture-webcam-resize small`, nebo `reset` pro návrat ke střední.

## Text, QR kódy a barvy

`Super + Ctrl + Print Screen` vybere oblast a provede její OCR do schránky. To je řádně popsáno v [Extrakce textu a diktování](11-text-extraction-dictation.md).

_Akce > Zachytit > QR kód_ dělá stejný trik pro QR kódy. Vyberte oblast s kódem a dekódovaná hodnota půjde do schránky. Hledá pouze QR kódy — hustý obsah obrazovky má jinak ve zvyku falešně pozitivně vyhodnocovat jako čárový kód. Důležité vědět: dekódovaná hodnota jde do schránky a nikam jinam. Není vytištěna, není v oznámení a je označena jako citlivá, takže nezůstává v [historii schránky](08-unified-clipboard-history.md). QR kódy běžně nesou tajemství — například URI `otpauth://` za kódem pro nastavení 2FA — a to v logu nechcete. Vkládání přesto funguje dobře.

`Super + Print Screen` (nebo _Akce > Zachytit > Barva_) promění kurzor v kapátko. Klikněte na cokoli na obrazovce a barva přistane ve schránce. Stiskněte klávesovou zkratku znovu a vycouvejte bez výběru.

## Překódování před sdílením

Nahrávání obrazovky ve 4K nebo surový HEIC z telefonu je často příliš velký na pouhé odeslání. `Super + Ctrl + .` (nebo _Akce > Překódovat_) to napraví. Nabídne vám fuzzy výběr souboru přes `~/Pictures` a `~/Videos` a poté se zeptá na formát a velikost.

Obrázky jdou do jpg nebo png ve vysoké, střední nebo nízké kvalitě, které omezují šířku na 3160, 2160 a 1080 pixelů. Videa jdou do mp4 nebo animovaného gifu ve 4k, 1080p nebo 720p. Převedený soubor se zapíše vedle originálu s rozlišením v názvu — `demo-1080p.mp4` — a cesta se zkopíruje do schránky jako URI souboru, takže ho můžete vložit přímo do aplikace, která přijímá upouštění souborů.

Funguje to i z terminálu, pokud už víte, co chcete: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Existuje také `omarchy transcode ascii`, který promění obrázek v ASCII art — ten je hlavně pro [branding](41-branding.md).

## Odeslání někam jinam

Jakmile máte soubor, `Super + Ctrl + S` otevře nabídku Sdílet a pošle ho na jiné zařízení ve vaší síti přes LocalSend. Viz [GUI](22-guis.md).
