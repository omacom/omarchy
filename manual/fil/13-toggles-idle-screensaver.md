# Mga Toggle, Idle at ang Screensaver

Marami sa binabago mo araw-araw ay hindi talaga setting. Mode ito na ino-on mo sa loob ng isang oras at ino-off ulit pagkatapos: night light habang nagtatrabaho ka nang gabi na, do not disturb habang nagpe-present ka, stay awake habang may pinapanood ka. Tinatawag itong mga toggle ng Omarchy, at pare-pareho ang paggana ng lahat ng ito — isang hotkey, isang entry sa menu, at isang command, na lahat ay tumatama sa iisang switch.

### Ang toggle menu

Binubuksan ng `Super + Ctrl + O` ang _Trigger > Toggle_ nang direkta, o maaari kang maglakad papunta roon mula sa menu ng Omarchy (`Super + Space`). Switch ang lahat ng nasa listahang iyon na maaari mong i-flip nang hindi iniisip kung saan nakatira ang state. Katabi nito ang mga switch para sa hitsura ng desktop, sa ilalim ng _Appearance_.

Mula sa terminal, ang parehong mga switch ay `omarchy toggle <thing>`. Patakbuhin ang `omarchy toggle` nang mag-isa para makita ang buong grupo.

| Toggle | Hotkey | Command |
| ------ | ------ | ------- |
| Night light | — | `omarchy toggle nightlight` |
| Patahimikin ang mga notification | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Manatiling gising (walang idle lock) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Crash capture | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) theme sync | — | `omarchy toggle theme sync` |
| Menu bar | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Touchscreen | — | `omarchy toggle touchscreen` |
| Suspend | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Ang mga switch ng touchpad, touchscreen, at hybrid GPU ay nakatira sa ilalim ng _Trigger > Hardware_ (`Super + Ctrl + H`) sa halip na sa ilalim ng Toggle, dahil lumalabas lang ang mga ito kapag mayroon ka talaga ng hardware na iyon. Nabubuhay ang mga switch ng touchpad at touchscreen kahit mag-reload ang Hyprland — sine-save ang pangalan ng naka-disable na device sa isang maliit na state file na binabasa ng Hyprland sa startup para i-disable ito ulit.

Hawak ng _Appearance_ ang menu bar at mga animation, pati ang ilang bagay na hindi mga command na `omarchy toggle` pero pareho ang kilos: porsyento ng baterya sa bar, ang default na layout ng workspace, at sa ilalim ng _Windows_, ang mga gap ng window (`Super + Shift + Backspace`) at ang 1-window square aspect (`Super + Ctrl + Backspace`).

Flag file lang ang karamihan sa mga ito sa ilalim ng `~/.local/state/omarchy/toggles/`. Kung gusto mong mag-branch sa isa sa mga ito sa isang script, binibigyan ka ng `omarchy-toggle-enabled` ng exit code sa halip na paghanapin ka pa:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Pinangalanan ang mga flag para sa off state — `screensaver-off`, `suspend-off`, `bar-off` — kaya ang presensya ng mga ito ay nangangahulugang naka-disable ang feature.

### Mga indicator sa bar

Kapag naka-on ang isang mode, makakakuha ka ng maliit na glyph sa gitna ng top bar sa tabi ng orasan. Iyon ang indicators widget, at dala nito ang dictation, screen recording, mga pending na reminder, night light, do not disturb, at stay awake.

Nakatago ang mga hindi aktibong indicator. Mag-hover kahit saan sa bar at unti-unti silang lilitaw nang malabo, para ma-click mo ang isa para i-on ito nang hindi nalalaman ang hotkey nito. Ang pag-click sa aktibo ay mag-o-off ulit nito. Kung mas gusto mong makita silang lahat sa lahat ng oras, itakda ang `alwaysShow` sa `true` sa entry na `omarchy.indicators` sa `~/.config/omarchy/shell.json` — tingnan ang [ang top bar](05-the-top-bar.md) para sa kung paano kino-configure ang mga widget ng bar.

### Night light

Pinapainit ng night light ang screen sa 4000K, at ang pag-toggle ulit nito ay ibinabalik ito sa 6500K. I-flip ito mula sa toggle menu (`Super + Ctrl + O`) o gamit ang `omarchy toggle nightlight`. Pinapatakbo ito ng hyprsunset, na sisimulan ng toggle para sa iyo kung hindi pa ito tumatakbo.

Bilang default, wala talagang ginagawa ang hyprsunset sa screen mo. Kasama ng `~/.config/hypr/hyprsunset.conf` ang isang identity profile nang tiyak para manatiling hindi nagagalaw ang display hanggang humingi ka ng init. Kung mas gusto mong mag-switch ito ayon sa orasan, palitan iyon ng time profile:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Pagkatapos ay simulan ang hyprsunset sa login sa pamamagitan ng pagdaragdag ng `o.launch_on_start("hyprsunset")` sa `~/.config/hypr/autostart.lua`. Fixed ang pares na 4000K/6500K na ginagamit ng toggle, kaya ang config file ang pupuntahan mo kung gusto mo ng ibang temperatura.

### Do not disturb

Pinapatahimik ng `Super + Ctrl + Alt + ,` ang mga notification. Walang toast na lilitaw habang naka-on ito, at nakaupo sa bar ang indicator ng kampanang may ekis para ipaalala sa iyo kung bakit tumahimik ang desktop.

Wala namang nawawala, gayunpaman. Hinahawakan muna ang mga pinatahimik na notification: ibalik ang huling ilan sa screen gamit ang `Super + Shift + Alt + ,`. Tingnan ang [mga notice](10-notices.md) para sa iba pa.

Dalawang uri ng mensahe ang nakakalusot pa rin: ang sariling mga confirmation toast ng Omarchy para sa isang bagay na kakagawa mo lang ("Theme changed", "Screenshot saved"), at mga critical alert na ipinadala mula sa command line. Hindi kwalipikado ang mga chat app na minamarkahang critical ang lahat para pilitin ang daan nila sa harap mo.

### Idle

Pag-aari ng shell ng Omarchy ang idle behavior, at ang mga timing ay isang top-level na `idle` block sa `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Parehong segundo ang dalawang numero na binibilang mula sa sandaling naging idle ka — hindi mula sa isa't isa. Kaya sa mga default, lalabas ang screensaver pagkatapos ng dalawa at kalahating minuto at aagaw ang lock screen sa limang minuto, tumakbo man ang screensaver o hindi. I-save ang file at agad kukunin ng shell ang mga bagong timing.

Kung i-dismiss mo ang screensaver bago ang deadline ng lock, binibilang iyon bilang activity at makakansela ang nakabinbing lock. Hindi ka mala-lock out dahil lang sumilip ka sa machine mo.

Para tuluyang ihinto ang pag-lock sa idle, ino-on ng `Super + Ctrl + I` — o `omarchy toggle idle` — ang stay awake, at lilitaw sa bar ang indicator ng tasa ng kape. Iyon ang pipindutin mo bago ang mahabang presentation o isang build na gusto mong panoorin. Pindutin itong muli para bumalik sa normal. Ini-print ng `omarchy toggle idle status` ang kasalukuyang state bilang JSON kung kailangan mo ito mula sa isang script.

Tungkol ito sa pag-lock at sa screensaver, hindi sa power. May sariling setup ang suspend at hibernation sa [pag-sleep ng system](36-system-sleep.md).

### Ang screensaver

Ang screensaver ng Omarchy ay ASCII art na dumadaan sa mga random na text effect, isang instance bawat monitor. Anumang key o paggalaw ng mouse ay lumalabas dito.

Maaari mo itong simulan kapag gusto mo mula sa _System > Screensaver_ (`Super + Esc`), na pipilitin itong umakyat kahit naka-off mo ang idle screensaver. Walang hotkey na naka-bind dito bilang default.

Ang `omarchy toggle screensaver` ang nag-o-off sa idle na isa, kung mas gusto mong dumiretso mula sa pagtatrabaho papunta sa naka-lock. Kailangan nito ng terminal na alam nitong i-configure — Alacritty, Foot, Ghostty, o Kitty — at sasabihin nito sa iyo kung iba ang default na terminal mo.

Sa iyo ang logo na iginuguhit nito para baguhin, sa ilalim ng _Appearance > Branding > Screensaver_. Mag-upload ng png o svg at iko-convert ito ng Omarchy sa ASCII. Tingnan ang [branding](41-branding.md).

### Ang lock screen

Ni-lo-lock ng `Super + Ctrl + L` ang machine. Pinapatakbo niyon ang lock screen mula sa shell ng Omarchy, bina-blank ang display, nire-reset ang layout ng keyboard mo sa una para hindi mo mata-type ang password mo sa maling alpabeto, at — kung pinapatakbo mo ito — ni-lo-lock ang 1Password palabas.

Tumatanggap ang lock screen ng password, at tatanggapin din nito ang fingerprint kapag nakapag-set up ka na ng isa. Iyon, at ang iba pang paraan para mag-authenticate, ay sakop sa [pag-authenticate gamit ang hardware](37-hardware-authentication.md).
