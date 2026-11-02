# Mga Toggle, Idle at ang Screensaver

Marami sa binabago mo araw-araw ay hindi talaga setting. Isa itong mode na bubuksan mo nang isang oras at isasara mo ulit: night light habang nagtatrabaho ka nang gabi na, do not disturb habang nagpe-present ka, manatiling gising habang may pinapanood ka. Toggles ang tawag ng Omarchy sa mga iyon, at iisa ang paraan ng paggana ng lahat ng mga ito — isang hotkey, isang entry sa menu, at isang command, na lahat ay tumatama sa iisang switch.

### Ang menu ng toggle

Direktang binubuksan ng `Super + Ctrl + O` ang _Trigger > Toggle_, o maaari kang maglakad papunta roon mula sa menu ng Omarchy (`Super + Space`). Lahat ng nasa listahang iyon ay switch na maaari mong i-flip nang hindi iniisip kung saan nakatira ang state. Katabi nito ang mga switch para sa hitsura ng desktop, sa ilalim ng _Appearance_.

Mula sa terminal, ang parehong mga switch ay `omarchy toggle <thing>`. Patakbuhin ang `omarchy toggle` nang mag-isa upang makita ang buong grupo.

| Toggle | Hotkey | Command |
| ------ | ------ | ------- |
| Night light | — | `omarchy toggle nightlight` |
| Patahimikin ang mga notification | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Manatiling gising (walang idle lock) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Pagkuha sa crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| Pag-sync ng tema ng [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Menu bar | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Touchscreen | — | `omarchy toggle touchscreen` |
| Suspend | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Ang mga switch ng touchpad, touchscreen, at hybrid GPU ay nakatira sa ilalim ng _Trigger > Hardware_ (`Super + Ctrl + H`) sa halip na sa ilalim ng Toggle, dahil lumalabas lang ang mga ito kapag talagang mayroon kang ganoong hardware. Nakakaligtas sa Hyprland reload ang sa touchpad at touchscreen — sine-save ang pangalan ng na-disable na device sa isang maliit na state file na binabasa ng Hyprland sa startup upang i-disable ito ulit.

Nasa _Appearance_ ang menu bar at mga animation, pati ang ilang bagay na hindi mga command na `omarchy toggle` pero ganito rin ang kilos: porsiyento ng baterya sa bar, ang default na layout ng workspace, at sa ilalim ng _Windows_, ang mga puwang sa window (`Super + Shift + Backspace`) at ang 1-window square aspect (`Super + Ctrl + Backspace`).

Karamihan sa mga ito ay flag file lang sa ilalim ng `~/.local/state/omarchy/toggles/`. Kung gusto mong mag-branch batay sa isa sa mga ito sa isang script, binibigyan ka ng `omarchy-toggle-enabled` ng exit code sa halip na pahanapin ka pa:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Pinangalanan ang mga flag para sa off na state — `screensaver-off`, `suspend-off`, `bar-off` — kaya ang presensya ng mga ito ay nangangahulugang naka-disable ang feature.

### Mga indicator sa bar

Kapag naka-on ang isang mode, makakakuha ka ng maliit na glyph sa gitna ng top bar sa tabi ng orasan. Iyon ang indicators widget, at dala nito ang dictation, screen recording, mga nakabinbing paalala, night light, do not disturb, at manatiling gising.

Nakatago ang mga hindi aktibong indicator. I-hover ang mouse kahit saan sa bar at lilitaw silang malabo, kaya maaari mong i-click ang isa upang buksan ito nang hindi alam ang hotkey nito. Ang pag-click sa isang aktibo ay magsasara nito ulit. Kung mas gusto mong makita silang lahat sa lahat ng oras, itakda ang `alwaysShow` sa `true` sa entry na `omarchy.indicators` sa `~/.config/omarchy/shell.json` — tingnan ang [ang top bar](05-the-top-bar.md) para sa kung paano kino-configure ang mga widget ng bar.

### Night light

Pinapainit ng night light ang screen sa 4000K, at ang pag-toggle dito ulit ay magbabalik nito sa 6500K. I-flip ito mula sa menu ng toggle (`Super + Ctrl + O`) o gamit ang `omarchy toggle nightlight`. Pinatatakbo ito ng hyprsunset, na sisimulan ng toggle para sa iyo kung hindi pa ito tumatakbo.

Bilang default, wala talagang ginagawa ang hyprsunset sa screen mo. May kasamang identity profile ang `~/.config/hypr/hyprsunset.conf` nang tiyakan upang manatiling hindi nagagalaw ang display hanggang humingi ka ng init. Kung mas gusto mong lumipat ito ayon sa orasan, palitan iyon ng isang time profile:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Pagkatapos ay simulan ang hyprsunset sa login sa pamamagitan ng pagdagdag ng `o.launch_on_start("hyprsunset")` sa `~/.config/hypr/autostart.lua`. Nakapirmi ang pares na 4000K/6500K na ginagamit ng toggle, kaya ang config file ang pupuntahan mo kung gusto mo ng ibang temperatura.

### Do not disturb

Pinatatahimik ng `Super + Ctrl + Alt + ,` ang mga notification. Walang toast na lilitaw habang naka-on ito, at nakaupo sa bar ang indicator na kampanang may ekis upang ipaalala sa iyo kung bakit tumahimik ang desktop.

Wala namang mawawala. Hinohold back ang mga pinatahimik na notification: ibalik ang huling ilan sa screen gamit ang `Super + Shift + Alt + ,`. Tingnan ang [mga abiso](10-notices.md) para sa iba pa.

Dalawang uri ng mensahe ang nakakalusot pa rin: ang sariling mga confirmation toast ng Omarchy para sa isang bagay na kakagawa mo lang ("Theme changed", "Screenshot saved"), at mga critical alert na ipinadala mula sa command line. Ang mga chat app na minamarkahang critical ang lahat para piliting unahan ka ay hindi kwalipikado.

### Idle

Ang shell ng Omarchy ang nagmamay-ari ng idle na kilos, at ang mga timing ay isang top-level na `idle` block sa `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Parehong bilang ay mga segundong binibilang mula sa sandaling naging idle ka — hindi mula sa isa't isa. Kaya sa mga default, lalabas ang screensaver pagkatapos ng dalawa at kalahating minuto at aagaw ang lock screen sa limang minuto, tumakbo man ang screensaver o hindi. I-save ang file at kukunin agad ng shell ang mga bagong timing.

Kung i-dismiss mo ang screensaver bago ang deadline ng lock, mabibilang iyon bilang activity at makakansela ang nakabinbing lock. Hindi ka mala-lock out dahil lang sumilip ka sa machine mo.

Upang ihinto nang lubusan ang pag-lock sa idle, ang `Super + Ctrl + I` — o `omarchy toggle idle` — ay magbubukas sa stay awake, at lilitaw sa bar ang indicator na tasa ng kape. Iyon ang pipindutin mo bago ang isang mahabang presentation o isang build na gusto mong panoorin. Pindutin ito ulit upang bumalik sa normal. Inililimbag ng `omarchy toggle idle status` ang kasalukuyang state bilang JSON kung kailangan mo ito mula sa isang script.

Tungkol ito sa pag-lock at sa screensaver, hindi sa power. Ang suspend at hibernation ay may sarili nilang setup sa [pagtulog ng system](36-system-sleep.md).

### Ang screensaver

Ang screensaver ng Omarchy ay ASCII art na tumatakbo sa mga random na text effect, isang instance bawat monitor. Anumang key o galaw ng mouse ay lumalabas dito.

Maaari mo itong simulan kapag kailangan mula sa _System > Screensaver_ (`Super + Esc`), na pipilitin itong lumabas kahit na isinara mo ang idle na screensaver. Walang hotkey na nakatali dito bilang default.

Ang `omarchy toggle screensaver` ang nagsasara sa idle na isa, kung mas gusto mong dumiretso mula sa pagtatrabaho patungong naka-lock. Anumang key, click, scroll o galaw ng mouse ay magsasara nito.

Ang logo na iginuguhit nito ay sa iyo upang baguhin, sa ilalim ng _Appearance > Branding > Screensaver_. Mag-upload ng png o svg at iko-convert ito ng Omarchy sa ASCII. Tingnan ang [branding](41-branding.md).

### Ang lock screen

Ni-lo-lock ng `Super + Ctrl + L` ang machine. Pinatatakbo niyon ang lock screen mula sa shell ng Omarchy, bina-blank ang display, nire-reset ang layout ng keyboard mo sa una upang hindi mo mai-type ang password mo sa maling alpabeto, at — kung pinatatakbo mo ito — ni-lo-lock ang 1Password palabas.

Tumatanggap ang lock screen ng password, at tatanggap din ito ng fingerprint kapag nakapag-set up ka na ng isa. Iyon, at ang iba pang paraan ng pagpapatunay, ay sakop sa [pagpapatunay sa hardware](37-hardware-authentication.md).
