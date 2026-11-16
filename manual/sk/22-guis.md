# Grafické aplikácie

## Súbory

Súbory (Nautilus) sú grafický správca súborov. `Super + Shift + F` ho otvorí a `Super + Shift + Alt + F` ho otvorí v adresári, v ktorom sa práve nachádza váš terminál, čo ušetrí veľa klikania. `Ctrl + L` vám umožní zadať cestu a stlačením klávesu `Space` na ľubovoľnom súbore získate rýchly náhľad bez toho, aby ste čokoľvek otvárali.

Zapojte USB kľúč alebo SD kartu a automaticky sa pripojí, takže sa jednoducho zobrazí v bočnom paneli. Na čokoľvek zložitejšie — formátovanie disku, kontrolu stavu SMART, vytváranie oddielov — spustite _Disks_ zo spúšťača aplikácií (`Super + Space`).

Dvojité kliknutie sa riadi rozumnými predvolenými nastaveniami: obrázky, videá a hudba sa otvárajú v Omaview, PDF v Document Viewer, Markdown v Omawrite a obyčajný text v editore vybranom v _Setup > Default > Editor_.

## Disktree

Keď sa disk zaplní a vy netušíte, čo ho zapĺňa, spustite [Disktree](https://github.com/tobi/disktree) zo spúšťača aplikácií (`Super + Space`). Zobrazí grafickú stromovú mapu vášho domovského adresára. Väčšie bloky zaberajú viac miesta; prechádzajte adresármi pomocou klávesnice alebo myši, označte, čo má ísť preč, a pred odstránením čohokoľvek si svoje výbery skontrolujte. Spustite `disktree --disk`, ak chcete preskenovať celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoko rozšíriteľná aplikácia na písanie poznámok, ktorá na ukladanie používa jednoduché súbory Markdown.

Obsidian je bezplatný na všetky účely vrátane osobného, komerčného a neziskového použitia.

Obsidian ponúka aj [komerčný doplnok na synchronizáciu](https://obsidian.md/sync) s mobilnými aplikáciami pre iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocou `Super + Shift + O`. Ak chcete používať synchronizáciu tém, musíte v nastaveniach vybrať tému `Omarchy`.

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

[LocalSend](https://localsend.org/) vám umožňuje odosielať súbory do iných zariadení v rovnakej sieti, na ktorých beží táto aplikácia, podobne ako AirDrop od Apple. Je však multiplatformový, takže môžete odosielať súbory do a zo systémov Windows, macOS, Android, iOS a samozrejme Linux.

Ponuku Share môžete otvoriť pomocou `Super + Ctrl + S` alebo v ponuke Omarchy pod _Trigger > Share_. Ponúka vám štyri možnosti:

- **Clipboard** odošle všetko, čo ste skopírovali, ako textový súbor. Skvelé na to, ako dostať odkaz alebo úryvok do telefónu bez toho, aby ste si posielali e-mail.
- **File** otvorí výber súborov, v ktorom môžete vybrať niekoľko naraz.
- **Folder** odošle celý adresár.
- **Receive** otvorí samotný LocalSend, aby vám iné zariadenie mohlo niečo poslať.

Rovnaká vec funguje aj z terminálu pomocou `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Cestu vynechajte a zobrazí sa vám výber súborov.

Odosielať môžete aj priamo zo správcu súborov: kliknite pravým tlačidlom myši na ľubovoľný výber v Nautilus a vyberte _Send via LocalSend_.

Firewall v Omarchy je predvolene zatvorený s výnimkou portu LocalSend, takže to funguje hneď po čerstvej inštalácii. Pozrite si [zabezpečenie](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletný kancelársky balík s textovým procesorom, tabuľkovým kalkulátorom, prezentáciami, aplikáciou na kreslenie a ďalšími. Je kompatibilný so súbormi z Microsoft Office, takže je to skvelý spôsob, ako otvárať tie dokumenty z Wordu.

LibreOffice spustíte cez spúšťač aplikácií (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastná úplne jednoduchá prezentačná aplikácia Omarchy. Vaša prezentácia je jeden súbor Markdown s obrázkami a videami vedľa neho: každý snímok píšete pod živým náhľadom, snímky presúvate ťahaním do požadovaného poradia, potom prezentujete na celej obrazovke alebo exportujete do PDF a PowerPoint. Dokonca preberie aj vašu tému Omarchy.

Hype spustíte cez spúšťač aplikácií (`Super + Space`). Stlačte `?` vnútri aplikácie, aby ste videli všetky skratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastný úplne jednoduchý spôsob Omarchy, ako podpisovať PDF súbory a vyplňovať ich. Umiestnite svoj uložený podpis, text a dnešný dátum kamkoľvek na stránku, potom uložte podpísanú kópiu vedľa originálu. Ako na to, pozrite si [Vyplňovanie PDF súborov](27-filling-out-pdfs.md).

Signed spustíte cez spúšťač aplikácií (`Super + Space`) alebo s ním otvorte PDF zo správcu súborov.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) je vlastná 3D šachová hra Omarchy. Hrajte s priateľom na tom istom počítači alebo proti vstavanému protivníkovi na troch úrovniach, so štyrmi modelovanými súpravami, z ktorých každá sa pohybuje vlastným spôsobom: orbitálne plavidlá, vyrezávané drevo a slonová kosť, lesné tvory a cukríky. Hry nemajú hodiny a ukladajú sa po každom ťahu.

Checkmate spustíte cez spúšťač aplikácií (`Super + Space`). Stlačte `?` vnútri aplikácie, aby ste videli všetky skratky.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastná úplne jednoduchá kalkulačka Omarchy, ktorá sa otvára v plávajúcom okne.

Omacalc spustíte pomocou `Super + Shift + Q` (alebo klávesom kalkulačky, ak ho vaša klávesnica má).

## Signal

[Signal](https://signal.org/) je priekopníkom šifrovanej komunikácie E2E a skvelou možnosťou komunikácie pre každého, kto by radšej nešiel cez jeden z veľkých technologických konglomerátov.

Signal spustíte pomocou `Super + Shift + G`. Nie je súčasťou základnej inštalácie, takže keď to stlačíte prvýkrát, Omarchy vám ponúkne, že vám ho nainštaluje (nachádza sa aj v ponuke Omarchy pod _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastný úplne jednoduchý prehliadač obrázkov a prehrávač médií Omarchy: jedno okno pre vaše fotografie, videá a hudbu. Otvorte fotografiu a klávesy so šípkami prechádzajú zvyškom jej priečinka, `N` a `P` to robia pre čokoľvek a `Ctrl + M` zobrazí celý priečinok ako mriežku. Zobrazuje aj fotografie HEIC, AVIF a JPEG XL a pokračuje tam, kde ste prestali, pri čokoľvek dlhom.

Stlačte `F` pre celú obrazovku, `E` na úpravu obrázka v Omasnap alebo orezanie videa v Omacut, `Ctrl + P` na tlač obrázka a `Delete` na presunutie súboru do koša (`Ctrl + Z` ho vráti späť). Stlačte `?` vnútri aplikácie, aby ste videli všetky skratky.

Omaview spustíte ako _Media Viewer_ cez spúšťač aplikácií (`Super + Space`) alebo jednoducho dvakrát kliknite na obrázok, video alebo skladbu v správcovi súborov.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastný úplne jednoduchý strihač videa Omarchy. Keď potrebujete len odrezať začiatok a koniec klipu, prekoná spúšťanie plnohodnotného editora videa.

Omacut spustíte cez spúšťač aplikácií (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastný úplne jednoduchý rekordér webkamery Omarchy. Raz si vyberte kameru a mikrofón, potom stlačte `Space` na nahrávanie a znova na pozastavenie a pokračovanie toho istého záberu. Vždy nahráva v najvyššom rozlíšení vašej kamery, so živým meračom mikrofónu, aby ste si pred začiatkom mohli skontrolovať úrovne.

Zastavte záber a okamžite sa otvorí vo vstavanom editore. Dvakrát kliknite na klip, aby ste ho rozdelili, potiahnite úchyty na orezanie každého kúska a odstráňte časti, ktoré nechcete. Potom ho uložte ako MP4. Vaša pôvodná nahrávka sa zachová, kým ju nezahodíte, takže sa k nej môžete vždy vrátiť a zostrihať ju inak.

Monologue spustíte cez spúšťač aplikácií (`Super + Space`).
