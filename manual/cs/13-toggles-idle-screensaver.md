# Přepínače, nečinnost a spořič obrazovky

Spousta toho, co denně měníte, vlastně není nastavení. Je to režim, který na hodinu zapnete a pak zase vypnete: noční světlo, když pracujete dlouho do noci, nerušit, když prezentujete, zůstat vzhůru, když se na něco díváte. Omarchy jim říká přepínače a všechny fungují stejně — klávesová zkratka, položka v menu a příkaz, všechny míří na stejný přepínač.

### Menu přepínačů

`Super + Ctrl + O` otevře přímo _Trigger > Přepínače_, nebo tam můžete dojít z menu Omarchy (`Super + Space`). Vše v tom seznamu je přepínač, který můžete přepnout, aniž byste přemýšleli, kde se stav ukládá. Přepínače toho, jak desktop vypadá, sedí hned vedle, pod _Vzhledem_.

Z terminálu jsou stejné přepínače `omarchy toggle <thing>`. Spusťte samotné `omarchy toggle` a uvidíte celou skupinu.

| Přepínač | Klávesová zkratka | Příkaz |
| ------ | ------ | ------- |
| Noční světlo | — | `omarchy toggle nightlight` |
| Ztlumení oznámení | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Zůstat vzhůru (bez zamykání při nečinnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zachytávání pádů | — | `omarchy toggle crash-capture` |
| Spořič obrazovky | — | `omarchy toggle screensaver` |
| Synchronizace motivu [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Lišta menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Dotyková obrazovka | — | `omarchy toggle touchscreen` |
| Uspání | — | `omarchy toggle suspend` |
| Hybridní GPU | — | `omarchy toggle hybrid gpu` |

Přepínače touchpadu, dotykové obrazovky a hybridní GPU žijí pod _Trigger > Hardware_ (`Super + Ctrl + H`) spíše než pod Přepínači, protože se zobrazí jen tehdy, když takový hardware skutečně máte. Přepínače touchpadu a dotykové obrazovky přežijí opětovné načtení Hyprlandu — název zakázaného zařízení se uloží do malého stavového souboru, který Hyprland při spuštění přečte, aby ho znovu zakázal.

_Vzhled_ obsahuje lištu menu a animace plus pár věcí, které nejsou příkazy `omarchy toggle`, ale chovají se stejně: procenta baterie v liště, výchozí rozložení pracovní plochy a pod _Okny_ mezery oken (`Super + Shift + Backspace`) a čtvercový poměr stran pro 1 okno (`Super + Ctrl + Backspace`).

Většina z nich je jen soubor příznaku pod `~/.local/state/omarchy/toggles/`. Pokud na některý chcete ve skriptu větvit, `omarchy-toggle-enabled` vám dá návratový kód, místo abyste ho museli hledat:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Příznaky jsou pojmenované podle vypnutého stavu — `screensaver-off`, `suspend-off`, `bar-off` — takže jejich přítomnost znamená, že je funkce zakázaná.

### Indikátory v liště

Když je režim zapnutý, dostanete malý glyf uprostřed horní lišty vedle hodin. To je widget indikátorů a nese diktování, nahrávání obrazovky, čekající připomínky, noční světlo, nerušit a zůstat vzhůru.

Neaktivní indikátory jsou skryté. Najeďte kamkoli na lištu a objeví se ztlumené, takže na některý můžete kliknout a zapnout ho, aniž byste znali jeho klávesovou zkratku. Kliknutím na aktivní ho zase vypnete. Pokud je chcete raději vidět všechny pořád, nastavte `alwaysShow` na `true` u záznamu `omarchy.indicators` v `~/.config/omarchy/shell.json` — viz [horní lištu](05-the-top-bar.md), kde je popsáno, jak se widgety lišty konfigurují.

### Noční světlo

Noční světlo zahřeje obrazovku na 4000K a opětovným přepnutím ji vrátí na 6500K. Přepněte ho z menu přepínačů (`Super + Ctrl + O`) nebo pomocí `omarchy toggle nightlight`. Pohání ho hyprsunset, který za vás přepínač spustí, pokud už neběží.

Ve výchozím nastavení hyprsunset s vaší obrazovkou nedělá vůbec nic. `~/.config/hypr/hyprsunset.conf` se dodává právě s identitním profilem, aby displej zůstal nedotčený, dokud si o teplo neřeknete. Pokud chcete raději, aby se přepínal podle hodin, nahraďte ho časovým profilem:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Pak hyprsunset spouštějte při přihlášení přidáním `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Dvojice 4000K/6500K, kterou přepínač používá, je pevná, takže pokud chcete jinou teplotu, jdete do konfiguračního souboru.

### Nerušit

`Super + Ctrl + Alt + ,` ztlumí oznámení. Dokud je zapnuté, nevyskakují žádné toasty a přeškrtnutý zvonek v liště vám připomíná, proč desktop ztichl.

Nic se ale neztratí. Ztlumená oznámení se pozdrží: poslední pár jich vrátíte zpět na obrazovku pomocí `Super + Shift + Alt + ,`. Zbytek viz [oznámení](10-notices.md).

Dva druhy zpráv se přesto dostanou skrz: vlastní potvrzovací toasty Omarchy pro něco, co jste právě udělali ("Theme changed", "Screenshot saved"), a kritická upozornění odeslaná z příkazového řádku. Chatovací aplikace, které označují vše jako kritické, aby si vynutily cestu před vás, se nekvalifikují.

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

Obě čísla jsou sekundy počítané od okamžiku, kdy jste přestali být aktivní — ne od sebe navzájem. Takže ve výchozím nastavení se spořič obrazovky objeví po dvou a půl minutách a zamykací obrazovka převezme vládu v pěti minutách, ať už spořič běžel, nebo ne. Uložte soubor a prostředí si nové časování převezme hned.

Pokud spořič odmítnete před termínem zamknutí, počítá se to jako aktivita a čekající zamknutí se zruší. Nezůstanete zamčeni venku za to, že jste se na svůj stroj jen podívali.

Chcete-li zamykání při nečinnosti úplně zastavit, `Super + Ctrl + I` — nebo `omarchy toggle idle` — zapne zůstat vzhůru a v liště se objeví indikátor šálku kávy. Ten zmáčkněte před dlouhou prezentací nebo buildem, který chcete sledovat. Zmáčkněte ho znovu pro návrat do normálu. `omarchy toggle idle status` vypíše aktuální stav jako JSON, pokud ho potřebujete ze skriptu.

Tohle je o zamykání a spořiči obrazovky, ne o napájení. Uspání a hibernace mají vlastní nastavení v [uspávání systému](36-system-sleep.md).

### Spořič obrazovky

Spořič obrazovky Omarchy je ASCII art procházející náhodnými textovými efekty, jedna instance na monitor. Jakákoli klávesa nebo pohyb myši ho ukončí.

Můžete ho spustit na vyžádání ze _Systém > Spořič obrazovky_ (`Super + Esc`), což ho vynutí, i když jste spořič při nečinnosti vypnuli. Ve výchozím nastavení k němu není přiřazena žádná klávesová zkratka.

`omarchy toggle screensaver` je to, co vypne ten při nečinnosti, pokud chcete raději jít rovnou z práce do zamčeného stavu. Potřebuje terminál, který umí nakonfigurovat — Alacritty, Foot, Ghostty nebo Kitty — a řekne vám to, pokud je váš výchozí terminál něco jiného.

Logo, které kreslí, si můžete změnit pod _Vzhled > Branding > Spořič obrazovky_. Nahrajte png nebo svg a Omarchy ho převede do ASCII. Viz [branding](41-branding.md).

### Zamykací obrazovka

`Super + Ctrl + L` zamkne stroj. To spustí zamykací obrazovku z prostředí Omarchy, zhasne displej, resetuje rozložení klávesnice na první, abyste nepsali heslo ve špatné abecedě, a — pokud ho máte spuštěný — cestou ven zamkne 1Password.

Zamykací obrazovka bere heslo a vezme i otisk prstu, jakmile si ho nastavíte. To a další způsoby ověření jsou popsány v [hardwarovém ověřování](37-hardware-authentication.md).
