# Snímky obrazovky a nahrávanie

Všetko, čo môžete zachytiť z obrazovky, visí na klávese Print Screen. Samotný kláves vytvorí snímku a modifikátory vytvoria nahrávku, vyberú farbu alebo získajú text vnútri oblasti. Ak vaša klávesnica kláves Print Screen vôbec nemá, `Super + Ctrl + Alt + C` vytvorí rovnakú snímku obrazovky a `Super + Ctrl + C` otvorí celú sadu ako ponuku.

| Klávesová skratka | Funkcia |
| ------ | -------- |
| `Print Screen` | Snímka obrazovky |
| `Super + Ctrl + Alt + C` | Snímka obrazovky |
| `Alt + Print Screen` | Nahrávanie obrazovky (alebo zastavenie bežiaceho nahrávania) |
| `Super + Print Screen` | Výber farby |
| `Super + Ctrl + Print Screen` | Extrahovať text z oblasti |
| `Super + Ctrl + C` | Ponuka zachytávania |
| `Super + Ctrl + .` | Prekódovať obrázok alebo video |

## Snímky obrazovky

Stlačte `Print Screen` (alebo `Super + Ctrl + Alt + C`) a Omasnap zachytí aktívny monitor skôr, ako sa zobrazí jeho prekrytie, takže sa vám počas mierenia pod rukami nič neposunie. Potiahnutím vyberte voľnú oblasť, kliknutím na okno zachyťte okno alebo kliknutím na voľné miesto zachyťte celý monitor. Stlačením `S` pred kreslením zachytíte posúvajúcu sa oblasť. Rozmysleli ste si to? Opätovným stlačením rovnakého klávesu Omasnap zatvoríte.

Po výbere oblasti Omasnap snímku uloží, skopíruje ju do schránky a zobrazí upozornenie s jej miniatúrou, rovnako ako pri uloženej nahrávke obrazovky. Výberom možnosti Otvoriť zobrazíte uloženú snímku v prehliadači obrázkov alebo výberom možnosti Upraviť ju môžete anotovať.

Editor anotácií dokáže kresliť šípky, čiary, tvary, zvýraznenia, číslované značky a text, bezpečne začierňovať citlivé časti, orezať obrázok alebo z neho časť vyrezať, vykonať OCR jeho textu a pridať pozadie. V editore stlačením `Enter` skopírujete a uložíte hotové PNG, stlačením `Ctrl + C` ho skopírujete bez uloženia alebo stlačením `Ctrl + S` ho uložíte bez kopírovania.

Uložené snímky obrazovky predvolene končia v `~/Pictures/Screenshots` s názvom ako `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavením `OMASNAP_SCREENSHOT_DIR` použijete iný adresár — pozrite si [časté otázky](46-faq.md), kde nájdete, kam umiestniť premenné prostredia relácie. Omasnap adresár vytvorí pri uložení prvej snímky. Nastavením `[output] autosave = false` v `~/.config/omasnap/omasnap.conf` zakážete automatické ukladanie; snímky sa potom iba kopírujú a zobrazujú v náhľade na 7 sekúnd, ktorý môžete na obrazovke ponechať jeho tlačidlom pripnutia alebo stlačením `Ctrl + P`.

Z terminálu otvorí `omarchy screenshot` rovnaké prekrytie a môžete si zvoliť jeho počiatočný režim: `omarchy capture screenshot region`, `windows`, `fullscreen` alebo `scroll`. Druhý argument `copy` alebo `save` odošle snímku priamo do daného cieľa. Ak chcete pred výstupom upravovať, použite `omarchy screenshot --editor=overlay` pre editor na celú obrazovku alebo `omarchy screenshot --editor=window` pre samostatné okno.

### Ovládanie výberu z klávesnice

Počas zobrazeného výberu nemusíte myš vôbec používať:

| Kláves | Funkcia |
| --- | -------- |
| `S` | Prepnúť režim posúvajúcej sa oblasti |
| `Super + Arrow keys` | Pohyb medzi oknami v režime okien |
| `Return` | Zachytiť zvýraznené okno |
| `Ctrl + A` | Zachytiť celý aktívny monitor |
| `R` | Obnoviť poslednú oblasť nakreslenú v tejto relácii |
| `Esc` | Zatvoriť Omasnap |

Tieto väzby existujú iba počas otvoreného Omasnap, takže nemôžu kolidovať s ničím vo vašej vlastnej konfigurácii.

## Nahrávanie obrazovky

`Alt + Print Screen` otvorí _Trigger > Capture > Screenrecord_, kde sa vás opýta, čo chcete mať na zvukovej stope: žiadny zvuk, zvuk pracovnej plochy, pracovnú plochu plus mikrofón alebo pracovnú plochu plus mikrofón plus webkameru. Posledná možnosť sa zobrazí iba vtedy, ak máte skutočne pripojenú kameru. Vyberte jednu možnosť a výber nahrávania v Omarchy vám umožní potiahnutím vybrať oblasť alebo kliknúť na okno či monitor.

Nahrávanie beží na gpu-screen-recorder, ktorý kóduje na GPU pri 60fps a v prípade potreby sa vráti k CPU; na GPU, ktoré nepodporuje, ako je Apple Silicon, Omarchy namiesto toho nahráva pomocou wf-recorder. Výsledkom je MP4 v `~/Videos` s názvom `screenrecording-2026-08-13_14-22-05.mp4`. Nastavením `OMARCHY_SCREENRECORD_DIR` to zmeníte — ale všimnite si, že na rozdiel od adresára snímok obrazovky tento adresár už musí existovať, inak nahrávanie odmietne začať.

Počas nahrávania sa v paneli zobrazí malý indikátor. Kliknutím naň nahrávanie zastavíte. Zastaviť môžete aj opätovným stlačením `Alt + Print Screen` alebo položkou _Stop Screenrecording_ v časti _Trigger > Capture > Screenrecord_, ktorá sa zobrazuje iba počas skutočného nahrávania.

Zastavenie pred odovzdaním súboru vykoná trochu upratovania: prvý snímok sa oreže a ak je prítomný zvuk, normalizuje sa na -14 LUFS, pričom prasknutie pri zachytávaní cez PipeWire na úplnom začiatku sa stlmí. Potom sa zobrazí upozornenie s miniatúrou z nahrávky. Výberom _Open_ prehráte súbor v Omaview alebo výberom _Cut_ ho orežete v Omacut.

### Prekrytie webkamery

Keď nahrávate s webkamerou, kamera sa zobrazí ako pripnuté, orezané okno na výšku v pravom dolnom rohu toho, čo nahrávate. Ak prekrýva niečo, čo potrebujete, za behu zmeňte jeho veľkosť:

| Klávesová skratka | Funkcia |
| ------ | -------- |
| `Super + Alt + [` | Zmenšiť prekrytie webkamery |
| `Super + Alt + ]` | Zväčšiť prekrytie webkamery |

K dispozícii sú tri veľkosti — malá, stredná a veľká — a klávesové skratky medzi nimi posúvajú. Stredná je predvolená. Sú úmerné nahrávke, takže kamera zaberá rovnaký podiel snímky, či nahrávate 1080p monitor alebo 6K monitor. A ak ste namiesto celej obrazovky nahrávali oblasť, prekrytie sa ukotví k rohu tejto oblasti namiesto rohu monitora, takže zostane vnútri záberu.

Môžete ho tiež zavolať priamo pomocou `omarchy-capture-webcam-resize small` alebo pomocou `reset` sa vrátiť na strednú veľkosť.

## Text, QR kódy a farby

`Super + Ctrl + Print Screen` vyberie oblasť a vykoná na nej OCR do schránky. Tomu sa riadne venuje časť [Extrakcia textu a diktovanie](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ robí rovnaký trik pre QR kódy. Vyberte oblasť s kódom a dekódovaná hodnota prejde do schránky. Hľadá iba QR kódy — hustý obsah obrazovky má inak tendenciu falošne sa vyhodnocovať ako čiarový kód. Stojí za to vedieť: dekódovaná hodnota ide do schránky a nikde inde. Nevypisuje sa, nie je v upozornení a je označená ako citlivá, takže nezostane v [histórii schránky](08-unified-clipboard-history.md). QR kódy bežne nesú tajomstvá — napríklad URI `otpauth://` za nastavovacím kódom 2FA — a to v protokole nechcete. Prilepovanie stále funguje bez problémov.

`Super + Print Screen` (alebo _Trigger > Capture > Color_) premení kurzor na kvapkadlo. Kliknite na čokoľvek na obrazovke a farba skončí v schránke. Opätovným stlačením klávesovej skratky akciu zrušíte bez výberu.

## Prekódovanie pred zdieľaním

4K nahrávka obrazovky alebo surové HEIC z telefónu je často príliš veľké na jednoduché odoslanie. `Super + Ctrl + .` (alebo _Trigger > Transcode_) to napraví. Ponúkne vám fuzzy výber súborov nad `~/Pictures` a `~/Videos` a potom sa opýta na formát a veľkosť.

Obrázky prechádzajú do jpg alebo png vo vysokej, strednej alebo nízkej kvalite, ktoré obmedzujú šírku na 3160, 2160 a 1080 pixelov. Videá prechádzajú do mp4 alebo animovaného gif v rozlíšení 4k, 1080p alebo 720p. Prevedený súbor sa zapíše vedľa originálu s rozlíšením v názve — `demo-1080p.mp4` — a cesta sa skopíruje do schránky ako URI súboru, takže ho môžete prilepiť priamo do aplikácie, ktorá prijíma súbory presunutím.

Funguje to aj z terminálu, ak už viete, čo chcete: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. K dispozícii je aj `omarchy transcode ascii`, ktoré premení obrázok na ASCII art — to slúži hlavne na [tvorbu značky](41-branding.md).

## Odoslanie niekam

Keď máte súbor, `Super + Ctrl + S` otvorí ponuku Share a odošle ho cez LocalSend do iného zariadenia vo vašej sieti. Pozrite si k tomu [grafické rozhrania](22-guis.md).
