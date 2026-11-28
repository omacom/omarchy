# Přepínače, nečinnost a spořič obrazovky

Spousta toho, co denně měníte, vlastně není nastavení. Je to režim, který na hodinu zapnete a pak zase vypnete: noční světlo, když pracujete do noci, režim nerušit, když prezentujete, zůstat vzhůru, když se na něco díváte. Omarchy jim říká přepínače a všechny fungují stejně — klávesová zkratka, položka v nabídce a příkaz, všechny míří na stejný přepínač.

### Nabídka přepínačů

`Super + Ctrl + O` otevře přímo _Spouštěč > Přepínač_, nebo tam můžete dojít z nabídky Omarchy (`Super + Space`). Všechno v tom seznamu je přepínač, který můžete přepnout, aniž byste přemýšleli, kde se stav ukládá. Přepínače toho, jak plocha vypadá, sedí hned vedle, pod _Vzhled_.

Z terminálu jsou tytéž přepínače `omarchy toggle <thing>`. Spusťte samotné `omarchy toggle` a uvidíte celou skupinu.

| Přepínač | Klávesová zkratka | Příkaz |
| ------ | ------ | ------- |
| Noční světlo | — | `omarchy toggle nightlight` |
| Ztišit oznámení | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Zůstat vzhůru (bez zamykání při nečinnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Zachytávání pádů | — | `omarchy toggle crash-capture` |
| Spořič obrazovky | — | `omarchy toggle screensaver` |
| Synchronizace motivu [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Lišta nabídek | `Super + Shift + Space` | `omarchy toggle bar` |
| Plocha na celou obrazovku (bez lišty, bez mezer) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animace, rozostření a stíny | — | `omarchy toggle animations` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Dotyková obrazovka | — | `omarchy device touchscreen` |
| Uspat | — | `omarchy toggle suspend` |
| Hybridní GPU | — | `omarchy device gpu hybrid` |

Přepínače touchpadu, dotykové obrazovky a hybridní GPU žijí pod _Spouštěč > Hardware_ (`Super + Ctrl + H`) spíše než pod Přepínač, protože se zobrazí jen tehdy, když ten hardware skutečně máte. Přepínače touchpadu a dotykové obrazovky přežijí opětovné načtení Hyprland — název zakázaného zařízení se uloží do malého stavového souboru, který Hyprland při spuštění přečte, aby ho znovu zakázal.

_Vzhled_ obsahuje lištu nabídek a animace plus pár věcí, které nejsou příkazy `omarchy toggle`, ale chovají se stejně: procenta baterie v liště, výchozí rozložení pracovních ploch a pod _Okna_ mezery oken (`Super + Shift + Backspace`) a čtvercový poměr stran pro 1 okno (`Super + Ctrl + Backspace`).

Když Hyprland nemá GPU, se kterou by kreslil, a vykresluje místo toho na CPU (llvmpipe), jako na Macích, jejichž GPU ještě není podporovaná, ve většině virtuálních strojů, nebo když se nepodaří načíst grafický ovladač, Omarchy pro tu relaci vypne animace, rozostření a stíny a jednou vám to řekne oznámením. _Vzhled > Zapnout animace_ je přivede zpět a Omarchy si to pamatuje i pro další relace.

Většina z nich je jen příznakový soubor pod `~/.local/state/omarchy/toggles/`. Pokud se na některý chcete ve skriptu větvit, `omarchy-toggle-enabled` vám dá návratový kód, místo abyste ho museli hledat:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Příznaky jsou pojmenované podle vypnutého stavu — `screensaver-off`, `suspend-off`, `bar-off` — takže jejich přítomnost znamená, že je funkce zakázaná.

### Indikátory v liště

Když je režim zapnutý, dostanete malý glyf uprostřed horní lišty vedle hodin. To je widget indikátorů a nese nahrávání obrazovky, čekající připomínky, noční světlo, režim nerušit a zůstat vzhůru, plus varování, když je zapnuté sudo bez hesla nebo je někdo připojený ke vzdálené relaci.

Neaktivní indikátory jsou skryté. Najeďte kamkoli na lištu a objeví se ztlumené, takže na jeden můžete kliknout a zapnout ho, aniž byste znali jeho klávesovou zkratku. Kliknutím na aktivní ho zase vypnete. Pokud je chcete raději vidět všechny pořád, nastavte `alwaysShow` na `true` u položky `omarchy.indicators` v `~/.config/omarchy/shell.json` — viz [horní lišta](05-the-top-bar.md), kde je popsáno, jak se widgety lišty konfigurují.

### Noční světlo

Noční světlo zahřeje obrazovku na 4000K a opětovné přepnutí ji vrátí na 6500K. Přepněte ho z nabídky přepínačů (`Super + Ctrl + O`) nebo pomocí `omarchy toggle nightlight`. Pohání ho hyprsunset, který za vás přepínač spustí, pokud ještě neběží.

Ve výchozím nastavení hyprsunset s vaší obrazovkou nedělá vůbec nic. `~/.config/hypr/hyprsunset.conf` se dodává s profilem identity právě proto, aby displej zůstal nedotčený, dokud si o teplo neřeknete. Pokud chcete raději, aby přepínal podle hodin, nahraďte ho časovým profilem:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Potom spusťte hyprsunset při přihlášení přidáním `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Dvojice 4000K/6500K, kterou přepínač používá, je pevná, takže do konfiguračního souboru jdete, když chcete jinou teplotu.

### Nerušit

`Super + Ctrl + Alt + ,` ztiší oznámení. Dokud je zapnutý, nevyskakují žádné toasty a přeškrtnutý zvonek v liště vám připomíná, proč plocha ztichla.

Nic se ale neztratí. Ztišená oznámení se zadržují: poslední pár jich vrátíte na obrazovku pomocí `Super + Shift + Alt + ,`. Zbytek viz [oznámení](10-notices.md).

Tři druhy zpráv přesto projdou: vlastní potvrzovací toasty Omarchy k něčemu, co jste právě udělali ("Motiv změněn", "Snímek obrazovky uložen"), kritická upozornění odeslaná z příkazového řádku a ověřovací kódy. Chatovacím aplikacím, které označují všechno jako kritické, aby si vynutily cestu před vás, to neprojde.

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

Obě čísla jsou sekundy počítané od okamžiku, kdy jste přestali být aktivní — ne od sebe navzájem. Takže s výchozími hodnotami se spořič obrazovky objeví po dvou a půl minutách a zamykací obrazovka převezme vládu v pěti minutách, ať už spořič běžel, nebo ne. Uložte soubor a shell nové časování převezme okamžitě.

Pokud spořič obrazovky odmítnete před lhůtou pro zamknutí, počítá se to jako aktivita a čekající zamknutí se zruší. Nezamknete se venku jen za to, že jste se na svůj stroj podívali.

Chcete-li zamykání při nečinnosti úplně zastavit, `Super + Ctrl + I` — nebo `omarchy toggle idle` — zapne režim zůstat vzhůru a v liště se objeví indikátor šálku kávy. Ten zmáčkněte před dlouhou prezentací nebo buildem, který chcete sledovat. Zmáčkněte ho znovu a vrátíte se k normálu. `omarchy toggle idle status` vypíše aktuální stav jako JSON, pokud ho potřebujete ze skriptu.

Tady jde o zamykání a spořič obrazovky, ne o napájení. Uspání a hibernace mají vlastní nastavení v [spánek systému](36-system-sleep.md).

### Spořič obrazovky

Spořič obrazovky Omarchy je ASCII art běžící přes náhodné textové efekty, jedna instance na monitor. Jakákoli klávesa nebo pohyb myši ho ukončí.

Můžete ho spustit na požádání ze _Systém > Spořič obrazovky_ (`Super + Esc`), což ho vynutí nahoru, i když jste spořič při nečinnosti vypnuli. Ve výchozím nastavení k němu není přiřazena žádná klávesová zkratka.

`omarchy toggle screensaver` vypíná ten při nečinnosti, pokud chcete raději jít rovnou z práce na zamčenou obrazovku. Zavře ho jakákoli klávesa, kliknutí, posun nebo pohyb myši.

Logo, které kreslí, si můžete změnit pod _Vzhled > Branding > Spořič obrazovky_. Nahrajte png nebo svg a Omarchy ho převede do ASCII. Viz [branding](41-branding.md).

### Zamykací obrazovka

`Super + Ctrl + L` zamkne stroj. To spustí zamykací obrazovku ze shellu Omarchy, zhasne displej, resetuje rozložení klávesnice na první, abyste nepsali heslo ve špatné abecedě, a — pokud ho máte spuštěný — cestou ven zamkne 1Password.

Zamykací obrazovka přijímá heslo a přijme i otisk prstu, jakmile si ho nastavíte. To a další způsoby ověřování pokrývá [hardwarové ověřování](37-hardware-authentication.md).
