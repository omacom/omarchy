# Časté dotazy

### Jak přepínat mezi rozloženími klávesnice?

Upravte soubor `~/.config/hypr/input.lua` a přidejte toto pro přepínání mezi rozloženími pomocí `Left Alt + Right Alt`:

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

### Jak změnit formát hodin na 12hodinový?

Klikněte pravým tlačítkem na hodiny v liště a procházejte běžné formáty, včetně těch 12hodinových. Formát můžete nastavit také přímo:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Zobrazí se neděle 10:55 AM.

### Jak změnit časové pásmo?

Spusťte v nabídce Omarchy _Setup > Region > Timezone_ a vyberte ze seznamu. Pokud je časové pásmo správné, ale hodiny samotné se rozcházejí, _Update > Time_ za vás restartuje synchronizaci času.

### Jak změnit DNS, sdílet Wi-Fi nebo zkontrolovat rychlost připojení?

To vše najdete v [práci se sítí](35-networking.md).

### Jak zkontrolovat, jak rychlý je můj disk?

_Trigger > Speed Test > Disk Speed Test_ měří aktuální rychlost čtení a zápisu na vašem disku, nebo `omarchy disk speedtest` z terminálu.

### Jak přidat tiskárnu?

Tisk je nastavený a běží hned po instalaci a každou tiskárnu si přidáte sami z _Print Settings_ ve spouštěči aplikací (`Super + Space`).

Zvolte _Add_ a dejte tomu chvíli na hledání: tiskárna připojená přes USB a většina síťových tiskáren se najde za vás. Pokud ta vaše v seznamu není, vyberte _Network Printer > Internet Printing Protocol (ipp)_ a zadejte její adresu — vlastní displej tiskárny nebo její webová stránka vám řekne, jaká to je, obvykle něco jako `192.168.1.50` s frontou `ipp/print`. _Forward_ pak nabídne ovladač, kde moderní tiskárna funguje nejlépe s bezovladačovým profilem _IPP Everywhere_ a starší chce vlastní ovladač daného modelu.

Klikněte pravým tlačítkem na tiskárnu a zvolte _Set as Default_, abyste vybrali, kterou vaše aplikace použijí jako první, a _Properties_ pro nastavení velikosti papíru, duplexu a kvality.

Automatické vyhledávání, kdy se tiskárny v síti objevují bez přidávání, je dočasně vypnuté, zatímco se přepracovává, a proto je první krok výše na vás, nikoli automatický. Tisk do souboru PDF funguje i bez jakékoli tiskárny.

### Jak změnit, kam se ukládají snímky obrazovky nebo nahrávky obrazovky?

Uložené snímky obrazovky se ve výchozím nastavení ukládají do `~/Pictures/Screenshots`. Chcete-li použít jiný adresář, přidejte toto do souboru pod `~/.config/uwsm/env.d/` (například `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Totéž můžete udělat pro nahrávky obrazovky pomocí `OMARCHY_SCREENRECORD_DIR`.

Omasnap svůj adresář pro snímky obrazovky vytváří automaticky. Adresář pro nahrávky obrazovky si vytvořte sami a poté restartujte Omarchy, aby se kterákoli ze změn prostředí projevila.

### Jak rozchodit reproduktory + webkameru na mém Apple Studio Display?

Člověk by si myslel, že po zapojení USB C by mělo všechno fungovat, ale bohužel tomu tak není. Řešení, které jsem našel a které funguje spolehlivě, je použití [kabelu WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Pak reproduktory a webkamera fungují jako po másle.

Nezapomeňte, že v Omarchy máte vestavěné ovládání jasu pro displeje Apple (Studio i XDR) pomocí běžných kláves pro jas na klávesnici.

### Jak se zbavit všeho dalšího softwaru?

Pokud nechcete programy jako Obsidian nebo LibreOffice ani žádný další předinstalovaný software, můžete je velmi snadno odstranit.

Spusťte _Remove > Package_ a zobrazí se všechny nainstalované balíčky. Poté můžete klávesou tab vybrat libovolný balíček, který chcete odstranit, a klávesou return začít odstraňovat vše vybrané.

A z nabídky Omarchy můžete použít _Remove > Web App_ k odstranění kterékoli z předinstalovaných webových aplikací, které nechcete.

Nebo spusťte _Remove > Preinstalls_ a jedním tahem vymetete všechny předinstalované doplňky — webové aplikace, TUI a volitelné aplikace. Klávesové zkratky, které je spouštěly, zmizí s nimi, takže vám zůstane čistý prostor vazeb, který si můžete zaplnit vlastními v `~/.config/hypr/bindings.lua`.

---

Chyby a rozbité věci najdete v [části Řešení problémů](45-troubleshooting.md).
