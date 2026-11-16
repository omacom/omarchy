# GUIs

## Files

Files (Nautilus) je grafický správce souborů. `Super + Shift + F` ho otevře a `Super + Shift + Alt + F` ho otevře v adresáři, ve kterém právě sedí váš terminál, což ušetří spoustu klikání. `Ctrl + L` vám umožní napsat cestu a stisknutím `Space` na libovolném souboru získáte rychlý náhled, aniž byste cokoli otevírali.

Zapojte USB flash disk nebo SD kartu a automaticky se připojí, takže se prostě objeví v postranním panelu. Pro cokoli složitějšího — formátování disku, kontrolu stavu SMART, vytváření oddílů — spusťte _Disks_ ze spouštěče aplikací (`Super + Space`).

Dvojklik se řídí rozumnými výchozími volbami: obrázky, videa a hudba se otevírají v Omaview, PDF v Document Viewer, Markdown v Omawrite a prostý text v editoru vybraném v _Setup > Default > Editor_.

## Disktree

Když se disk zaplní a vy nemáte tušení, co ho žere, spusťte [Disktree](https://github.com/tobi/disktree) ze spouštěče aplikací (`Super + Space`). Zobrazí grafickou treemapu vašeho domovského adresáře. Větší bloky zabírají více místa; procházejte adresáři klávesnicí nebo myší, označte, co má jít pryč, a před odstraněním čehokoli si výběr zkontrolujte. Spuštěním `disktree --disk` prohledáte celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoce rozšiřitelná aplikace na poznámky, která k ukládání používá jednoduché soubory Markdown.

Obsidian je zdarma pro všechny účely, včetně osobního, komerčního a neziskového použití.

Obsidian nabízí také [komerční doplněk pro synchronizaci](https://obsidian.md/sync) s mobilními aplikacemi pro iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocí `Super + Shift + O`. Chcete-li používat synchronizaci témat, musíte v nastavení vybrat téma `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastní naprosto jednoduchá aplikace Omarchy na psaní v Markdownu. Žádné trezory, žádné pluginy, jen vy a slova.

Omawrite spustíte pomocí `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základní nástroj na úpravu obrázků, který je skvělý na ořezávání, změnu velikosti a další základní úpravy. Jen od něj nečekejte alternativu k Photoshopu. Ale pořád má Kouzelnou hůlku a vrstvy!

Pintu spustíte přes spouštěč aplikací (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikace na vytváření témat, která dokáže vytáhnout barvy z obrázku na pozadí a proměnit je v kompletní, soudržné téma. Je to nejjednodušší způsob, jak si [vytvořit vlastní téma](43-making-your-own-theme.md).

Aether spustíte přes spouštěč aplikací (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožní posílat soubory do dalších zařízení ve stejné síti, na kterých běží tato aplikace, podobně jako AirDrop od Applu. Je ale multiplatformní, takže můžete posílat soubory do Windows, macOS, Androidu, iOS a samozřejmě Linuxu i z nich.

Nabídku Share otevřete pomocí `Super + Ctrl + S` nebo v nabídce Omarchy pod _Trigger > Share_. Nabízí čtyři možnosti:

- **Clipboard** odešle vše, co jste zkopírovali, jako textový soubor. Skvělé, když chcete dostat odkaz nebo úryvek kódu do telefonu, aniž byste si posílali e-mail sami sobě.
- **File** otevře výběr souborů, kde jich můžete vybrat několik najednou.
- **Folder** odešle celý adresář.
- **Receive** otevře samotný LocalSend, aby vám jiné zařízení mohlo něco poslat.

Totéž funguje z terminálu pomocí `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Cestu vynechte a zobrazí se výběr souborů.

Posílat můžete také přímo ze správce souborů: klikněte pravým tlačítkem na libovolný výběr v Nautilu a zvolte _Send via LocalSend_.

Firewall Omarchy je ve výchozím nastavení uzavřený s výjimkou portu LocalSend, takže to na čerstvé instalaci funguje hned po vybalení. Viz [zabezpečení](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletní kancelářský balík s textovým procesorem, tabulkami, prezentacemi, aplikací na kreslení a dalšími nástroji. Je kompatibilní se soubory z Microsoft Office, takže je to skvělý způsob, jak si otevřít ty dokumenty z Wordu.

LibreOffice spustíte přes spouštěč aplikací (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastní naprosto jednoduchá prezentační aplikace Omarchy. Vaše prezentace je jediný soubor Markdown s obrázky a videi vedle něj: každý snímek píšete pod živým náhledem, snímky přetahujete do požadovaného pořadí a pak prezentujete na celé obrazovce nebo exportujete do PDF a PowerPointu. Dokonce převezme vaše téma Omarchy.

Hype spustíte přes spouštěč aplikací (`Super + Space`). Stiskněte v něm `?` a zobrazí se všechny zkratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastní naprosto jednoduchý způsob Omarchy, jak podepisovat PDF a vyplňovat je. Umístěte uložený podpis, text a dnešní datum kamkoli na stránku a pak uložte podepsanou kopii vedle originálu. Jak na to, se dozvíte v [Vyplňování PDF](27-filling-out-pdfs.md).

Signed spustíte přes spouštěč aplikací (`Super + Space`) nebo s ním otevřete PDF ze správce souborů.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) je vlastní 3D šachová hra Omarchy. Hrajte s přítelem na stejném počítači nebo proti vestavěnému soupeři ve třech úrovních obtížnosti, se čtyřmi propracovanými sadami, z nichž každá se pohybuje po svém: orbitální plavidla, vyřezávané dřevo a slonovina, lesní tvorové a bonbony. Hry nemají hodiny a ukládají se po každém tahu.

Checkmate spustíte přes spouštěč aplikací (`Super + Space`). Stiskněte v něm `?` a zobrazí se všechny zkratky.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastní naprosto jednoduchá kalkulačka Omarchy, která se otevírá v plovoucím okně.

Omacalc spustíte pomocí `Super + Shift + Q` (nebo klávesou kalkulačky, pokud ji vaše klávesnice má).

## Signal

[Signal](https://signal.org/) je průkopníkem zpráv s koncovým šifrováním E2E a skvělou volbou pro komunikaci pro každého, kdo by raději nešel přes některý z velkých technologických konglomerátů.

Signal spustíte pomocí `Super + Shift + G`. Není součástí základní instalace, takže když to stisknete poprvé, Omarchy vám nabídne, že ho za vás nainstaluje (najdete ho také v nabídce Omarchy pod _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastní naprosto jednoduchý prohlížeč obrázků a přehrávač médií Omarchy: jedno okno pro vaše fotky, videa i hudbu. Otevřete fotku a klávesami se šipkami procházíte zbytek její složky, `N` a `P` to samé dělají pro cokoli a `Ctrl + M` zobrazí celou složku jako mřížku. Zobrazuje také fotky ve formátech HEIC, AVIF a JPEG XL a u čehokoli dlouhého naváže tam, kde jste skončili.

Stiskněte `F` pro celou obrazovku, `E` pro úpravu obrázku v Omasnapu nebo oříznutí videa v Omacutu, `Ctrl + P` pro tisk obrázku a `Delete` pro přesunutí souboru do koše (`Ctrl + Z` ho vrátí zpět). Stiskněte v něm `?` a zobrazí se všechny zkratky.

Omaview spustíte jako _Media Viewer_ přes spouštěč aplikací (`Super + Space`) nebo prostě dvakrát kliknete na obrázek, video nebo skladbu ve správci souborů.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastní naprosto jednoduchý nástroj Omarchy na ořezávání videa. Když potřebujete jen useknout začátek a konec klipu, je to lepší než spouštět plnohodnotný editor videa.

Omacut spustíte přes spouštěč aplikací (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastní naprosto jednoduchý rekordér webkamery Omarchy. Jednou si zvolte kameru a mikrofon, pak stiskněte `Space` pro nahrávání a znovu pro pozastavení a pokračování stejného záběru. Vždy nahrává v nejvyšším rozlišení vaší kamery, s živým ukazatelem úrovně mikrofonu, takže si před začátkem můžete zkontrolovat hlasitost.

Zastavte záběr a okamžitě se otevře ve vestavěném editoru. Dvojklikem klip rozdělíte, tažením za úchyty každý kus oříznete a části, které nechcete, odstraníte. Pak ho uložte jako MP4. Původní nahrávka zůstává zachována, dokud ji nezahodíte, takže se k ní můžete vždy vrátit a sestříhat ji jinak.

Monologue spustíte přes spouštěč aplikací (`Super + Space`).
