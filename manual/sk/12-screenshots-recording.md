# Snímky obrazovky a nahrávanie

Všetko, čo môžete zachytiť z obrazovky, visí na klávese Print Screen. Samotný kláves urobí snímku a modifikátory urobia nahrávku, vyberú farbu alebo text vnútri oblasti. Ak vaša klávesnica kláves Print Screen vôbec nemá, `Super + Ctrl + Alt + C` urobí rovnakú snímku obrazovky a `Super + Ctrl + C` otvorí celú sadu ako menu.

| Klávesová skratka | Funkcia |
| ------ | -------- |
| `Print Screen` | Snímka obrazovky |
| `Super + Ctrl + Alt + C` | Snímka obrazovky |
| `Alt + Print Screen` | Nahrávanie obrazovky (alebo zastavenie prebiehajúceho nahrávania) |
| `Super + Print Screen` | Výber farby |
| `Super + Ctrl + Print Screen` | Extrahovať text z oblasti |
| `Super + Ctrl + C` | Menu zachytávania |
| `Super + Ctrl + .` | Prekódovať obrázok alebo video |

## Snímky obrazovky

Stlačte `Print Screen` (alebo `Super + Ctrl + Alt + C`) a Omasnap zachytí zameraný monitor skôr, ako sa objaví jeho prekrytie, takže sa pod vami nič neposunie, kým mieriťe. Potiahnite voľnú oblasť, kliknite na okno, aby ste ho zachytili, alebo kliknite na voľné miesto, aby ste zachytili celý monitor. Stlačte `S` pred kreslením, aby ste zachytili posúvateľnú oblasť. Zmenili ste názor? Stlačte ten istý kláves znova, aby ste Omasnap zatvorili.

Po výbere oblasti Omasnap snímku uloží, skopíruje ju do schránky a zobrazí oznámenie s jej miniatúrou, rovnako ako pri uloženej nahrávke obrazovky. Vyberte Open, aby ste si uloženú snímku pozreli v prehliadači obrázkov, alebo Edit, aby ste ju anotovali.

Editor anotácií dokáže kresliť šípky, čiary, tvary, zvýraznenia, číslované značky, text a bezpečné redakcie; orezať alebo vystrihnúť časť obrázka; urobiť OCR jeho textu; a pridať pozadie. V editore stlačte `Enter` na skopírovanie a uloženie hotového PNG, `Ctrl + C` na skopírovanie bez uloženia alebo `Ctrl + S` na uloženie bez kopírovania.

Uložené snímky obrazovky štandardne pristávajú v `~/Pictures/Screenshots` s názvom ako `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavte `OMASNAP_SCREENSHOT_DIR`, aby ste použili iný adresár — pozrite si [Časté otázky](46-faq.md), kde sa dozviete, kam umiestniť premenné prostredia relácie. Omasnap adresár vytvorí, keď ukladá prvú snímku. Nastavte `[output] autosave = false` v `~/.config/omasnap/omasnap.conf`, aby ste vypli automatické ukladanie; snímky sa potom iba kopírujú a zobrazujú sa v náhľade na 10 sekúnd, ktorý môžete nechať na obrazovke jeho tlačidlom pripnutia alebo pomocou `Ctrl + P`.

Z terminálu `omarchy screenshot` otvorí rovnaké prekrytie a môžete si vybrať jeho počiatočný režim: `omarchy capture screenshot region`, `windows`, `fullscreen` alebo `scroll`. Druhý argument `copy` alebo `save` pošle snímku priamo na dané miesto určenia. Ak chcete pred výstupom upravovať, použite `omarchy screenshot --editor=overlay` pre editor na celú obrazovku alebo `omarchy screenshot --editor=window` pre samostatné okno.

### Ovládanie výberu z klávesnice

Kým je výber otvorený, myš vôbec nemusíte používať:

| Kláves | Funkcia |
| --- | -------- |
| `S` | Prepnúť režim posúvateľnej oblasti |
| `Super + Arrow keys` | Pohyb medzi oknami v režime okien |
| `Return` | Zachytiť zvýraznené okno |
| `Ctrl + A` | Zachytiť celý zameraný monitor |
| `R` | Obnoviť poslednú oblasť nakreslenú v tejto relácii |
| `Esc` | Zatvoriť Omasnap |

Tieto väzby existujú iba kým je Omasnap otvorený, takže nemôžu kolidovať s ničím vo vašej vlastnej konfigurácii.

## Nahrávanie obrazovky

`Alt + Print Screen` otvorí _Trigger > Capture > Screenrecord_, ktoré sa opýta, čo chcete na zvukovej stope: žiadny zvuk, zvuk pracovnej plochy, pracovnú plochu plus mikrofón alebo pracovnú plochu plus mikrofón plus webkameru. Tá posledná možnosť sa zobrazí iba vtedy, ak máte skutočne pripojenú kameru. Vyberte si jednu a výber nahrávania v Omarchy vám umožní potiahnuť oblasť alebo kliknúť na okno či monitor.

Nahrávanie beží na gpu-screen-recorder, ktorý kóduje na GPU pri 60fps a v prípade potreby sa vráti k CPU. Výsledkom je MP4 v `~/Videos` s názvom `screenrecording-2026-08-13_14-22-05.mp4`. Nastavte `OMARCHY_SCREENRECORD_DIR`, aby ste to zmenili — ale všimnite si, že na rozdiel od adresára snímok obrazovky tento už musí existovať, inak sa nahrávanie odmietne spustiť.

Počas nahrávania sa v paneli zobrazí malý indikátor. Kliknite naň, aby ste zastavili. Zastaviť môžete aj opätovným stlačením `Alt + Print Screen` alebo položkou _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, ktorá sa zobrazuje iba vtedy, keď niečo skutočne nahráva.

Zastavenie pred odovzdaním súboru urobí trochu poriadku: prvá snímka sa oreže a ak je prítomný zvuk, normalizuje sa na -14 LUFS, pričom prasknutie zachytávania PipeWire na úplnom začiatku sa stlmí. Potom sa zobrazí oznámenie s miniatúrou z nahrávky. Kliknite naň, aby ste súbor prehrali v mpv.

### Prekrytie webkamery

Keď nahrávate s webkamerou, kamera sa zobrazí ako pripnuté, orezané portrétové okno v pravom dolnom rohu toho, čo nahrávate. Ak sedí na niečom, čo potrebujete, zmeňte jeho veľkosť za behu:

| Klávesová skratka | Funkcia |
| ------ | -------- |
| `Super + Alt + [` | Zmenšiť prekrytie webkamery |
| `Super + Alt + ]` | Zväčšiť prekrytie webkamery |

Existujú tri veľkosti — malá, stredná a veľká — a klávesové skratky medzi nimi krokovo prepínajú. Stredná je predvolená. Sú proporcionálne k nahrávke, takže kamera zaberá rovnaký podiel záberu, či nahrávate 1080p monitor alebo 6K monitor. A ak ste nahrali oblasť namiesto celého displeja, prekrytie sa ukotví k rohu danej oblasti namiesto rohu monitora, takže zostane vnútri záberu.

Môžete to tiež zavolať priamo pomocou `omarchy-capture-webcam-resize small` alebo `reset`, aby ste sa vrátili na strednú veľkosť.

## Text, QR kódy a farby

`Super + Ctrl + Print Screen` vyberie oblasť a urobí OCR do schránky. To je riadne pokryté v [Extrakcia textu a diktovanie](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ robí ten istý trik pre QR kódy. Vyberte oblasť s kódom a dekódovaná hodnota prejde do schránky. Hľadá iba QR kódy — hustý obsah obrazovky má inak vo zvyku falošne sa javiť ako čiarový kód. Stojí za to vedieť: dekódovaná hodnota ide do schránky a nikam inam. Nevytlačí sa, nie je v oznámení a je označená ako citlivá, takže nezostane v [histórii schránky](08-unified-clipboard-history.md). QR kódy bežne nesú tajomstvá — napríklad `otpauth://` URI za nastavovacím kódom 2FA — a to v logu nechcete. Vkladanie stále funguje v poriadku.

`Super + Print Screen` (alebo _Trigger > Capture > Color_) premení kurzor na kvapkadlo. Kliknite na čokoľvek na obrazovke a farba pristane v schránke. Stlačte klávesovú skratku znova, aby ste sa vrátili bez výberu.

## Prekódovanie pred zdieľaním

Nahrávka obrazovky v 4K alebo surové HEIC z telefónu je často príliš veľká na to, aby ste ju len tak poslali. `Super + Ctrl + .` (alebo _Trigger > Transcode_) to napraví. Ponúkne vám fuzzy výber súborov nad `~/Pictures` a `~/Videos` a potom sa opýta na formát a veľkosť.

Obrázky idú do jpg alebo png vo vysokej, strednej alebo nízkej kvalite, ktoré obmedzujú šírku na 3160, 2160 a 1080 pixelov. Videá idú do mp4 alebo animovaného gif v 4k, 1080p alebo 720p. Prevedený súbor sa zapíše vedľa originálu s rozlíšením v názve — `demo-1080p.mp4` — a cesta sa skopíruje do schránky ako URI súboru, takže ju môžete vložiť priamo do aplikácie, ktorá prijíma súbory ťahaním.

Funguje to aj z terminálu, ak už viete, čo chcete: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Existuje aj `omarchy transcode ascii`, ktoré premení obrázok na ASCII art — to je hlavne pre [branding](41-branding.md).

## Poslanie niekam inam

Keď už máte súbor, `Super + Ctrl + S` otvorí menu Share a pošle ho na iné zariadenie vo vašej sieti cez LocalSend. Pozrite si k tomu [GUI](22-guis.md).
