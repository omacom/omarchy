# GUI

## Súbory

Súbory (Nautilus) je grafický správca súborov. Otvára sa pomocou `Super + Shift + F` a pomocou `Super + Shift + Alt + F` sa otvorí v adresári, v ktorom sa nachádza tvoj terminál, čo šetrí množstvo klikania. Pomocou `Ctrl + L` môžeš zadať cestu a stlačenie `Space` na ľubovoľnom súbore ti poskytne rýchly náhľad bez toho, aby si niečo otváral.

Zapoj USB kľúč alebo SD kartu a automaticky sa pripojí, takže sa jednoducho objaví v bočnom paneli. Na čokoľvek náročnejšie — formátovanie jednotky, kontrolu stavu SMART, vytváranie oddielov — spusti _Disky_ zo spúšťača aplikácií (`Super + Space`).

Dvojklik sa riadi rozumnými predvolenými nastaveniami: obrázky sa otvárajú v imv, video v mpv, PDF v programe Document Viewer a obyčajný text v editore Neovim.

## Disktree

Keď sa jednotka zaplní a ty netušíš, čo ju požiera, spusti [Disktree](https://github.com/tobi/disktree) zo spúšťača aplikácií (`Super + Space`). Zobrazí grafickú stromovú mapu tvojho domovského adresára. Väčšie bloky zaberajú viac miesta; prechádzaj do adresárov klávesnicou alebo myšou, označ, čo má ísť preč, a pred odstránením čohokoľvek si skontroluj svoj výber. Spustením `disktree --disk` naskenuješ celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoko rozšíriteľná aplikácia na písanie poznámok, ktorá na ukladanie používa jednoduché súbory Markdown.

Obsidian je bezplatný na všetky účely vrátane osobného, komerčného a neziskového použitia.

Obsidian ponúka aj [komerčný doplnok na synchronizáciu](https://obsidian.md/sync) s mobilnými aplikáciami pre iOS a Android. (https://obsidian.md/pricing).

Obsidian spúšťaš pomocou `Super + Shift + O`. Ak chceš používať synchronizáciu témy, musíš v nastaveniach vybrať tému `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastná, úplne jednoduchá aplikácia Omarchy na písanie v Markdowne. Žiadne sejfy, žiadne pluginy, len ty a slová.

Omawrite spúšťaš pomocou `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základný nástroj na úpravu obrázkov, ktorý je skvelý na orezávanie, zmenu veľkosti a ďalšie základné úpravy. Len nečakaj alternatívu k Photoshopu. Ale stále má čarovnú paličku (Magic Wand) a vrstvy!

Pintu spúšťaš prostredníctvom spúšťača aplikácií (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikácia na tvorbu tém, ktorá dokáže extrahovať farby z obrázka pozadia a premeniť ich na kompletnú, súvislú tému. Je to najjednoduchší spôsob, ako si [vytvoriť vlastnú tému](43-making-your-own-theme.md).

Aether spúšťaš prostredníctvom spúšťača aplikácií (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ti umožňuje odosielať súbory do iných zariadení v tej istej sieti, na ktorých beží táto aplikácia, podobne ako AirDrop od Apple. Je však multiplatformový, takže súbory môžeš odosielať do systému Windows, macOS, Android, iOS a samozrejme Linuxu a z nich.

Menu Zdieľať môžeš otvoriť pomocou `Super + Ctrl + S` alebo v časti _Akcie > Zdieľať_ v menu Omarchy. Poskytuje ti štyri možnosti:

- **Schránka** odošle všetko, čo si skopíroval, ako textový súbor. Skvelé na to, ako dostať odkaz alebo útržok do telefónu bez toho, aby si si posielal e-mail.
- **Súbor** otvorí výber súborov, kde ich môžeš vybrať niekoľko naraz.
- **Priečinok** odošle celý adresár.
- **Prijať** otvorí samotný LocalSend, aby ti iné zariadenie mohlo niečo poslať.

Rovnaká vec funguje z terminálu pomocou `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Ak cestu vynecháš, dostaneš výber.

Odosielať môžeš aj priamo zo správcu súborov: klikni pravým tlačidlom myši na ľubovoľný výber v programe Nautilus a vyber _Send via LocalSend_.

Brána firewall v Omarchy je predvolene zatvorená s výnimkou portu LocalSend, takže to funguje hneď po čerstvej inštalácii. Pozri si časť [zabezpečenie](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletný kancelársky balík s textovým procesorom, tabuľkovým kalkulátorom, prezentáciami, aplikáciou na kreslenie a ďalšími. Je kompatibilný so súbormi z balíka Microsoft Office, takže je to skvelý spôsob, ako môžeš otvárať dokumenty Wordu.

LibreOffice spúšťaš prostredníctvom spúšťača aplikácií (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastná, úplne jednoduchá prezentačná aplikácia Omarchy. Tvoja prezentácia je jediný súbor Markdown s obrázkami a videami vedľa neho: každú snímku píšeš pod živým náhľadom, snímky presúvaš do poradia a potom prezentuješ na celú obrazovku alebo exportuješ do PDF a PowerPointu. Dokonca preberie aj tvoju tému Omarchy.

Hype spúšťaš prostredníctvom spúšťača aplikácií (`Super + Space`). Stlačením `?` v ňom zobrazíš každú skratku.

## Signed

[Signed](https://github.com/omacom/signed) je vlastný, úplne jednoduchý spôsob Omarchy, ako podpisovať PDF a vypĺňať ich. Umiestni svoj uložený podpis, text a dnešný dátum kdekoľvek na stránku a potom ulož podpísanú kópiu vedľa originálu. Ako na to, nájdeš v časti [Vypĺňanie PDF](27-filling-out-pdfs.md).

Signed spúšťaš prostredníctvom spúšťača aplikácií (`Super + Space`) alebo pomocou neho otvoríš PDF zo správcu súborov.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastná, úplne jednoduchá kalkulačka Omarchy, ktorá sa otvára v plávajúcom okne.

Omacalc spúšťaš pomocou `Super + Ctrl + Q` (alebo klávesu kalkulačky, ak ho tvoja klávesnica má).

## Signal

[Signal](https://signal.org/) je priekopníkom správ so šifrovaním E2E a skvelou možnosťou komunikácie pre každého, kto by radšej nešiel cez niektorý z veľkých technologických konglomerátov.

Signal spúšťaš pomocou `Super + Shift + G`. Nie je súčasťou základnej inštalácie, takže keď to stlačíš prvýkrát, Omarchy ti ponúkne jeho inštaláciu (je aj v časti _Inštalovať > Služba_ v menu Omarchy).

## mpv

[mpv](https://mpv.io/) je jednoduchý, rýchly prehrávač médií, ktorý prehrá takmer čokoľvek z akéhokoľvek zdroja. Skvelý na sledovanie videí.

mpv spúšťaš prostredníctvom spúšťača aplikácií (`Super + Space`) alebo jednoducho dvojitým kliknutím na video v správcovi súborov.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastný, úplne jednoduchý strihač videa od Omarchy. Keď potrebuješ len odrezať začiatok a koniec klipu, poráža spúšťanie plnohodnotného editora videa.

Omacut spúšťaš prostredníctvom spúšťača aplikácií (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastný, úplne jednoduchý rekordér webkamery od Omarchy. Raz si vyber kameru a mikrofón, potom stlač `Space`, aby si nahrával, a znova, aby si ten istý záber pozastavil a obnovil. Vždy nahráva v najvyššom rozlíšení tvojej kamery, so živým meračom mikrofónu, aby si si pred začatím mohol skontrolovať úrovne.

Zastav záber a okamžite sa otvorí vo vstavanom editore. Dvojitým kliknutím na klip ho rozdelíš, potiahnutím rukovätí orežeš každý kúsok a odstrániš časti, ktoré nechceš. Potom ho ulož ako MP4. Tvoja pôvodná nahrávka sa uchováva, kým ju nezahodíš, takže sa k nej môžeš vždy vrátiť a zostrihať ju inak.

Monologue spúšťaš prostredníctvom spúšťača aplikácií (`Super + Space`).
