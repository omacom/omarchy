# Mga Toggle, Idle at ang Screensaver

Marami sa binabago mo araw-araw ay hindi talaga setting. Isa itong mode na binubuksan mo nang isang oras at pinapatay ulit: night light habang nagtatrabaho ka nang gabi, do not disturb habang nagpe-present ka, stay awake habang may pinapanood ka. Tinatawag iyon ng Omarchy na mga toggle, at pare-pareho ang paggana ng lahat ng iyon — isang hotkey, isang entry sa menu, at isang command, lahat tumatama sa iisang switch.

### Ang menu ng toggle

Binubuksan ng `Super + Ctrl + O` ang _Trigger > Toggle_ nang direkta, o maaari kang maglakad papunta roon mula sa menu ng Omarchy (`Super + Space`). Lahat ng nasa listahang iyon ay switch na maaari mong i-flip nang hindi iniisip kung saan nakatira ang state. Katabi nito ang mga switch para sa hitsura ng desktop, sa ilalim ng _Appearance_.

Mula sa terminal, ang parehong mga switch ay `omarchy toggle <thing>`. Patakbuhin ang `omarchy toggle` nang mag-isa upang makita ang buong grupo.

| Toggle | Hotkey | Command |
| ------ | ------ | ------- |
| Night light | — | `omarchy toggle nightlight` |
| Patahimikin ang mga notification | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Manatiling gising (walang idle lock) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Crash capture | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| Pag-sync ng tema ng [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Menu bar | `Super + Shift + Space` | `omarchy toggle bar` |
| Full screen na desktop (walang bar, walang gaps) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Mga animation, blur at shadow | — | `omarchy toggle animations` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Touchscreen | — | `omarchy device touchscreen` |
| Suspend | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy device gpu hybrid` |

Ang mga switch ng touchpad, touchscreen, at hybrid GPU ay nakatira sa ilalim ng _Trigger > Hardware_ (`Super + Ctrl + H`) sa halip na sa ilalim ng Toggle, dahil lumalabas lang ang mga iyon kapag talagang mayroon kang ganoong hardware. Nakaligtas sa Hyprland reload ang mga switch ng touchpad at touchscreen — sine-save ang pangalan ng naka-disable na device sa isang maliit na state file na binabasa ng Hyprland sa startup upang i-disable ulit ito.

Hawak ng _Appearance_ ang menu bar at mga animation, kasama ang ilang bagay na hindi mga command na `omarchy toggle` pero pareho ang kilos: porsyento ng baterya sa bar, ang default na layout ng workspace, at sa ilalim ng _Windows_, mga gap ng window (`Super + Shift + Backspace`) at ang 1-window square aspect (`Super + Ctrl + Backspace`).

Kapag walang GPU ang Hyprland na magagamit sa pagguhit at nagre-render ito sa CPU sa halip (llvmpipe), tulad sa mga Mac na hindi pa suportado ang GPU, sa karamihan ng mga virtual machine, o kapag nabigong mag-load ang isang graphics driver, pinapatay ng Omarchy ang mga animation, blur at shadow para sa session na iyon at sinasabi sa iyo iyon nang isang beses sa pamamagitan ng notification. Ibinabalik iyon ng _Appearance > Animations On_, at naaalala iyon ng Omarchy para rin sa mga susunod na session.

Karamihan sa mga ito ay flag file lang sa ilalim ng `~/.local/state/omarchy/toggles/`. Kung gusto mong mag-branch sa isa sa isang script, binibigyan ka ng `omarchy-toggle-enabled` ng exit code sa halip na paghanapin ka:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Pinangalanan ang mga flag para sa off state — `screensaver-off`, `suspend-off`, `bar-off` — kaya ang presensya ng mga iyon ay nangangahulugang naka-disable ang feature.

### Mga indicator sa bar

Kapag naka-on ang isang mode, makakakuha ka ng maliit na glyph sa gitna ng top bar sa tabi ng orasan. Iyon ang indicators widget, at dala nito ang screen recording, mga pending na paalala, night light, do not disturb, at stay awake, kasama ang mga babala habang naka-on ang passwordless sudo o may nakakonekta sa isang remote session.

Nakatago ang mga hindi aktibong indicator. Mag-hover kahit saan sa bar at magfe-fade in ang mga iyon nang dimmed, para maaari mong i-click ang isa upang buksan ito nang hindi alam ang hotkey nito. Ang pag-click sa aktibong isa ay magpapatay ulit dito. Kung mas gusto mong makita ang lahat ng iyon sa lahat ng oras, itakda ang `alwaysShow` sa `true` sa entry na `omarchy.indicators` sa `~/.config/omarchy/shell.json` — tingnan ang [ang top bar](05-the-top-bar.md) para sa kung paano kino-configure ang mga widget ng bar.

### Night light

Pinapainit ng night light ang screen sa 4000K, at ang pag-toggle ulit dito ay ibinabalik ito sa 6500K. I-flip ito mula sa menu ng toggle (`Super + Ctrl + O`) o gamit ang `omarchy toggle nightlight`. Pinatatakbo ito ng hyprsunset, na sinisimulan ng toggle para sa iyo kung hindi pa ito tumatakbo.

Bilang default, wala talagang ginagawa ang hyprsunset sa screen mo. Ang `~/.config/hypr/hyprsunset.conf` ay may kasamang identity profile nang tiyak para manatiling hindi nagagalaw ang display hanggang humingi ka ng init. Kung mas gusto mong magpalit ito ayon sa orasan, palitan iyon ng time profile:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Pagkatapos ay simulan ang hyprsunset sa login sa pamamagitan ng pagdagdag ng `o.launch_on_start("hyprsunset")` sa `~/.config/hypr/autostart.lua`. Naka-fix ang pares na 4000K/6500K na ginagamit ng toggle, kaya ang config file ang pupuntahan mo kung gusto mo ng ibang temperatura.

### Do not disturb

Pinatatahimik ng `Super + Ctrl + Alt + ,` ang mga notification. Walang toast na lalabas habang naka-on ito, at nakaupo sa bar ang indicator ng kampanang may ekis upang ipaalala sa iyo kung bakit tumahimik ang desktop.

Pero walang nawawala. Hinohold back ang mga pinatahimik na notification: ibalik ang huling ilan sa screen gamit ang `Super + Shift + Alt + ,`. Tingnan ang [mga notice](10-notices.md) para sa iba pa.

Tatlong uri ng mensahe ang nakakalusot pa rin: ang sariling mga confirmation toast ng Omarchy para sa isang bagay na kakagawa mo lang ("Theme changed", "Screenshot saved"), mga critical alert na ipinadala mula sa command line, at mga verification code. Hindi kwalipikado ang mga chat app na minamarkahan ang lahat bilang critical upang pilitin ang kanilang daan sa harap mo.

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

Parehong bilang ay segundong binibilang mula sa sandaling naging idle ka — hindi mula sa isa't isa. Kaya sa mga default, lumalabas ang screensaver pagkatapos ng dalawa at kalahating minuto at nangunguna ang lock screen sa limang minuto, tumakbo man o hindi ang screensaver. I-save ang file at kukunin agad ng shell ang mga bagong timing.

Kung idi-dismiss mo ang screensaver bago ang deadline ng lock, binibilang iyon bilang activity at makakansela ang nakabinbing lock. Hindi ka mala-lock out dahil lang sumilip ka sa machine mo.

Upang ihinto nang buo ang pag-lock sa idle, binubuksan ng `Super + Ctrl + I` — o `omarchy toggle idle` — ang stay awake, at lumalabas sa bar ang indicator ng tasa ng kape. Iyon ang pipindutin bago ang mahabang presentation o isang build na gusto mong panoorin. Pindutin ulit ito upang bumalik sa normal. Ini-print ng `omarchy toggle idle status` ang kasalukuyang state bilang JSON kung kailangan mo ito mula sa isang script.

Tungkol ito sa pag-lock at sa screensaver, hindi sa power. Ang suspend at hibernation ay may sariling setup sa [pagtulog ng system](36-system-sleep.md).

### Ang screensaver

Ang screensaver ng Omarchy ay ASCII art na tumatakbo sa pamamagitan ng mga random na text effect, isang instance bawat monitor. Anumang key o galaw ng mouse ay magpapalabas dito.

Maaari mo itong simulan on demand mula sa _System > Screensaver_ (`Super + Esc`), na pinipilit itong lumabas kahit pinatay mo ang idle screensaver. Walang hotkey na naka-bind dito bilang default.

Ang `omarchy toggle screensaver` ang nagpapatay sa idle na isa, kung mas gusto mong dumiretso mula sa pagtatrabaho patungo sa naka-lock. Anumang key, click, scroll o galaw ng mouse ay nagsasara dito.

Ang logo na iginuguhit nito ay sa iyo upang baguhin, sa ilalim ng _Appearance > Branding > Screensaver_. Mag-upload ng png o svg at iko-convert ito ng Omarchy sa ASCII. Tingnan ang [branding](41-branding.md).

### Ang lock screen

Nilolock ng `Super + Ctrl + L` ang machine. Pinapatakbo niyon ang lock screen mula sa shell ng Omarchy, bina-blank ang display, nire-reset ang layout ng keyboard mo sa una para hindi mo tina-type ang password mo sa maling alpabeto, at — kung pinapatakbo mo ito — nilolock ang 1Password palabas.

Tumatanggap ang lock screen ng password, at tatanggap din ito ng fingerprint kapag nag-setup ka na ng isa. Iyon, at ang iba pang paraan upang mag-authenticate, ay saklaw sa [pagpapatunay ng hardware](37-hardware-authentication.md).
