# Grafické aplikácie

## Files

Files (Nautilus) je grafický správca súborov. `Super + Shift + F` ho otvorí a `Super + Shift + Alt + F` ho otvorí v adresári, v ktorom sa práve nachádza váš terminál, čo ušetrí veľa klikania. `Ctrl + L` vám umožní zadať cestu a stlačením `Space` na ľubovoľnom súbore získate rýchly náhľad bez toho, aby ste čokoľvek otvárali.

Zapojte USB kľúč alebo SD kartu a automaticky sa pripojí, takže sa jednoducho zobrazí v bočnom paneli. Pre čokoľvek náročnejšie — formátovanie disku, kontrolu stavu SMART, vytváranie oddielov — spustite _Disks_ zo spúšťača aplikácií (`Super + Space`).

Dvojklik dodržiava rozumné predvolené nastavenia: obrázky, videá a hudba sa otvárajú v Omaview, PDF súbory v Document Viewer, Markdown v Omawrite a obyčajný text v editore vybranom v _Setup > Default > Editor_.

## Disktree

Keď sa disk zaplní a nemáte ani tušenie, čo ho zapĺňa, spustite [Disktree](https://github.com/tobi/disktree) zo spúšťača aplikácií (`Super + Space`). Zobrazuje grafickú stromovú mapu vášho domovského adresára. Väčšie bloky zaberajú viac miesta; prechádzajte adresármi klávesnicou alebo myšou, označte, čo má ísť preč, a pred odstránením čohokoľvek si skontrolujte svoj výber. Spustite `disktree --disk`, ak chcete preskenovať celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoko rozšíriteľná aplikácia na písanie poznámok, ktorá na ukladanie používa jednoduché súbory Markdown.

Obsidian je bezplatný na všetky účely vrátane osobného, komerčného a neziskového použitia.

Obsidian ponúka aj [komerčný doplnok na synchronizáciu](https://obsidian.md/sync) s mobilnými aplikáciami pre iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocou `Super + Shift + O`. Ak chcete používať synchronizáciu tém, musíte v nastaveniach vybrať tému `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastná úplne jednoduchá aplikácia Omarchy na písanie v Markdowne. Žiadne trezory, žiadne doplnky, len vy a slová.

Omawrite spustíte pomocou `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základný nástroj na úpravu obrázkov, ktorý je skvelý na orezávanie, zmenu veľkosti a ďalšie základné úpravy. Len nečakajte alternatívu k Photoshopu. Stále však má Čarovnú paličku a vrstvy!

Pinta spustíte cez spúšťač aplikácií (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikácia na tvorbu tém, ktorá dokáže extrahovať farby z obrázka na pozadí a premeniť ich na kompletnú, súdržnú tému. Je to najjednoduchší spôsob, ako si [vytvoriť vlastnú tému](43-making-your-own-theme.md).

Aether spustíte cez spúšťač aplikácií (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožňuje posielať súbory do iných zariadení v rovnakej sieti, na ktorých beží táto aplikácia, podobne ako AirDrop od Apple. Je však multiplatformový, takže môžete posielať súbory do a z Windows, macOS, Android, iOS a samozrejme Linuxu.

Menu Zdieľať môžete otvoriť pomocou `Super + Ctrl + S` alebo v menu Omarchy pod _Trigger > Share_. Ponúka vám štyri možnosti:

- **Clipboard** odošle všetko, čo ste skopírovali, ako textový súbor. Skvelé na to, aby ste dostali odkaz alebo útržok do telefónu bez toho, aby ste si posielali e-mail.
- **File** otvorí nástroj na výber súborov, v ktorom ich môžete vybrať niekoľko naraz.
- **Folder** odošle celý adresár.
- **Receive** otvorí samotný LocalSend, aby vám iné zariadenie mohlo niečo poslať.

To isté funguje aj z terminálu pomocou `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Cestu vynechajte a zobrazí sa vám nástroj na výber súborov.

Môžete posielať aj priamo zo správcu súborov: kliknite pravým tlačidlom myši na ľubovoľný výber v Nautiluse a vyberte _Send via LocalSend_.

Firewall v Omarchy je predvolene zatvorený s výnimkou portu LocalSend, takže to funguje hneď po čerstvej inštalácii. Pozrite si [zabezpečenie](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletný kancelársky balík s textovým procesorom, tabuľkovým kalkulátorom, prezentáciami, aplikáciou na kreslenie a ďalšími nástrojmi. Je kompatibilný so súbormi z Microsoft Office, takže je to skvelý spôsob, ako môžete otvárať tie dokumenty Word.

LibreOffice spustíte cez spúšťač aplikácií (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastná úplne jednoduchá prezentačná aplikácia Omarchy. Vaša prezentácia je jeden súbor Markdown s obrázkami a videami vedľa neho: každú snímku píšete pod živým náhľadom, snímky presúvate do požadovaného poradia, potom prezentujete na celú obrazovku alebo exportujete do PDF a PowerPointu. Dokonca preberie aj vašu tému Omarchy.

Hype spustíte cez spúšťač aplikácií (`Super + Space`). Stlačte `?` vnútri, aby ste videli všetky skratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastný úplne jednoduchý spôsob Omarchy na podpisovanie PDF súborov a ich vypĺňanie. Umiestnite svoj uložený podpis, text a dnešný dátum kamkoľvek na stránku a potom uložte podpísanú kópiu vedľa originálu. Ako na to, nájdete v časti [Vypĺňanie PDF súborov](27-filling-out-pdfs.md).

Signed spustíte cez spúšťač aplikácií (`Super + Space`) alebo s ním otvorte PDF súbor zo správcu súborov.

## Game Vibes

Game Vibes v spúšťači aplikácií (`Super + Space`) je miesto, kde žijú malé hry Omarchy: Checkmate, 3D šachová hra proti priateľovi alebo vstavanému súperovi; Cards, solitér Klondike; a Neon Swarm, arkádová strieľačka. Každá je jedna webová stránka, ktorá sa riadi vašou témou. Vyberte si jednu šípkami a `Enter` a vráťte sa do zoznamu pomocou `Esc` z titulnej obrazovky hry alebo `Q`, keď je pozastavená. Otvára sa na celú obrazovku: `Super + F` z nej urobí okno a `Super + W` ju zatvorí.

Hry, ktoré vytvoríte s agentom, sa zobrazia aj tu: vyberte _Make something cool → Game_ v paneli agentov a opíšte jednu, alebo pomenujte hru, ktorá už je v Game Vibes, aby ste na nej ďalej pracovali. Agent ju skopíruje do `~/Games/vibes`, kde je vaša a môžete ju meniť, a po dokončení ju otvorí. Túto kópiu si môžete vytvoriť aj sami pomocou `omarchy games vibes copy <game>`. Hra, ktorú zdieľa niekto iný, sa inštaluje ako téma: vyberte _Install > Gaming > Game Vibes_ a vložte jej git adresu, alebo spustite `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ jednu opäť odstráni a _Update > Game Vibes Games_ načíta nové verzie. Hry načítavajú three.js z webu, takže na spustenie potrebujú pripojenie.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastná úplne jednoduchá kalkulačka Omarchy, ktorá sa otvára v plávajúcom okne.

Omacalc spustíte pomocou `Super + Shift + Q` (alebo klávesom kalkulačky, ak ho vaša klávesnica má).

## Signal

[Signal](https://signal.org/) je priekopníkom E2E šifrovanej komunikácie a skvelou komunikačnou možnosťou pre každého, kto by radšej nešiel cez jeden z veľkých technologických konglomerátov.

Signal spustíte pomocou `Super + Shift + G`. Nie je súčasťou základnej inštalácie, takže keď to stlačíte prvýkrát, Omarchy vám ponúkne, že ho pre vás nainštaluje (nachádza sa aj v _Install > Service_ v menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastný úplne jednoduchý prehliadač obrázkov a prehrávač médií Omarchy: jedno okno pre vaše fotografie, videá a hudbu. Otvorte fotografiu a šípkami prechádzate zvyšok jej priečinka, `N` a `P` to robia pre čokoľvek a `Ctrl + M` zobrazí celý priečinok ako mriežku. Zobrazuje aj fotografie HEIC, AVIF a JPEG XL a pokračuje tam, kde ste prestali pri čomkoľvek dlhom.

Stlačte `F` pre celú obrazovku, `E` na úpravu obrázka v Omasnap alebo orezanie videa v Omacut, `Ctrl + P` na tlač obrázka a `Delete` na presunutie súboru do koša (`Ctrl + Z` ho vráti späť). Stlačte `?` vnútri, aby ste videli všetky skratky.

Omaview spustíte ako _Media Viewer_ cez spúšťač aplikácií (`Super + Space`) alebo jednoducho dvakrát kliknite na obrázok, video alebo skladbu v správcovi súborov.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastný úplne jednoduchý strihač videa Omarchy. Keď potrebujete len odrezať začiatok a koniec klipu, je to lepšie ako spúšťať plnohodnotný editor videa.

Omacut spustíte cez spúšťač aplikácií (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastný úplne jednoduchý záznamník z webkamery Omarchy. Raz si vyberte kameru a mikrofón, potom stlačte `Space` na nahrávanie a znova na pozastavenie a pokračovanie toho istého záberu. Vždy nahráva v najvyššom rozlíšení vašej kamery, so živým meračom mikrofónu, takže si môžete skontrolovať úrovne pred začiatkom.

Zastavte záber a okamžite sa otvorí vo vstavanom editore. Dvakrát kliknite na klip, aby ste ho rozdelili, potiahnite úchyty na orezanie každého kúska a odstráňte časti, ktoré nechcete. Potom ho uložte ako MP4. Váš pôvodný záznam sa zachová, kým ho nezahodíte, takže sa vždy môžete vrátiť a zostrihať ho inak.

Monologue spustíte cez spúšťač aplikácií (`Super + Space`).
