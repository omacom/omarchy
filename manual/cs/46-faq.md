# Časté dotazy

### Jak přepínat mezi rozloženími klávesnice?

Upravte soubor `~/.config/hypr/input.lua` a přidejte do něj toto, abyste mohli přepínat mezi rozloženími stiskem `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

V panelu se automaticky zobrazí aktuální rozložení klávesnice, jakmile jich budete mít nakonfigurováno několik (a kliknutím ho můžete také přepnout).

### Jak změnit formát hodin na 12hodinový?

Kliknutím pravým tlačítkem na hodiny v panelu budete procházet běžné formáty, včetně těch 12hodinových. Formát můžete nastavit také přímo:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Tím se zobrazí Sunday 10:55 AM.

### Jak změnit časové pásmo?

V nabídce Omarchy spusťte volbu _Aktualizovat > Timezone_ a vyberte ze seznamu. Pokud je časové pásmo správné, ale hodiny samy o sobě ujely, volba _Aktualizovat > Time_ za vás restartuje synchronizaci času.

### Jak změnit DNS, sdílet Wi-Fi nebo zkontrolovat rychlost připojení?

To vše najdete v části [síť](35-networking.md).

### Jak zjistím, jak rychlý je můj disk?

Volba _Akce > Test rychlosti > Test rychlosti disku_ měří aktuální rychlost čtení a zápisu na vašem disku, případně z terminálu příkaz `omarchy disk speedtest`.

### Proč se nemohu v Chromiu přihlásit ke svému účtu Google?

Čistě otevřená sestava Chromia se nedodává s přihlašovacími údaji OAuth, které Google pro přihlášení k účtu vyžaduje. V nabídce Omarchy spusťte volbu _Instalovat > Service > Chromium Account_, čímž je přidáte, restartujte prohlížeč a přihlášení proběhne.

### Jak přidám tiskárnu?

Tisk je nastavený a hned po instalaci běží a jednotlivé tiskárny si přidáváte sami v části _Print Settings_ ve spouštěči aplikací (`Super + Space`).

Zvolte _Add_ a dejte tomu chvilku na vyhledání: najde se tiskárna připojená přes USB a většina síťových tiskáren. Pokud vaše tiskárna v seznamu není, vyberte _Network Printer > Internet Printing Protocol (ipp)_ a zadejte její adresu — tu vám sdělí displej tiskárny nebo její webová stránka, obvykle něco jako `192.168.1.50` s frontou `ipp/print`. Volba _Forward_ poté nabídne ovladač, přičemž moderní tiskárna funguje nejlépe s bezovladačovým profilem _IPP Everywhere_ a starší tiskárna chce vlastní ovladač daného modelu.

Klikněte na tiskárnu pravým tlačítkem a volbou _Set as Default_ vyberte, kterou tiskárnu mají vaše aplikace používat jako první, a volbou _Properties_ nastavíte formát papíru, oboustranný tisk a kvalitu.

Automatické vyhledávání, při kterém se tiskárny v síti objeví, aniž by byly přidány, je během přepracování dočasně vypnuté, a proto je první krok výše na vás, nikoli automatický. Tisk do souboru PDF funguje i zcela bez tiskárny.

### Jak změním místo ukládání snímků obrazovky nebo záznamů obrazovky?

Uložené snímky obrazovky se ve výchozím nastavení ukládají do složky `~/Pictures/Screenshots`. Chcete-li použít jiný adresář, přidejte toto do souboru ve složce `~/.config/uwsm/env.d/` (například `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Stejně můžete postupovat i u záznamů obrazovky pomocí proměnné `OMARCHY_SCREENRECORD_DIR`.

Omasnap si adresář pro snímky obrazovky vytvoří sám. Adresář pro záznamy obrazovky si vytvořte sami a poté Omarchy restartujte, aby se změna prostředí projevila.

### Jak zprovozním reproduktory a webovou kameru na Apple Studio Display?

Člověk by čekal, že vše bude fungovat pouhým připojením přes USB C, ale bohužel tomu tak není. Řešení, které jsem našel a které funguje spolehlivě, spočívá v použití [kabelu WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Potom fungují reproduktory i webová kamera jako z partesu.

Nezapomeňte, že pro displeje Apple (Studio i XDR) máte v systému Omarchy vestavěné ovládání jasu pomocí běžných kláves pro jas na klávesnici.

### Jak se zbavím veškerého přebytečného softwaru?

Pokud nechcete programy jako Obsidian nebo LibreOffice ani žádný další předinstalovaný software, můžete je velmi snadno odstranit.

Spuštěním volby _Odebrat > Package_ zobrazíte všechny nainstalované balíčky. Poté můžete klávesou Tab vybrat libovolný balíček, který chcete odstranit, a klávesou Enter zahájit odstraňování všeho vybraného.

K odebrání předinstalovaných webových aplikací, které nechcete, můžete v nabídce Omarchy využít volbu _Odebrat > Web App_.

Nebo spusťte volbu _Odebrat > Preinstalls_ a jedním tahem vymetete všechny předinstalované doplňky — webové aplikace, aplikace TUI a volitelné aplikace. Klávesové zkratky, které je spouštěly, zmizí spolu s nimi, takže uvolněná přiřazení kláves můžete v souboru `~/.config/hypr/bindings.lua` zaplnit vlastními zkratkami.

---

Informace o chybách a poruchách najdete v části [Řešení potíží](45-troubleshooting.md).
