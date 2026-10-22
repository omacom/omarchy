# GUI

## Soubory

Soubory (Nautilus) jsou grafický správce souborů. Stisknutí `Super + Shift + F` ho otevře a `Super + Shift + Alt + F` ho otevře v adresáři, ve kterém se nachází váš terminál, což ušetří spoustu klikání. Pomocí `Ctrl + L` můžete zadat cestu a stisknutí klávesy `Space` na libovolném souboru vám poskytne rychlý náhled, aniž byste cokoli otevírali.

Připojte USB disk nebo SD kartu a připojí se automaticky, takže se jednoduše objeví v postranním panelu. Pro cokoli náročnějšího — naformátování jednotky, kontrolu stavu SMART, vytváření oddílů — spusťte _Disky_ ze spouštěče aplikací (`Super + Space`).

Dvojklik dodržuje rozumná výchozí nastavení: obrázky se otevírají v imv, videa v mpv, PDF v Prohlížeči dokumentů a prostý text v Neovimu.

## Disktree

Když se jednotka zaplní a nemáte ponětí, co ji požírá, spusťte program [Disktree](https://github.com/tobi/disktree) ze spouštěče aplikací (`Super + Space`). Zobrazí grafickou treemapu vašeho domovského adresáře. Větší bloky zabírají více místa; procházejte do adresářů pomocí klávesnice nebo myši, označte, co by mělo jít pryč, a před odebráním čehokoli si výběr zkontrolujte. Celý disk prohledáte příkazem `disktree --disk`.

## Obsidian

[Obsidian](https://obsidian.md/) je bezplatná a vysoce rozšiřitelná aplikace pro poznámky, která k ukládání používá jednoduché soubory Markdown.

Obsidian je zdarma pro všechny účely, včetně osobního, komerčního a neziskového použití.

Obsidian nabízí také [komerční doplněk pro synchronizaci](https://obsidian.md/sync) s mobilními aplikacemi v systémech iOS a Android. (https://obsidian.md/pricing).

Obsidian spustíte pomocí `Super + Shift + O`. Chcete-li použít synchronizaci motivu, musíte v nastavení vybrat motiv `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastní, zcela jednoduchá aplikace Omarchy pro psaní v Markdownu. Žádné trezory, žádné zásuvné moduly, jen vy a slova.

Omawrite spustíte pomocí `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je základní nástroj pro úpravu obrázků, který je skvělý pro ořezávání, změnu velikosti a další základní manipulace. Jen nepčekejte alternativu k Photoshopu. Ale pořád má kouzelnou hůlku a vrstvy!

Pintu spustíte prostřednictvím spouštěče aplikací (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikace pro motivy, která dokáže extrahovat barvy z obrázku na pozadí a proměnit je v úplný, soudržný motiv. Je to nejjednodušší způsob, jak [vytvořit vlastní motiv](43-making-your-own-theme.md).

Aether spustíte prostřednictvím spouštěče aplikací (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vám umožňuje posílat soubory na další zařízení ve stejné síti, kde aplikace běží, podobně jako AirDrop od společnosti Apple. Je ale multiplatformní, takže můžete posílat soubory do a z Windows, macOS, Androidu, iOS a samozřejmě Linuxu.

Nabídku Sdílet můžete otevřít pomocí `Super + Ctrl + S` nebo v části _Akce > Sdílet_ v nabídce Omarchy. Poskytuje čtyři možnosti:

- **Clipboard** odešle cokoli, co jste zkopírovali, jako textový soubor. Skvělé pro přenesení odkazu nebo úryvku do telefonu bez posílání e-mailu sami sobě.
- **File** otevře výběr souborů, kde můžete vybrat několik souborů najednou.
- **Folder** odešle celý adresář.
- **Receive** otevře samotný LocalSend, aby vám jiné zařízení mohlo něco poslat.

Totéž funguje z terminálu pomocí příkazů `omarchy share clipboard`, `omarchy share file [path]` a `omarchy share folder [path]`. Cestu vynechte a zobrazí se výběr.

Můžete odesílat také přímo ze správce souborů: klikněte pravým tlačítkem na libovolný výběr v Nautilu a vyberte možnost _Send via LocalSend_.

Brána firewall v Omarchy je ve výchozím nastavení zavřená s výjimkou portu LocalSendu, takže toto funguje rovnou po čerstvé instalaci. Viz část [zabezpečení](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je kompletní kancelářský balík s textovým procesorem, tabulkami, prezentacemi, kreslicí aplikací a dalšími funkcemi. Je kompatibilní se soubory z Microsoft Office, takže je to skvělý způsob, jak otevírat tyto dokumenty Wordu.

LibreOffice spustíte prostřednictvím spouštěče aplikací (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastní, zcela jednoduchá prezentační aplikace Omarchy. Vaše prezentace je jeden soubor Markdown s obrázky a videi vedle něj: napište každý snímek pod živý náhled, přetáhněte snímky do pořadí, poté prezentujte na celou obrazovku nebo exportujte do formátů PDF a PowerPoint. Dokonce převezme váš motiv Omarchy.

Hype spustíte prostřednictvím spouštěče aplikací (`Super + Space`). Stisknutím klávesy `?` uvnitř zobrazíte každou zkratku.

## Signed

[Signed](https://github.com/omacom/signed) je vlastní, zcela jednoduchý způsob Omarchy, jak podepisovat PDF a vyplňovat je. Umístěte svůj uložený podpis, text a dnešní datum kamkoli na stránku a poté uložte podepsanou kopii vedle originálu. Jak na to, najdete v části [Vyplňování PDF](27-filling-out-pdfs.md).

Signed spustíte prostřednictvím spouštěče aplikací (`Super + Space`) nebo v něm otevřete PDF ze správce souborů.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastní, zcela jednoduchá kalkulačka Omarchy, která se otevírá v plovoucím okně.

Omacalc spustíte pomocí `Super + Ctrl + Q` (nebo klávesou kalkulačky, pokud ji vaše klávesnice má).

## Signal

[Signal](https://signal.org/) je průkopníkem E2E šifrovaného předávání zpráv a skvělou komunikační možností pro kohokoli, kdo by raději neprocházel jedním z velkých technologických konglomerátů.

Signal spustíte pomocí `Super + Shift + G`. Není součástí základní instalace, takže při prvním stisknutí této kombinace vám Omarchy nabídne jeho instalaci (je také v části _Instalovat > Služba_ v nabídce Omarchy).

## mpv

[mpv](https://mpv.io/) je jednoduchý a rychlý přehrávač médií, který přehraje téměř cokoli z libovolného zdroje. Skvělý pro sledování videí.

mpv spustíte prostřednictvím spouštěče aplikací (`Super + Space`) nebo jednoduše dvakrát kliknete na video ve správci souborů.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastní, zcela jednoduchý sestřihovač videa Omarchy. Když potřebujete pouze oříznout začátek a konec klipu, poráží spouštění plnohodnotného editoru videa.

Omacut spustíte prostřednictvím spouštěče aplikací (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastní, zcela jednoduchý záznamník webové kamery Omarchy. Jednou si vyberte kameru a mikrofon, poté stisknutím klávesy `Space` nahrávejte a dalším stisknutím pozastavte a obnovte tentýž záběr. Vždy nahrává v nejvyšším rozlišení vaší kamery a obsahuje živý měřič mikrofonu, takže před zahájením můžete zkontrolovat své úrovně.

Zastavte záběr a okamžitě se otevře v integrovaném editoru. Dvojklikem klip rozdělte, přetažením úchytů ořízněte každý kousek a odstraňte části, které nechcete. Poté ho uložte jako soubor MP4. Původní záznam si ponechá, dokud ho nezahodíte, takže se vždy můžete vrátit a sestříhat ho jinak.

Monologue spustíte prostřednictvím spouštěče aplikací (`Super + Space`).
