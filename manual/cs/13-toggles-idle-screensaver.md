# Přepínače, nečinnost a spořič obrazovky

Spousta toho, co denně měníte, vlastně není nastavení. Je to režim, který na hodinu zapnete a pak zase vypnete: noční světlo, když pracujete dlouho do noci, nerušit, když prezentujete, zůstat vzhůru, když se na něco díváte. Omarchy jim říká přepínače a všechny fungují stejně — klávesová zkratka, položka v menu a příkaz, všechny sahají na tentýž přepínač.

### Menu přepínačů

`Super + Ctrl + O` otevře přímo _Trigger > Toggle_, nebo se tam dostanete z menu Omarchy (`Super + Space`). Všechno v tom seznamu je přepínač, který můžete přepnout, aniž byste přemýšleli, kde se stav ukládá. Přepínače vzhledu plochy sedí hned vedle, pod _Appearance_.

Z terminálu jsou tytéž přepínače `omarchy toggle <thing>`. Spusťte `omarchy toggle` samostatně a uvidíte celou skupinu.

| Přepínač | Klávesová zkratka | Příkaz |
| ------ | ------ | ------- |
| Noční světlo | — | `omarchy toggle nightlight` |
| Umlčet oznámení | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Zůstat vzhůru (bez zámku při nečinnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zachytávání pádů | — | `omarchy toggle crash-capture` |
| Spořič obrazovky | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) synchronizace motivu | — | `omarchy toggle theme sync` |
| Lišta menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Dotyková obrazovka | — | `omarchy toggle touchscreen` |
| Uspání | — | `omarchy toggle suspend` |
| Hybridní GPU | — | `omarchy toggle hybrid gpu` |

Přepínače touchpadu, dotykové obrazovky a hybridní GPU žijí pod _Trigger > Hardware_ (`Super + Ctrl + H`), nikoli pod Toggle, protože se objeví jen tehdy, když ten hardware skutečně máte. Přepínače touchpadu a dotykové obrazovky přežijí opětovné načtení Hyprlandu — název deaktivovaného zařízení se uloží do malého stavového souboru, který Hyprland při spuštění přečte, aby ho znovu deaktivoval.

_Appearance_ obsahuje lištu menu a animace a navíc pár věcí, které nejsou příkazy `omarchy toggle`, ale chovají se stejně: procenta baterie v liště, výchozí rozložení pracovní plochy a pod _Windows_ mezery mezi okny (`Super + Shift + Backspace`) a čtvercový poměr pro 1 okno (`Super + Ctrl + Backspace`).

Když Hyprland nemá GPU, se kterou by mohl kreslit, a vykresluje místo toho na CPU (llvmpipe), jako na Macích, jejichž GPU zatím není podporována, ve většině virtuálních strojů nebo když se nepodaří načíst grafický ovladač, Omarchy pro danou relaci vypne animace, rozostření a stíny a jednou vám to oznámí upozorněním. _Appearance > Animations On_ je vrátí zpět a Omarchy si to zapamatuje i pro další relace.

Většina z nich je jen příznakový soubor pod `~/.local/state/omarchy/toggles/`. Pokud se podle některého chcete větvit ve skriptu, `omarchy-toggle-enabled` vám dá návratový kód, místo abyste ho museli hledat sami:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Příznaky jsou pojmenované podle vypnutého stavu — `screensaver-off`, `suspend-off`, `bar-off` — takže jejich přítomnost znamená, že je funkce deaktivovaná.

### Ukazatele v liště

Když je nějaký režim zapnutý, objeví se vám uprostřed horní lišty vedle hodin malý glyf. To je widget ukazatelů a nese diktování, nahrávání obrazovky, čekající připomínky, noční světlo, nerušit a zůstat vzhůru.

Neaktivní ukazatele jsou skryté. Najeďte kamkoli na lištu a ztlumeně se objeví, takže na některý můžete kliknout a zapnout ho, i když neznáte jeho klávesovou zkratku. Kliknutím na aktivní ho zase vypnete. Pokud je raději chcete vidět všechny pořád, nastavte `alwaysShow` na `true` u položky `omarchy.indicators` v `~/.config/omarchy/shell.json` — jak se widgety lišty konfigurují, najdete v [horní liště](05-the-top-bar.md).

### Noční světlo

Noční světlo ohřeje obrazovku na 4000K a opětovným přepnutím ji vrátí na 6500K. Přepnete ho z menu přepínačů (`Super + Ctrl + O`) nebo pomocí `omarchy toggle nightlight`. Pohání ho hyprsunset, který za vás přepínač spustí, pokud už neběží.

Ve výchozím stavu hyprsunset s vaší obrazovkou nedělá vůbec nic. `~/.config/hypr/hyprsunset.conf` se dodává s identitním profilem právě proto, aby displej zůstal nedotčený, dokud si teplo sami nevyžádáte. Pokud chcete, aby se přepínal podle hodin, nahraďte ho časovým profilem:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Potom spouštějte hyprsunset při přihlášení přidáním `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Dvojice 4000K/6500K, kterou přepínač používá, je pevná, takže pokud chcete jinou teplotu, musíte do konfiguračního souboru.

### Nerušit

`Super + Ctrl + Alt + ,` umlčí oznámení. Dokud je zapnutý, nevyskakují žádné toasty a přeškrtnutý zvonek v liště vám připomíná, proč plocha ztichla.

Nic se ale neztratí. Umlčená oznámení se podrží stranou: poslední z nich vrátíte na obrazovku pomocí `Super + Shift + Alt + ,`. Zbytek najdete v [upozorněních](10-notices.md).

Dva druhy zpráv přesto projdou: vlastní potvrzovací toasty Omarchy pro něco, co jste právě udělali ("Theme changed", "Screenshot saved"), a kritická upozornění odeslaná z příkazového řádku. Chatovací aplikace, které označují všechno jako kritické, aby se vám vnutily do popředí, se nepočítají.

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

Obě čísla jsou sekundy počítané od okamžiku, kdy jste se stali nečinnými — ne od sebe navzájem. Takže ve výchozím nastavení naskočí spořič obrazovky po dvou a půl minutách a zamykací obrazovka převezme vládu v pěti minutách, ať už spořič běžel, nebo ne. Uložte soubor a shell nová časování okamžitě převezme.

Pokud spořič obrazovky zrušíte před lhůtou pro zamknutí, počítá se to jako aktivita a čekající zamknutí se zruší. Nebudete zamčeni ven za to, že jste se na svůj počítač jen podívali.

Chcete-li zamykání při nečinnosti úplně zastavit, `Super + Ctrl + I` — nebo `omarchy toggle idle` — zapne režim zůstat vzhůru a v liště se objeví ukazatel šálku kávy. Ten zmáčkněte před dlouhou prezentací nebo buildem, který chcete sledovat. Zmáčkněte ho znovu a vrátíte se do normálu. `omarchy toggle idle status` vypíše aktuální stav jako JSON, pokud ho potřebujete ze skriptu.

Tady jde o zamykání a spořič obrazovky, ne o napájení. Uspání a hibernace mají vlastní nastavení v [uspávání systému](36-system-sleep.md).

### Spořič obrazovky

Spořič obrazovky Omarchy je ASCII art procházející náhodnými textovými efekty, jedna instance na monitor. Jakákoli klávesa nebo pohyb myši ho ukončí.

Na požádání ho spustíte ze _System > Screensaver_ (`Super + Esc`), což ho vynutí, i když jste spořič při nečinnosti vypnuli. Ve výchozím stavu k němu není přiřazena žádná klávesová zkratka.

`omarchy toggle screensaver` je to, co vypne ten při nečinnosti, pokud chcete jít raději rovnou z práce na zamčenou obrazovku. Zavře ho jakákoli klávesa, kliknutí, scrollování nebo pohyb myši.

Logo, které kreslí, si můžete změnit pod _Appearance > Branding > Screensaver_. Nahrajte png nebo svg a Omarchy ho převede do ASCII. Viz [branding](41-branding.md).

### Zamykací obrazovka

`Super + Ctrl + L` počítač zamkne. Spustí to zamykací obrazovku ze shellu Omarchy, zhasne displej, resetuje rozložení klávesnice na první, abyste nepsali heslo ve špatné abecedě, a — pokud ho máte spuštěný — cestou ven zamkne i 1Password.

Zamykací obrazovka přijímá heslo a přijme i otisk prstu, jakmile si ho nastavíte. To a další způsoby ověřování pokrývá [hardwarové ověřování](37-hardware-authentication.md).
