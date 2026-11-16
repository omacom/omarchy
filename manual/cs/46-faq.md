# FAQ

### Jak přepínám mezi rozloženími klávesnice?

Upravte svůj soubor `~/.config/hypr/input.lua` a přidejte do něj toto, abyste mohli přepínat mezi rozloženími pomocí `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Lišta vám automaticky zobrazí aktuální rozložení klávesnice, jakmile budete mít nakonfigurováno více rozložení (a kliknutím na něj můžete také přepínat).

### Jak změním formát hodin na 12hodinový?

Klikněte pravým tlačítkem na hodiny v liště a procházejte běžné formáty, včetně těch 12hodinových. Formát můžete také nastavit přímo:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Zobrazí se neděle 10:55 AM.

### Jak změním své časové pásmo?

Spusťte _Update > Timezone_ v nabídce Omarchy a vyberte ze seznamu. Pokud je časové pásmo správné, ale samotné hodiny se rozcházejí, _Update > Time_ za vás restartuje synchronizaci času.

### Jak změním DNS, nasdílím svou Wi-Fi nebo zjistím rychlost svého připojení?

To všechno najdete v části [sítě](35-networking.md).

### Jak zjistím, jak rychlý je můj disk?

_Trigger > Speed Test > Disk Speed Test_ měří aktuální rychlost čtení a zápisu na vašem disku, nebo `omarchy disk speedtest` z terminálu.

### Jak přidám tiskárnu?

Tisk je nastavený a běží hned po instalaci a každou tiskárnu si přidáte sami z _Print Settings_ ve spouštěči aplikací (`Super + Space`).

Zvolte _Add_ a dejte tomu chvilku na hledání: tiskárna připojená přes USB a většina síťových tiskáren se najde za vás. Pokud ta vaše v seznamu není, vyberte _Network Printer > Internet Printing Protocol (ipp)_ a zadejte její adresu — vlastní displej tiskárny nebo její webová stránka vám řeknou, jaká to je, obvykle něco jako `192.168.1.50` s frontou `ipp/print`. _Forward_ pak nabídne ovladač, přičemž moderní tiskárna funguje nejlépe s bezovladačovým profilem _IPP Everywhere_ a starší chce vlastní ovladač pro daný model.

Klikněte pravým tlačítkem na tiskárnu a zvolte _Set as Default_, abyste vybrali, kterou vaše aplikace použijí jako první, a _Properties_ pro nastavení velikosti papíru, oboustranného tisku a kvality.

Automatické vyhledávání, při kterém se tiskárny v síti objeví, aniž byste je museli přidávat, je dočasně vypnuté, zatímco se přepracovává, a proto je první krok výše na vás, nikoli automatický. Tisk do souboru PDF funguje i bez jakékoli tiskárny.

### Jak změním, kam se ukládají snímky obrazovky nebo nahrávky obrazovky?

Uložené snímky obrazovky jdou ve výchozím nastavení do `~/Pictures/Screenshots`. Chcete-li použít jiný adresář, přidejte toto do souboru v `~/.config/uwsm/env.d/` (například `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Stejně můžete postupovat i u nahrávek obrazovky pomocí `OMARCHY_SCREENRECORD_DIR`.

Omasnap vytvoří adresář pro snímky obrazovky automaticky. Adresář pro nahrávky obrazovky si vytvořte sami a potom restartujte Omarchy, aby se kterákoli ze změn prostředí projevila.

### Jak zprovozním reproduktory + webkameru na svém Apple Studio Display?

Člověk by si myslel, že to všechno bude fungovat prostě po zapojení USB C, ale bohužel tomu tak není. Řešení, které jsem našel a díky kterému to funguje spolehlivě, je použití [kabelu WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Pak reproduktory i webkamera fungují jako po másle.

Pamatujte, že v Omarchy máte vestavěné ovládání jasu pro displeje Apple (Studio i XDR) pomocí běžných kláves pro ovládání jasu na klávesnici.

### Jak se zbavím všeho toho softwaru navíc?

Pokud nechcete programy jako Obsidian nebo LibreOffice ani žádné další předinstalované věci, můžete je velmi snadno odstranit.

Spusťte _Remove > Package_, abyste viděli všechny nainstalované balíčky. Pak můžete klávesou tab vybrat libovolný balíček, který chcete odstranit, a klávesou return začít odstraňovat vše, co jste vybrali.

A pomocí _Remove > Web App_ z nabídky Omarchy můžete odstranit kteroukoli z předinstalovaných webových aplikací, kterou nechcete.

Nebo spusťte _Remove > Preinstalls_ a jedním tahem vymeťte všechny předinstalované doplňky — webové aplikace, TUI a volitelné aplikace. Klávesové zkratky, které je spouštěly, zmizí spolu s nimi, takže vám zůstane čistý štít vazeb, které si můžete zaplnit vlastními v `~/.config/hypr/bindings.lua`.

---

Pro chyby a rozbité věci viz [oddíl Řešení potíží](45-troubleshooting.md).
