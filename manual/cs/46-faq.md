# Časté dotazy

### Jak přepínám mezi rozloženími klávesnice?

Upravte soubor `~/.config/hypr/input.lua` a přidejte do něj toto pro přepínání mezi rozloženími pomocí `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Panel automaticky zobrazí vaše aktuální rozložení klávesnice, jakmile budete mít nakonfigurováno více rozložení (a kliknutím na něj můžete také přepínat).

### Jak změním formát hodin na 12hodinový?

Kliknutím pravým tlačítkem na hodiny v panelu můžete procházet běžné formáty, včetně 12hodinových. Formát můžete také nastavit přímo:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Tím se zobrazí neděle 10:55 AM.

### Jak změním své časové pásmo?

Spusťte _Nastavení > Oblast > Časové pásmo_ v nabídce Omarchy a vyberte ze seznamu. Pokud je časové pásmo správné, ale hodiny samotné se rozcházejí, _Aktualizace > Čas_ za vás restartuje synchronizaci času.

### Jak změním svůj DNS, sdílím svou Wi-Fi nebo zkontroluji rychlost svého připojení?

To vše najdete v části [sítě](35-networking.md).

### Jak zkontroluji, jak rychlý je můj disk?

_Spustit > Test rychlosti > Test rychlosti disku_ změří aktuální rychlost čtení a zápisu na vašem disku, nebo `omarchy disk speedtest` z terminálu.

### Jak přidám tiskárnu?

Tisk je nastavený a běží hned po instalaci a každou tiskárnu si přidáte sami z _Nastavení tisku_ ve spouštěči aplikací (`Super + Alt + Space`).

Zvolte _Přidat_ a dejte tomu chvíli na hledání: tiskárna připojená přes USB a většina síťových tiskáren se najde za vás. Pokud ta vaše v seznamu není, vyberte _Síťová tiskárna > Internet Printing Protocol (ipp)_ a zadejte její adresu — vlastní displej tiskárny nebo její webová stránka vám řekne, jaká to je, obvykle něco jako `192.168.1.50` s frontou `ipp/print`. _Vpřed_ pak nabídne ovladač, kde moderní tiskárna funguje nejlépe na bezovladačovém profilu _IPP Everywhere_ a starší chce vlastní ovladač daného modelu.

Klikněte na tiskárnu pravým tlačítkem a zvolte _Nastavit jako výchozí_, abyste vybrali, kterou vaše aplikace použijí jako první, a _Vlastnosti_ pro nastavení velikosti papíru, oboustranného tisku a kvality.

Automatické vyhledávání, kdy se tiskárny v síti objeví, aniž byste je přidávali, je dočasně vypnuté, zatímco se přepracovává, a proto je první krok výše na vás, a ne automatický. Tisk do souboru PDF funguje i bez jakékoli tiskárny.

### Jak změním, kam se ukládají snímky obrazovky nebo nahrávky obrazovky?

Uložené snímky obrazovky jdou ve výchozím nastavení do `~/Pictures/Screenshots`. Chcete-li použít jiný adresář, přidejte toto do souboru v `~/.config/uwsm/env.d/` (například `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Totéž můžete udělat pro nahrávky obrazovky pomocí `OMARCHY_SCREENRECORD_DIR`.

Omasnap si svůj adresář pro snímky obrazovky vytvoří automaticky. Adresář pro nahrávky obrazovky si vytvořte sami a poté restartujte Omarchy, aby se kterákoli ze změn prostředí projevila.

### Jak zprovozním reproduktory + webkameru na svém Apple Studio Display?

Řekli byste, že by to všechno mělo fungovat jen po zapojení přes USB C, ale bohužel to tak není. Řešení, které mi spolehlivě funguje, je použít [kabel WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Pak reproduktory a webkamera fungují jako po másle.

Nezapomeňte, že v Omarchy máte vestavěné ovládání jasu pro Apple displeje (Studio i XDR) pomocí běžných kláves pro jas na klávesnici.

### Jak se zbavím všeho toho softwaru navíc?

Pokud nechcete programy jako Obsidian nebo LibreOffice ani žádný další předinstalovaný balast, můžete je velmi snadno odstranit.

Spusťte _Odstranit > Balíček_ a uvidíte každý nainstalovaný balíček. Pak můžete klávesou tab vybrat libovolný balíček, který chcete odstranit, a klávesou return začít odstraňovat vše, co jste vybrali.

A pomocí _Odstranit > Webová aplikace_ z nabídky Omarchy můžete odstranit libovolné předinstalované webové aplikace, které nechcete.

Nebo spusťte _Odstranit > Předinstalované_ a vymetete všechny předinstalované doplňky — webové aplikace, TUI a volitelné aplikace — naráz. Klávesové zkratky, které je spouštěly, zmizí s nimi, takže vám zůstane čistý štít vazeb, které si můžete zaplnit vlastními v `~/.config/hypr/bindings.lua`.

---

Pro chyby a rozbité věci viz [část Řešení potíží](45-troubleshooting.md).
