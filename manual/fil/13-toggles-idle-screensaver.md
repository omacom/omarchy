# Mga Toggle, Idle at ang Screensaver

Marami sa mga binabago mo araw-araw ay hindi talaga setting. Isa itong mode na ini-on mo sa loob ng isang oras at ini-off ulit: ilaw-panggabi habang nagtatrabaho ka nang hatinggabi, do not disturb habang nagpe-presenta ka, manatiling gising habang may pinapanood ka. Tinatawag ng Omarchy ang mga iyon na mga toggle, at lahat sila ay gumagana sa parehong paraan — isang hotkey, isang entry sa menu, at isang command, lahat ay tumatama sa parehong switch.

### Ang menu ng toggle

Binubuksan ng `Super + Ctrl + O` ang _Mag-trigger > I-toggle_ nang diretso, o maaari kang maglakad papunta roon mula sa menu ng Omarchy (`Super + Space`). Lahat ng nasa listahang iyon ay isang switch na maaari mong i-flip nang hindi nag-iisip kung saan nakatira ang state. Ang mga switch para sa kung paano nagmumukha ang desktop ay nakaupo sa tabi nito, sa ilalim ng _Mag-trigger > Hitsura_.

Mula sa terminal, ang parehong mga switch ay `omarchy toggle <thing>`. Patakbuhin ang `omarchy toggle` nang mag-isa para makita ang buong grupo.

| Toggle | Hotkey | Command |
| ------ | ------ | ------- |
| Ilaw-panggabi | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Patahimikin ang mga notipikasyon | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Manatiling gising (walang idle lock) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Pagsagap ng crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| Sync ng tema ng [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Menu bar | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Touchscreen | — | `omarchy toggle touchscreen` |
| I-suspend | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Ang mga switch ng touchpad, touchscreen, at hybrid GPU ay nakatira sa ilalim ng _Mag-trigger > Hardware_ (`Super + Ctrl + H`) sa halip ng sa ilalim ng Toggle, dahil lumalabas lang ang mga ito kapag talagang mayroon kang hardware na iyon. Ang mga sa touchpad at touchscreen ay nabubuhay pagkatapos ng isang Hyprland reload — ang pangalan ng naka-disable na device ay sine-save sa isang maliit na state file na binabasa ng Hyprland sa startup para i-disable ito ulit.

Hawak ng _Mag-trigger > Hitsura_ ang menu bar at mga animation, plus ilang bagay na hindi mga command na `omarchy toggle` ngunit kumikilos nang pareho: porsyento ng baterya sa bar, ang default na layout ng workspace, pagitan ng bintana (`Super + Shift + Backspace`), at ang 1-window square aspect (`Super + Ctrl + Backspace`).

Karamihan sa mga ito ay isa lang flag file sa ilalim ng `~/.local/state/omarchy/toggles/`. Kung gusto mong mag-branch sa isa sa isang script, binibigyan ka ng `omarchy-toggle-enabled` ng isang exit code sa halip na pilitin kang maghanap:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Ang mga flag ay pinapangalanan para sa off state — `screensaver-off`, `suspend-off`, `bar-off` — kaya ang kanilang presensya ay nangangahulugang naka-disable ang feature.

### Mga indikator sa bar

Kapag naka-on ang isang mode, makakakuha ka ng isang maliit na glyph sa gitna ng top bar sa tabi ng orasan. Iyon ang widget ng mga indikator, at dala nito ang diktasyon, pag-record ng screen, mga nakabinbing paalala, ilaw-panggabi, do not disturb, at manatiling gising.

Nakatago ang mga hindi aktibong indikator. I-hover ang lugar sa paligid ng mga ito at lalabo silang lalabas, kaya maaari mong i-click ang isa para i-on ito nang hindi alam ang hotkey nito. Ang pag-click sa isang aktibo ay ini-off ito ulit. Kung mas gusto mong makita silang lahat sa lahat ng oras, itakda ang `alwaysShow` sa `true` sa entry na `omarchy.indicators` sa `~/.config/omarchy/shell.json` — tingnan ang [top bar](05-the-top-bar.md) para sa kung paano nako-configure ang mga widget ng bar.

### Ilaw-panggabi

Pinaiinit ng `Super + Ctrl + N` ang screen sa 4000K, at ang pagpindot ulit dito ay ibinabalik ito sa 6500K. Hinimok ito ng hyprsunset, na sinisimulan ng toggle para sa iyo kung hindi pa ito tumatakbo.

Bilang default, walang ginagawa ang hyprsunset sa iyong screen. Ang `~/.config/hypr/hyprsunset.conf` ay ipinapadala na may identity profile nang tiyak para manatiling hindi nagagalaw ang display hanggang humingi ka ng init. Kung mas gusto mong lumipat ito ayon sa orasan, palitan iyon ng isang time profile:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Pagkatapos ay simulan ang hyprsunset sa login sa pamamagitan ng pagdaragdag ng `o.launch_on_start("hyprsunset")` sa `~/.config/hypr/autostart.lua`. Ang pares na 4000K/6500K na ginagamit ng toggle ay nakapirmi, kaya ang config file ang pupuntahan mo kung gusto mo ng ibang temperatura.

### Do not disturb

Pinatatahimik ng `Super + Ctrl + ,` ang mga notipikasyon. Walang mga toast na lalabas habang naka-on ito, at ang naka-cross-out na indikator ng kampana ay nakaupo sa bar para ipaalala sa iyo kung bakit tumahimik ang desktop.

Wala namang nawawala. Ang isang pinatahimik na notipikasyon ay direktang isinusulat sa iyong kasaysayan ng notipikasyon, na siyang eksaktong tala na gusto mo kapag bumalik ka at nagtataka kung ano ang nalampasan mo. Buksan ito gamit ang `Super + Shift + Alt + ,`. Tingnan ang [mga notice](10-notices.md) para sa natitirang bahagi ng kuwento ng notipikasyon.

Dalawang uri ng mensahe ang nakakalusot pa rin: ang sariling mga confirmation toast ng Omarchy para sa isang bagay na ginawa mo lang ("Theme changed", "Screenshot saved"), at mga critical alert na ipinadala mula sa command line. Ang mga chat app na minamarkahang critical ang lahat para piliting makapasok sa harap mo ay hindi kwalipikado.

### Idle

Ang shell ng Omarchy ang nagmamay-ari ng idle behavior, at ang mga timing ay isang top-level na `idle` block sa `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ang dalawang numero ay mga segundong binibilang mula sa sandaling naging idle ka — hindi mula sa isa't isa. Kaya sa mga default, lumalabas ang screensaver pagkatapos ng dalawa at kalahating minuto at ang lock screen ang pumapalit sa limang minuto, tumakbo man o hindi ang screensaver. I-save ang file at agad na kukunin ng shell ang mga bagong timing.

Kung idi-dismiss mo ang screensaver bago ang deadline ng lock, binibilang iyon bilang aktibidad at kinakansela ang nakabinbing lock. Hindi ka mai-lock out dahil sa pagsulyap sa iyong makina.

Para lubusang ihinto ang pag-lock kapag idle, ini-on ng `Super + Ctrl + I` — o `omarchy toggle idle` — ang manatiling gising, at lumalabas ang indikator ng tasa ng kape sa bar. Iyan ang pipindutin bago ang isang mahabang presentasyon o isang build na gusto mong panoorin. Pindutin ito ulit para bumalik sa normal. Ini-print ng `omarchy toggle idle status` ang kasalukuyang state bilang JSON kung kailangan mo ito mula sa isang script.

Ito ay tungkol sa pag-lock at sa screensaver, hindi sa power. Ang suspend at hibernation ay may sariling setup sa [pagtulog ng sistema](36-system-sleep.md).

### Ang screensaver

Ang screensaver ng Omarchy ay ASCII art na tumatakbo sa mga random na text effect, isang instance bawat monitor. Ang anumang key o paggalaw ng mouse ay lumalabas dito.

Maaari mo itong simulan on demand mula sa _Sistema > Screensaver_ (`Super + Esc`), na pumipilit ditong lumabas kahit na-off mo ang idle screensaver. Walang hotkey na naka-bind dito bilang default.

Ang `omarchy toggle screensaver` ang nag-o-off sa idle, kung mas gusto mong dumiretso mula sa pagtatrabaho papunta sa naka-lock. Kailangan nito ng isang terminal na alam nitong i-configure — Alacritty, Foot, Ghostty, o Kitty — at sasabihin nito sa iyo kung ang default mong terminal ay iba.

Ang logo na iginuguhit nito ay sa iyo para baguhin, sa ilalim ng _Estilo > Screensaver_. Mag-upload ng isang png o svg at iko-convert ito ng Omarchy sa ASCII. Tingnan ang [branding](41-branding.md).

### Ang lock screen

Ini-lock ng `Super + Ctrl + L` ang makina. Pinapatakbo niyon ang lock screen mula sa shell ng Omarchy, bina-blank ang display, nire-reset ang layout ng iyong keyboard sa una para hindi mo ma-type ang iyong password sa maling alpabeto, at — kung tumatakbo ito sa iyo — ini-lock ang 1Password paglabas.

Tumatanggap ang lock screen ng isang password, at tatanggap din ito ng fingerprint kapag nakapag-setup ka na. Iyon, at ang iba pang mga paraan para mag-authenticate, ay tinatalakay sa [authentication ng hardware](37-hardware-authentication.md).
