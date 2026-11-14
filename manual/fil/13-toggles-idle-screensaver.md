# Mga Toggle, Idle at ang Screensaver

Marami sa binabago mo araw-araw ay hindi talaga setting. Isa itong mode na bubuksan mo sa loob ng isang oras at papatayin ulit: night light habang nagtatrabaho ka nang gabing-gabi, do not disturb habang nagpe-present ka, manatiling gising habang may pinapanood ka. Tinatawag iyan ng Omarchy na mga toggle, at pare-pareho ang paggana ng lahat ng iyon — isang hotkey, isang entry sa menu, at isang command, lahat tumatama sa iisang switch.

### Ang menu ng toggle

Direktang binubuksan ng `Super + Ctrl + O` ang _Trigger > Toggle_, o makakapunta ka roon sa paglalakad mula sa menu ng Omarchy (`Super + Space`). Lahat ng nasa listahang iyon ay switch na maaari mong i-flip nang hindi iniisip kung saan nakatira ang state. Katabi nito ang mga switch para sa hitsura ng desktop, sa ilalim ng _Appearance_.

Mula sa terminal, ang parehong mga switch ay `omarchy toggle <thing>`. Patakbuhin ang `omarchy toggle` nang mag-isa para makita ang buong grupo.

| Toggle | Hotkey | Command |
| ------ | ------ | ------- |
| Night light | — | `omarchy toggle nightlight` |
| Patahimikin ang mga notification | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Manatiling gising (walang idle lock) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Pag-capture ng crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) pag-sync ng tema | — | `omarchy toggle theme sync` |
| Menu bar | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Touchscreen | — | `omarchy toggle touchscreen` |
| Suspend | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Ang mga switch ng touchpad, touchscreen, at hybrid GPU ay nasa ilalim ng _Trigger > Hardware_ (`Super + Ctrl + H`) sa halip na sa ilalim ng Toggle, dahil lumalabas lang ang mga iyon kapag talagang mayroon kang ganoong hardware. Nakakaligtas sa isang Hyprland reload ang mga switch ng touchpad at touchscreen — sine-save ang pangalan ng na-disable na device sa isang maliit na state file na binabasa ng Hyprland sa startup para i-disable itong muli.

Hawak ng _Appearance_ ang menu bar at mga animation, pati ilang bagay na hindi mga command na `omarchy toggle` pero pareho ang kilos: ang porsyento ng baterya sa bar, ang default na layout ng workspace, at sa ilalim ng _Windows_, ang mga gap ng window (`Super + Shift + Backspace`) at ang 1-window square aspect (`Super + Ctrl + Backspace`).

Kapag walang GPU ang Hyprland na magagamit para mag-draw at sa CPU ito nagre-render sa halip (llvmpipe), gaya sa mga Mac na hindi pa suportado ang GPU, sa karamihan ng mga virtual machine, o kapag nabigong mag-load ang isang graphics driver, pinapatay ng Omarchy ang mga animation, blur at shadow para sa session na iyon at isang beses ka nitong sasabihan gamit ang isang notification. Ibinabalik sila ng _Appearance > Animations On_, at naaalala rin iyon ng Omarchy para sa mga susunod na session.

Karamihan sa mga ito ay isang flag file lang sa ilalim ng `~/.local/state/omarchy/toggles/`. Kung gusto mong mag-branch batay sa isa nito sa isang script, bibigyan ka ng `omarchy-toggle-enabled` ng exit code sa halip na paghanapin ka pa:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Pinapangalanan ang mga flag para sa off state — `screensaver-off`, `suspend-off`, `bar-off` — kaya ang presensya ng mga iyon ay nangangahulugang naka-disable ang feature.

### Mga indicator sa bar

Kapag naka-on ang isang mode, makakakuha ka ng maliit na glyph sa gitna ng top bar sa tabi ng orasan. Iyon ang indicators widget, at dala nito ang dictation, screen recording, mga nakabinbing paalala, night light, do not disturb, at manatiling gising.

Nakatago ang mga hindi aktibong indicator. Mag-hover kahit saan sa bar at magfe-fade in sila nang dimmed, kaya maaari mong i-click ang isa para buksan ito nang hindi alam ang hotkey nito. Ang pag-click sa isang aktibo ay magpapatay ulit dito. Kung mas gusto mong makita silang lahat sa lahat ng oras, itakda ang `alwaysShow` sa `true` sa entry na `omarchy.indicators` sa `~/.config/omarchy/shell.json` — tingnan ang [ang top bar](05-the-top-bar.md) para sa kung paano kino-configure ang mga widget ng bar.

### Night light

Pinapainit ng night light ang screen sa 4000K, at ang pag-toggle ulit dito ay ibinabalik ito sa 6500K. I-flip ito mula sa menu ng toggle (`Super + Ctrl + O`) o gamit ang `omarchy toggle nightlight`. Pinapagana ito ng hyprsunset, na sinisimulan ng toggle para sa iyo kung hindi pa ito tumatakbo.

Bilang default, wala talagang ginagawa ang hyprsunset sa screen mo. May kasamang identity profile ang `~/.config/hypr/hyprsunset.conf` nang tiyak para manatiling hindi nagagalaw ang display hanggang humingi ka ng init. Kung mas gusto mong magpalit ito batay sa orasan, palitan iyon ng isang time profile:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Pagkatapos ay simulan ang hyprsunset sa login sa pamamagitan ng pagdagdag ng `o.launch_on_start("hyprsunset")` sa `~/.config/hypr/autostart.lua`. Fixed ang pares na 4000K/6500K na ginagamit ng toggle, kaya ang config file ang pupuntahan mo kung gusto mo ng ibang temperature.

### Do not disturb

Pinapatahimik ng `Super + Ctrl + Alt + ,` ang mga notification. Walang toast na lilitaw habang naka-on ito, at nakaupo sa bar ang indicator na bell na may ekis para ipaalala sa iyo kung bakit tumahimik ang desktop.

Wala namang mawawala, gayunman. Hinohold back ang mga pinatahimik na notification: ibalik ang huling ilan sa screen gamit ang `Super + Shift + Alt + ,`. Tingnan ang [mga notice](10-notices.md) para sa iba pa.

Dalawang uri ng mensahe ang nakakalusot pa rin: ang sariling mga confirmation toast ng Omarchy para sa isang bagay na kakagawa mo lang ("Theme changed", "Screenshot saved"), at mga critical alert na ipinadala mula sa command line. Hindi kwalipikado ang mga chat app na ginagawang critical ang lahat para piliting makaharap sa iyo.

### Idle

Pagmamay-ari ng Omarchy shell ang idle behavior, at ang mga timing ay isang top-level na `idle` block sa `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Parehong segundo ang dalawang numero na binibilang mula sa sandaling naging idle ka — hindi mula sa isa't isa. Kaya sa mga default, lalabas ang screensaver pagkalipas ng dalawa at kalahating minuto at aagaw ang lock screen sa limang minuto, tumakbo man ang screensaver o hindi. I-save ang file at agad kukunin ng shell ang mga bagong timing.

Kung i-dismiss mo ang screensaver bago ang deadline ng lock, mabibilang iyon bilang activity at makakansela ang nakabinbing lock. Hindi ka mala-lock out dahil lang sinilip mo ang machine mo.

Para tuluyang ihinto ang pag-lock sa idle, ang `Super + Ctrl + I` — o `omarchy toggle idle` — ang nagbubukas sa stay awake, at lalabas sa bar ang indicator na tasa ng kape. Iyon ang pipindutin bago ang isang mahabang presentation o isang build na gusto mong panoorin. Pindutin itong muli para bumalik sa normal. Ini-print ng `omarchy toggle idle status` ang kasalukuyang state bilang JSON kung kailangan mo ito mula sa isang script.

Tungkol ito sa pag-lock at sa screensaver, hindi sa power. May sariling setup ang suspend at hibernation sa [system sleep](36-system-sleep.md).

### Ang screensaver

Ang screensaver ng Omarchy ay ASCII art na tumatakbo sa mga random na text effect, isang instance bawat monitor. Anumang key o galaw ng mouse ang magpapalabas dito.

Maaari mo itong simulan on demand mula sa _System > Screensaver_ (`Super + Esc`), na pipilitin itong lumabas kahit pinatay mo ang idle screensaver. Walang hotkey na nakabind dito bilang default.

Ang `omarchy toggle screensaver` ang nagpapatay sa idle na isa, kung mas gusto mong dumiretso mula sa pagtatrabaho patungo sa naka-lock. Anumang key, click, scroll o galaw ng mouse ang magsasara dito.

Ang logo na dino-draw nito ay sa iyo para baguhin, sa ilalim ng _Appearance > Branding > Screensaver_. Mag-upload ng png o svg at iko-convert ito ng Omarchy sa ASCII. Tingnan ang [branding](41-branding.md).

### Ang lock screen

Ang `Super + Ctrl + L` ang nagla-lock sa machine. Pinapatakbo niyon ang lock screen mula sa Omarchy shell, bina-blank ang display, nire-reset ang keyboard layout mo sa una para hindi mo mai-type ang password mo sa maling alpabeto, at — kung pinapatakbo mo ito — nila-lock ang 1Password palabas.

Tumatanggap ang lock screen ng password, at tatanggap din ito ng fingerprint kapag nakapag-set up ka na ng isa. Iyon, at ang iba pang paraan para mag-authenticate, ay sakop sa [hardware authentication](37-hardware-authentication.md).
