# Grafické rozhrania

## Súbory

Files (Nautilus) je grafický správca súborov. Otvoríte ho pomocou `Super + Shift + F` a pomocou `Super + Shift + Alt + F` ho otvoríte v adresári, v ktorom sa práve nachádza váš terminál, čo ušetrí veľa klikania. `Ctrl + L` vám umožní zadať cestu a stlačením `Space` na ľubovoľnom súbore získate rýchly náhľad bez toho, aby ste čokoľvek otvárali.

Pripojte USB kľúč alebo SD kartu a automaticky sa pripojí, takže sa jednoducho zobrazí v bočnom paneli. Pre čokoľvek náročnejšie — formátovanie disku, kontrolu stavu SMART, vytváranie partícií — spustite _Disks_ zo spúšťača aplikácií (`Super + Space`).

Dvojité kliknutie dodržiava rozumné predvolené nastavenia: obrázky sa otvárajú v imv, videá v mpv, PDF súbory v Document Viewer a obyčajný text v Neovim.

## Disktree

Keď sa disk zaplní a vy netušíte, čo ho zapĺňa, spustite [Disktree](https://github.com/tobi/disktree) zo spúšťača aplikácií (`Super + Space`). Zobrazí grafickú stromovú mapu vášho domovského adresára. Väčšie bloky zaberajú viac miesta; prechádzajte adresármi pomocou klávesnice alebo myši, označte, čo má ísť preč, a pred odstránením čohokoľvek skontrolujte svoj výber. Spustite `disktree --disk` na skenovanie celého disku.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoko rozšíriteľná aplikácia na písanie poznámok, ktorá na ukladanie používa jednoduché súbory vo formáte Markdown.

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

[LocalSend](https://localsend.org/) vám umožňuje odosielať súbory do iných zariadení v rovnakej sieti, na ktorých je spustená táto aplikácia, podobne ako AirDrop od Apple. Je však multiplatformový, takže môžete odosielať súbory do a zo systémov Windows, macOS, Android, iOS a samozrejme Linux.

Ponuku Zdieľať môžete otvoriť pomocou `Super + Ctrl + S` alebo v ponuke Omarchy pod _Trigger > Share_. Ponúka vám štyri možnosti:

- **Clipboard** odošle všetko, čo ste skopírovali, ako textový súbor. Skvelé na to, aby ste dostali odkaz alebo úryvok do telefónu bez toho, aby ste si posielali e-mail.
- **File** otvorí výber súborov, kde môžete vybrať niekoľko naraz.
- **Folder** odošle celý adresár.
- **Receive** otvorí samotný LocalSend, aby vám iné zariadenie mohlo niečo poslať.

To isté funguje z terminálu pomocou `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Vynechajte cestu a zobrazí sa vám výber.

Môžete odosielať aj priamo zo správcu súborov: kliknite pravým tlačidlom myši na ľubovoľný výber v Nautilus a vyberte _Send via LocalSend_.

Firewall Omarchy je predvolene zatvorený s výnimkou portu LocalSend, takže to funguje hneď po čerstvej inštalácii. Pozrite si [zabezpečenie](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletný kancelársky balík s textovým procesorom, tabuľkovým procesorom, prezentáciami, aplikáciou na kreslenie a ďalšími nástrojmi. Je kompatibilný so súbormi z Microsoft Office, takže je to skvelý spôsob, ako otvárať dokumenty Word.

LibreOffice spustíte cez spúšťač aplikácií (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastná úplne jednoduchá prezentačná aplikácia Omarchy. Vaša prezentácia je jeden súbor vo formáte Markdown s obrázkami a videami vedľa neho: každú snímku píšete pod živým náhľadom, snímky presúvate do požadovaného poradia a potom prezentujete na celú obrazovku alebo exportujete do PDF a PowerPoint. Dokonca preberie aj vašu tému Omarchy.

Hype spustíte cez spúšťač aplikácií (`Super + Space`). Stlačte `?` vnútri aplikácie, aby ste videli všetky skratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastný úplne jednoduchý spôsob Omarchy, ako podpisovať PDF súbory a vypĺňať ich. Umiestnite svoj uložený podpis, text a dnešný dátum kamkoľvek na stránku a potom uložte podpísanú kópiu vedľa originálu. Pozrite si [Vypĺňanie PDF súborov](27-filling-out-pdfs.md), kde sa dozviete ako.

Signed spustíte cez spúšťač aplikácií (`Super + Space`) alebo s ním otvoríte PDF zo správcu súborov.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastná úplne jednoduchá kalkulačka Omarchy, ktorá sa otvára v plávajúcom okne.

Omacalc spustíte pomocou `Super + Shift + Q` (alebo klávesom kalkulačky, ak ho vaša klávesnica má).

## Signal

[Signal](https://signal.org/) je pionierom E2E šifrovaných správ a skvelou komunikačnou možnosťou pre každého, kto by radšej nešiel cez jeden z veľkých technologických konglomerátov.

Signal spustíte pomocou `Super + Shift + G`. Nie je súčasťou základnej inštalácie, takže keď to stlačíte prvýkrát, Omarchy vám ponúkne, že vám ho nainštaluje (nachádza sa aj v ponuke Omarchy pod _Install > Service_).

## mpv

[mpv](https://mpv.io/) je jednoduchý, rýchly prehrávač médií, ktorý prehrá takmer čokoľvek z akéhokoľvek zdroja. Skvelý na sledovanie videí.

mpv spustíte cez spúšťač aplikácií (`Super + Space`) alebo jednoducho dvojitým kliknutím na video v správcovi súborov.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastný úplne jednoduchý strihač videa Omarchy. Keď potrebujete len odrezať začiatok a koniec klipu, je to lepšie ako spúšťať plnohodnotný editor videa.

Omacut spustíte cez spúšťač aplikácií (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastný úplne jednoduchý rekordér webkamery Omarchy. Raz si vyberte kameru a mikrofón, potom stlačte `Space` na nahrávanie a znova na pozastavenie a pokračovanie toho istého záberu. Vždy nahráva v najvyššom rozlíšení vašej kamery so živým meračom mikrofónu, takže si pred začiatkom môžete skontrolovať úrovne.

Zastavte záber a okamžite sa otvorí vo vstavanom editore. Dvojitým kliknutím na klip ho rozdelíte, potiahnutím úchytov orežete každý kus a odstránite časti, ktoré nechcete. Potom ho uložte ako MP4. Vaša pôvodná nahrávka sa zachová, kým ju nezahodíte, takže sa k nej môžete kedykoľvek vrátiť a zostrihať ju inak.

Monologue spustíte cez spúšťač aplikácií (`Super + Space`).
