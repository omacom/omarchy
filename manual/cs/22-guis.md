# GUI aplikace

## Files

Files (Nautilus) je grafický správce souborů. Otevřete ho pomocí `Super + Shift + F` a pomocí `Super + Shift + Alt + F` ho otevřete ve složce, ve které právě sedí váš terminál, což ušetří spoustu klikání. `Ctrl + L` vám umožní napsat cestu a stisknutí `Space` na libovolném souboru vám dá rychlý náhled, aniž byste cokoli otevírali.

Připojte USB disk nebo SD kartu a automaticky se připojí, takže se prostě objeví v postranním panelu. Na cokoli složitějšího — formátování disku, kontrolu stavu SMART, vytváření oddílů — spusťte _Disks_ ze spouštěče aplikací (`Super + Space`).

Dvojklik se řídí rozumnými výchozími nastaveními: obrázky, videa a hudba se otevírají v Omaview, PDF v Document Viewer, Markdown v Omawrite a prostý text v editoru vybraném v _Setup > Default > Editor_.

## Disktree

Když se disk zaplní a vy nemáte tušení, co ho žere, spusťte [Disktree](https://github.com/tobi/disktree) ze spouštěče aplikací (`Super + Space`). Zobrazí grafickou stromovou mapu vaší domovské složky. Větší bloky zabírají více místa; procházejte složkami klávesnicí nebo myší, označte, co má jít pryč, a před odstraněním čehokoli si výběr zkontrolujte. Spuštěním `disktree --disk` prohledáte celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoce rozšiřitelná aplikace na poznámky, která k ukládání používá jednoduché soubory Markdown.

Obsidian je bezplatný pro všechny účely, včetně osobního, komerčního a neziskového použití.

Obsidian nabízí také [komerční doplněk pro synchronizaci](https://obsidian.md/sync) s mobilními aplikacemi pro iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocí `Super + Shift + O`. Chcete-li používat synchronizaci témat, musíte v nastavení vybrat téma `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastní naprosto jednoduchá aplikace Omarchy na psaní v Markdownu. Žádné trezory, žádné pluginy, jen vy a slova.

Omawrite spustíte pomocí `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základní nástroj na úpravu obrázků, který je skvělý na ořezávání, změnu velikosti a další základní manipulace. Jen nečekejte náhradu za Photoshop. Ale pořád má Magic Wand a vrstvy!

Pinta spustíte přes spouštěč aplikací (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikace na tvorbu témat, která umí vytáhnout barvy z obrázku na pozadí a proměnit je v kompletní, soudržné téma. Je to nejjednodušší způsob, jak si [vytvořit vlastní téma](43-making-your-own-theme.md).

Aether spustíte přes spouštěč aplikací (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožní posílat soubory na jiná zařízení ve stejné síti, na kterých běží tato aplikace, podobně jako AirDrop od Applu. Je ale multiplatformní, takže můžete posílat soubory do Windows, macOS, Androidu, iOS a samozřejmě Linuxu a z nich.

Nabídku Sdílet otevřete pomocí `Super + Ctrl + S` nebo v nabídce Omarchy v _Trigger > Share_. Nabídne vám čtyři možnosti:

- **Clipboard** odešle cokoli, co jste zkopírovali, jako textový soubor. Skvělé, když chcete dostat odkaz nebo úryvek do telefonu, aniž byste si posílali e-mail.
- **File** otevře výběr souborů, kde jich můžete vybrat několik najednou.
- **Folder** odešle celou složku.
- **Receive** otevře samotný LocalSend, aby vám jiné zařízení mohlo něco poslat.

Totéž funguje z terminálu pomocí `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Cestu vynechte a dostanete výběr souborů.

Posílat můžete také rovnou ze správce souborů: klikněte pravým tlačítkem na libovolný výběr v Nautilu a vyberte _Send via LocalSend_.

Firewall v Omarchy je ve výchozím nastavení zavřený s výjimkou portu LocalSend, takže to funguje hned po čerstvé instalaci. Viz [zabezpečení](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletní kancelářský balík s textovým procesorem, tabulkami, prezentacemi, aplikací na kreslení a dalšími. Je kompatibilní se soubory z Microsoft Office, takže je to skvělý způsob, jak si moct otevřít ty dokumenty z Wordu.

LibreOffice spustíte přes spouštěč aplikací (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastní naprosto jednoduchá prezentační aplikace Omarchy. Vaše prezentace je jediný soubor Markdown s obrázky a videi vedle něj: každý snímek napište pod živý náhled, přetáhněte snímky do správného pořadí, pak prezentujte na celou obrazovku nebo exportujte do PDF a PowerPointu. Dokonce převezme i vaše téma Omarchy.

Hype spustíte přes spouštěč aplikací (`Super + Space`). Stiskněte v ní `?` a uvidíte všechny zkratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastní naprosto jednoduchý způsob Omarchy, jak podepisovat PDF a vyplňovat je. Umístěte svůj uložený podpis, text a dnešní datum kamkoli na stránku, pak uložte podepsanou kopii vedle originálu. Jak na to, najdete v [Vyplňování PDF](27-filling-out-pdfs.md).

Signed spustíte přes spouštěč aplikací (`Super + Space`), nebo s ním otevřete PDF ze správce souborů.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) je vlastní 3D šachová hra Omarchy. Hrajte s přítelem na stejném počítači nebo proti vestavěnému soupeři ve třech úrovních, se čtyřmi vyřezávanými sadami, z nichž se každá pohybuje po svém: orbitální stroje, vyřezávané dřevo a slonovina, lesní tvorové a cukroví. Partie nemají hodiny a ukládají se po každém tahu.

Checkmate spustíte přes spouštěč aplikací (`Super + Space`), kde je uvedená jako Chess. Stiskněte v ní `?` a uvidíte všechny zkratky.

## Cards

[Cards](https://github.com/omacom/cards) je vlastní solitaire Klondike od Omarchy. Taháte po třech, bez omezení počtu průchodů, ve čtyřech sériích karet: jedna je kreslená v barvách vašeho tématu a tři mají vlastní vzhled. Klikněte na kartu a pak tam, kam patří, přetáhněte ji, nebo ji dvojklikem pošlete na nejlepší místo. Hry se ukládají po každém tahu.

Cards spustíte přes spouštěč aplikací (`Super + Space`). Klikněte na její název, nebo stiskněte `?`, a uvidíte všechny zkratky.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastní naprosto jednoduchá kalkulačka Omarchy, která se otevírá v plovoucím okně.

Omacalc spustíte pomocí `Super + Shift + Q` (nebo klávesou kalkulačky, pokud ji vaše klávesnice má).

## Signal

[Signal](https://signal.org/) je průkopníkem šifrovaných zpráv E2E a skvělou komunikační volbou pro každého, kdo by raději nešel přes jeden z velkých technologických konglomerátů.

Signal spustíte pomocí `Super + Shift + G`. Není součástí základní instalace, takže když to stisknete poprvé, Omarchy vám nabídne, že ho za vás nainstaluje (je také v nabídce Omarchy v _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastní naprosto jednoduchý prohlížeč obrázků a přehrávač médií Omarchy: jedno okno pro vaše fotky, videa a hudbu. Otevřete fotku a klávesy se šipkami procházejí zbytek její složky, `N` a `P` to dělají pro cokoli a `Ctrl + M` zobrazí celou složku jako mřížku. Zobrazuje také fotky HEIC, AVIF a JPEG XL a u čehokoli dlouhého pokračuje tam, kde jste skončili.

Stiskněte `F` pro celou obrazovku, `E` pro úpravu obrázku v Omasnap nebo oříznutí videa v Omacut, `Ctrl + P` pro tisk obrázku a `Delete` pro přesunutí souboru do koše (`Ctrl + Z` ho vrátí zpět). Stiskněte v něm `?` a uvidíte všechny zkratky.

Omaview spustíte jako _Media Viewer_ přes spouštěč aplikací (`Super + Space`), nebo prostě dvojklikem na obrázek, video nebo písničku ve správci souborů.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastní naprosto jednoduchý nástroj Omarchy na stříhání videa. Když potřebujete jen useknout začátek a konec klipu, porazí spouštění plnohodnotného editoru videa.

Omacut spustíte přes spouštěč aplikací (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastní naprosto jednoduchý záznamník z webkamery od Omarchy. Jednou si vyberte kameru a mikrofon, pak stiskněte `Space` pro nahrávání a znovu pro pozastavení a pokračování stejného záběru. Vždy nahrává v nejvyšším rozlišení vaší kamery, s živým měřičem mikrofonu, abyste si před začátkem mohli zkontrolovat úrovně.

Zastavte záběr a hned se otevře ve vestavěném editoru. Dvojklikem klip rozdělíte, tažením za úchyty oříznete každý kousek a odstraníte části, které nechcete. Pak ho uložte jako MP4. Vaše původní nahrávka zůstane uložená, dokud ji nezahodíte, takže se k ní můžete kdykoli vrátit a sestříhat ji jinak.

Monologue spustíte přes spouštěč aplikací (`Super + Space`).
