# Grafické aplikácie

## Súbory

Súbory (Nautilus) sú grafický správca súborov. Otvoríte ho pomocou `Super + Shift + F` a pomocou `Super + Shift + Alt + F` ho otvoríte v adresári, v ktorom sa práve nachádza váš terminál, čo ušetrí veľa klikania. Pomocou `Ctrl + L` môžete zadať cestu a stlačením `Space` na ľubovoľnom súbore získate rýchly náhľad bez toho, aby ste čokoľvek otvárali.

Pripojte USB kľúč alebo SD kartu a automaticky sa pripojí, takže sa jednoducho zobrazí v bočnom paneli. Na čokoľvek zložitejšie — formátovanie disku, kontrolu stavu SMART, vytváranie partícií — spustite _Disks_ zo spúšťača aplikácií (`Super + Space`).

Dvojité kliknutie sa riadi rozumnými predvolenými nastaveniami: obrázky, videá a hudba sa otvárajú v Omaview, PDF súbory v Document Viewer a obyčajný text v Neovim.

## Disktree

Keď sa disk zaplní a nemáte tušenie, čo ho zapĺňa, spustite [Disktree](https://github.com/tobi/disktree) zo spúšťača aplikácií (`Super + Space`). Zobrazí grafickú stromovú mapu vášho domovského adresára. Väčšie bloky zaberajú viac miesta; prechádzajte adresármi pomocou klávesnice alebo myši, označte, čo má ísť preč, a pred odstránením čokoľvek skontrolujte svoje výbery. Spustite `disktree --disk`, ak chcete skenovať celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoko rozšíriteľná aplikácia na písanie poznámok, ktorá na ukladanie používa jednoduché súbory Markdown.

Obsidian je bezplatný na všetky účely vrátane osobného, komerčného a neziskového použitia.

Obsidian ponúka aj [komerčný doplnok na synchronizáciu](https://obsidian.md/sync) s mobilnými aplikáciami pre iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocou `Super + Shift + O`. Ak chcete používať synchronizáciu tém, musíte v nastaveniach vybrať tému `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastná úplne jednoduchá aplikácia Omarchy na písanie v Markdowne. Žiadne vaulty, žiadne pluginy, len vy a slová.

Omawrite spustíte pomocou `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základný nástroj na úpravu obrázkov, ktorý je skvelý na orezávanie, zmenu veľkosti a ďalšie základné úpravy. Len od neho nečakajte alternatívu k Photoshopu. Ale stále má Magic Wand a vrstvy!

Pinta spustíte cez spúšťač aplikácií (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikácia na tvorbu tém, ktorá dokáže extrahovať farby z obrázka na pozadí a premeniť ich na kompletnú, súdržnú tému. Je to najjednoduchší spôsob, ako si [vytvoriť vlastnú tému](43-making-your-own-theme.md).

Aether spustíte cez spúšťač aplikácií (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožňuje posielať súbory do iných zariadení v rovnakej sieti, v ktorých beží táto aplikácia, podobne ako AirDrop od Apple. Je však multiplatformový, takže môžete posielať súbory do a zo systémov Windows, macOS, Android, iOS a samozrejme Linux.

Ponuku Share môžete otvoriť pomocou `Super + Ctrl + S` alebo v ponuke Omarchy pod _Trigger > Share_. Ponúka vám štyri možnosti:

- **Clipboard** odošle všetko, čo ste skopírovali, ako textový súbor. Skvelé na to, aby ste dostali odkaz alebo útržok kódu do telefónu bez toho, aby ste si posielali e-mail.
- **File** otvorí výber súborov, kde môžete vybrať niekoľko naraz.
- **Folder** odošle celý adresár.
- **Receive** otvorí samotný LocalSend, aby vám iné zariadenie mohlo niečo poslať.

To isté funguje z terminálu pomocou `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Ak cestu vynecháte, zobrazí sa výber súborov.

Posielať môžete aj priamo zo správcu súborov: kliknite pravým tlačidlom myši na ľubovoľný výber v Nautiluse a vyberte _Send via LocalSend_.

Firewall v Omarchy je predvolene uzavretý s výnimkou portu pre LocalSend, takže to funguje hneď po čistej inštalácii. Pozri [bezpečnosť](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletný kancelársky balík s textovým procesorom, tabuľkovým kalkulátorom, prezentáciami, aplikáciou na kreslenie a ďalšími. Je kompatibilný so súbormi z Microsoft Office, takže je to skvelý spôsob, ako môžete otvárať tie dokumenty z Wordu.

LibreOffice spustíte cez spúšťač aplikácií (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastná úplne jednoduchá prezentačná aplikácia Omarchy. Vaša prezentácia je jeden súbor Markdown s obrázkami a videami vedľa neho: každý slajd píšete pod živým náhľadom, slajdy potiahnutím usporiadate do poradia, potom prezentujete na celej obrazovke alebo exportujete do PDF a PowerPoint. Dokonca prevezme vašu tému Omarchy.

Hype spustíte cez spúšťač aplikácií (`Super + Space`). Stlačte v ňom `?`, ak chcete vidieť všetky skratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastný úplne jednoduchý spôsob Omarchy, ako podpisovať PDF súbory a vypĺňať ich. Umiestnite svoj uložený podpis, text a dnešný dátum kamkoľvek na stránku, potom uložte podpísanú kópiu vedľa originálu. Ako na to, pozri [Vypĺňanie súborov PDF](27-filling-out-pdfs.md).

Signed spustíte cez spúšťač aplikácií (`Super + Space`) alebo s ním otvorte PDF súbor zo správcu súborov.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastná úplne jednoduchá kalkulačka Omarchy, ktorá sa otvára v plávajúcom okne.

Omacalc spustíte pomocou `Super + Shift + Q` (alebo klávesom kalkulačky, ak ho vaša klávesnica má).

## Signal

[Signal](https://signal.org/) je priekopníkom E2E šifrovanej komunikácie a skvelou komunikačnou možnosťou pre každého, kto by radšej nešiel cez jeden z veľkých technologických konglomerátov.

Signal spustíte pomocou `Super + Shift + G`. Nie je súčasťou základnej inštalácie, takže keď to stlačíte prvýkrát, Omarchy vám ponúkne, že ho pre vás nainštaluje (nachádza sa aj v ponuke Omarchy pod _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastný úplne jednoduchý prehliadač obrázkov a prehrávač médií Omarchy: jedno okno pre vaše fotografie, videá a hudbu. Otvorte fotografiu a klávesy so šípkami prechádzajú zvyškom jej priečinka, `N` a `P` to robia pre čokoľvek a `Ctrl + M` zobrazí celý priečinok ako mriežku. Zobrazuje aj fotografie HEIC, AVIF a JPEG XL a pri všetkom dlhom pokračuje tam, kde ste prestali.

Stlačte `F` pre režim celej obrazovky, `E` na úpravu obrázka v Omasnap alebo orezanie videa v Omacut, `Ctrl + P` na tlač obrázka a `Delete` na presunutie súboru do Trash (`Ctrl + Z` ho vráti späť). Stlačte v ňom `?`, ak chcete vidieť všetky skratky.

Omaview spustíte ako _Media Viewer_ cez spúšťač aplikácií (`Super + Space`) alebo jednoducho dvakrát kliknite na obrázok, video alebo skladbu v správcovi súborov.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastný úplne jednoduchý strihač videa Omarchy. Keď potrebujete len odrezať začiatok a koniec klipu, je to lepšie, než spúšťať plnohodnotný editor videa.

Omacut spustíte cez spúšťač aplikácií (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastný úplne jednoduchý záznamník z webkamery Omarchy. Vyberte si kameru a mikrofón raz, potom stlačte `Space` na nahrávanie a znova na pozastavenie a pokračovanie toho istého záberu. Vždy nahráva v najvyššom rozlíšení vašej kamery, so živým meračom mikrofónu, takže si pred začatím môžete skontrolovať svoje úrovne.

Zastavte záber a hneď sa otvorí vo vstavanom editore. Dvojitým kliknutím klip rozdelíte, potiahnutím úchytov orežete každý kus a odstránite časti, ktoré nechcete. Potom ho uložte ako MP4. Vaša pôvodná nahrávka zostane zachovaná, kým ju nezahodíte, takže sa k nej môžete vždy vrátiť a zostrihať ju inak.

Monologue spustíte cez spúšťač aplikácií (`Super + Space`).
