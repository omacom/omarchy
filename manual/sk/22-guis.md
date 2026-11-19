# GUIs

## Files

Files (Folio) je grafický správca súborov. `Super + Shift + F` ho otvorí a `Super + Shift + Alt + F` ho otvorí v adresári, v ktorom sa práve nachádza váš terminál, čo ušetrí veľa klikania. `Ctrl + L` vám umožní zadať cestu a stlačením `Space` na ľubovoľnom súbore si ho zobrazíte v náhľade v plnej veľkosti bez toho, aby ste ho otvorili.

Pripojte USB kľúč alebo SD kartu a automaticky sa pripojí, takže sa jednoducho zobrazí v bočnom paneli. Pre čokoľvek zložitejšie — formátovanie disku, kontrolu stavu SMART, vytváranie oddielov — spustite _Disks_ zo spúšťača aplikácií (`Super + Space`).

Dvojklik funguje podľa rozumných predvolených nastavení: obrázky, videá a hudba sa otvárajú v Omaview, PDF v Document Viewer, Markdown v Omawrite a obyčajný text v editore vybranom v časti _Setup > Default > Editor_.

## Disktree

Keď sa disk zaplní a vy nemáte ani tušenie, čo ho zapĺňa, spustite [Disktree](https://github.com/tobi/disktree) zo spúšťača aplikácií (`Super + Space`). Zobrazuje grafickú stromovú mapu vášho domovského adresára. Väčšie bloky zaberajú viac miesta; prechádzajte adresármi klávesnicou alebo myšou, označte, čo má ísť preč, a pred odstránením čohokoľvek si skontrolujte svoj výber. Spustením `disktree --disk` preskenujete celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoko rozšíriteľná aplikácia na poznámky, ktorá na ukladanie používa jednoduché súbory Markdown.

Obsidian je bezplatný na všetky účely vrátane osobného, komerčného a neziskového použitia.

Obsidian ponúka aj [komerčný doplnok na synchronizáciu](https://obsidian.md/sync) s mobilnými aplikáciami pre iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocou `Super + Shift + O`. Ak chcete používať synchronizáciu tém, musíte v nastaveniach vybrať tému `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastná úplne jednoduchá aplikácia Omarchy na písanie v Markdowne. Žiadne trezory, žiadne pluginy, len vy a slová.

Omawrite spustíte pomocou `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základný nástroj na úpravu obrázkov, ktorý je skvelý na orezávanie, zmenu veľkosti a ďalšie základné úpravy. Len nečakajte alternatívu k Photoshopu. Ale stále má čarovnú paličku a vrstvy!

Pinta spustíte cez spúšťač aplikácií (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikácia na tvorbu tém, ktorá dokáže extrahovať farby z obrázka na pozadí a premeniť ich na kompletnú, súdržnú tému. Je to najjednoduchší spôsob, ako si [vytvoriť vlastnú tému](43-making-your-own-theme.md).

Aether spustíte cez spúšťač aplikácií (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožňuje posielať súbory do iných zariadení v rovnakej sieti, v ktorých beží táto aplikácia, podobne ako AirDrop od Apple. Je však multiplatformový, takže môžete posielať súbory do a z Windows, macOS, Android, iOS a samozrejme Linuxu.

Ponuku Zdieľať môžete otvoriť pomocou `Super + Ctrl + S` alebo v ponuke Omarchy v časti _Trigger > Share_. Ponúka vám štyri možnosti:

- **Clipboard** odošle všetko, čo ste skopírovali, ako textový súbor. Skvelé na to, aby ste si dostali odkaz alebo úryvok do telefónu bez toho, aby ste si posielali e-mail.
- **File** otvorí výber súborov, kde môžete vybrať niekoľko naraz.
- **Folder** odošle celý adresár.
- **Receive** otvorí samotný LocalSend, aby vám iné zariadenie mohlo niečo poslať.

To isté funguje z terminálu pomocou `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Ak cestu vynecháte, zobrazí sa výber súborov.

Môžete posielať aj priamo zo správcu súborov: kliknite pravým tlačidlom na ľubovoľný výber vo Files a zdieľajte ho pomocou LocalSend.

Firewall Omarchy je predvolene uzavretý okrem portu LocalSend, takže to funguje hneď po čerstvej inštalácii. Pozrite si [zabezpečenie](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletný kancelársky balík s textovým procesorom, tabuľkovým procesorom, prezentáciami, aplikáciou na kreslenie a ďalšími. Je kompatibilný so súbormi z Microsoft Office, takže je to skvelý spôsob, ako otvárať tie dokumenty Word.

LibreOffice spustíte cez spúšťač aplikácií (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastná úplne jednoduchá prezentačná aplikácia Omarchy. Vaša prezentácia je jeden súbor Markdown s obrázkami a videami vedľa neho: každú snímku píšete pod živým náhľadom, snímky presúvate ťahaním do požadovaného poradia a potom prezentujete na celú obrazovku alebo exportujete do PDF a PowerPoint. Dokonca preberie aj vašu tému Omarchy.

Hype spustíte cez spúšťač aplikácií (`Super + Space`). Stlačením `?` vnútri zobrazíte všetky skratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastný úplne jednoduchý spôsob Omarchy, ako podpisovať PDF a vypĺňať ich. Umiestnite svoj uložený podpis, text a dnešný dátum kamkoľvek na stránku a potom uložte podpísanú kópiu vedľa originálu. Pozrite si [Vypĺňanie PDF](27-filling-out-pdfs.md), ako na to.

Signed spustíte cez spúšťač aplikácií (`Super + Space`) alebo s ním otvorte PDF zo správcu súborov.

## Game Vibes

Game Vibes v spúšťači aplikácií (`Super + Space`) je miesto, kde žijú malé hry Omarchy: Checkmate, 3D šachová hra proti priateľovi alebo vstavanému súperovi; Cards, solitaire Klondike; a Neon Swarm, arkádová strieľačka. Každá je jedna webová stránka, ktorá nasleduje vašu tému. Vyberte si jednu šípkami a `Enter` a vráťte sa do zoznamu pomocou `Esc` z titulnej obrazovky hry alebo `Q`, keď je pozastavená. Otvára sa na celú obrazovku: `Super + F` z nej urobí okno a `Super + W` ju zatvorí.

Hry, ktoré vytvoríte s agentom, sa tu tiež zobrazujú: v paneli agentov vyberte _Make something cool → Game_ a jednu opíšte, alebo pomenujte hru, ktorá už je v Game Vibes, aby ste na nej ďalej pracovali. Agent ju skopíruje do `~/Games/vibes`, kde je vaša a môžete ju meniť, a po dokončení ju otvorí. Túto kópiu si môžete vytvoriť sami pomocou `omarchy games vibes copy <game>`. Hra, ktorú zdieľa niekto iný, sa inštaluje ako téma: vyberte _Install > Gaming > Game Vibes_ a vložte jej git adresu, alebo spustite `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ jednu opäť odstráni a _Update > Game Vibes Games_ načíta nové verzie. Hry načítavajú three.js z webu, takže na spustenie potrebujú pripojenie.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastná úplne jednoduchá kalkulačka Omarchy, ktorá sa otvára v plávajúcom okne.

Omacalc spustíte pomocou `Super + Shift + Q` (alebo klávesom kalkulačky, ak ho vaša klávesnica má).

## Signal

[Signal](https://signal.org/) je priekopníkom v oblasti správ s E2E šifrovaním a skvelou komunikačnou možnosťou pre každého, kto by radšej nešiel cez jeden z veľkých technologických konglomerátov.

Signal spustíte pomocou `Super + Shift + G`. Nie je súčasťou základnej inštalácie, takže keď to prvýkrát stlačíte, Omarchy vám ponúkne, že vám ho nainštaluje (je tiež v ponuke Omarchy v časti _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastný úplne jednoduchý prehliadač obrázkov a prehrávač médií Omarchy: jedno okno pre vaše fotografie, videá a hudbu. Otvorte fotografiu a šípkami prechádzate zvyškom jej priečinka, `N` a `P` to robia pre čokoľvek a `Ctrl + M` zobrazí celý priečinok ako mriežku. Zobrazuje aj fotografie HEIC, AVIF a JPEG XL a pokračuje tam, kde ste prestali, pri čomkoľvek dlhom.

Stlačte `F` pre celú obrazovku, `E` na úpravu obrázka v Omasnap alebo orezanie videa v Omacut, `Ctrl + P` na tlač obrázka a `Delete` na presunutie súboru do koša (`Ctrl + Z` ho vráti späť). Stlačením `?` vnútri zobrazíte všetky skratky.

Omaview spustíte ako _Media Viewer_ cez spúšťač aplikácií (`Super + Space`) alebo jednoducho dvakrát kliknite na obrázok, video alebo pieseň v správcovi súborov.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastný úplne jednoduchý strihač videa Omarchy. Keď potrebujete len odrezať začiatok a koniec klipu, je lepší než spúšťať plnohodnotný editor videa.

Omacut spustíte cez spúšťač aplikácií (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastný úplne jednoduchý záznamník z webkamery Omarchy. Vyberte si kameru a mikrofón raz, potom stlačte `Space` na nahrávanie a znova na pozastavenie a pokračovanie toho istého záberu. Vždy nahráva v najvyššom rozlíšení vašej kamery, so živým meračom mikrofónu, aby ste si pred začatím mohli skontrolovať úrovne.

Zastavte záber a hneď sa otvorí vo vstavanom editore. Dvojitým kliknutím na klip ho rozdelíte, ťahaním úchytov orezáte každý kúsok a odstránite časti, ktoré nechcete. Potom ho uložte ako MP4. Vaša pôvodná nahrávka sa zachová, kým ju nezahodíte, takže sa vždy môžete vrátiť a zostrihať ju inak.

Monologue spustíte cez spúšťač aplikácií (`Super + Space`).
