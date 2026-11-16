# GUI aplikácie

## Files

Files (Nautilus) je grafický správca súborov. `Super + Shift + F` ho otvorí a `Super + Shift + Alt + F` ho otvorí v priečinku, v ktorom sa práve nachádza váš terminál, čo ušetrí veľa klikania. `Ctrl + L` vám umožní zadať cestu a stlačením `Space` na ľubovoľnom súbore získate rýchly náhľad bez toho, aby ste čokoľvek otvárali.

Zapojte USB kľúč alebo SD kartu a automaticky sa pripojí, takže sa jednoducho zobrazí v bočnom paneli. Na čokoľvek zložitejšie — formátovanie disku, kontrolu stavu SMART, vytváranie oddielov — spustite _Disks_ zo spúšťača aplikácií (`Super + Space`).

Dvojklik funguje podľa rozumných predvolených nastavení: obrázky, videá a hudba sa otvárajú v Omaview, PDF v Document Viewer, Markdown v Omawrite a obyčajný text v editore vybranom v časti _Setup > Default > Editor_.

## Disktree

Keď sa disk zaplní a vy netušíte, čo ho zapĺňa, spustite [Disktree](https://github.com/tobi/disktree) zo spúšťača aplikácií (`Super + Space`). Zobrazuje grafickú stromovú mapu vášho domovského priečinka. Väčšie bloky zaberajú viac miesta; prechádzajte priečinkami pomocou klávesnice alebo myši, označte, čo má ísť preč, a pred odstránením čohokoľvek skontrolujte svoj výber. Spustite `disktree --disk`, ak chcete preskenovať celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoko rozšíriteľná aplikácia na písanie poznámok, ktorá na ukladanie používa jednoduché súbory Markdown.

Obsidian je bezplatný na všetky účely vrátane osobného, komerčného a neziskového použitia.

Obsidian ponúka aj [komerčný doplnok na synchronizáciu](https://obsidian.md/sync) s mobilnými aplikáciami pre iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocou `Super + Shift + O`. Ak chcete používať synchronizáciu tém, musíte v nastaveniach vybrať tému `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastná, úplne jednoduchá aplikácia Omarchy na písanie v Markdowne. Žiadne vaulty, žiadne pluginy, len vy a slová.

Omawrite spustíte pomocou `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základný nástroj na úpravu obrázkov, ktorý je skvelý na orezávanie, zmenu veľkosti a ďalšie základné úpravy. Len nečakajte alternatívu k Photoshopu. Stále však má Magic Wand a vrstvy!

Pintu spustíte cez spúšťač aplikácií (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikácia na tvorbu tém, ktorá dokáže extrahovať farby z obrázka na pozadí a premeniť ich na kompletnú, súdržnú tému. Je to najjednoduchší spôsob, ako si [vytvoriť vlastnú tému](43-making-your-own-theme.md).

Aether spustíte cez spúšťač aplikácií (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožňuje posielať súbory do iných zariadení v rovnakej sieti, v ktorých beží táto aplikácia, podobne ako AirDrop od Apple. Je však multiplatformový, takže môžete posielať súbory do a zo systémov Windows, macOS, Android, iOS a, samozrejme, Linux.

Ponuku Share môžete otvoriť pomocou `Super + Ctrl + S` alebo v ponuke Omarchy v časti _Trigger > Share_. Ponúka vám štyri možnosti:

- **Clipboard** odošle všetko, čo ste skopírovali, ako textový súbor. Skvelé, keď chcete dostať odkaz alebo úryvok do telefónu bez toho, aby ste si posielali e-mail.
- **File** otvorí výber súborov, kde môžete vybrať aj niekoľko naraz.
- **Folder** odošle celý priečinok.
- **Receive** otvorí samotný LocalSend, aby vám iné zariadenie mohlo niečo poslať.

To isté funguje z terminálu pomocou `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Vynechajte cestu a zobrazí sa vám výber súborov.

Posielať môžete aj priamo zo správcu súborov: kliknite pravým tlačidlom myši na ľubovoľný výber v Nautilus a vyberte _Send via LocalSend_.

Firewall v Omarchy je predvolene zatvorený s výnimkou portu LocalSend, takže to na čerstvej inštalácii funguje bez ďalšieho nastavovania. Pozrite si [zabezpečenie](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletný kancelársky balík s textovým procesorom, tabuľkovým procesorom, prezentáciami, aplikáciou na kreslenie a ďalšími nástrojmi. Je kompatibilný so súbormi z Microsoft Office, takže je to skvelý spôsob, ako otvárať tie dokumenty z Wordu.

LibreOffice spustíte cez spúšťač aplikácií (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastná, úplne jednoduchá prezentačná aplikácia Omarchy. Vaša prezentácia je jeden súbor Markdown s obrázkami a videami vedľa neho: každú snímku píšete pod živým náhľadom, snímky presúvate do požadovaného poradia a potom prezentujete na celú obrazovku alebo exportujete do PDF a PowerPoint. Dokonca preberie aj vašu tému Omarchy.

Hype spustíte cez spúšťač aplikácií (`Super + Space`). Stlačte `?` vnútri aplikácie, ak chcete zobraziť všetky skratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastný, úplne jednoduchý spôsob Omarchy, ako podpisovať PDF súbory a vyplňovať ich. Umiestnite svoj uložený podpis, text a dnešný dátum kamkoľvek na stránku a potom uložte podpísanú kópiu vedľa originálu. Ako na to, nájdete v časti [Vyplňovanie PDF súborov](27-filling-out-pdfs.md).

Signed spustíte cez spúšťač aplikácií (`Super + Space`) alebo s ním otvorte PDF zo správcu súborov.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) je vlastná 3D šachová hra Omarchy. Hrajte s priateľom na tom istom počítači alebo proti vstavanému súperovi na troch úrovniach, na štyroch tvarovaných súpravách, z ktorých každá sa pohybuje vlastným spôsobom: orbitálne plavidlá, vyrezávané drevo a slonovina, lesné bytosti a cukríky. Hry nemajú hodiny a ukladajú sa po každom ťahu.

Checkmate spustíte cez spúšťač aplikácií (`Super + Space`), kde je uvedená ako Chess. Stlačte `?` vnútri aplikácie, ak chcete zobraziť všetky skratky.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastná, úplne jednoduchá kalkulačka Omarchy, ktorá sa otvára v plávajúcom okne.

Omacalc spustíte pomocou `Super + Shift + Q` (alebo klávesom kalkulačky, ak ho vaša klávesnica má).

## Signal

[Signal](https://signal.org/) je priekopníkom šifrovanej komunikácie E2E a skvelou možnosťou komunikácie pre každého, kto by radšej nešiel cez jeden z veľkých technologických konglomerátov.

Signal spustíte pomocou `Super + Shift + G`. Nie je súčasťou základnej inštalácie, takže keď to stlačíte prvýkrát, Omarchy vám ponúkne, že vám ho nainštaluje (nachádza sa aj v ponuke Omarchy v časti _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastný, úplne jednoduchý prehliadač obrázkov a prehrávač médií Omarchy: jedno okno pre vaše fotografie, videá a hudbu. Otvorte fotografiu a klávesy so šípkami prechádzajú zvyškom jej priečinka, `N` a `P` to robia pre čokoľvek a `Ctrl + M` zobrazí celý priečinok ako mriežku. Zobrazuje aj fotografie HEIC, AVIF a JPEG XL a pri čomkoľvek dlhom pokračuje tam, kde ste skončili.

Stlačte `F` pre zobrazenie na celú obrazovku, `E`, ak chcete upraviť obrázok v Omasnap alebo zostrihať video v Omacut, `Ctrl + P`, ak chcete vytlačiť obrázok, a `Delete`, ak chcete presunúť súbor do Trash (`Ctrl + Z` ho vráti späť). Stlačte `?` vnútri aplikácie, ak chcete zobraziť všetky skratky.

Omaview spustíte ako _Media Viewer_ cez spúšťač aplikácií (`Super + Space`) alebo jednoducho dvakrát kliknite na obrázok, video alebo skladbu v správcovi súborov.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastný, úplne jednoduchý strihač videa Omarchy. Keď potrebujete len odrezať začiatok a koniec klipu, je to lepšie ako spúšťať plnohodnotný editor videa.

Omacut spustíte cez spúšťač aplikácií (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastný, úplne jednoduchý záznamník z webkamery Omarchy. Raz si vyberte kameru a mikrofón, potom stlačte `Space` na nahrávanie a znova na pozastavenie a pokračovanie toho istého záberu. Vždy nahráva v najvyššom rozlíšení vašej kamery, so živým ukazovateľom úrovne mikrofónu, takže si pred začatím môžete skontrolovať úrovne.

Keď záber zastavíte, hneď sa otvorí vo vstavanom editore. Dvojitým kliknutím klip rozdelíte, potiahnutím úchytov orežete každú časť a odstránite časti, ktoré nechcete. Potom ho uložte ako MP4. Vaša pôvodná nahrávka zostane zachovaná, kým ju nezahodíte, takže sa k nej môžete vždy vrátiť a zostrihať ju inak.

Monologue spustíte cez spúšťač aplikácií (`Super + Space`).
