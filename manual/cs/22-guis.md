# Grafická rozhraní

## Files

Files (Folio) je grafický správce souborů. `Super + Shift + F` ho otevře a `Super + Shift + Alt + F` ho otevře v adresáři, ve kterém se právě nachází váš terminál, což ušetří spoustu klikání. `Ctrl + L` vám umožní napsat cestu a stisknutí `Space` na libovolném souboru ho zobrazí v náhledu v plné velikosti, aniž byste ho otevírali.

Zapojte USB flash disk nebo SD kartu a automaticky se připojí, takže se prostě objeví v postranním panelu. Pro cokoliv složitějšího — formátování disku, kontrolu stavu SMART, vytváření oddílů — spusťte _Disks_ ze spouštěče aplikací (`Super + Space`).

Šifrovaný disk si při připojení vyžádá heslo. Aby se jeden odemykal sám, přidejte k němu keyfile pomocí `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` a ten keyfile umístěte do `~/.config/omarchy/drive-keys/<UUID>`, pojmenovaný podle UUID, které pro šifrovaný oddíl vypíše `lsblk -dno UUID /dev/sdX1`, a čitelný pouze pro vás (`chmod 600`). Pokud ten keyfile chybí nebo je odmítnut, budete jako obvykle vyzváni k zadání hesla.

Dvojklik se řídí rozumnými výchozími volbami: obrázky, videa a hudba se otevírají v Omaview, PDF v Document Viewer, Markdown v Omawrite a prostý text ve vašem editoru, Plain, pokud si v _Setup > Defaults > Editor_ nevyberete jiný.

## Disktree

Když se disk zaplní a vy netušíte, co ho požírá, spusťte [Disktree](https://github.com/tobi/disktree) ze spouštěče aplikací (`Super + Space`). Zobrazí grafickou stromovou mapu vašeho domovského adresáře. Větší bloky zabírají více místa; procházejte adresáře klávesnicí nebo myší, označte, co má jít pryč, a před odstraněním čehokoliv své volby zkontrolujte. Spuštěním `disktree --disk` prohledáte celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoce rozšiřitelná aplikace na poznámky, která k ukládání používá jednoduché soubory Markdown.

Obsidian je zdarma pro všechny účely, včetně osobního, komerčního a neziskového použití.

Obsidian nabízí také [komerční doplněk pro synchronizaci](https://obsidian.md/sync) s mobilními aplikacemi na iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocí `Super + Shift + O`. Chcete-li používat synchronizaci motivů, musíte v nastavení vybrat motiv `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastní, naprosto jednoduchá aplikace Omarchy na psaní v Markdownu. Žádné vaulty, žádné pluginy, jen vy a slova.

Omawrite spustíte pomocí `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základní nástroj na úpravu obrázků, který je skvělý na ořezávání, změnu velikosti a další základní úpravy. Jen nečekejte alternativu k Photoshopu. Ale i tak má Magic Wand a vrstvy!

Pinta spustíte přes spouštěč aplikací (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikace na tvorbu motivů, která dokáže z obrázku na pozadí vytáhnout barvy a proměnit je v kompletní, soudržný motiv. Je to nejjednodušší způsob, jak si [vytvořit vlastní motiv](43-making-your-own-theme.md).

Aether spustíte přes spouštěč aplikací (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožní posílat soubory do jiných zařízení ve stejné síti, na kterých běží tato aplikace, podobně jako AirDrop od Applu. Je ale multiplatformní, takže můžete posílat soubory do a z Windows, macOS, Androidu, iOS a samozřejmě Linuxu.

Nabídku Share můžete otevřít pomocí `Super + Ctrl + S` nebo v nabídce Omarchy pod _Trigger > Share_. Nabízí vám čtyři možnosti:

- **Clipboard** odešle cokoliv, co jste zkopírovali, jako textový soubor. Skvělé, když chcete dostat odkaz nebo úryvek do telefonu, aniž byste si posílali e-mail.
- **File** otevře výběr souborů, kde můžete vybrat několik najednou.
- **Folder** odešle celý adresář.
- **Receive** otevře samotný LocalSend, aby vám jiné zařízení mohlo něco poslat.

Totéž funguje z terminálu pomocí `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Cestu vynechte a dostanete výběr souborů.

Posílat můžete také přímo ze správce souborů: klikněte pravým tlačítkem na libovolný výběr v Files a sdílejte ho pomocí LocalSend.

Firewall Omarchy je ve výchozím nastavení zavřený s výjimkou portu LocalSend, takže to na čerstvé instalaci funguje hned po instalaci. Viz [zabezpečení](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletní kancelářský balík s textovým procesorem, tabulkovým procesorem, prezentacemi, kreslicí aplikací a dalším. Je kompatibilní se soubory z Microsoft Office, takže je to skvělý způsob, jak otevřít ty dokumenty ve Wordu.

LibreOffice spustíte přes spouštěč aplikací (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastní, naprosto jednoduchá prezentační aplikace Omarchy. Vaše prezentace je jediný soubor Markdown s obrázky a videi vedle něj: každou stránku píšete pod živým náhledem, stránky přetažením seřadíte a pak prezentujete na celou obrazovku nebo exportujete do PDF a PowerPointu. Dokonce převezme váš motiv Omarchy.

Hype spustíte přes spouštěč aplikací (`Super + Space`). Stisknutím `?` uvnitř zobrazíte všechny zkratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastní, naprosto jednoduchý způsob Omarchy, jak podepisovat PDF a vyplňovat je. Umístěte svůj uložený podpis, text a dnešní datum kamkoliv na stránku a pak uložte podepsanou kopii vedle originálu. Jak na to, viz [Vyplňování PDF](27-filling-out-pdfs.md).

Signed spustíte přes spouštěč aplikací (`Super + Space`), nebo s ním otevřete PDF ze správce souborů.

## Game Vibes

Game Vibes ve spouštěči aplikací (`Super + Space`) je místo, kde žijí malé hry Omarchy: Checkmate, 3D šachová hra proti příteli nebo vestavěnému soupeři; Cards, Klondike solitaire; Death Wish, pixelově přesná plošinovka o deseti místnostech plných hrotů a pil; a Neon Swarm, arkádová střílečka. Každá je jediná webová stránka, která se řídí vaším motivem. Vyberte jednu šipkami a `Enter` a zpět na seznam se vrátíte pomocí `Esc` z titulní obrazovky hry nebo `Q`, když je pozastavená. Otevírá se na celou obrazovku: `Super + F` z ní udělá okno a `Super + W` ji zavře.

Hry, které vytvoříte s agentem, se tu také objeví: v panelu agentů zvolte _Make something cool → Game_ a jednu popište, nebo pojmenujte hru, která už v Game Vibes je, abyste na ní dál pracovali. Agent ji zkopíruje do `~/Games/vibes`, kde je vaše a můžete ji měnit, a po dokončení ji otevře. Tuto kopii si můžete vytvořit sami pomocí `omarchy games vibes copy <game>`. Hra, kterou sdílí někdo jiný, se instaluje jako motiv: zvolte _Install > Gaming > Game Vibes_ a vložte její git adresu, nebo spusťte `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ ji zase odstraní a _Update > Game Vibes Games_ stáhne nové verze. Hry načítají three.js z webu, takže ke spuštění potřebují připojení.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastní, naprosto jednoduchá kalkulačka Omarchy, která se otevírá v plovoucím okně.

Omacalc spustíte pomocí `Super + Shift + Q` (nebo klávesou kalkulačky, pokud ji vaše klávesnice má).

## Signal

[Signal](https://signal.org/) je průkopník E2E šifrovaného zasílání zpráv a skvělá možnost komunikace pro každého, kdo by raději nešel přes jeden z velkých technologických konglomerátů.

Signal spustíte pomocí `Super + Shift + G`. Není součástí základní instalace, takže když to stisknete poprvé, Omarchy vám nabídne, že ho pro vás nainstaluje (je také v nabídce Omarchy pod _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastní, naprosto jednoduchý prohlížeč obrázků a přehrávač médií Omarchy: jedno okno pro vaše fotky, videa a hudbu. Otevřete fotku a klávesy se šipkami procházejí zbytek její složky, `N` a `P` to dělají pro cokoliv a `Ctrl + M` zobrazí celou složku jako mřížku. Zobrazuje také fotky HEIC, AVIF a JPEG XL a u čehokoliv dlouhého pokračuje tam, kde jste skončili.

Stiskněte `F` pro celou obrazovku, `E` pro úpravu obrázku v Omasnap nebo oříznutí videa v Omacut, `Ctrl + P` pro tisk obrázku a `Delete` pro přesunutí souboru do koše (`Ctrl + Z` ho vrátí zpět). Stisknutím `?` uvnitř zobrazíte všechny zkratky.

Omaview spustíte jako _Media Viewer_ přes spouštěč aplikací (`Super + Space`), nebo prostě dvakrát klikněte na obrázek, video nebo píseň ve správci souborů.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastní, naprosto jednoduchý střihač videa Omarchy. Když potřebujete jen oříznout začátek a konec klipu, porazí spouštění plnohodnotného videoeditoru.

Omacut spustíte přes spouštěč aplikací (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastní, naprosto jednoduchý záznamník z webkamery Omarchy. Jednou si vyberte kameru a mikrofon, pak stiskněte `Space` pro nahrávání a znovu pro pozastavení a pokračování téhož záběru. Vždy nahrává v nejvyšším rozlišení vaší kamery, s živým měřičem mikrofonu, abyste si před spuštěním mohli zkontrolovat úrovně.

Zastavte záběr a hned se otevře ve vestavěném editoru. Dvojklikem klip rozdělíte, přetažením úchytů každý kousek oříznete a části, které nechcete, odstraníte. Pak ho uložte jako MP4. Váš původní záznam se zachová, dokud ho nezahodíte, takže se můžete vždy vrátit a sestříhat ho jinak.

Monologue spustíte přes spouštěč aplikací (`Super + Space`).
