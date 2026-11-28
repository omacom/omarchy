# Grafické aplikácie

## Files

Files (Folio) je grafický správca súborov. `Super + Shift + F` ho otvorí a `Super + Shift + Alt + F` ho otvorí v adresári, v ktorom sa práve nachádza váš terminál, čo ušetrí veľa klikania. Pomocou `Ctrl + L` môžete napísať cestu a stlačením `Space` na ľubovoľnom súbore si ho zobrazíte v plnej veľkosti bez toho, aby ste ho otvorili.

Pripojte USB kľúč alebo SD kartu a automaticky sa pripojí, takže sa jednoducho zobrazí v bočnom paneli. Na čokoľvek zložitejšie — formátovanie disku, kontrolu stavu SMART, vytváranie oddielov — spustite _Disks_ zo spúšťača aplikácií (`Super + Space`).

Šifrovaný disk si pri pripojení vyžiada heslo. Ak chcete, aby sa jeden odomykal sám, pridajte k nemu keyfile pomocou `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` a umiestnite tento keyfile do `~/.config/omarchy/drive-keys/<UUID>`, pomenovaný podľa UUID, ktoré pre šifrovaný oddiel vypíše `lsblk -dno UUID /dev/sdX1`, a čitateľný len pre vás (`chmod 600`). Ak tento keyfile chýba alebo je odmietnutý, heslo sa od vás vyžiada ako zvyčajne.

Dvojklik dodržiava rozumné predvolené nastavenia: obrázky, videá a hudba sa otvárajú v Omaview, PDF v Document Viewer, Markdown v Omawrite a obyčajný text vo vašom editore, Plain, pokiaľ si v _Setup > Defaults > Editor_ nevyberiete iný.

## Disktree

Keď sa disk zaplní a vy netušíte, čo ho zapĺňa, spustite [Disktree](https://github.com/tobi/disktree) zo spúšťača aplikácií (`Super + Space`). Zobrazí grafickú treemapu vášho domovského adresára. Väčšie bloky zaberajú viac miesta; do adresárov prechádzajte klávesnicou alebo myšou, označte, čo má ísť preč, a pred odstránením čohokoľvek si svoj výber skontrolujte. Na skenovanie celého disku spustite `disktree --disk`.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoko rozšíriteľná aplikácia na písanie poznámok, ktorá na ukladanie používa jednoduché súbory Markdown.

Obsidian je bezplatný na všetky účely vrátane osobného, komerčného a neziskového použitia.

Obsidian ponúka aj [komerčný doplnok na synchronizáciu](https://obsidian.md/sync) s mobilnými aplikáciami na iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocou `Super + Shift + O`. Ak chcete používať synchronizáciu tém, musíte v nastaveniach vybrať tému `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastná úplne jednoduchá aplikácia Omarchy na písanie v Markdowne. Žiadne vaulty, žiadne pluginy, len vy a slová.

Omawrite spustíte pomocou `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základný nástroj na úpravu obrázkov, ktorý je skvelý na orezávanie, zmenu veľkosti a ďalšie základné úpravy. Len nečakajte alternatívu k Photoshopu. Ale stále má Magic Wand a vrstvy!

Pintu spustíte cez spúšťač aplikácií (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikácia na tvorbu tém, ktorá dokáže extrahovať farby z obrázka na pozadí a premeniť ich na kompletnú, ucelenú tému. Je to najjednoduchší spôsob, ako si [vytvoriť vlastnú tému](43-making-your-own-theme.md).

Aether spustíte cez spúšťač aplikácií (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožňuje posielať súbory do iných zariadení v rovnakej sieti, v ktorých beží táto aplikácia, podobne ako AirDrop od Apple. Je však multiplatformový, takže môžete posielať súbory do a z Windows, macOS, Android, iOS a samozrejme Linuxu.

Menu Share otvoríte pomocou `Super + Ctrl + S` alebo v menu Omarchy pod _Trigger > Share_. Ponúka vám štyri možnosti:

- **Clipboard** pošle čokoľvek, čo ste skopírovali, ako textový súbor. Skvelé na to, ako dostať odkaz alebo útržok do telefónu bez toho, aby ste si museli posielať e-mail.
- **File** otvorí výber súborov, kde ich môžete vybrať niekoľko naraz.
- **Folder** pošle celý adresár.
- **Receive** otvorí samotný LocalSend, aby vám iné zariadenie mohlo niečo poslať.

To isté funguje aj z terminálu pomocou `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Ak cestu vynecháte, zobrazí sa výber.

Posielať môžete aj priamo zo správcu súborov: kliknite pravým tlačidlom na ľubovoľný výber v Files a zdieľajte ho cez LocalSend.

Firewall v Omarchy je predvolene zatvorený s výnimkou portu LocalSend, takže to funguje hneď po čerstvej inštalácii. Pozrite si [zabezpečenie](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletný kancelársky balík s textovým procesorom, tabuľkovým kalkulátorom, prezentáciami, aplikáciou na kreslenie a ďalšími. Je kompatibilný so súbormi z Microsoft Office, takže je to skvelý spôsob, ako otvárať tie dokumenty z Wordu.

LibreOffice spustíte cez spúšťač aplikácií (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastná úplne jednoduchá prezentačná aplikácia Omarchy. Vaša prezentácia je jeden súbor Markdown s obrázkami a videami vedľa neho: každý slide píšete pod živým náhľadom, snímky presúvaním zoradíte a potom prezentujete na celú obrazovku alebo exportujete do PDF a PowerPointu. Dokonca prevezme aj vašu tému Omarchy.

Hype spustíte cez spúšťač aplikácií (`Super + Space`). Stlačením `?` vnútri zobrazíte všetky skratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastný úplne jednoduchý spôsob Omarchy, ako podpisovať PDF a vypĺňať ich. Umiestnite svoj uložený podpis, text a dnešný dátum kamkoľvek na stránku a potom uložte podpísanú kópiu vedľa originálu. Ako na to, nájdete v [Vypĺňanie PDF](27-filling-out-pdfs.md).

Signed spustíte cez spúšťač aplikácií (`Super + Space`) alebo s ním otvoríte PDF zo správcu súborov.

## Game Vibes

Game Vibes v spúšťači aplikácií (`Super + Space`) je miesto, kde žijú malé hry Omarchy: Checkmate, 3D šachová hra proti priateľovi alebo vstavanému súperovi; Cards, solitér Klondike; Death Wish, pixelovo presná plošinovka s desiatimi miestnosťami plnými ostňov a píl; a Neon Swarm, arkádová strieľačka. Každá je jedna webová stránka, ktorá sa riadi vašou témou. Jednu si vyberiete šípkami a klávesom `Enter` a do zoznamu sa vrátite pomocou `Esc` z titulnej obrazovky hry alebo `Q`, keď je pozastavená. Otvára sa na celú obrazovku: `Super + F` z nej urobí okno a `Super + W` ju zatvorí.

Hry, ktoré vytvoríte s agentom, sa tu zobrazia tiež: v paneli agentov vyberte _Make something cool → Game_ a jednu opíšte, alebo pomenujte hru, ktorá už v Game Vibes je, a pokračujte v práci na nej. Agent ju skopíruje do `~/Games/vibes`, kde je vaša a môžete ju meniť, a po dokončení ju otvorí. Túto kópiu si môžete vytvoriť aj sami pomocou `omarchy games vibes copy <game>`. Hra, ktorú zdieľa niekto iný, sa inštaluje ako téma: vyberte _Install > Gaming > Game Vibes_ a vložte jej git adresu, alebo spustite `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ ju zase odstráni a _Update > Game Vibes Games_ stiahne nové verzie. Hry načítavajú three.js z webu, takže na spustenie potrebujú pripojenie.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastná úplne jednoduchá kalkulačka Omarchy, ktorá sa otvára v plávajúcom okne.

Omacalc spustíte pomocou `Super + Shift + Q` (alebo klávesom kalkulačky, ak ho vaša klávesnica má).

## Signal

[Signal](https://signal.org/) je priekopníkom E2E šifrovanej komunikácie a skvelou možnosťou komunikácie pre každého, kto by radšej nešiel cez jeden z veľkých technologických konglomerátov.

Signal spustíte pomocou `Super + Shift + G`. Nie je súčasťou základnej inštalácie, takže keď to stlačíte prvýkrát, Omarchy vám ponúkne, že ho za vás nainštaluje (nájdete ho aj v menu Omarchy pod _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastný úplne jednoduchý prehliadač obrázkov a prehrávač médií Omarchy: jedno okno pre vaše fotografie, videá a hudbu. Otvorte fotografiu a klávesy so šípkami prechádzajú zvyškom jej priečinka, `N` a `P` to robia pre čokoľvek a `Ctrl + M` zobrazí celý priečinok ako mriežku. Zobrazuje aj fotografie HEIC, AVIF a JPEG XL a pri všetkom dlhom pokračuje tam, kde ste prestali.

Stlačte `F` pre celú obrazovku, `E` na úpravu obrázka v Omasnap alebo orezanie videa v Omacut, `Ctrl + P` na tlač obrázka a `Delete` na presunutie súboru do Trash (`Ctrl + Z` ho vráti späť). Stlačením `?` vnútri zobrazíte všetky skratky.

Omaview spustíte ako _Media Viewer_ cez spúšťač aplikácií (`Super + Space`) alebo jednoducho dvakrát kliknete na obrázok, video alebo skladbu v správcovi súborov.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastný úplne jednoduchý nástroj Omarchy na strihanie videa. Keď potrebujete len odrezať začiatok a koniec klipu, je to lepšie ako spúšťať plnohodnotný editor videa.

Omacut spustíte cez spúšťač aplikácií (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastný úplne jednoduchý rekordér webkamery Omarchy. Raz si vyberte kameru a mikrofón, potom stlačte `Space` na nahrávanie a znova na pozastavenie a pokračovanie toho istého záberu. Vždy nahráva v najvyššom rozlíšení vašej kamery, so živým meračom mikrofónu, aby ste si pred začiatkom mohli skontrolovať úrovne.

Zastavte záber a okamžite sa otvorí vo vstavanom editore. Dvojklikom klip rozdelíte, potiahnutím úchytov orežete každý kúsok a odstránite časti, ktoré nechcete. Potom ho uložte ako MP4. Vaša pôvodná nahrávka zostane zachovaná, kým ju nezahodíte, takže sa k nej môžete vždy vrátiť a zostrihať ju inak.

Monologue spustíte cez spúšťač aplikácií (`Super + Space`).
