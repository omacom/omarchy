# Grafické aplikácie

## Súbory

Files (Nautilus) je grafický správca súborov. `Super + Shift + F` ho otvorí a `Super + Shift + Alt + F` ho otvorí v adresári, v ktorom sa práve nachádza váš terminál, čo ušetrí veľa klikania. `Ctrl + L` vám umožní zadať cestu a stlačením `Space` na ľubovoľnom súbore získate rýchly náhľad bez toho, aby ste čokoľvek otvárali.

Pripojte USB kľúč alebo SD kartu a automaticky sa pripojí, takže sa jednoducho zobrazí v bočnom paneli. Na čokoľvek zložitejšie — formátovanie disku, kontrolu stavu SMART alebo vytváranie partícií — spustite _Disks_ zo spúšťača aplikácií (`Super + Space`).

Dvojité kliknutie sa riadi rozumnými predvoľbami: obrázky, videá a hudba sa otvárajú v Omaview, PDF v Document Viewer, Markdown v Omawrite a obyčajný text v editore vybranom v časti _Setup > Default > Editor_.

## Disktree

Keď sa disk zaplní a vy netušíte, čo ho žerie, spustite [Disktree](https://github.com/tobi/disktree) zo spúšťača aplikácií (`Super + Space`). Zobrazuje grafickú stromovú mapu vášho domovského adresára. Väčšie bloky zaberajú viac miesta; adresármi prechádzajte klávesnicou alebo myšou, označte, čo má ísť preč, a pred odstránením čohokoľvek si svoj výber skontrolujte. Spustením `disktree --disk` preskenujete celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoko rozšíriteľná aplikácia na zapisovanie poznámok, ktorá na ukladanie používa jednoduché súbory Markdown.

Obsidian je bezplatný na všetky účely vrátane osobného, komerčného a neziskového použitia.

Obsidian ponúka aj [komerčný doplnok na synchronizáciu](https://obsidian.md/sync) s mobilnými aplikáciami pre iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocou `Super + Shift + O`. Ak chcete používať synchronizáciu tém, musíte v nastaveniach vybrať tému `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastná mŕtvolne jednoduchá aplikácia Omarchy na písanie v Markdowne. Žiadne vaulty, žiadne pluginy, len vy a slová.

Omawrite spustíte pomocou `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základný nástroj na úpravu obrázkov, ktorý je skvelý na orezávanie, zmenu veľkosti a ďalšie základné úpravy. Len nečakajte alternatívu k Photoshopu. Ale stále má čarovný prútik a vrstvy!

Pintu spustíte cez spúšťač aplikácií (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikácia na tvorbu tém, ktorá dokáže vyextrahovať farby z obrázka na pozadí a premeniť ich na kompletnú, ucelenú tému. Je to najjednoduchší spôsob, ako si [vytvoriť vlastnú tému](43-making-your-own-theme.md).

Aether spustíte cez spúšťač aplikácií (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožňuje posielať súbory do iných zariadení v tej istej sieti, na ktorých beží táto aplikácia, podobne ako AirDrop od Apple. Je však multiplatformový, takže môžete posielať súbory do zariadení so systémami Windows, macOS, Android, iOS a samozrejme Linux aj z nich.

Ponuku Share otvoríte pomocou `Super + Ctrl + S` alebo v ponuke Omarchy v časti _Trigger > Share_. Dáva vám štyri možnosti:

- **Clipboard** odošle všetko, čo ste skopírovali, ako textový súbor. Skvelé na to, aby ste dostali odkaz alebo úryvok kódu do telefónu bez toho, aby ste si posielali e-mail.
- **File** otvorí nástroj na výber súborov, v ktorom ich môžete vybrať niekoľko naraz.
- **Folder** odošle celý adresár.
- **Receive** otvorí samotný LocalSend, aby vám mohlo iné zariadenie niečo poslať.

To isté funguje aj z terminálu pomocou `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Ak cestu vynecháte, zobrazí sa nástroj na výber súborov.

Posielať môžete aj priamo zo správcu súborov: kliknite pravým tlačidlom myši na ľubovoľný výber v Nautilus a zvoľte _Send via LocalSend_.

Firewall Omarchy je predvolene zatvorený s výnimkou portu LocalSend, takže to funguje hneď po čerstvej inštalácii. Pozrite si [zabezpečenie](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletný kancelársky balík s textovým procesorom, tabuľkovým procesorom, prezentáciami, aplikáciou na kreslenie a ďalšími nástrojmi. Je kompatibilný so súbormi z Microsoft Office, takže je to skvelý spôsob, ako môžete otvárať tie dokumenty z Wordu.

LibreOffice spustíte cez spúšťač aplikácií (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastná mŕtvolne jednoduchá prezentačná aplikácia Omarchy. Vaša prezentácia je jediný súbor Markdown, vedľa ktorého sú jeho obrázky a videá: každú snímku napíšete pod živým náhľadom, snímky potiahnutím usporiadate do poradia a potom prezentujete na celej obrazovke alebo exportujete do PDF a PowerPoint. Dokonca prevezme aj vašu tému Omarchy.

Hype spustíte cez spúšťač aplikácií (`Super + Space`). Stlačením `?` v ňom zobrazíte všetky skratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastný mŕtvolne jednoduchý spôsob Omarchy na podpisovanie PDF a ich vypĺňanie. Umiestnite svoj uložený podpis, text a dnešný dátum kamkoľvek na stránku a potom uložte podpísanú kópiu vedľa originálu. Ako na to, sa dozviete v časti [Vypĺňanie PDF](27-filling-out-pdfs.md).

Signed spustíte cez spúšťač aplikácií (`Super + Space`) alebo ním otvoríte PDF zo správcu súborov.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastná mŕtvolne jednoduchá kalkulačka Omarchy, ktorá sa otvára v plávajúcom okne.

Omacalc spustíte pomocou `Super + Shift + Q` (alebo klávesom kalkulačky, ak ho vaša klávesnica má).

## Signal

[Signal](https://signal.org/) je priekopníkom šifrovanej komunikácie E2E a skvelou možnosťou komunikácie pre každého, kto by radšej nešiel cez niektorý z veľkých technologických konglomerátov.

Signal spustíte pomocou `Super + Shift + G`. Nie je súčasťou základnej inštalácie, takže keď ho stlačíte prvýkrát, Omarchy vám ponúkne, že ho za vás nainštaluje (je aj v ponuke Omarchy v časti _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastný mŕtvolne jednoduchý prehliadač obrázkov a prehrávač médií Omarchy: jedno okno pre vaše fotografie, videá a hudbu. Otvorte fotografiu a klávesmi so šípkami prejdete zvyškom jej priečinka, `N` a `P` to robia pri čomkoľvek a `Ctrl + M` zobrazí celý priečinok ako mriežku. Zobrazuje aj fotografie HEIC, AVIF a JPEG XL a pri všetkom dlhom pokračuje tam, kde ste skončili.

Stlačením `F` prejdete na celú obrazovku, `E` upravíte obrázok v Omasnap alebo orežete video v Omacut, `Ctrl + P` vytlačíte obrázok a `Delete` presuniete súbor do Trash (`Ctrl + Z` ho vráti späť). Stlačením `?` v ňom zobrazíte všetky skratky.

Omaview spustíte ako _Media Viewer_ cez spúšťač aplikácií (`Super + Space`) alebo jednoducho dvakrát kliknete na obrázok, video či skladbu v správcovi súborov.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastný mŕtvolne jednoduchý orezávač videa Omarchy. Keď potrebujete len odrezať začiatok a koniec klipu, porazí spúšťanie plnohodnotného editora videa.

Omacut spustíte cez spúšťač aplikácií (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastný mŕtvolne jednoduchý rekordér z webovej kamery Omarchy. Kameru a mikrofón si vyberiete raz, potom stlačíte `Space` na nahrávanie a znova na pozastavenie a obnovenie toho istého záberu. Vždy nahráva v najvyššom rozlíšení vašej kamery, so živým meračom mikrofónu, takže si pred začatím môžete skontrolovať úrovne.

Zastavte záber a okamžite sa otvorí vo vstavanom editore. Dvojitým kliknutím klip rozdelíte, potiahnutím úchytov orežete každý kúsok a odstránite časti, ktoré nechcete. Potom ho uložte ako MP4. Vaša pôvodná nahrávka zostane uchovaná, kým ju nezahodíte, takže sa k nej môžete vždy vrátiť a zostrihať ju inak.

Monologue spustíte cez spúšťač aplikácií (`Super + Space`).
