# Přepínače, nečinnost a spořič obrazovky

Mnoho z toho, co denně měníte, není vlastně nastavení. Je to režim, který na hodinu zapnete a zase vypnete: noční světlo, když pracujete dlouho do noci, nerušit, když prezentujete, zůstat vzhůru, když se na něco díváte. Omarchy jim říká přepínače a všechny fungují stejně — klávesová zkratka, položka nabídky a příkaz, všechny zasahují tentýž přepínač.

### Nabídka přepínačů

`Super + Ctrl + O` otevře přímo _Akce > Přepnout_, nebo tam můžete dojít z nabídky Omarchy (`Super + Space`). Všechno v tomto seznamu je přepínač, který můžete přepnout, aniž byste přemýšleli o tom, kde stav žije. Přepínače pro vzhled plochy sedí hned vedle, v _Akce > Vzhled_.

Z terminálu jsou tytéž přepínače `omarchy toggle <thing>`. Samostatným spuštěním `omarchy toggle` uvidíte celou skupinu.

| Přepínač | Klávesová zkratka | Příkaz |
| ------ | ------ | ------- |
| Noční světlo | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Ztišit oznámení | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Zůstat vzhůru (žádné zamykání při nečinnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Záznam pádů | — | `omarchy toggle crash-capture` |
| Spořič obrazovky | — | `omarchy toggle screensaver` |
| Synchronizace motivu [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Panel nabídek | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Dotykový displej | — | `omarchy toggle touchscreen` |
| Uspat | — | `omarchy toggle suspend` |
| Hybridní GPU | — | `omarchy toggle hybrid gpu` |

Přepínače touchpadu, dotykového displeje a hybridní GPU žijí v _Akce > Hardware_ (`Super + Ctrl + H`) místo v Přepnout, protože se objeví, jen když daný hardware skutečně máte. Přepínače touchpadu a dotykového displeje přežijí opětovné načtení Hyprlandu — název zakázaného zařízení se uloží do malého stavového souboru, který Hyprland při spuštění přečte, aby ho znovu zakázal.

_Akce > Vzhled_ obsahuje panel nabídek a animace, plus pár věcí, které nejsou příkazy `omarchy toggle`, ale chovají se stejně: procenta baterie na panelu, výchozí rozložení pracovní plochy, mezery oken (`Super + Shift + Backspace`) a čtvercový poměr pro 1 okno (`Super + Ctrl + Backspace`).

Většina z nich je jen příznakový soubor v `~/.local/state/omarchy/toggles/`. Pokud se chcete na některém větvit ve skriptu, `omarchy-toggle-enabled` vám dá návratový kód, místo abyste ho museli hledat:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Příznaky jsou pojmenovány podle vypnutého stavu — `screensaver-off`, `suspend-off`, `bar-off` — takže jejich přítomnost znamená, že funkce je zakázána.

### Ukazatele na panelu

Když je režim zapnutý, dostanete malý glyf uprostřed horního panelu vedle hodin. To je widget ukazatelů a nese diktování, nahrávání obrazovky, čekající připomínky, noční světlo, nerušit a zůstat vzhůru.

Neaktivní ukazatele jsou skryté. Najeďte na oblast kolem nich a objeví se ztlumené, takže na jeden můžete kliknout a zapnout ho, aniž byste znali jeho klávesovou zkratku. Kliknutím na aktivní ho zase vypnete. Pokud byste je raději viděli všechny neustále, nastavte `alwaysShow` na `true` u položky `omarchy.indicators` v `~/.config/omarchy/shell.json` — jak se widgety panelu konfigurují, viz [horní panel](05-the-top-bar.md).

### Noční světlo

`Super + Ctrl + N` zahřeje obrazovku na 4000 K a opětovným stisknutím ji vrátí na 6500 K. Řídí ho hyprsunset, který přepínač spustí za vás, pokud už neběží.

Ve výchozím nastavení hyprsunset s vaší obrazovkou nedělá vůbec nic. `~/.config/hypr/hyprsunset.conf` se dodává s identitním profilem právě proto, aby displej zůstal nedotčený, dokud nepožádáte o teplo. Pokud byste raději, aby se přepínal podle hodin, nahraďte ho časovým profilem:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Poté spouštějte hyprsunset při přihlášení přidáním `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Pár 4000 K/6500 K používaný přepínačem je pevný, takže konfigurační soubor je místem, kam jdete, pokud chcete jinou teplotu.

### Nerušit

`Super + Ctrl + ,` ztiší oznámení. Zatímco je zapnuté, nevyskakují žádné toastové zprávy a ukazatel přeškrtnutého zvonku sedí na panelu, aby vám připomínal, proč plocha ztichla.

Nic se ale neztratí. Ztišené oznámení se zapíše přímo do vaší historie oznámení, což je přesně záznam, který chcete, když se vrátíte a přemýšlíte, co jste zmeškali. Otevřete ji pomocí `Super + Shift + Alt + ,`. Zbytek příběhu oznámení viz [upozornění](10-notices.md).

Dva druhy zpráv se stále dostanou skrz: vlastní potvrzovací toastové zprávy Omarchy o tom, co jste právě udělali („Theme changed“, „Screenshot saved“), a kritické výstrahy odeslané z příkazového řádku. Chatovací aplikace, které označují všechno jako kritické, aby si vynutily cestu před vás, se nepočítají.

### Nečinnost

Shell Omarchy vlastní chování při nečinnosti a časování jsou blokem `idle` na nejvyšší úrovni v `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obě čísla jsou sekundy počítané od okamžiku, kdy jste se stali nečinnými — ne od sebe navzájem. Takže s výchozími nastaveními se spořič obrazovky objeví po dvou a půl minutách a zamykací obrazovka převezme řízení po pěti minutách, ať už spořič běžel, nebo ne. Uložte soubor a shell nová časování převezme okamžitě.

Pokud spořič obrazovky zavřete před lhůtou pro zamknutí, počítá se to jako aktivita a čekající zamknutí se zruší. Nebudete uzamčeni za to, že jste se podívali na svůj počítač.

Chcete-li úplně zastavit zamykání při nečinnosti, `Super + Ctrl + I` — nebo `omarchy toggle idle` — zapne zůstat vzhůru a na panelu se objeví ukazatel šálku kávy. Ten stiskněte před dlouhou prezentací nebo buildem, který chcete sledovat. Stiskněte ho znovu pro návrat k normálu. `omarchy toggle idle status` vypíše aktuální stav jako JSON, pokud ho potřebujete ze skriptu.

Tady jde o zamykání a spořič obrazovky, ne o napájení. Uspání a hibernace mají vlastní nastavení v [uspání systému](36-system-sleep.md).

### Spořič obrazovky

Spořič obrazovky Omarchy je ASCII art procházející náhodnými textovými efekty, jedna instance na monitor. Jakákoli klávesa nebo pohyb myši ho ukončí.

Můžete ho spustit na požádání z _Systém > Spořič obrazovky_ (`Super + Esc`), což ho vynutí, i když jste spořič při nečinnosti vypnuli. Ve výchozím nastavení k němu není přiřazena žádná klávesová zkratka.

`omarchy toggle screensaver` je to, co vypne ten při nečinnosti, pokud byste raději šli přímo od práce k zamknutí. Potřebuje terminál, který umí nakonfigurovat — Alacritty, Foot, Ghostty nebo Kitty — a řekne vám to, pokud je váš výchozí terminál něco jiného.

Logo, které kreslí, si můžete změnit v _Styl > Spořič obrazovky_. Nahrajte png nebo svg a Omarchy ho převede na ASCII. Viz [branding](41-branding.md).

### Zamykací obrazovka

`Super + Ctrl + L` zamkne počítač. Tím se spustí zamykací obrazovka ze shellu Omarchy, zhasne displej, resetuje vaše rozložení klávesnice na první, abyste nepsali heslo ve špatné abecedě, a — pokud ho máte spuštěný — cestou ven zamkne 1Password.

Zamykací obrazovka přijímá heslo a přijme i otisk prstu, jakmile si ho nastavíte. To a další způsoby ověřování jsou popsány v [hardwarovém ověřování](37-hardware-authentication.md).
