# Mga Toggle, Idle at ang Screensaver

Marami sa binabago mo araw-araw ay hindi talaga setting. Isa itong mode na bubuksan mo nang isang oras at isasara ulit: night light habang nagtatrabaho ka nang gabi na, do not disturb habang nagpi-present ka, manatiling gising habang may pinapanood ka. Toggle ang tawag ng Omarchy sa mga iyan, at pare-pareho ang paggana ng lahat — isang hotkey, isang entry sa menu, at isang command, lahat tumatama sa iisang switch.

### Ang menu ng toggle

Binubuksan ng `Super + Ctrl + O` ang _Trigger > Toggle_ nang direkta, o maaari kang maglakad papunta roon mula sa menu ng Omarchy (`Super + Space`). Lahat ng nasa listahang iyon ay switch na maaari mong i-flip nang hindi iniisip kung saan nakatira ang state. Ang mga switch para sa hitsura ng desktop ay katabi nito, sa ilalim ng _Appearance_.

Mula sa terminal, ang parehong mga switch ay `omarchy toggle <thing>`. Patakbuhin ang `omarchy toggle` nang mag-isa para makita ang buong grupo.

| Toggle | Hotkey | Utos |
| ------ | ------ | ------- |
| Ilaw pang-gabi | — | `omarchy toggle nightlight` |
| Patahimikin ang mga notification | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Manatiling gising (walang idle lock) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Pagkuha ng crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| Pag-sync ng tema ng [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Menu bar | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Touchscreen | — | `omarchy device touchscreen` |
| Suspend | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Ang mga switch ng touchpad, touchscreen, at hybrid GPU ay nasa ilalim ng _Trigger > Hardware_ (`Super + Ctrl + H`) sa halip na sa ilalim ng Toggle, dahil lumalabas lang ang mga ito kapag mayroon ka talagang ganoong hardware. Nakaligtas sa Hyprland reload ang mga switch ng touchpad at touchscreen — sine-save ang pangalan ng naka-disable na device sa isang maliit na state file na binabasa ng Hyprland sa startup para i-disable ulit ito.

Nasa _Appearance_ ang menu bar at mga animation, kasama ang ilang bagay na hindi mga command na `omarchy toggle` pero pareho ang kilos: ang porsyento ng baterya sa bar, ang default na layout ng workspace, at sa ilalim ng _Windows_, ang mga gap ng window (`Super + Shift + Backspace`) at ang 1-window square aspect (`Super + Ctrl + Backspace`).

Kapag walang magamit na GPU ang Hyprland para mag-draw at sa CPU ito nagre-render sa halip (llvmpipe), gaya sa mga Mac na hindi pa suportado ang GPU, sa karamihan ng mga virtual machine, o kapag nabigong mag-load ang isang graphics driver, pinapatay ng Omarchy ang mga animation, blur at shadow para sa session na iyon at sinasabi sa iyo nang isang beses sa pamamagitan ng notification. Ibinabalik sila ng _Appearance > Animations On_, at naaalala iyon ng Omarchy para sa mga susunod na session din.

Karamihan sa mga ito ay flag file lang sa ilalim ng `~/.local/state/omarchy/toggles/`. Kung gusto mong mag-branch sa isa sa script, binibigyan ka ng `omarchy-toggle-enabled` ng exit code sa halip na paghanapin ka:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Pinangalanan ang mga flag para sa off na state — `screensaver-off`, `suspend-off`, `bar-off` — kaya ang presensya nila ay nangangahulugang naka-disable ang feature.

### Mga indicator sa bar

Kapag naka-on ang isang mode, makakakuha ka ng maliit na glyph sa gitna ng top bar sa tabi ng orasan. Iyon ang widget ng mga indicator, at dala nito ang dictation, screen recording, mga pending na paalala, night light, do not disturb, at stay awake.

Nakatago ang mga hindi aktibong indicator. Mag-hover kahit saan sa bar at magfe-fade in sila nang dimmed, para maaari mong i-click ang isa para buksan ito nang hindi alam ang hotkey nito. Ang pag-click sa aktibo ay magsasara ulit dito. Kung mas gusto mong makita silang lahat palagi, itakda ang `alwaysShow` sa `true` sa entry na `omarchy.indicators` sa `~/.config/omarchy/shell.json` — tingnan ang [ang top bar](05-the-top-bar.md) para sa kung paano kino-configure ang mga widget ng bar.

### Ilaw pang-gabi

Pinapainit ng night light ang screen sa 4000K, at ang pag-toggle ulit dito ay ibinabalik ito sa 6500K. I-flip ito mula sa menu ng toggle (`Super + Ctrl + O`) o gamit ang `omarchy toggle nightlight`. Pinapatakbo ito ng hyprsunset, na sinisimulan ng toggle para sa iyo kung hindi pa ito tumatakbo.

Bilang default, wala talagang ginagawa ang hyprsunset sa screen mo. May kasamang identity profile ang `~/.config/hypr/hyprsunset.conf` nang tiyak para manatiling hindi nagagalaw ang display hanggang humingi ka ng init. Kung mas gusto mong magpalit ito ayon sa orasan, palitan iyon ng time profile:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Pagkatapos ay simulan ang hyprsunset sa login sa pamamagitan ng pagdagdag ng `o.launch_on_start("hyprsunset")` sa `~/.config/hypr/autostart.lua`. Naka-fix ang pares na 4000K/6500K na ginagamit ng toggle, kaya ang config file ang pupuntahan mo kung gusto mo ng ibang temperatura.

### Huwag istorbohin

Pinatatahimik ng `Super + Ctrl + Alt + ,` ang mga notification. Walang toast na lalabas habang naka-on ito, at nakaupo sa bar ang indicator ng kampanang may ekis para ipaalala sa iyo kung bakit tumahimik ang desktop.

Walang nawawala, gayunman. Hinahawakan muna ang mga pinatahimik na notification: ibalik ang huling ilan sa screen gamit ang `Super + Shift + Alt + ,`. Tingnan ang [mga notice](10-notices.md) para sa iba pa.

Dalawang uri ng mensahe ang nakakalusot pa rin: ang sariling mga toast ng kumpirmasyon ng Omarchy para sa bagay na ginawa mo lang ("Theme changed", "Screenshot saved"), at mga critical alert na ipinadala mula sa command line. Hindi kwalipikado ang mga chat app na minamarkahan ang lahat bilang critical para pilitin ang daan nila sa harap mo.

### Idle

Ang shell ng Omarchy ang nagmamay-ari ng kilos ng idle, at ang mga timing ay isang top-level na `idle` block sa `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Parehong bilang ay mga segundo na binibilang mula sa sandaling naging idle ka — hindi mula sa isa't isa. Kaya sa mga default, lalabas ang screensaver pagkalipas ng dalawa't kalahating minuto at aagaw ang lock screen sa limang minuto, nag-run man ang screensaver o hindi. I-save ang file at kukunin agad ng shell ang mga bagong timing.

Kung i-dismiss mo ang screensaver bago ang deadline ng lock, binibilang iyon bilang activity at makakansela ang pending na lock. Hindi ka mala-lock out dahil lang sumilip ka sa machine mo.

Para tumigil nang tuluyan sa pag-lock sa idle, binubuksan ng `Super + Ctrl + I` — o `omarchy toggle idle` — ang stay awake, at lalabas sa bar ang indicator ng tasa ng kape. Iyon ang pipindutin bago ang mahabang presentation o build na gusto mong panoorin. Pindutin ulit para bumalik sa normal. Ini-print ng `omarchy toggle idle status` ang kasalukuyang state bilang JSON kung kailangan mo ito mula sa script.

Tungkol ito sa pag-lock at screensaver, hindi sa power. Ang suspend at hibernation ay may sarili nilang setup sa [tulog ng system](36-system-sleep.md).

### Ang screensaver

Ang screensaver ng Omarchy ay ASCII art na tumatakbo sa random na mga text effect, isang instance bawat monitor. Anumang key o galaw ng mouse ay lumalabas dito.

Maaari mo itong simulan on demand mula sa _System > Screensaver_ (`Super + Esc`), na pinipilit itong lumabas kahit pinatay mo pa ang idle screensaver. Walang hotkey na naka-bind dito bilang default.

Ang `omarchy toggle screensaver` ang nagpapatay sa idle, kung mas gusto mong dumiretso mula sa pagtatrabaho patungong naka-lock. Anumang key, click, scroll o galaw ng mouse ay nagsasara dito.

Ang logo na dine-draw nito ay sa iyo para baguhin, sa ilalim ng _Appearance > Branding > Screensaver_. Mag-upload ng png o svg at iko-convert ito ng Omarchy sa ASCII. Tingnan ang [branding](41-branding.md).

### Ang lock screen

Ni-lo-lock ng `Super + Ctrl + L` ang machine. Pinapatakbo nito ang lock screen mula sa shell ng Omarchy, bina-blank ang display, nire-reset ang layout ng keyboard mo sa una para hindi ka nagta-type ng password mo sa maling alpabeto, at — kung pinapatakbo mo ito — ni-lo-lock ang 1Password palabas.

Tumatanggap ang lock screen ng password, at tatanggap din ito ng fingerprint kapag nakapag-set up ka na ng isa. Iyon, at ang iba pang paraan para mag-authenticate, ay sakop sa [pagpapatunay sa hardware](37-hardware-authentication.md).
