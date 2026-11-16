# Grafické aplikace

## Files

Files (Nautilus) je grafický správce souborů. `Super + Shift + F` ho otevře a `Super + Shift + Alt + F` ho otevře ve složce, ve které se právě nachází váš terminál, což ušetří spoustu klikání. Pomocí `Ctrl + L` můžete zadat cestu a stisknutím `Space` na libovolném souboru získáte rychlý náhled, aniž byste cokoli otevírali.

Připojte USB flash disk nebo SD kartu a automaticky se připojí, takže se prostě objeví v postranním panelu. Pro cokoli složitějšího — formátování disku, kontrolu stavu SMART, vytváření oddílů — spusťte _Disks_ ze spouštěče aplikací (`Super + Space`).

Dvojklik se řídí rozumnými výchozími volbami: obrázky, videa a hudba se otevírají v Omaview, PDF v Document Viewer, Markdown v Omawrite a prostý text v editoru vybraném v _Setup > Default > Editor_.

## Disktree

Když se disk zaplní a vy nemáte tušení, co ho požírá, spusťte [Disktree](https://github.com/tobi/disktree) ze spouštěče aplikací (`Super + Space`). Zobrazí grafickou stromovou mapu vašeho domovského adresáře. Větší bloky zabírají více místa; procházejte adresáře klávesnicí nebo myší, označte, co má jít pryč, a před odstraněním čehokoli si svůj výběr zkontrolujte. Spuštěním `disktree --disk` prohledáte celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoce rozšiřitelná aplikace na poznámky, která k ukládání používá jednoduché soubory Markdown.

Obsidian je zdarma pro všechny účely, včetně osobního, komerčního a neziskového použití.

Obsidian také nabízí [komerční doplněk pro synchronizaci](https://obsidian.md/sync) s mobilními aplikacemi na iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocí `Super + Shift + O`. Chcete-li používat synchronizaci motivů, musíte v nastavení vybrat motiv `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastní naprosto jednoduchá aplikace Omarchy na psaní v Markdownu. Žádné trezory, žádné pluginy, jen vy a slova.

Omawrite spustíte pomocí `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základní nástroj na úpravu obrázků, který je skvělý na ořezávání, změnu velikosti a další základní úpravy. Jen nečekejte alternativu k Photoshopu. Ale pořád má Kouzelnou hůlku a vrstvy!

Pintu spustíte přes spouštěč aplikací (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikace na tvorbu motivů, která dokáže z obrázku na pozadí vytáhnout barvy a proměnit je v kompletní, soudržný motiv. Je to nejsnadnější způsob, jak [si vytvořit vlastní motiv](43-making-your-own-theme.md).

Aether spustíte přes spouštěč aplikací (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožní posílat soubory do jiných zařízení ve stejné síti, na kterých běží tato aplikace, podobně jako AirDrop od Applu. Je ale multiplatformní, takže můžete posílat soubory do Windows, macOS, Androidu, iOS a samozřejmě Linuxu a z nich.

Nabídku Share otevřete pomocí `Super + Ctrl + S` nebo v nabídce Omarchy v části _Trigger > Share_. Nabízí čtyři možnosti:

- **Clipboard** odešle cokoli, co jste zkopírovali, jako textový soubor. Skvělé, když chcete dostat odkaz nebo úryvek do telefonu, aniž byste si posílali e-mail.
- **File** otevře výběr souborů, kde jich můžete vybrat několik najednou.
- **Folder** odešle celý adresář.
- **Receive** otevře samotný LocalSend, aby vám jiné zařízení mohlo něco poslat.

Totéž funguje z terminálu pomocí `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Když cestu vynecháte, zobrazí se výběr souborů.

Posílat můžete i přímo ze správce souborů: klikněte pravým tlačítkem na libovolný výběr v Nautilu a zvolte _Send via LocalSend_.

Firewall v Omarchy je ve výchozím nastavení zavřený s výjimkou portu LocalSendu, takže to na čerstvé instalaci funguje hned po instalaci. Viz [zabezpečení](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletní kancelářský balík s textovým procesorem, tabulkami, prezentacemi, kreslicí aplikací a dalšími nástroji. Je kompatibilní se soubory z Microsoft Office, takže je to skvělý způsob, jak otevřít i ty dokumenty z Wordu.

LibreOffice spustíte přes spouštěč aplikací (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastní naprosto jednoduchá prezentační aplikace Omarchy. Vaše prezentace je jediný soubor Markdown, vedle kterého leží její obrázky a videa: každý snímek píšete pod živým náhledem, přetažením snímky seřadíte, a pak prezentujete na celé obrazovce nebo exportujete do PDF a PowerPointu. Dokonce převezme váš motiv Omarchy.

Hype spustíte přes spouštěč aplikací (`Super + Space`). Stisknutím `?` uvnitř zobrazíte všechny zkratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastní naprosto jednoduchý způsob Omarchy, jak podepisovat PDF a vyplňovat je. Umístěte svůj uložený podpis, text a dnešní datum kamkoli na stránku a pak uložte podepsanou kopii vedle originálu. Jak na to, najdete v části [Vyplňování PDF](27-filling-out-pdfs.md).

Signed spustíte přes spouštěč aplikací (`Super + Space`), nebo s ním otevřete PDF ze správce souborů.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastní naprosto jednoduchá kalkulačka Omarchy, která se otevírá v plovoucím okně.

Omacalc spustíte pomocí `Super + Shift + Q` (nebo klávesou kalkulačky, pokud ji vaše klávesnice má).

## Signal

[Signal](https://signal.org/) je průkopníkem šifrovaných zpráv E2E a skvělou komunikační volbou pro každého, kdo by raději nešel přes některý z velkých technologických konglomerátů.

Signal spustíte pomocí `Super + Shift + G`. Není součástí základní instalace, takže když to stisknete poprvé, Omarchy vám nabídne, že ho za vás nainstaluje (najdete ho také v nabídce Omarchy v části _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastní naprosto jednoduchý prohlížeč obrázků a přehrávač médií Omarchy: jedno okno pro vaše fotky, videa i hudbu. Otevřete fotku a šipkami procházíte zbytek její složky, `N` a `P` to dělají pro cokoli a `Ctrl + M` zobrazí celou složku jako mřížku. Zobrazuje také fotky HEIC, AVIF a JPEG XL a u všeho dlouhého pokračuje tam, kde jste skončili.

Stiskněte `F` pro celou obrazovku, `E` pro úpravu obrázku v Omasnap nebo oříznutí videa v Omacut, `Ctrl + P` pro tisk obrázku a `Delete` pro přesunutí souboru do koše (`Ctrl + Z` ho vrátí zpět). Stisknutím `?` uvnitř zobrazíte všechny zkratky.

Omaview spustíte jako _Media Viewer_ přes spouštěč aplikací (`Super + Space`), nebo prostě dvakrát kliknete na obrázek, video či skladbu ve správci souborů.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastní naprosto jednoduchý nástroj Omarchy na stříhání videa. Když potřebujete jen useknout začátek a konec klipu, je to lepší než spouštět plnohodnotný editor videa.

Omacut spustíte přes spouštěč aplikací (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastní naprosto jednoduchý záznamník z webkamery od Omarchy. Jednou si vyberete kameru a mikrofon, pak stisknete `Space` pro nahrávání a znovu pro pozastavení a pokračování ve stejném záběru. Vždy nahrává v nejvyšším rozlišení vaší kamery a s živým měřičem mikrofonu, takže si před začátkem můžete zkontrolovat úrovně.

Když záběr zastavíte, otevře se hned ve vestavěném editoru. Dvojklikem klip rozdělíte, přetažením úchytů každou část oříznete a odstraníte části, které nechcete. Pak to uložíte jako MP4. Původní záznam zůstane zachován, dokud ho nezahodíte, takže se k němu můžete vždy vrátit a sestříhat ho jinak.

Monologue spustíte přes spouštěč aplikací (`Super + Space`).
