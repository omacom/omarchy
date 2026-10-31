# Mga Dotfile

Pangunahing naka-configure ang Omarchy sa pamamagitan ng tinatawag na mga dotfile na nakatira sa `~/.config`. Itinuturing ang mga iyon na iyong mga file para sa iyong mga pagbabago. Ang mga file na nakatira sa `/usr/share/omarchy` ay pagmamay-ari ng Omarchy mismo, at hindi mo dapat pinakikialaman ang mga iyon. Kung kailangan mong baguhin ang anumang bagay sa `/usr/share/omarchy`, dapat mong patungan ang value sa `~/.config` sa halip.

Maaaring i-edit ang mga pangunahing config nang direkta mula sa Omarchy menu (`Super + Space`), tulad ng _Setup > Monitors_, _Setup > Keybindings_, _Setup > Input_, at _Setup > Config > [file]_. Kapag ginawa mo ito sa ganitong paraan, anumang prosesong kailangang i-restart pagkatapos ng mga pag-edit sa config ay awtomatikong magre-restart pagkatapos mong umalis sa editor (Neovim bilang default — `:wq`, tandaan! — pero maaari mong baguhin iyon sa pamamagitan ng _Setup > Defaults > Editor_).

Narito ang listahan ng mga pangunahing file sa `~/.config` at kung ano ang kinokontrol nila:

| File                  | Layunin              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Ang pangunahing Hyprland config. Nilo-load ang mga Omarchy default kasama ang iyong mga override file sa ibaba. [Matuto pa tungkol sa mga Hyprland config](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Ang iyong sariling mga keybinding at mga override ng mga default. |
| `~/.config/hypr/monitors.lua` | Kinokontrol ang iyong mga monitor, resolution, at posisyon. |
| `~/.config/hypr/input.lua` | Kinokontrol ang iyong keyboard layout, mouse, at mga setting ng trackpad. |
| `~/.config/hypr/looknfeel.lua` | Kinokontrol ang mga gap, hangganan, animasyon, at ang natitira pang hitsura. |
| `~/.config/hypr/autostart.lua` | Kinokontrol ang mga karagdagang prosesong sinimulan kasama ng session. |
| `~/.config/omarchy/shell.json` | Kinokontrol ang Omarchy shell: posisyon ng bar, layout, at mga widget, pati na rin ang screensaver, lock, at mga timing ng idle. |
| `~/.config/foot/foot.ini` | Kinokontrol ang iyong terminal (ang foot ang default). |
| `~/.XCompose` | Tinutukoy ang iyong quick-access emoji at name/email autocomplete. Tiyakin na patakbuhin ang `omarchy-restart-xcompose` pagkatapos gumawa ng mga pagbabago. |

Kung marami kang gagawing pagbabago para i-tweak ang sarili mong setup, magandang ideya na i-backup ang lahat ng mga dotfile na ito. [Ang Stow ay isang mahusay na paraan para gawin iyon](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Pagsisimula ng sarili mong mga app kasama ng session

Kung gusto mo ng isang bagay na tumakbo sa tuwing magla-log in ka — isang sync daemon, isang chat app, ang sarili mong script — ilagay ito sa `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Sinisimulan niyon ang command bilang bahagi ng session, kaya maayos itong nililinis kapag nag-log out ka ulit.

### Pagpapatakbo ng mga script sa mga kaganapan ng sistema

Nagpapaputok ang Omarchy ng mga hook sa iilang sandali, at maaari mong ikabit ang sarili mong mga script sa mga ito. Nakatira sila sa `~/.config/omarchy/hooks/<event>.d/`, isang direktoryo bawat kaganapan, at ang bawat executable file roon ay tumatakbo kapag nangyari ang kaganapan:

| Kaganapan | Kailan ito tumatakbo |
| ----- | ------------ |
| `post-boot` | Kaagad pagkatapos magsimula ang desktop |
| `post-update` | Malapit sa dulo ng `omarchy update`, pagkatapos ng mga package, migration, at pag-restart ng serbisyo, bago i-update ang mga mise tool |
| `pre-refresh-pacman` | Pagkatapos muling i-sync ng `omarchy refresh pacman` ang package config, bago ito mag-update ng mga package; pinapatakbo ito ng isang paglipat ng channel sa parehong hakbang ng refresh na iyon |
| `theme-set` | Pagkatapos ng pagbabago ng tema (pangalan ng tema sa `$1`) |
| `font-set` | Pagkatapos ng pagbabago ng font (pangalan ng font sa `$1`) |
| `battery-low` | Kapag mababa na ang baterya (porsyento sa `$1`) |

Ang `pre-refresh-pacman` hook ay kung saan nabibilang ang mga custom na repository o mga linyang `IgnorePkg`, dahil tumatakbo ito bago ang transaksyon ng package. Ang parehong update-related hook ay tumatakbo bilang iyong user pagkatapos alisin ng Omarchy ang naka-cache nitong sudo authorization, kaya ang isang hook na gumagamit ng `sudo` ay nangangailangan ng sarili nitong awtorisasyon at maaaring humingi ng iyong password.

Ang bawat isa sa mga direktoryong iyon ay mayroon nang `.sample` file na nagpapakita ng hugis ng isang hook — alisin ang `.sample` sa pangalan para paganahin ito. Para mag-install ng script na isinulat mo sa ibang lugar, gamitin ang `omarchy hook install post-boot ~/my-hook`, na kinokopya ito papasok at ginagawang executable.

### Pagdaragdag ng sarili mong mga entry sa menu

Ang Omarchy menu (`Super + Space`) ay maaaring palawakin gamit ang sarili mong mga row sa pamamagitan ng pag-edit ng `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Naka-key ang mga entry sa isang dotted id, at ang id ang naglalagay sa kanila sa tree, kaya ang `personal` ay lumalabas sa root menu at ang `personal.notes` ay lumalabas sa loob nito:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Muling gamitin ang isang umiiral na id at papatungan mo ang row na iyon sa halip na magdagdag ng bago. May kasama ang file na lahat ng available na field ay nadokumento bilang mga komento.

### Pagdaragdag ng sarili mong mga shell export, function, at alias

May kasamang maraming ergonomic alias at kapaki-pakinabang na function ang Omarchy, pero napakakaraniwan na gustong magdagdag ng sarili mo. Dapat mong idagdag ang parehong mga alias, function, at export sa `~/.bashrc`. Hindi mapapatungan ang file na ito sa mga update. Kung gusto mong baguhin ang anumang Omarchy default, maaari mo ring ligtas na idagdag ang mga ito rito.

### Pagbabago ng mga internal na file ng Omarchy

Tingnan mo, computer mo ito. Maaari mong gawin ang anumang gusto mo dito, pero ipapayo ko laban sa paggawa ng mga pagbabago sa mga file sa `/usr/share/omarchy` nang direkta. Pagmamay-ari sila ng Omarchy pacman package, kaya mapapatungan lang ang iyong mga pagbabago sa susunod na update. Mas mabuti kang patungan na lang ang anumang default value na hindi mo gusto sa folder na `~/.config/*` sa halip.

Maaari mong baguhin ang halos lahat sa ganoong paraan, tulad ng mga default na keybinding. I-edit lang ang `~/.config/hypr/bindings.lua` para, halimbawa, palitan ang [Obsidian](https://obsidian.md/) ng [Joplin](https://joplinapp.org/) (i-install gamit ang `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Tinatanggal ng `o.rebind` ang umiiral na binding bago idagdag ang kapalit nito. Kinukuha nito ang parehong mga argumento tulad ng `o.bind`, kasama ang mga launch helper at binding option. Gamitin ang `o.bind` para magdagdag ng binding, o ang `hl.unbind` para alisin ang isa nang hindi ito pinapalitan.

Kung ipipilit mong i-hack ang mga internal na file ng Omarchy, lumipat sa dev channel sa pamamagitan ng _Update > Channel > Dev_. Nagli-link iyon sa Omarchy sa isang git checkout ng source code sa `~/omarchy`, na malaya mong baguhin ayon sa gusto ng puso mo. Walang sinuman dito na magsasabi sa iyo kung ano ang gagawin!

### Pag-reset ng anumang pagbabago

Kung magulo ang mga configuration, maaari mo silang laging ibalik sa mga default sa pamamagitan ng _Update > Config_ sa Omarchy menu. O sa pamamagitan ng pagpapatakbo ng `omarchy reinstall configs` para i-reset ang lahat.
