# Snímky obrazovky a nahrávanie

Všetko, čo môžete zachytiť z obrazovky, visí na klávese Print Screen. Samotný kláves urobí snímku a modifikátory urobia nahrávku, farbu alebo text vnútri oblasti. Ak vaša klávesnica vôbec nemá kláves Print Screen, `Super + Ctrl + Alt + C` urobí rovnakú snímku obrazovky a `Super + Ctrl + C` otvorí celú sadu ako menu.

| Klávesová skratka | Funkcia |
| ------ | -------- |
| `Print Screen` | Snímka obrazovky |
| `Super + Ctrl + Alt + C` | Snímka obrazovky |
| `Alt + Print Screen` | Nahrávanie obrazovky (alebo zastavenie toho, ktoré práve beží) |
| `Super + Print Screen` | Výber farby |
| `Super + Ctrl + Print Screen` | Extrakcia textu z oblasti |
| `Super + Ctrl + C` | Menu zachytávania |
| `Super + Ctrl + .` | Prekódovanie obrázka alebo videa |

## Snímky obrazovky

Stlačte `Print Screen` (alebo `Super + Ctrl + Alt + C`) a Omasnap zachytí zameraný monitor ešte predtým, než sa objaví jeho prekrytie, takže sa pod vami nič neposunie, kým mierite. Potiahnite voľnú oblasť, kliknite na okno, aby ste ho zachytili, alebo kliknite na prázdne miesto, aby ste zachytili celý monitor. Stlačte `S` pred kreslením, aby ste zachytili posúvajúcu sa oblasť. Zmenili ste názor? Znova stlačte ten istý kláves a Omasnap zmizne.

Po výbere oblasti Omasnap uloží záber, skopíruje ho do schránky a zobrazí oznámenie s jeho miniatúrou, rovnako ako pri uloženej nahrávke obrazovky. Vyberte Open, aby ste si uloženú snímku pozreli v prehliadači obrázkov, alebo Edit, aby ste ju anotovali.

Editor anotácií dokáže kresliť šípky, čiary, tvary, zvýraznenia, číslované značky, text a bezpečné redakcie; orezať alebo vystrihnúť časť obrázka; OCR-spracovať jeho text; a pridať pozadie. V editore stlačte `Enter` na skopírovanie a uloženie hotového PNG, `Ctrl + C` na skopírovanie bez uloženia alebo `Ctrl + S` na uloženie bez kopírovania.

Uložené snímky obrazovky štandardne končia v `~/Pictures/Screenshots` s názvom ako `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavte `OMASNAP_SCREENSHOT_DIR`, ak chcete použiť iný adresár — pozrite si [Časté otázky](46-faq.md), kam patria premenné prostredia relácie. Omasnap vytvorí adresár pri uložení prvej snímky. Nastavte `[output] autosave = false` v `~/.config/omasnap/omasnap.conf`, ak chcete vypnúť automatické ukladanie; zábery sa potom iba skopírujú a zobrazia sa v náhľade na 10 sekúnd, ktorý môžete nechať na obrazovke jeho tlačidlom pripnutia alebo `Ctrl + P`.

Z terminálu `omarchy screenshot` otvorí rovnaké prekrytie a môžete si vybrať jeho počiatočný režim: `omarchy capture screenshot region`, `windows`, `fullscreen` alebo `scroll`. Druhý argument `copy` alebo `save` pošle snímku rovno do tohto cieľa. Na úpravu pred výstupom použite `omarchy screenshot --editor=overlay` pre editor na celú obrazovku alebo `omarchy screenshot --editor=window` pre samostatné okno.

### Ovládanie výberu z klávesnice

Kým je výber otvorený, vôbec nemusíte používať myš:

| Kláves | Funkcia |
| --- | -------- |
| `S` | Prepnúť režim posúvajúcej sa oblasti |
| `Super + Arrow keys` | Pohyb medzi oknami v režime Window |
| `Return` | Zachytiť zvýraznené okno |
| `Ctrl + A` | Zachytiť celý zameraný monitor |
| `R` | Obnoviť poslednú oblasť nakreslenú v tejto relácii |
| `Esc` | Zatvoriť Omasnap |

Tieto väzby existujú len vtedy, keď je Omasnap otvorený, takže nemôžu kolidovať s ničím vo vašej vlastnej konfigurácii.

## Nahrávanie obrazovky

`Alt + Print Screen` otvorí _Trigger > Capture > Screenrecord_, ktoré sa spýta, čo chcete mať na zvukovej stope: žiadny zvuk, zvuk plochy, plochu plus mikrofón alebo plochu plus mikrofón plus webkameru. Tá posledná možnosť sa zobrazí len vtedy, ak máte skutočne pripojenú kameru. Vyberte si jednu a výber nahrávania v Omarchy vám umožní potiahnuť oblasť alebo kliknúť na okno či monitor.

Nahrávanie beží na gpu-screen-recorder, ktorý kóduje na GPU pri 60fps a v prípade potreby prepadne na CPU. Výsledkom je MP4 v `~/Videos` s názvom `screenrecording-2026-08-13_14-22-05.mp4`. Nastavte `OMARCHY_SCREENRECORD_DIR`, ak to chcete zmeniť — ale všimnite si, že na rozdiel od adresára snímok obrazovky tento už musí existovať, inak nahrávanie odmietne začať.

Počas nahrávania sa v lište objaví malý indikátor. Kliknite naň, ak chcete zastaviť. Zastaviť môžete aj opätovným stlačením `Alt + Print Screen` alebo položkou _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, ktorá sa objaví len vtedy, keď sa skutočne niečo nahráva.

Zastavenie pred odovzdaním súboru urobí trochu poriadku: prvá snímka sa oreže a ak je prítomný zvuk, normalizuje sa na -14 LUFS, pričom puknutie zachytávania PipeWire na úplnom začiatku sa stlmí. Potom sa objaví oznámenie s miniatúrou z nahrávky. Kliknite naň, ak chcete súbor prehrať v Omaview.

### Prekrytie webkamery

Keď nahrávate s webkamerou, kamera sa objaví ako pripnuté, orezané okno na výšku v pravom dolnom rohu toho, čo nahrávate. Ak sedí na niečom, čo potrebujete, zmeňte jeho veľkosť za behu:

| Klávesová skratka | Funkcia |
| ------ | -------- |
| `Super + Alt + [` | Zmenšiť prekrytie webkamery |
| `Super + Alt + ]` | Zväčšiť prekrytie webkamery |

Existujú tri veľkosti — malá, stredná a veľká — a klávesové skratky medzi nimi krokovo prepínajú. Stredná je predvolená. Sú úmerné nahrávke, takže kamera zaberá rovnaký podiel záberu, či už nahrávate 1080p monitor alebo 6K monitor. A ak ste nahrali oblasť namiesto celého displeja, prekrytie sa ukotví do rohu tejto oblasti namiesto rohu monitora, takže zostane vnútri záberu.

Môžete ho zavolať aj priamo pomocou `omarchy-capture-webcam-resize small` alebo `reset`, ak sa chcete vrátiť na strednú veľkosť.

## Text, QR kódy a farby

`Super + Ctrl + Print Screen` vyberie oblasť a OCR-spracuje ju do schránky. To je poriadne popísané v [Extrakcia textu a diktovanie](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ robí rovnaký trik pre QR kódy. Vyberte oblasť s kódom a dekódovaná hodnota pôjde do schránky. Hľadá iba QR kódy — hustý obsah obrazovky má inak vo zvyku falošne sa hlásiť ako čiarový kód. Stojí za to vedieť: dekódovaná hodnota ide do schránky a nikam inam. Nevytlačí sa, nie je v oznámení a je označená ako citlivá, takže nezostane visieť v [histórii schránky](08-unified-clipboard-history.md). QR kódy bežne nesú tajomstvá — napríklad `otpauth://` URI za nastavovacím kódom 2FA — a to nechcete mať v logu. Prilepovanie stále funguje bez problémov.

`Super + Print Screen` (alebo _Trigger > Capture > Color_) premení kurzor na kvapkadlo. Kliknite na čokoľvek na obrazovke a farba pristane v schránke. Znova stlačte klávesovú skratku, ak chcete odísť bez výberu.

## Prekódovanie pred zdieľaním

Nahrávka obrazovky v 4K alebo surové HEIC z telefónu je často príliš veľká na to, aby ste ju len tak poslali. `Super + Ctrl + .` (alebo _Trigger > Transcode_) to opraví. Ponúkne vám fuzzy výber súborov nad `~/Pictures` a `~/Videos` a potom sa spýta na formát a veľkosť.

Obrázky idú do jpg alebo png vo vysokej, strednej alebo nízkej kvalite, ktoré obmedzujú šírku na 3160, 2160 a 1080 pixelov. Videá idú do mp4 alebo animovaného gif vo 4k, 1080p alebo 720p. Prevedený súbor sa zapíše vedľa originálu s rozlíšením v názve — `demo-1080p.mp4` — a cesta sa skopíruje do schránky ako file URI, takže ju môžete prilepiť priamo do aplikácie, ktorá prijíma súbory ťahaním.

Funguje to aj z terminálu, ak už viete, čo chcete: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Existuje aj `omarchy transcode ascii`, ktoré premení obrázok na ASCII art — to je hlavne pre [branding](41-branding.md).

## Odoslanie niekam

Keď už máte súbor, `Super + Ctrl + S` otvorí menu Share a pošle ho na iné zariadenie vo vašej sieti cez LocalSend. Pozrite si na to [Grafické rozhrania](22-guis.md).
