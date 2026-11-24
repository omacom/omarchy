# Grafické aplikace

## Soubory

Soubory (Folio) jsou grafický správce souborů. `Super + Shift + F` ho otevře a `Super + Shift + Alt + F` ho otevře v adresáři, ve kterém se právě nachází váš terminál, což ušetří spoustu klikání. Pomocí `Ctrl + L` můžete zadat cestu a stisknutím klávesy `Space` na libovolném souboru si ho bez otevření zobrazíte v náhledu v plné velikosti.

Připojte USB flash disk nebo SD kartu a připojí se automaticky, takže se prostě objeví v postranním panelu. Pro cokoli složitějšího — formátování disku, kontrolu stavu SMART, vytváření oddílů — spusťte _Disks_ ze spouštěče aplikací (`Super + Space`).

Dvojklik se řídí rozumnými výchozími nastaveními: obrázky, videa a hudba se otevírají v Omaview, PDF v Document Viewer, Markdown v Omawrite a prostý text ve vašem editoru, kterým je Plain, pokud si v _Setup > Defaults > Editor_ nevyberete jiný.

## Disktree

Když se disk zaplní a nemáte tušení, co ho požírá, spusťte [Disktree](https://github.com/tobi/disktree) ze spouštěče aplikací (`Super + Space`). Zobrazí grafickou stromovou mapu vašeho domovského adresáře. Větší bloky zabírají více místa; procházejte adresáře klávesnicí nebo myší, označte, co má jít pryč, a před odstraněním čehokoli si svůj výběr zkontrolujte. Spuštěním `disktree --disk` prohledáte celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a velmi rozšiřitelná aplikace na poznámky, která k ukládání používá jednoduché soubory ve formátu Markdown.

Obsidian je zdarma pro všechny účely, včetně osobního, komerčního a neziskového použití.

Obsidian také nabízí [komerční doplněk pro synchronizaci](https://obsidian.md/sync) s mobilními aplikacemi na iOS a Androidu. (https://obsidian.md/pricing).

Obsidian spustíte klávesami `Super + Shift + O`. Chcete-li používat synchronizaci motivů, musíte v nastavení vybrat motiv `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastní naprosto jednoduchá aplikace Omarchy na psaní v Markdownu. Žádné trezory, žádné pluginy, jen vy a slova.

Omawrite spustíte klávesami `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základní nástroj na úpravu obrázků, který je skvělý na ořezávání, změnu velikosti a další základní úpravy. Jen nečekejte náhradu za Photoshop. Ale stejně má Magic Wand a vrstvy!

Pintu spustíte přes spouštěč aplikací (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikace na tvorbu motivů, která dokáže extrahovat barvy z obrázku na pozadí a proměnit je v kompletní, soudržný motiv. Je to nejjednodušší způsob, jak si [vytvořit vlastní motiv](43-making-your-own-theme.md).

Aether spustíte přes spouštěč aplikací (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožňuje posílat soubory do jiných zařízení ve stejné síti, na kterých běží tato aplikace, podobně jako AirDrop od Applu. Je ale multiplatformní, takže můžete posílat soubory do a z Windows, macOS, Androidu, iOS a samozřejmě Linuxu.

Nabídku Share otevřete klávesami `Super + Ctrl + S` nebo v nabídce Omarchy v části _Trigger > Share_. Nabízí čtyři možnosti:

- **Clipboard** odešle cokoli, co jste zkopírovali, jako textový soubor. Skvělé, když potřebujete dostat odkaz nebo úryvek do telefonu, aniž byste si posílali e-mail.
- **File** otevře výběr souborů, kde jich můžete vybrat několik najednou.
- **Folder** odešle celý adresář.
- **Receive** otevře samotný LocalSend, aby vám jiné zařízení mohlo něco poslat.

Totéž funguje z terminálu příkazy `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Vynechte cestu a zobrazí se vám výběr souborů.

Posílat můžete i přímo ze správce souborů: klikněte pravým tlačítkem na libovolný výběr v aplikaci Soubory a sdílejte ho přes LocalSend.

Firewall v Omarchy je ve výchozím nastavení zavřený s výjimkou portu LocalSendu, takže to na čerstvé instalaci funguje hned po vybalení. Viz [zabezpečení](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletní kancelářský balík s textovým procesorem, tabulkami, prezentacemi, aplikací na kreslení a dalšími nástroji. Je kompatibilní se soubory z Microsoft Office, takže je to skvělý způsob, jak otevřít ty dokumenty z Wordu.

LibreOffice spustíte přes spouštěč aplikací (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastní naprosto jednoduchá prezentační aplikace Omarchy. Vaše prezentace je jediný soubor v Markdownu, vedle kterého leží její obrázky a videa: každý snímek píšete pod živým náhledem, snímky přetažením seřadíte, a pak prezentujete na celé obrazovce nebo exportujete do PDF a PowerPointu. Dokonce převezme i váš motiv Omarchy.

Hype spustíte přes spouštěč aplikací (`Super + Space`). Stisknutím `?` uvnitř aplikace zobrazíte všechny zkratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastní naprosto jednoduchý způsob Omarchy, jak podepisovat PDF a vyplňovat je. Umístěte svůj uložený podpis, text a dnešní datum kamkoli na stránku a pak uložte podepsanou kopii vedle originálu. Jak na to, najdete v části [Vyplňování PDF](27-filling-out-pdfs.md).

Signed spustíte přes spouštěč aplikací (`Super + Space`) nebo v něm otevřete PDF ze správce souborů.

## Game Vibes

Game Vibes ve spouštěči aplikací (`Super + Space`) je místo, kde žijí malé hry Omarchy: Checkmate, 3D šachová hra proti kamarádovi nebo vestavěnému soupeři; Cards, Klondike solitaire; Death Wish, na pixel přesná plošinovka o deseti místnostech plných bodců a pil; a Neon Swarm, arkádová střílečka. Každá je jediná webová stránka, která se řídí vaším motivem. Vyberte si jednu šipkami a klávesou `Enter` a zpět na seznam se vrátíte klávesou `Esc` z titulní obrazovky hry nebo klávesou `Q`, když je pozastavená. Otevírá se na celou obrazovku: `Super + F` z ní udělá okno a `Super + W` ji zavře.

Hry, které vytvoříte s agentem, se tu objeví taky: v panelu agentů zvolte _Make something cool → Game_ a jednu popište, nebo pojmenujte hru, která už v Game Vibes je, a pokračujte v práci na ní. Agent ji zkopíruje do `~/Games/vibes`, kde je vaše a můžete ji měnit, a po dokončení ji otevře. Tuto kopii si můžete vytvořit sami příkazem `omarchy games vibes copy <game>`. Hra, kterou sdílí někdo jiný, se instaluje jako motiv: zvolte _Install > Gaming > Game Vibes_ a vložte její git adresu, nebo spusťte `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ ji zase odstraní a _Update > Game Vibes Games_ stáhne nové verze. Hry načítají three.js z webu, takže ke spuštění potřebují připojení.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastní naprosto jednoduchá kalkulačka Omarchy, která se otevírá v plovoucím okně.

Omacalc spustíte klávesami `Super + Shift + Q` (nebo klávesou kalkulačky, pokud ji vaše klávesnice má).

## Signal

[Signal](https://signal.org/) je průkopníkem E2E šifrované komunikace a skvělou volbou pro každého, kdo by raději nešel přes některý z velkých technologických konglomerátů.

Signal spustíte klávesami `Super + Shift + G`. Není součástí základní instalace, takže když to stisknete poprvé, Omarchy vám nabídne, že ho za vás nainstaluje (najdete ho také v nabídce Omarchy v části _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastní naprosto jednoduchý prohlížeč obrázků a přehrávač médií Omarchy: jedno okno pro vaše fotky, videa a hudbu. Otevřete fotku a šipky procházejí zbytek její složky, klávesy `N` a `P` to dělají pro cokoli a `Ctrl + M` zobrazí celou složku jako mřížku. Zobrazuje i fotky HEIC, AVIF a JPEG XL a u všeho dlouhého pokračuje tam, kde jste skončili.

Stiskněte `F` pro celou obrazovku, `E` pro úpravu obrázku v Omasnap nebo oříznutí videa v Omacut, `Ctrl + P` pro tisk obrázku a `Delete` pro přesunutí souboru do koše (`Ctrl + Z` ho vrátí zpět). Stisknutím `?` uvnitř aplikace zobrazíte všechny zkratky.

Omaview spustíte jako _Media Viewer_ přes spouštěč aplikací (`Super + Space`) nebo prostě dvakrát klikněte na obrázek, video nebo písničku ve správci souborů.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastní naprosto jednoduchý střihač videa Omarchy. Když potřebujete jen ustřihnout začátek a konec klipu, je to lepší než spouštět plnohodnotný editor videa.

Omacut spustíte přes spouštěč aplikací (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastní naprosto jednoduchý rekordér z webkamery Omarchy. Jednou si vyberte kameru a mikrofon, pak stiskněte `Space` pro nahrávání a znovu pro pozastavení a pokračování stejného záběru. Vždy nahrává v nejvyšším rozlišení vaší kamery a má živý měřič mikrofonu, takže si před začátkem můžete zkontrolovat úrovně.

Zastavte záběr a hned se otevře ve vestavěném editoru. Dvojklikem klip rozdělíte, přetažením úchytů každý kus oříznete a části, které nechcete, odstraníte. Pak ho uložíte jako MP4. Původní nahrávka zůstane zachována, dokud ji nezahodíte, takže se k ní můžete vždy vrátit a sestříhat ji jinak.

Monologue spustíte přes spouštěč aplikací (`Super + Space`).
