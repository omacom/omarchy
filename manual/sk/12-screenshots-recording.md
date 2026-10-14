# Snímky obrazovky a nahrávanie

Všetko, čo môžete uchmatnúť z obrazovky, visí na klávese Print Screen. Jeden kláves sám urobí obrázok a modifikátory urobia nahrávku, farbu alebo text vnútri oblasti. Ak vaša klávesnica nemá vôbec kláves Print Screen, `Super + Ctrl + C` otvára tú istú sadu ako menu.

| Skratka | Funkcia |
| ------ | -------- |
| `Print Screen` | Snímka obrazovky |
| `Alt + Print Screen` | Nahrať obrazovku (alebo zastaviť bežiace nahrávanie) |
| `Super + Print Screen` | Kvapkadlo na farby |
| `Super + Ctrl + Print Screen` | Extrahovať text z oblasti |
| `Super + Ctrl + C` | Menu zachytenia |
| `Super + Ctrl + .` | Prekódovať obrázok alebo video |

## Snímky obrazovky

Stlačte `Print Screen` a Omasnap zachytí zameraný monitor skôr, než sa objaví jeho prekrytie, takže sa pod vami nič neposunie, kým mierite. Potiahnite voľnú oblasť, kliknite na okno, aby ste ho zachytili, alebo kliknite na voľné miesto, aby ste zachytili celý monitor. Stlačte `S` pred kreslením, aby ste zachytili rolujúcu oblasť. Zmenili ste názor? Znova stlačte `Print Screen`, aby ste Omasnap zrušili.

Po výbere oblasti Omasnap uloží zábery, skopíruje ho do schránky a ukáže ukážku na 10 sekúnd. Použite tlačidlo na pripnutie ukážky alebo `Ctrl + P`, aby ste ho nechali na obrazovke, alebo vyberte Upraviť, aby ste ho okomentovali.

Editor anotácií môže kresliť šípky, čiary, tvary, zvýraznenia, očíslované značky, text a bezpečné redakcie; orezávať alebo vystrihovať časť obrázka; robiť OCR jeho textu; a pridávať pozadie. V editore stlačte `Enter` na kopírovanie a uloženie dokončeného PNG, `Ctrl + C` na kopírovanie bez ukladania alebo `Ctrl + S` na uloženie bez kopírovania.

Uložené snímky obrazovky predvolene končia v `~/Pictures/Screenshots` s názvom ako `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavte `OMASNAP_SCREENSHOT_DIR` na použitie iného adresára — pozrite si [Časté otázky](46-faq.md), kam dať premenné prostredia relácie. Omasnap vytvorí adresár, keď ukladá prvú snímku. Nastavte `[output] autosave = false` v `~/.config/omasnap/omasnap.conf`, aby ste zakázali automatické ukladanie.

Z terminálu `omarchy screenshot` otvára to isté prekrytie a môžete si vybrať jeho počiatočný režim: `omarchy capture screenshot region`, `windows`, `fullscreen` alebo `scroll`. Druhý argument `copy` alebo `save` preskočí ukážku a odošle snímku priamo do tohto cieľa. Ak chcete upravovať pred výstupom, použite `omarchy screenshot --editor=overlay` na celobrazovkový editor alebo `omarchy screenshot --editor=window` na samostatné okno.

### Ovládanie výberu z klávesnice

Kým je výber zobrazený, nemusíte vôbec používať myš:

| Kláves | Funkcia |
| --- | -------- |
| `S` | Prepnúť režim rolujúcej oblasti |
| `Super + Arrow keys` | Pohybovať sa medzi oknami v režime Okná |
| `Return` | Zachytiť zvýraznené okno |
| `Ctrl + A` | Zachytiť celý zameraný monitor |
| `R` | Obnoviť poslednú oblasť nakreslenú v tejto relácii |
| `Esc` | Zrušiť Omasnap |

Tieto väzby existujú len, kým je Omasnap otvorený, takže nemôžu kolidovať s ničím vo vašej vlastnej konfigurácii.

## Nahrávanie obrazovky

`Alt + Print Screen` otvára _Akcie > Zachytiť > Nahrať obrazovku_, ktorá sa pýta, čo chcete na zvukovej stope: žiadny zvuk, zvuk pracovnej plochy, zvuk pracovnej plochy plus mikrofón, alebo zvuk pracovnej plochy plus mikrofón plus webkamera. To posledné sa objaví len, ak skutočne máte pripojenú kameru. Vyberte jedno a nahrávací výber Omarchy vám umožní potiahnuť oblasť alebo kliknúť na okno alebo monitor.

Nahrávanie beží na gpu-screen-recorder, ktorý kóduje na GPU pri 60 fps a v prípade potreby sa vráti na CPU. Výsledkom je MP4 v `~/Videos` s názvom `screenrecording-2026-08-13_14-22-05.mp4`. Nastavte `OMARCHY_SCREENRECORD_DIR`, aby ste to zmenili — ale všimnite si, že na rozdiel od adresára snímok obrazovky tento už musí existovať, inak sa nahrávanie odmietne spustiť.

Kým nahrávate, v lište sa objaví malý indikátor. Kliknite naň, aby ste zastavili. Môžete tiež zastaviť znova pomocou `Alt + Print Screen` alebo pomocou položky _Zastaviť nahrávanie_ pod _Akcie > Zachytiť > Nahrať obrazovku_, ktorá sa objaví len, kým sa skutočne niečo nahráva.

Zastavenie urobí trochu upratovania, než vám odovzdá súbor: prvý rámec sa oreže a ak existuje zvuk, normalizuje sa na -14 LUFS, pričom lupnutie zo zachytenia PipeWire úplne na začiatku sa stlmí. Potom sa objaví upozornenie s miniatúrou z nahrávky. Kliknite naň, aby ste súbor prehrali v mpv.

### Prekrytie webkamery

Keď nahrávate s webkamerou, kamera sa objaví ako pripnuté, orezané portrétové okno v pravom dolnom rohu čohokoľvek, čo nahrávate. Ak sedí na niečom, čo potrebujete, zmeňte jej veľkosť za chodu:

| Skratka | Funkcia |
| ------ | -------- |
| `Super + Alt + [` | Zmenšiť prekrytie webkamery |
| `Super + Alt + ]` | Zväčšiť prekrytie webkamery |

Existujú tri veľkosti — malá, stredná a veľká — a klávesové skratky medzi nimi prechádzajú. Stredná je predvolená. Sú proporcionálne k nahrávke, takže kamera zaberá rovnaký podiel rámca, či nahrávate 1080p monitor alebo 6K. A ak ste nahrávali oblasť namiesto celého displeja, prekrytie sa ukotví k rohu tejto oblasti namiesto rohu monitora, takže zostane vnútri záberu.

Môžete ho tiež zavolať priamo pomocou `omarchy-capture-webcam-resize small` alebo `reset`, aby ste sa vrátili na strednú.

## Text, QR kódy a farby

`Super + Ctrl + Print Screen` vyberie oblasť a urobí jej OCR do schránky. To je riadne opísané v [Extrakcii textu a diktovaní](11-text-extraction-dictation.md).

_Akcie > Zachytiť > QR kód_ robí ten istý trik pre QR kódy. Vyberte oblasť s kódom a dekódovaná hodnota ide do schránky. Hľadá len QR kódy — hustý obsah obrazovky má inak vo zvyku falošne pozitívne vyzerať ako čiarový kód. Stojí za to vedieť: dekódovaná hodnota ide do schránky a nikde inde. Nevypisuje sa, nie je v upozornení a je označená ako citlivá, takže nezostáva v [histórii schránky](08-unified-clipboard-history.md). QR kódy bežne nesú tajomstvá — napríklad URI `otpauth://` za nastavovacím kódom 2FA — a to nechcete mať v logu. Vkladanie stále funguje dobre.

`Super + Print Screen` (alebo _Akcie > Zachytiť > Farba_) zmení kurzor na kvapkadlo. Kliknite na čokoľvek na obrazovke a farba pristane v schránke. Znova stlačte klávesovú skratku, aby ste ustúpili bez výberu.

## Prekódovanie pred zdieľaním

Nahrávka obrazovky v 4K alebo surové HEIC z vášho telefónu sú často príliš veľké na jednoduché odoslanie. `Super + Ctrl + .` (alebo _Akcie > Prekódovať_) to napraví. Ponúkne vám fuzzy výber súborov cez `~/Pictures` a `~/Videos`, potom sa pýta na formát a veľkosť.

Obrázky idú do jpg alebo png vo vysokej, strednej alebo nízkej kvalite, ktoré obmedzujú šírku na 3160, 2160 a 1080 pixelov. Videá idú do mp4 alebo animovaného gif v 4k, 1080p alebo 720p. Konvertovaný súbor sa zapíše vedľa originálu s rozlíšením v názve — `demo-1080p.mp4` — a cesta sa skopíruje do schránky ako URI súboru, takže ho môžete priamo vložiť do aplikácie, ktorá prijíma ukladanie súborov.

Funguje to aj z terminálu, ak už viete, čo chcete: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Existuje aj `omarchy transcode ascii`, ktoré zmení obrázok na ASCII art — to je väčšinou na [branding](41-branding.md).

## Odoslanie niekam

Keď máte súbor, `Super + Ctrl + S` otvára menu Zdieľať a odošle ho inému zariadeniu vo vašej sieti cez LocalSend. Pozrite si [GUI](22-guis.md) pre to.
