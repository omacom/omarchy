# Snímky obrazovky a nahrávanie

Všetko, čo môžete z obrazovky zachytiť, visí na klávese Print Screen. Samotný kláves urobí snímku a modifikátory urobia nahrávku, vyberú farbu alebo vytiahnu text z oblasti. Ak vaša klávesnica kláves Print Screen vôbec nemá, `Super + Ctrl + Alt + C` urobí rovnakú snímku obrazovky a `Super + Ctrl + C` otvorí celú sadu ako menu.

| Klávesová skratka | Funkcia |
| ------ | -------- |
| `Print Screen` | Snímka obrazovky |
| `Super + Ctrl + Alt + C` | Snímka obrazovky |
| `Alt + Print Screen` | Nahrávanie obrazovky (alebo zastavenie toho, ktoré beží) |
| `Super + Print Screen` | Výber farby |
| `Super + Ctrl + Print Screen` | Extrahovať text z oblasti |
| `Super + Ctrl + C` | Menu zachytávania |
| `Super + Ctrl + .` | Prekódovať obrázok alebo video |

## Snímky obrazovky

Stlačte `Print Screen` (alebo `Super + Ctrl + Alt + C`) a Omasnap zachytí zameraný monitor skôr, než sa objaví jeho prekrytie, takže sa pod vami nič neposunie, kým mierite. Potiahnite voľnú oblasť, kliknite na okno, ak ho chcete zachytiť, alebo kliknite na voľné miesto, ak chcete zachytiť celý monitor. Stlačte `S` pred kreslením, ak chcete zachytiť posúvateľnú oblasť. Zmenili ste názor? Stlačte ten istý kláves znova a Omasnap zmizne.

Po výbere oblasti Omasnap snímku uloží, skopíruje ju do schránky a na 10 sekúnd zobrazí náhľad. Tlačidlom pripnutia v náhľade alebo `Ctrl + P` ju necháte na obrazovke, alebo zvoľte Edit, ak ju chcete poznamkovať.

Editor poznámok dokáže kresliť šípky, čiary, tvary, zvýraznenia, číslované značky, text a bezpečné redakcie; orezať alebo vystrihnúť časť obrázka; OCR-spracovať jeho text; a pridať pozadie. V editore stlačte `Enter` na skopírovanie a uloženie hotového PNG, `Ctrl + C` na skopírovanie bez uloženia alebo `Ctrl + S` na uloženie bez kopírovania.

Uložené snímky obrazovky končia predvolene v `~/Pictures/Screenshots` s názvom ako `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavte `OMASNAP_SCREENSHOT_DIR`, ak chcete použiť iný adresár — pozrite [časté otázky](46-faq.md), kde nájdete, kam patria premenné prostredia relácie. Omasnap adresár vytvorí, keď ukladá prvú snímku. Nastavte `[output] autosave = false` v `~/.config/omasnap/omasnap.conf`, ak chcete automatické ukladanie vypnúť.

Z terminálu `omarchy screenshot` otvorí rovnaké prekrytie a môžete si zvoliť jeho počiatočný režim: `omarchy capture screenshot region`, `windows`, `fullscreen` alebo `scroll`. Druhý argument `copy` alebo `save` preskočí náhľad a pošle snímku priamo do toho cieľa. Ak chcete pred výstupom upravovať, použite `omarchy screenshot --editor=overlay` pre editor na celú obrazovku alebo `omarchy screenshot --editor=window` pre samostatné okno.

### Ovládanie výberu z klávesnice

Kým je výber otvorený, myš vôbec nepotrebujete:

| Kláves | Funkcia |
| --- | -------- |
| `S` | Prepnúť režim posúvateľnej oblasti |
| `Super + Arrow keys` | Pohyb medzi oknami v režime Window |
| `Return` | Zachytiť zvýraznené okno |
| `Ctrl + A` | Zachytiť celý zameraný monitor |
| `R` | Obnoviť poslednú oblasť nakreslenú v tejto relácii |
| `Esc` | Zavrieť Omasnap |

Tieto väzby existujú len kým je Omasnap otvorený, takže nemôžu kolidovať s ničím vo vašej vlastnej konfigurácii.

## Nahrávanie obrazovky

`Alt + Print Screen` otvorí _Trigger > Capture > Screenrecord_, ktoré sa spýta, čo chcete mať na zvukovej stope: žiadny zvuk, zvuk pracovnej plochy, pracovnú plochu plus mikrofón alebo pracovnú plochu plus mikrofón plus webkameru. Tá posledná možnosť sa zobrazí len vtedy, ak máte skutočne pripojenú kameru. Vyberte jednu a výber nahrávania v Omarchy vám umožní potiahnuť oblasť alebo kliknúť na okno či monitor.

Nahrávanie beží na gpu-screen-recorder, ktorý kóduje na GPU pri 60fps a v prípade potreby prejde späť na CPU. Výsledkom je MP4 v `~/Videos` s názvom `screenrecording-2026-08-13_14-22-05.mp4`. Nastavte `OMARCHY_SCREENRECORD_DIR`, ak to chcete zmeniť — ale všimnite si, že na rozdiel od adresára snímok obrazovky tento už musí existovať, inak nahrávanie odmietne začať.

Kým nahrávate, v lište sa objaví malý indikátor. Kliknite naň, ak chcete zastaviť. Zastaviť môžete aj opätovným stlačením `Alt + Print Screen` alebo položkou _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, ktorá sa objaví len vtedy, keď sa niečo skutočne nahráva.

Zastavenie pred odovzdaním súboru urobí trochu poriadku: prvý snímok sa oreže a ak je prítomný zvuk, normalizuje sa na -14 LUFS, pričom prasknutie zachytávania PipeWire na úplnom začiatku sa stlmí. Potom sa objaví oznámenie s miniatúrou z nahrávky. Kliknite naň, ak chcete súbor prehrať v mpv.

### Prekrytie webkamery

Keď nahrávate s webkamerou, kamera sa objaví ako pripnuté, orezané okno na výšku v pravom dolnom rohu toho, čo nahrávate. Ak sedí na niečom, čo potrebujete, zmeňte jej veľkosť za behu:

| Klávesová skratka | Funkcia |
| ------ | -------- |
| `Super + Alt + [` | Zmenšiť prekrytie webkamery |
| `Super + Alt + ]` | Zväčšiť prekrytie webkamery |

Existujú tri veľkosti — malá, stredná a veľká — a klávesové skratky medzi nimi posúvajú. Stredná je predvolená. Sú proporcionálne k nahrávke, takže kamera zaberá rovnaký podiel záberu, či nahrávate 1080p monitor alebo 6K monitor. A ak ste nahrávali oblasť namiesto celého displeja, prekrytie sa ukotví do rohu tej oblasti namiesto rohu monitora, takže zostane vnútri záberu.

Môžete ho zavolať aj priamo pomocou `omarchy-capture-webcam-resize small`, alebo `reset`, ak sa chcete vrátiť na strednú veľkosť.

## Text, QR kódy a farby

`Super + Ctrl + Print Screen` vyberie oblasť a jej text cez OCR skopíruje do schránky. To je poriadne pokryté v [Extrakcia textu a diktovanie](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ robí rovnaký trik pre QR kódy. Vyberte oblasť s kódom a dekódovaná hodnota ide do schránky. Hľadá len QR kódy — hustý obsah obrazovky má inak zvyk falošne sa hlásiť ako čiarový kód. Stojí za to vedieť: dekódovaná hodnota ide do schránky a nikam inam. Nevytlačí sa, nie je v oznámení a je označená ako citlivá, takže nezostane v [histórii schránky](08-unified-clipboard-history.md). QR kódy bežne nesú tajomstvá — napríklad URI `otpauth://` za nastavovacím kódom 2FA — a to nechcete mať v logu. Vkladanie stále funguje v poriadku.

`Super + Print Screen` (alebo _Trigger > Capture > Color_) zmení kurzor na kvapkadlo. Kliknite na čokoľvek na obrazovke a farba pristane v schránke. Stlačte klávesovú skratku znova, ak chcete odísť bez výberu.

## Prekódovanie pred zdieľaním

4K nahrávka obrazovky alebo surové HEIC z vášho telefónu je často príliš veľké na jednoduché poslanie. `Super + Ctrl + .` (alebo _Trigger > Transcode_) to opraví. Ponúkne vám fuzzy výber súboru nad `~/Pictures` a `~/Videos`, potom sa spýta na formát a veľkosť.

Obrázky idú do jpg alebo png vo vysokej, strednej alebo nízkej kvalite, ktoré obmedzujú šírku na 3160, 2160 a 1080 pixelov. Videá idú do mp4 alebo animovaného gif v 4k, 1080p alebo 720p. Prevedený súbor sa zapíše vedľa originálu s rozlíšením v názve — `demo-1080p.mp4` — a cesta sa skopíruje do schránky ako URI súboru, takže ju môžete vložiť priamo do aplikácie, ktorá prijíma súbory potiahnutím.

Funguje to aj z terminálu, ak už viete, čo chcete: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Existuje aj `omarchy transcode ascii`, ktorý zmení obrázok na ASCII art — ten je hlavne pre [branding](41-branding.md).

## Odoslanie niekam

Keď máte súbor, `Super + Ctrl + S` otvorí menu Share a pošle ho na iné zariadenie vo vašej sieti cez LocalSend. Pozrite [Grafické rozhrania](22-guis.md), kde to nájdete.
