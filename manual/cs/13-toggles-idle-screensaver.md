# Přepínače, nečinnost a spořič obrazovky

Řadu funkcí během dne jen zapnete a později zase vypnete: noční světlo při práci do noci, režim nerušit při prezentaci nebo zákaz automatického zamykání při sledování obrazovky. Omarchy jim říká přepínače. Každý ovládáte stejně — klávesovou zkratkou, položkou nabídky nebo příkazem. Všechny tři možnosti mění tentýž stav.

### Nabídka přepínačů

`Super + Ctrl + O` otevře _Akce > Přepnout_. Do stejné nabídky se dostanete i přes nabídku Omarchy (`Super + Space`). Všechny uvedené funkce můžete rovnou zapnout nebo vypnout. Přepínače vzhledu plochy najdete vedle, v nabídce _Vzhled_.

Z terminálu jsou tytéž přepínače `omarchy toggle <thing>`. Spusťte samotné `omarchy toggle` a uvidíte celou skupinu.

| Přepínač | Klávesová zkratka | Příkaz |
| ------ | ------ | ------- |
| Noční světlo | — | `omarchy toggle nightlight` |
| Ztišit oznámení | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Nezamykat při nečinnosti | `Super + Ctrl + I` | `omarchy toggle idle` |
| Záznam pádů | — | `omarchy toggle crash-capture` |
| Spořič obrazovky | — | `omarchy toggle screensaver` |
| Synchronizace motivu [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Horní lišta | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Dotyková obrazovka | — | `omarchy toggle touchscreen` |
| Uspání | — | `omarchy toggle suspend` |
| Hybridní GPU | — | `omarchy toggle hybrid gpu` |

Přepínače touchpadu, dotykové obrazovky a hybridní GPU najdete v nabídce _Akce > Hardware_ (`Super + Ctrl + H`), a ne v nabídce _Přepnout_, protože se zobrazí jen tehdy, když ten hardware skutečně máte. Přepínače touchpadu a dotykové obrazovky přežijí opětovné načtení Hyprlandu — název vypnutého zařízení se uloží do malého stavového souboru, který Hyprland při spuštění přečte, aby ho znovu vypnul.

_Vzhled_ obsahuje horní lištu a animace plus pár věcí, které nejsou příkazy `omarchy toggle`, ale chovají se stejně: procenta baterie v liště, výchozí rozložení pracovních ploch a pod _Okna_ mezery mezi okny (`Super + Shift + Backspace`) a čtvercový poměr stran pro 1 okno (`Super + Ctrl + Backspace`).

Většina z nich je jen soubor s příznakem pod `~/.local/state/omarchy/toggles/`. Pokud na některém z nich chcete ve skriptu větvit, `omarchy-toggle-enabled` vám dá návratový kód, místo abyste ho museli hledat:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Příznaky jsou pojmenované podle vypnutého stavu — `screensaver-off`, `suspend-off`, `bar-off` — takže jejich přítomnost znamená, že je funkce vypnutá.

### Indikátory v liště

Zapnutý režim poznáte podle malé ikony uprostřed horní lišty vedle hodin. Widget ukazatelů takto zobrazuje diktování, nahrávání obrazovky, čekající připomínky, noční světlo, režim nerušit a vypnuté automatické zamykání.

Neaktivní ukazatele jsou skryté. Najeďte kamkoli na lištu a objeví se ztlumené, takže na jeden můžete kliknout a zapnout ho, aniž byste znali jeho klávesovou zkratku. Kliknutím na aktivní ho zase vypnete. Pokud byste je raději viděli všechny neustále, nastavte `alwaysShow` na `true` u položky `omarchy.indicators` v `~/.config/omarchy/shell.json` — jak se widgety lišty konfigurují, viz [horní lišta](05-the-top-bar.md).

### Noční světlo

Noční světlo nastaví teplejší barvy obrazovky s barevnou teplotou 4000 K. Dalším přepnutím se vrátíte na 6500 K. Zapnete ho z nabídky přepínačů (`Super + Ctrl + O`) nebo příkazem `omarchy toggle nightlight`. Změnu zajišťuje hyprsunset, který přepínač v případě potřeby sám spustí.

Ve výchozím nastavení hyprsunset barevnou teplotu nemění. Profil v `~/.config/hypr/hyprsunset.conf` ponechává původní nastavení obrazovky, dokud noční světlo sami nezapnete. Pokud chcete teplotu měnit podle času, nahraďte ho časovým profilem:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Pak hyprsunset spouštějte při přihlášení přidáním `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Dvojice 4000K/6500K, kterou přepínač používá, je pevná, takže pokud chcete jinou teplotu, musíte do konfiguračního souboru.

### Nerušit

`Super + Ctrl + Alt + ,` ztiší oznámení. Dokud je tento režim zapnutý, oznámení nevyskakují na obrazovce. Přeškrtnutý zvonek na liště vám připomíná, proč je na ploše klid.

Nic se ale neztratí. Ztišená oznámení se pozdrží: poslední pár jich vrátíte na obrazovku pomocí `Super + Shift + Alt + ,`. Zbytek viz [oznámení](10-notices.md).

Dva druhy zpráv se stále dostanou skrz: vlastní potvrzovací vyskakovací zprávy Omarchy o tom, co jste právě udělali („Theme changed“, „Screenshot saved“), a kritické výstrahy odeslané z příkazového řádku. Chatovací aplikace, které označují všechno jako kritické, aby si vynutily cestu před vás, se nepočítají.

### Nečinnost

Prostředí Omarchy vlastní chování při nečinnosti a časování je blok `idle` na nejvyšší úrovni v `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obě čísla jsou sekundy počítané od okamžiku, kdy jste přestali být aktivní — ne od sebe navzájem. Takže ve výchozím nastavení spořič obrazovky naskočí po dvou a půl minutách a zamykací obrazovka převezme vládu v pěti minutách, ať už spořič běžel, nebo ne. Uložte soubor a prostředí nové časování převezme okamžitě.

Pokud spořič obrazovky zrušíte před termínem zamknutí, počítá se to jako aktivita a čekající zamknutí se zruší. Nebudete uzamčeni za to, že jste se na svůj počítač jen podívali.

Automatické zamykání a spořič obrazovky vypnete pomocí `Super + Ctrl + I` nebo `omarchy toggle idle`. Na liště se objeví šálek kávy. Tento režim se hodí před dlouhou prezentací nebo sestavováním programu, jehož průběh chcete sledovat. Dalším stisknutím se vrátíte k běžnému chování. Pro použití ve skriptech vypíše `omarchy toggle idle status` aktuální stav jako JSON.

Tady jde o zamykání a spořič obrazovky, ne o napájení. Uspání a hibernace mají vlastní nastavení v [uspání systému](36-system-sleep.md).

### Spořič obrazovky

Spořič obrazovky Omarchy je ASCII art procházející náhodnými textovými efekty, jedna instance na monitor. Jakákoli klávesa nebo pohyb myši ho ukončí.

Můžete ho spustit na vyžádání z nabídky _Systém > Spořič obrazovky_ (`Super + Esc`), což ho vynutí i tehdy, když jste spořič při nečinnosti vypnuli. Ve výchozím nastavení k němu není přiřazena žádná klávesová zkratka.

`omarchy toggle screensaver` je to, co vypne ten při nečinnosti, pokud chcete raději přejít rovnou od práce k zamknutí. Jakákoli klávesa, kliknutí, posun nebo pohyb myši ho zavře.

Logo, které kreslí, si můžete změnit v _Vzhled > Branding > Spořič obrazovky_. Nahrajte png nebo svg a Omarchy ho převede na ASCII. Viz [branding](41-branding.md).

### Zamykací obrazovka

`Super + Ctrl + L` zamkne počítač. To spustí zamykací obrazovku z prostředí Omarchy, zhasne displej, resetuje rozložení klávesnice na první, abyste nepsali heslo ve špatné abecedě, a — pokud ho máte spuštěný — cestou ven zamkne 1Password.

Zamykací obrazovka přijímá heslo a přijme i otisk prstu, jakmile si ho nastavíte. To a další způsoby ověřování pokrývá [ověřování pomocí hardwaru](37-hardware-authentication.md).
