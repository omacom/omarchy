# Grafická rozhraní

## Files

Files (Nautilus) je grafický správce souborů. Otevřete ho pomocí `Super + Shift + F` a pomocí `Super + Shift + Alt + F` ho otevřete v adresáři, ve kterém se právě nachází váš terminál, což ušetří spoustu klikání. Pomocí `Ctrl + L` můžete zadat cestu a stisknutím `Space` na libovolném souboru získáte rychlý náhled, aniž byste cokoli otevírali.

Připojte USB flash disk nebo SD kartu a automaticky se připojí, takže se prostě objeví v postranním panelu. Na cokoli složitějšího — formátování disku, kontrolu stavu SMART, vytváření oddílů — spusťte _Disks_ ze spouštěče aplikací (`Super + Space`).

Dvojklik se řídí rozumnými výchozími nastaveními: obrázky, videa a hudba se otevřou v Omaview, PDF v Document Viewer, Markdown v Omawrite a prostý text v editoru vybraném pod _Setup > Default > Editor_.

## Disktree

Když se disk zaplní a nemáte tušení, co ho žere, spusťte [Disktree](https://github.com/tobi/disktree) ze spouštěče aplikací (`Super + Space`). Zobrazí grafickou stromovou mapu vašeho domovského adresáře. Větší bloky zabírají více místa; procházejte adresáři klávesnicí nebo myší, označte, co má jít pryč, a před odstraněním čehokoli svůj výběr zkontrolujte. Spuštěním `disktree --disk` prohledáte celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoce rozšiřitelná aplikace na poznámky, která k ukládání používá jednoduché soubory ve formátu Markdown.

Obsidian je zdarma pro všechny účely, včetně osobního, komerčního a neziskového použití.

Obsidian také nabízí [komerční doplněk pro synchronizaci](https://obsidian.md/sync) s mobilními aplikacemi na iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocí `Super + Shift + O`. Chcete-li používat synchronizaci témat, musíte v nastavení vybrat téma `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastní zatraceně jednoduchá aplikace Omarchy na psaní v Markdownu. Žádné trezory, žádné pluginy, jen vy a slova.

Omawrite spustíte pomocí `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základní nástroj na úpravu obrázků, který je skvělý na ořezávání, změnu velikosti a další základní úpravy. Jen nečekejte alternativu k Photoshopu. Ale pořád má nástroj Magic Wand i vrstvy!

Pintu spustíte přes spouštěč aplikací (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikace na tvorbu témat, která dokáže extrahovat barvy z obrázku na pozadí a proměnit je v kompletní, soudržné téma. Je to nejjednodušší způsob, jak si [vytvořit vlastní téma](43-making-your-own-theme.md).

Aether spustíte přes spouštěč aplikací (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožní posílat soubory do dalších zařízení ve stejné síti, na kterých běží tato aplikace, podobně jako AirDrop od Applu. Je ale multiplatformní, takže můžete posílat soubory do a z Windows, macOS, Androidu, iOS a samozřejmě Linuxu.

Nabídku Share můžete otevřít pomocí `Super + Ctrl + S` nebo v nabídce Omarchy pod _Trigger > Share_. Nabízí čtyři možnosti:

- **Clipboard** pošle cokoli, co jste zkopírovali, jako textový soubor. Skvělé, když chcete dostat odkaz nebo úryvek do telefonu, aniž byste si posílali e-mail.
- **File** otevře výběr souborů, kde jich můžete vybrat několik najednou.
- **Folder** pošle celý adresář.
- **Receive** otevře samotný LocalSend, aby vám jiné zařízení mohlo něco poslat.

Totéž funguje z terminálu pomocí `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Cestu vynechte a zobrazí se výběr souborů.

Posílat můžete i přímo ze správce souborů: klikněte pravým tlačítkem na libovolný výběr v Nautilu a zvolte _Send via LocalSend_.

Firewall v Omarchy je ve výchozím nastavení zavřený s výjimkou portu LocalSendu, takže to na čerstvé instalaci funguje hned po vybalení. Viz [zabezpečení](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletní kancelářský balík s textovým procesorem, tabulkovým procesorem, prezentacemi, kreslicí aplikací a dalšími nástroji. Je kompatibilní se soubory z Microsoft Office, takže je to skvělý způsob, jak otevřít ty dokumenty z Wordu.

LibreOffice spustíte přes spouštěč aplikací (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastní zatraceně jednoduchá prezentační aplikace Omarchy. Vaše prezentace je jediný soubor v Markdownu, vedle kterého leží její obrázky a videa: každý snímek píšete pod živým náhledem, přetažením snímky seřadíte a pak prezentujete na celé obrazovce nebo exportujete do PDF a PowerPointu. Dokonce převezme i vaše téma Omarchy.

Hype spustíte přes spouštěč aplikací (`Super + Space`). Stisknutím `?` uvnitř zobrazíte všechny zkratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastní zatraceně jednoduchý způsob Omarchy, jak podepisovat PDF a vyplňovat je. Umístěte svůj uložený podpis, text a dnešní datum kamkoli na stránku a pak uložte podepsanou kopii vedle originálu. Jak na to, viz [Vyplňování PDF](27-filling-out-pdfs.md).

Signed spustíte přes spouštěč aplikací (`Super + Space`), nebo s ním otevřete PDF ze správce souborů.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) je vlastní 3D šachová hra Omarchy. Hrajte s kamarádem na stejném počítači nebo proti vestavěnému soupeři ve třech úrovních, na čtyřech vytvarovaných sadách, z nichž se každá pohybuje svým vlastním způsobem: orbitální plavidla, vyřezávané dřevo a slonovina, lesní tvorové a bonbóny. Hry nemají hodiny a ukládají se po každém tahu.

Checkmate spustíte přes spouštěč aplikací (`Super + Space`), kde je uveden jako Chess. Stisknutím `?` uvnitř zobrazíte všechny zkratky.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastní zatraceně jednoduchá kalkulačka Omarchy, která se otevírá v plovoucím okně.

Omacalc spustíte pomocí `Super + Shift + Q` (nebo klávesou kalkulačky, pokud ji vaše klávesnice má).

## Signal

[Signal](https://signal.org/) je průkopníkem šifrovaného posílání zpráv s koncovým šifrováním E2E a skvělou volbou pro komunikaci pro každého, kdo by raději nešel přes některý z velkých technologických konglomerátů.

Signal spustíte pomocí `Super + Shift + G`. Není součástí základní instalace, takže když to stisknete poprvé, Omarchy vám nabídne, že ho pro vás nainstaluje (je také v nabídce Omarchy pod _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastní zatraceně jednoduchý prohlížeč obrázků a přehrávač médií Omarchy: jedno okno pro vaše fotky, videa a hudbu. Otevřete fotku a klávesy se šipkami procházejí zbytek její složky, `N` a `P` to dělají pro cokoli a `Ctrl + M` zobrazí celou složku jako mřížku. Zobrazuje také fotky ve formátech HEIC, AVIF a JPEG XL a u všeho dlouhého naváže tam, kde jste skončili.

Stiskněte `F` pro celou obrazovku, `E` pro úpravu obrázku v Omasnap nebo střih videa v Omacut, `Ctrl + P` pro tisk obrázku a `Delete` pro přesunutí souboru do koše (`Ctrl + Z` ho vrátí zpět). Stisknutím `?` uvnitř zobrazíte všechny zkratky.

Omaview spustíte jako _Media Viewer_ přes spouštěč aplikací (`Super + Space`), nebo stačí dvakrát kliknout na obrázek, video nebo skladbu ve správci souborů.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastní zatraceně jednoduchý střihač videa Omarchy. Když potřebujete jen useknout začátek a konec klipu, je to lepší než spouštět plnohodnotný editor videa.

Omacut spustíte přes spouštěč aplikací (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastní zatraceně jednoduchý záznamník z webkamery Omarchy. Jednou si vyberte kameru a mikrofon, pak stiskněte `Space` pro nahrávání a znovu pro pozastavení a pokračování téhož záběru. Vždy nahrává v nejvyšším rozlišení vaší kamery, s živým ukazatelem mikrofonu, abyste si před začátkem mohli zkontrolovat úrovně.

Zastavte záběr a hned se otevře ve vestavěném editoru. Dvojklikem klip rozdělíte, přetažením úchytů každou část oříznete a odstraníte části, které nechcete. Pak to uložte jako MP4. Původní nahrávka zůstane zachována, dokud ji nezahodíte, takže se k ní můžete kdykoli vrátit a sestříhat ji jinak.

Monologue spustíte přes spouštěč aplikací (`Super + Space`).
