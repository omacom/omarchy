# Přepínače, nečinnost a spořič obrazovky

Spousta toho, co během dne měníte, vlastně není nastavení. Je to režim, který na hodinu zapnete a pak zase vypnete: noční světlo, když pracujete do noci, nerušit, když prezentujete, zůstat vzhůru, když se na něco díváte. Omarchy jim říká přepínače a všechny fungují stejně — klávesová zkratka, položka v nabídce a příkaz, všechny míří na stejný přepínač.

### Nabídka přepínačů

`Super + Ctrl + O` otevře přímo _Trigger > Toggle_, nebo tam můžete dojít z nabídky Omarchy (`Super + Space`). Všechno v tom seznamu je přepínač, který můžete přepnout, aniž byste přemýšleli, kde se ten stav ukládá. Přepínače pro vzhled plochy sedí hned vedle, pod _Appearance_.

Z terminálu jsou stejné přepínače `omarchy toggle <thing>`. Spusťte samotné `omarchy toggle` a uvidíte celou skupinu.

| Přepínač | Klávesová zkratka | Příkaz |
| ------ | ------ | ------- |
| Noční světlo | — | `omarchy toggle nightlight` |
| Ztlumit oznámení | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Zůstat vzhůru (bez zamykání při nečinnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zachytávání pádů | — | `omarchy toggle crash-capture` |
| Spořič obrazovky | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) synchronizace tématu | — | `omarchy toggle theme sync` |
| Lišta nabídek | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Dotyková obrazovka | — | `omarchy device touchscreen` |
| Uspání | — | `omarchy toggle suspend` |
| Hybridní GPU | — | `omarchy toggle hybrid gpu` |

Přepínače touchpadu, dotykové obrazovky a hybridní GPU žijí pod _Trigger > Hardware_ (`Super + Ctrl + H`), ne pod Toggle, protože se zobrazí jen tehdy, když takový hardware skutečně máte. Přepínače touchpadu a dotykové obrazovky přežijí opětovné načtení Hyprlandu — název vypnutého zařízení se uloží do malého stavového souboru, který Hyprland při spuštění přečte, aby ho znovu vypnul.

_Vzhled_ drží lištu nabídek a animace plus pár věcí, které nejsou příkazy `omarchy toggle`, ale chovají se stejně: procento baterie v liště, výchozí rozložení pracovních ploch a pod _Okna_ mezery oken (`Super + Shift + Backspace`) a čtvercový poměr stran pro 1 okno (`Super + Ctrl + Backspace`).

Když Hyprland nemá GPU, se kterou by kreslil, a vykresluje místo toho na CPU (llvmpipe), jako na počítačích Mac, jejichž GPU ještě není podporovaná, ve většině virtuálních strojů nebo když se nepodaří načíst grafický ovladač, Omarchy pro danou relaci vypne animace, rozmazání a stíny a jednou vám to oznámí oznámením. _Vzhled > Animace zapnuté_ je vrátí zpět a Omarchy si to zapamatuje i pro další relace.

Většina z nich je jen soubor s příznakem pod `~/.local/state/omarchy/toggles/`. Pokud se na některý chcete ve skriptu větvit, `omarchy-toggle-enabled` vám dá návratový kód, místo abyste ho museli hledat:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Příznaky jsou pojmenované podle vypnutého stavu — `screensaver-off`, `suspend-off`, `bar-off` — takže jejich přítomnost znamená, že je funkce vypnutá.

### Indikátory v liště

Když je režim zapnutý, dostanete malý glyf uprostřed horní lišty vedle hodin. To je widget indikátorů a nese diktování, nahrávání obrazovky, čekající připomínky, noční světlo, nerušit a zůstat vzhůru.

Neaktivní indikátory jsou skryté. Najeďte kamkoli na lištu a ztlumeně se objeví, takže na některý můžete kliknout a zapnout ho, aniž byste znali jeho klávesovou zkratku. Kliknutím na aktivní ho zase vypnete. Pokud je raději chcete vidět všechny pořád, nastavte `alwaysShow` na `true` u položky `omarchy.indicators` v `~/.config/omarchy/shell.json` — viz [horní lišta](05-the-top-bar.md), kde je popsané, jak se widgety lišty konfigurují.

### Noční světlo

Noční světlo ohřeje obrazovku na 4000K a opětovným přepnutím ji vrátí na 6500K. Přepnete ho z nabídky přepínačů (`Super + Ctrl + O`) nebo příkazem `omarchy toggle nightlight`. Pohání ho hyprsunset, který za vás přepínač spustí, pokud ještě neběží.

Ve výchozím nastavení hyprsunset s vaší obrazovkou nedělá vůbec nic. `~/.config/hypr/hyprsunset.conf` se dodává s identitním profilem právě proto, aby displej zůstal nedotčený, dokud si teplo nevyžádáte. Pokud chcete raději přepínání podle hodin, nahraďte ho časovým profilem:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Poté spusťte hyprsunset při přihlášení přidáním `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Dvojice 4000K/6500K, kterou přepínač používá, je pevná, takže pokud chcete jinou teplotu, jdete do konfiguračního souboru.

### Nerušit

`Super + Ctrl + Alt + ,` ztlumí oznámení. Dokud je zapnuté, nevyskakují žádné toasty a přeškrtnutý zvonek v liště vám připomíná, proč plocha ztichla.

Nic se ale neztratí. Ztlumená oznámení se pozdrží: poslední pár jich vrátíte na obrazovku příkazem `Super + Shift + Alt + ,`. Zbytek viz [oznámení](10-notices.md).

Dva druhy zpráv přesto projdou: vlastní potvrzovací toasty Omarchy pro něco, co jste právě udělali („Téma změněno“, „Snímek obrazovky uložen“), a kritická upozornění odeslaná z příkazového řádku. Chatovací aplikace, které označují všechno jako kritické, aby si vynutily cestu před vás, se nekvalifikují.

### Nečinnost

Chování při nečinnosti vlastní shell Omarchy a časování je blok `idle` na nejvyšší úrovni v `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obě čísla jsou sekundy počítané od okamžiku, kdy jste přestali být aktivní — ne jedno od druhého. Takže ve výchozím nastavení se spořič obrazovky objeví po dvou a půl minutách a zamykací obrazovka převezme vládu v pěti minutách, ať už spořič běžel, nebo ne. Uložte soubor a shell nové časování převezme okamžitě.

Pokud spořič obrazovky zavřete před termínem zamknutí, počítá se to jako aktivita a čekající zamknutí se zruší. Nezůstanete zamčení venku za to, že jste se na svůj stroj jen podívali.

Když chcete zamykání při nečinnosti úplně zastavit, `Super + Ctrl + I` — nebo `omarchy toggle idle` — zapne režim zůstat vzhůru a v liště se objeví indikátor šálku kávy. Ten zmáčkněte před dlouhou prezentací nebo buildem, který chcete sledovat. Zmáčkněte ho znovu a vrátíte se do normálu. `omarchy toggle idle status` vypíše aktuální stav jako JSON, pokud ho potřebujete ze skriptu.

Tohle je o zamykání a spořiči obrazovky, ne o napájení. Uspání a hibernace mají vlastní nastavení v [uspání systému](36-system-sleep.md).

### Spořič obrazovky

Spořič obrazovky Omarchy je ASCII art procházející náhodnými textovými efekty, jedna instance na monitor. Jakákoli klávesa nebo pohyb myši ho ukončí.

Můžete ho spustit na vyžádání ze _Systém > Spořič obrazovky_ (`Super + Esc`), což ho vynutí, i když jste spořič při nečinnosti vypnuli. Ve výchozím nastavení k němu není přiřazená žádná klávesová zkratka.

`omarchy toggle screensaver` je to, co vypne ten při nečinnosti, pokud raději jdete rovnou z práce na zamčenou obrazovku. Jakákoli klávesa, kliknutí, posun nebo pohyb myši ho zavře.

Logo, které kreslí, si můžete změnit pod _Vzhled > Branding > Spořič obrazovky_. Nahrajte png nebo svg a Omarchy ho převede do ASCII. Viz [identita značky](41-branding.md).

### Zamykací obrazovka

`Super + Ctrl + L` zamkne stroj. To spustí zamykací obrazovku ze shellu Omarchy, zhasne displej, resetuje rozložení klávesnice na první, abyste nepsali heslo ve špatné abecedě, a — pokud ho máte spuštěný — cestou ven zamkne 1Password.

Zamykací obrazovka přijímá heslo a přijme i otisk prstu, jakmile si ho nastavíte. To a další způsoby ověření jsou popsané v [hardwarovém ověřování](37-hardware-authentication.md).
