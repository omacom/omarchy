# Grafické aplikácie

## Súbory

Súbory (Nautilus) je grafický správca súborov. Pomocou `Super + Shift + F` ho otvoríte a pomocou `Super + Shift + Alt + F` ho otvoríte v adresári, v ktorom práve sedí váš terminál, čo ušetrí veľa klikania. Pomocou `Ctrl + L` môžete napísať cestu a stlačením klávesu `Space` pri ľubovoľnom súbore získate rýchly náhľad bez toho, aby ste čokoľvek otvárali.

Pripojte USB kľúč alebo SD kartu a automaticky sa pripojí, takže sa jednoducho zobrazí v bočnom paneli. Pre čokoľvek zložitejšie — formátovanie disku, kontrolu stavu SMART, vytváranie partícií — spustite _Disks_ zo spúšťača aplikácií (`Super + Space`).

Dvojité kliknutie dodržiava rozumné predvolené nastavenia: obrázky, videá a hudba sa otvárajú v Omaview, PDF v Document Viewer, Markdown v Omawrite a obyčajný text v editore vybratom v časti _Setup > Default > Editor_.

## Disktree

Keď sa disk zaplní a vy netušíte, čo ho požiera, spustite [Disktree](https://github.com/tobi/disktree) zo spúšťača aplikácií (`Super + Space`). Zobrazuje grafickú stromovú mapu vášho domovského adresára. Väčšie bloky zaberajú viac miesta; prechádzajte adresármi klávesnicou alebo myšou, označte, čo má ísť preč, a pred odstránením čokoľvek skontrolujte svoj výber. Spustením `disktree --disk` preskenujete celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoko rozšíriteľná aplikácia na poznámky, ktorá na ukladanie používa jednoduché súbory Markdown.

Obsidian je bezplatný na všetky účely vrátane osobného, komerčného a neziskového použitia.

Obsidian ponúka aj [komerčný doplnok na synchronizáciu](https://obsidian.md/sync) s mobilnými aplikáciami pre iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocou `Super + Shift + O`. Ak chcete používať synchronizáciu témy, musíte v nastaveniach vybrať tému `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastná úplne jednoduchá aplikácia Omarchy na písanie v Markdowne. Žiadne trezory, žiadne pluginy, len vy a slová.

Omawrite spustíte pomocou `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základný nástroj na úpravu obrázkov, ktorý je skvelý na orezávanie, zmenu veľkosti a ďalšie základné úpravy. Len nečakajte alternatívu k Photoshopu. Ale stále má Magic Wand a vrstvy!

Pintu spustíte cez spúšťač aplikácií (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikácia na tvorbu tém, ktorá dokáže extrahovať farby z obrázka na pozadí a premeniť ich na kompletnú, súdržnú tému. Je to najjednoduchší spôsob, ako si [vytvoriť vlastnú tému](43-making-your-own-theme.md).

Aether spustíte cez spúšťač aplikácií (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožňuje posielať súbory do iných zariadení v rovnakej sieti, v ktorých beží táto aplikácia, podobne ako AirDrop od Apple. Je však multiplatformový, takže môžete posielať súbory do a z Windows, macOS, Android, iOS a, samozrejme, Linuxu.

Ponuku Zdieľať môžete otvoriť pomocou `Super + Ctrl + S` alebo v ponuke Omarchy v časti _Trigger > Share_. Ponúka vám štyri možnosti:

- **Schránka** odošle všetko, čo ste skopírovali, ako textový súbor. Skvelé na to, aby ste dostali odkaz alebo úryvok do telefónu bez toho, aby ste si posielali e-mail.
- **Súbor** otvorí výber súborov, v ktorom ich môžete vybrať niekoľko naraz.
- **Priečinok** odošle celý adresár.
- **Prijať** otvorí samotný LocalSend, aby vám iné zariadenie mohlo niečo poslať.

To isté funguje z terminálu pomocou `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Ak cestu vynecháte, zobrazí sa výber.

Posielať môžete aj priamo zo správcu súborov: kliknite pravým tlačidlom na ľubovoľný výber v Nautiluse a vyberte _Send via LocalSend_.

Firewall Omarchy je predvolene zatvorený s výnimkou portu LocalSendu, takže to funguje hneď po čerstvej inštalácii. Pozrite si [bezpečnosť](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletný kancelársky balík s textovým procesorom, tabuľkovým procesorom, prezentáciami, aplikáciou na kreslenie a ďalšími. Je kompatibilný so súbormi z Microsoft Office, takže je to skvelý spôsob, ako môžete otvárať tie dokumenty Word.

LibreOffice spustíte cez spúšťač aplikácií (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastná úplne jednoduchá prezentačná aplikácia Omarchy. Vaša prezentácia je jeden súbor Markdown s obrázkami a videami vedľa neho: každú snímku napíšte pod živý náhľad, presuňte snímky do požadovaného poradia a potom prezentujte na celej obrazovke alebo exportujte do PDF a PowerPointu. Dokonca prevezme aj vašu tému Omarchy.

Hype spustíte cez spúšťač aplikácií (`Super + Space`). Stlačením `?` vnútri zobrazíte všetky skratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastný úplne jednoduchý spôsob Omarchy, ako podpisovať PDF a vypĺňať ich. Umiestnite svoj uložený podpis, text a dnešný dátum kamkoľvek na stránku a potom uložte podpísanú kópiu vedľa originálu. Ako na to, nájdete v časti [Vypĺňanie PDF](27-filling-out-pdfs.md).

Signed spustíte cez spúšťač aplikácií (`Super + Space`) alebo s ním otvorte PDF zo správcu súborov.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) je vlastná 3D šachová hra Omarchy. Hrajte s priateľom na tom istom počítači alebo proti vstavanému súperovi na troch úrovniach, na štyroch vyrezávaných súpravách, z ktorých každá sa pohybuje vlastným spôsobom: orbitálne plavidlá, vyrezávané drevo a slonovina, lesné bytosti a cukríky. Hry nemajú hodiny a ukladajú sa po každom ťahu.

Checkmate spustíte cez spúšťač aplikácií (`Super + Space`), kde je uvedená ako Chess. Stlačením `?` vnútri zobrazíte všetky skratky.

## Cards

[Cards](https://github.com/omacom/cards) je vlastný solitér Klondike od Omarchy. Ťahajte tri, bez obmedzenia počtu prechodov, v štyroch sériách kariet: jedna je nakreslená vo farbách vašej témy a tri majú svoj vlastný vzhľad. Kliknite na kartu a potom tam, kam má ísť, presuňte ju ťahaním alebo ju dvojitým kliknutím pošlite na najlepšie miesto. Hry sa ukladajú po každom ťahu.

Cards spustíte cez spúšťač aplikácií (`Super + Space`). Kliknutím na jeho názov alebo stlačením `?` zobrazíte všetky skratky.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastná úplne jednoduchá kalkulačka Omarchy, ktorá sa otvára v plávajúcom okne.

Omacalc spustíte pomocou `Super + Shift + Q` (alebo klávesom kalkulačky, ak ho vaša klávesnica má).

## Signal

[Signal](https://signal.org/) je priekopníkom E2E šifrovanej komunikácie a skvelou možnosťou komunikácie pre každého, kto by radšej nešiel cez jeden z veľkých technologických konglomerátov.

Signal spustíte pomocou `Super + Shift + G`. Nie je súčasťou základnej inštalácie, takže keď to stlačíte prvýkrát, Omarchy vám ponúkne, že ho za vás nainštaluje (je aj v ponuke Omarchy v časti _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastný úplne jednoduchý prehliadač obrázkov a prehrávač médií Omarchy: jedno okno pre vaše fotografie, videá a hudbu. Otvorte fotografiu a klávesy so šípkami prechádzajú zvyškom jej priečinka, `N` a `P` to robia pre čokoľvek a `Ctrl + M` zobrazí celý priečinok ako mriežku. Zobrazuje aj fotografie HEIC, AVIF a JPEG XL a pri všetkom dlhom pokračuje tam, kde ste skončili.

Stlačte `F` pre celú obrazovku, `E` na úpravu obrázka v Omasnap alebo orezanie videa v Omacut, `Ctrl + P` na tlač obrázka a `Delete` na presunutie súboru do koša (`Ctrl + Z` ho vráti späť). Stlačením `?` vnútri zobrazíte všetky skratky.

Omaview spustíte ako _Media Viewer_ cez spúšťač aplikácií (`Super + Space`) alebo jednoducho dvakrát kliknite na obrázok, video alebo pieseň v správcovi súborov.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastný úplne jednoduchý nástroj Omarchy na orezávanie videa. Keď potrebujete len odrezať začiatok a koniec klipu, je to lepšie ako spúšťať plnohodnotný editor videa.

Omacut spustíte cez spúšťač aplikácií (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastný úplne jednoduchý záznamník z webkamery od Omarchy. Raz si vyberte kameru a mikrofón, potom stlačte `Space` na nahrávanie a znova na pozastavenie a pokračovanie toho istého záberu. Vždy nahráva v najvyššom rozlíšení vašej kamery, so živým meračom mikrofónu, aby ste si pred začiatkom mohli skontrolovať úrovne.

Zastavte záber a hneď sa otvorí vo vstavanom editore. Dvojitým kliknutím na klip ho rozdelíte, ťahaním úchytov orežete každý kúsok a odstránite časti, ktoré nechcete. Potom ho uložte ako MP4. Váš pôvodný záznam sa zachová, kým ho nezahodíte, takže sa k nemu môžete vždy vrátiť a zostrihať ho inak.

Monologue spustíte cez spúšťač aplikácií (`Super + Space`).
