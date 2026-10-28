# GUIs

## Files

Files (Nautilus) je grafický správce souborů. Pomocí `Super + Shift + F` ho otevřete a `Super + Shift + Alt + F` ho otevře v adresáři, ve kterém se právě nachází váš terminál, což ušetří spoustu klikání. Pomocí `Ctrl + L` můžete zadat cestu a stisknutím `Space` na libovolném souboru získáte rychlý náhled, aniž byste cokoli otevírali.

Zapojte USB disk nebo SD kartu a automaticky se připojí, takže se prostě objeví v postranním panelu. Pro cokoli složitějšího — formátování disku, kontrolu stavu SMART, vytváření oddílů — spusťte _Disks_ ze spouštěče aplikací (`Super + Space`).

Dvojklik se řídí rozumnými výchozími nastaveními: obrázky se otevírají v imv, video v mpv, PDF v Document Viewer a prostý text v Neovim.

## Disktree

Když se disk zaplní a vy nemáte ponětí, co ho požírá, spusťte [Disktree](https://github.com/tobi/disktree) ze spouštěče aplikací (`Super + Space`). Zobrazí grafickou stromovou mapu vašeho domovského adresáře. Větší bloky zabírají více místa; procházejte adresáři pomocí klávesnice nebo myši, označte, co má jít pryč, a před odstraněním čehokoli si svůj výběr zkontrolujte. Spuštěním `disktree --disk` prohledáte celý disk.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoce rozšiřitelná aplikace na psaní poznámek, která k ukládání používá jednoduché soubory Markdown.

Obsidian je zdarma pro všechny účely, včetně osobního, komerčního a neziskového použití.

Obsidian také nabízí [komerční doplněk pro synchronizaci](https://obsidian.md/sync) s mobilními aplikacemi na iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocí `Super + Shift + O`. Chcete-li používat synchronizaci motivu, musíte v nastavení vybrat motiv `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastní, naprosto jednoduchá aplikace Omarchy na psaní v Markdownu. Žádné trezory, žádné pluginy, jen vy a slova.

Omawrite spustíte pomocí `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základní nástroj na úpravu obrázků, který je skvělý na ořezávání, změnu velikosti a další základní úpravy. Jen nečekejte alternativu k Photoshop. Ale pořád má Magic Wand a vrstvy!

Pinta spustíte přes spouštěč aplikací (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikace na tvorbu motivů, která dokáže vytáhnout barvy z obrázku na pozadí a proměnit je v kompletní, soudržný motiv. Je to nejjednodušší způsob, jak si [vytvořit vlastní motiv](43-making-your-own-theme.md).

Aether spustíte přes spouštěč aplikací (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožňuje posílat soubory do jiných zařízení ve stejné síti, na kterých běží tato aplikace, podobně jako AirDrop od Apple. Je ale multiplatformní, takže můžete posílat soubory do a z Windows, macOS, Android, iOS a samozřejmě Linux.

Nabídku Share otevřete pomocí `Super + Ctrl + S` nebo pod _Trigger > Share_ v nabídce Omarchy. Nabízí čtyři možnosti:

- **Clipboard** odešle cokoli, co jste zkopírovali, jako textový soubor. Skvělé, když potřebujete dostat odkaz nebo úryvek kódu do telefonu, aniž byste si posílali e-mail.
- **File** otevře výběr souborů, ve kterém můžete vybrat hned několik souborů najednou.
- **Folder** odešle celý adresář.
- **Receive** otevře samotný LocalSend, aby vám jiné zařízení mohlo něco poslat.

Totéž funguje z terminálu pomocí `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Cestu vynechte a zobrazí se vám výběr souborů.

Posílat můžete také rovnou ze správce souborů: klikněte pravým tlačítkem na libovolný výběr v Nautilus a vyberte _Send via LocalSend_.

Firewall v Omarchy je ve výchozím nastavení zavřený s výjimkou portu pro LocalSend, takže tohle funguje hned po čerstvé instalaci. Viz [zabezpečení](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletní kancelářský balík s textovým procesorem, tabulkovým procesorem, prezentacemi, kreslicí aplikací a dalšími nástroji. Je kompatibilní se soubory z Microsoft Office, takže je to skvělý způsob, jak si otevřít ty dokumenty z Word.

LibreOffice spustíte přes spouštěč aplikací (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastní, naprosto jednoduchá prezentační aplikace Omarchy. Vaše prezentace je jediný soubor Markdown s obrázky a videi vedle něj: každý snímek píšete pod živým náhledem, snímky přetažením seřadíte, a pak prezentujete na celé obrazovce nebo exportujete do PDF a PowerPoint. Dokonce převezme váš motiv Omarchy.

Hype spustíte přes spouštěč aplikací (`Super + Space`). Stisknutím `?` uvnitř zobrazíte všechny zkratky.

## Signed

[Signed](https://github.com/omacom/signed) je vlastní, naprosto jednoduchý způsob Omarchy, jak podepisovat PDF a vyplňovat je. Umístěte svůj uložený podpis, text a dnešní datum kamkoli na stránku a pak uložte podepsanou kopii vedle originálu. Jak na to, najdete v [Vyplňování PDF](27-filling-out-pdfs.md).

Signed spustíte přes spouštěč aplikací (`Super + Space`), nebo s ním otevřete PDF ze správce souborů.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastní, naprosto jednoduchá kalkulačka Omarchy, která se otevírá v plovoucím okně.

Omacalc spustíte pomocí `Super + Shift + Q` (nebo klávesou kalkulačky, pokud ji vaše klávesnice má).

## Signal

[Signal](https://signal.org/) je průkopníkem E2E šifrovaného zasílání zpráv a skvělou komunikační volbou pro každého, kdo by raději nešel přes některý z velkých technologických konglomerátů.

Signal spustíte pomocí `Super + Shift + G`. Není součástí základní instalace, takže když to poprvé stisknete, Omarchy vám nabídne, že ho za vás nainstaluje (najdete ho také pod _Install > Service_ v nabídce Omarchy).

## mpv

[mpv](https://mpv.io/) je jednoduchý, rychlý přehrávač médií, který přehraje téměř cokoli z jakéhokoli zdroje. Skvělý na sledování videí.

mpv spustíte přes spouštěč aplikací (`Super + Space`), nebo prostě dvojklikem na video ve správci souborů.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastní, naprosto jednoduchý střihač videa Omarchy. Když potřebujete jen useknout začátek a konec klipu, je to lepší než spouštět plnohodnotný editor videa.

Omacut spustíte přes spouštěč aplikací (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastní, naprosto jednoduchý rekordér webkamery Omarchy. Jednou si vyberte kameru a mikrofon, pak stiskněte `Space` pro nahrávání a znovu pro pozastavení a pokračování stejného záběru. Vždy nahrává v nejvyšším rozlišení vaší kamery, s živým ukazatelem mikrofonu, abyste si před začátkem mohli zkontrolovat úrovně.

Zastavte záběr a okamžitě se otevře ve vestavěném editoru. Dvojklikem klip rozdělíte, přetažením úchytů oříznete každý kousek a odstraníte části, které nechcete. Pak ho uložte jako MP4. Váš původní záznam zůstane zachován, dokud ho nezahodíte, takže se k němu můžete vždy vrátit a sestříhat ho jinak.

Monologue spustíte přes spouštěč aplikací (`Super + Space`).
