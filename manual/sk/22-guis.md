# GUIs

## Files

Files (Folio) je grafický správca súborov. `Super + Shift + F` ho otvorí a `Super + Shift + Alt + F` ho otvorí v adresári, v ktorom sa práve nachádza váš terminál, čo ušetrí veľa klikania. `Ctrl + L` vám umožní zadať cestu a stlačením `Space` na ľubovoľnom súbore si ho zobrazíte v plnej veľkosti bez toho, aby ste ho otvorili.

Pripojte USB kľúč alebo SD kartu a automaticky sa pripojí, takže sa jednoducho zobrazí v bočnom paneli. Na čokoľvek zložitejšie — formátovanie disku, kontrolu stavu SMART, vytváranie oddielov — spustite _Disks_ zo spúšťača aplikácií (`Super + Space`).

Dvojklik sa riadi rozumnými predvolenými nastaveniami: obrázky, videá a hudba sa otvárajú v Omaview, PDF súbory v Document Viewer, Markdown v Omawrite a obyčajný text vo vašom editore, v Plain, pokiaľ si v _Setup > Defaults > Editor_ nevyberiete iný.

## Disktree

Keď sa disk zaplní a vy nemáte ani tušenie, čo ho zapĺňa, spustite [Disktree](https://github.com/tobi/disktree) zo spúšťača aplikácií (`Super + Space`). Zobrazí grafickú stromovú mapu vášho domovského adresára. Väčšie bloky zaberajú viac miesta; do adresárov vstupujte klávesnicou alebo myšou, označte, čo má ísť preč, a pred odstránením čohokoľvek si svoje voľby skontrolujte. Spustením `disktree --disk` preskenujete celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoko rozšíriteľná aplikácia na písanie poznámok, ktorá na ukladanie používa jednoduché súbory Markdown.

Obsidian je bezplatný na všetky účely vrátane osobného, komerčného a neziskového použitia.

Obsidian ponúka aj [komerčný doplnok na synchronizáciu](https://obsidian.md/sync) s mobilnými aplikáciami pre iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocou `Super + Shift + O`. Ak chcete používať synchronizáciu tém, musíte v nastaveniach vybrať tému `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastná úplne jednoduchá aplikácia Omarchy na písanie v Markdowne. Žiadne trezory, žiadne doplnky, len vy a slová.

Omawrite spustíte pomocou `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základný nástroj na úpravu obrázkov, ktorý je skvelý na orezávanie, zmenu veľkosti a ďalšie základné úpravy. Len nečakajte alternatívu k Photoshopu. Stále však má Magic Wand aj vrstvy!

Pintu spustíte cez spúšťač aplikácií (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikácia na tvorbu tém, ktorá dokáže extrahovať farby z obrázka na pozadí a premeniť ich na kompletnú, súdržnú tému. Je to najjednoduchší spôsob, ako si [vytvoriť vlastnú tému](43-making-your-own-theme.md).

Aether spustíte cez spúšťač aplikácií (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožňuje posielať súbory do iných zariadení v rovnakej sieti, v ktorých beží táto aplikácia, podobne ako AirDrop od Apple. Je však multiplatformový, takže súbory môžete posielať do a z Windows, macOS, Android, iOS a samozrejme Linuxu.

Ponuku Share otvoríte pomocou `Super + Ctrl + S` alebo v ponuke Omarchy pod _Trigger > Share_. Ponúka vám štyri možnosti:

- **Clipboard** pošle čokoľvek, čo ste skopírovali, ako textový súbor. Skvelé na to, ako dostať odkaz alebo úryvok do telefónu bez toho, aby ste si posielali e-mail.
- **File** otvorí výber súborov, v ktorom ich môžete vybrať niekoľko naraz.
- **Folder** pošle celý adresár.
- **Receive** otvorí samotný LocalSend, aby vám iné zariadenie mohlo niečo poslať.

To isté funguje aj z terminálu pomocou `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Cestu vynechajte a zobrazí sa vám výber súborov.

Posielať môžete aj priamo zo správcu súborov: kliknite pravým tlačidlom na ľubovoľný výber v Files a zdieľajte ho cez LocalSend.

Firewall v Omarchy je predvolene uzavretý s výnimkou portu LocalSend, takže toto funguje hneď po čistej inštalácii. Pozrite si [zabezpečenie](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletný kancelársky balík s textovým procesorom, tabuľkovým procesorom, prezentáciami, aplikáciou na kreslenie a ďalšími. Je kompatibilný so súbormi z Microsoft Office, takže je to skvelý spôsob, ako otvárať tie dokumenty z Wordu.

LibreOffice spustíte cez spúšťač aplikácií (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastná úplne jednoduchá prezentačná aplikácia Omarchy. Vaša prezentácia je jeden súbor Markdown s obrázkami a videami vedľa neho: každú snímku píšete pod živým náhľadom, snímky presúvate ťahaním do požadovaného poradia a potom prezentujete na celú obrazovku alebo exportujete do PDF a PowerPointu. Dokonca prevezme aj vašu tému Omarchy.

Hype spustíte cez spúšťač aplikácií (`Super + Space`). Stlačením `?` v ňom zobrazíte všetky skratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastný úplne jednoduchý spôsob Omarchy, ako podpisovať PDF súbory a vypĺňať ich. Umiestnite svoj uložený podpis, text a dnešný dátum kamkoľvek na stránku a potom uložte podpísanú kópiu vedľa originálu. Ako na to, nájdete v časti [Vypĺňanie PDF súborov](27-filling-out-pdfs.md).

Signed spustíte cez spúšťač aplikácií (`Super + Space`) alebo s ním otvorte PDF súbor zo správcu súborov.

## Game Vibes

Game Vibes v spúšťači aplikácií (`Super + Space`) je miesto, kde žijú malé hry Omarchy: Checkmate, 3D šachová hra proti priateľovi alebo vstavanému súperovi; Cards, solitaire Klondike; Death Wish, pixelovo presný platformer s desiatimi miestnosťami plnými ostňov a píl; a Neon Swarm, arkádová strieľačka. Každá je jedna webová stránka, ktorá sa riadi vašou témou. Vyberte si jednu šípkami a klávesom `Enter` a do zoznamu sa vráťte klávesom `Esc` z úvodnej obrazovky hry alebo klávesom `Q`, keď je pozastavená. Otvorí sa na celú obrazovku: `Super + F` z nej urobí okno a `Super + W` ju zatvorí.

Hry, ktoré vytvoríte s agentom, sa zobrazia aj tu: v paneli agentov vyberte _Make something cool → Game_ a jednu opíšte, alebo pomenujte hru, ktorá už v Game Vibes je, aby ste na nej ďalej pracovali. Agent ju skopíruje do `~/Games/vibes`, kde je vaša a môžete ju meniť, a po dokončení ju otvorí. Túto kópiu si môžete vytvoriť aj sami pomocou `omarchy games vibes copy <game>`. Hra, ktorú zdieľa niekto iný, sa inštaluje ako téma: vyberte _Install > Gaming > Game Vibes_ a vložte jej git adresu, alebo spustite `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ jednu znova odstráni a _Update > Game Vibes Games_ stiahne nové verzie. Hry načítavajú three.js z webu, takže na spustenie potrebujú pripojenie.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastná úplne jednoduchá kalkulačka Omarchy, ktorá sa otvára v plávajúcom okne.

Omacalc spustíte pomocou `Super + Shift + Q` (alebo klávesom kalkulačky, ak ho vaša klávesnica má).

## Signal

[Signal](https://signal.org/) je priekopníkom E2E šifrovanej komunikácie a skvelou komunikačnou možnosťou pre každého, kto by radšej nešiel cez jeden z veľkých technologických konglomerátov.

Signal spustíte pomocou `Super + Shift + G`. Nie je súčasťou základnej inštalácie, takže keď ho prvýkrát stlačíte, Omarchy vám ponúkne, že vám ho nainštaluje (nachádza sa aj v ponuke Omarchy pod _Install > Service_). 

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastný úplne jednoduchý prehliadač obrázkov a prehrávač médií Omarchy: jedno okno pre vaše fotografie, videá a hudbu. Otvorte fotografiu a klávesmi so šípkami prechádzajte zvyškom jej priečinka, `N` a `P` to robia pre čokoľvek a `Ctrl + M` zobrazí celý priečinok ako mriežku. Zobrazuje aj fotografie HEIC, AVIF a JPEG XL a v čomkoľvek dlhom pokračuje tam, kde ste prestali.

Stlačte `F` pre celú obrazovku, `E` na úpravu obrázka v Omasnap alebo orezanie videa v Omacut, `Ctrl + P` na tlač obrázka a `Delete` na presunutie súboru do koša (`Ctrl + Z` ho vráti späť). Stlačením `?` v ňom zobrazíte všetky skratky.

Omaview spustíte ako _Media Viewer_ cez spúšťač aplikácií (`Super + Space`) alebo jednoducho dvakrát kliknite na obrázok, video či skladbu v správcovi súborov.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastný úplne jednoduchý strihač videa Omarchy. Keď potrebujete len odrezať začiatok a koniec klipu, je to lepšie než spúšťať plnohodnotný editor videa.

Omacut spustíte cez spúšťač aplikácií (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastný úplne jednoduchý záznamník z webkamery Omarchy. Raz si vyberte kameru a mikrofón, potom stlačte `Space` na nahrávanie a znova na pozastavenie a pokračovanie toho istého záberu. Vždy nahráva v najvyššom rozlíšení vašej kamery, so živým ukazovateľom mikrofónu, aby ste si pred začatím mohli skontrolovať úrovne.

Zastavte záber a hneď sa otvorí vo vstavanom editore. Dvojitým kliknutím klip rozdelíte, ťahaním úchytov orezáte každý kúsok a odstránite časti, ktoré nechcete. Potom ho uložte ako MP4. Vaša pôvodná nahrávka zostane zachovaná, kým ju nezahodíte, takže sa k nej môžete vždy vrátiť a zostrihať ju inak.

Monologue spustíte cez spúšťač aplikácií (`Super + Space`).
