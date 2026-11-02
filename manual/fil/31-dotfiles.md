# Dotfiles

Pangunahing nako-configure ang Omarchy sa pamamagitan ng tinatawag na mga dotfile na nasa `~/.config`. Itinuturing ang mga iyon na mga file mo para sa mga pagbabago mo. Ang mga file na nasa `/usr/share/omarchy` ay pag-aari mismo ng Omarchy, at hindi mo dapat pinakikialaman ang mga iyon. Kung may kailangan kang baguhin sa `/usr/share/omarchy`, dapat mo na lang i-overwrite ang value sa `~/.config`.

Maaaring i-edit ang mahahalagang config nang direkta mula sa Omarchy menu (`Super + Space`), tulad ng _Setup > Keyboard > Keybindings_, _Setup > Input_, at _Setup > Config > [file]_. Kapag ganito mo ito ginawa, awtomatikong mare-restart ang anumang prosesong kailangang i-restart pagkatapos ng mga pag-edit sa config pagkatapos mong isara ang editor (Neovim bilang default — `:wq`, tandaan mo! — pero maaari mong baguhin iyon sa pamamagitan ng _Setup > Defaults > Editor_).

Narito ang listahan ng mahahalagang file sa `~/.config` at kung ano ang kinokontrol ng mga ito:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Ang pangunahing config ng Hyprland. Nilo-load nito ang mga default ng Omarchy kasama ang mga override file mo sa ibaba. [Matuto pa tungkol sa mga config ng Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Ang sarili mong mga keybinding at mga override sa mga default. |
| `~/.config/hypr/monitors.lua` | Mga setting ng monitor na hindi sakop ng monitor panel, tulad ng rotation, mga karagdagang mode, o pananatiling naka-off ng isang monitor. |
| `~/.config/hypr/input.lua` | Kinokontrol nito ang layout ng keyboard mo, mouse, at mga setting ng trackpad. |
| `~/.config/hypr/looknfeel.lua` | Kinokontrol nito ang mga gap, border, animation, at ang iba pang bahagi ng hitsura. |
| `~/.config/hypr/autostart.lua` | Kinokontrol nito ang mga karagdagang prosesong sinisimulan kasama ng session. |
| `~/.config/omarchy/shell.json` | Kinokontrol nito ang Omarchy shell: posisyon ng bar, layout, at mga widget, kasama ang mga timing ng screensaver, lock, at idle. |
| `~/.config/foot/foot.ini` | Kinokontrol nito ang terminal mo (foot ang default). |
| `~/.XCompose` | Tinutukoy nito ang mabilisang access mo sa emoji at autocomplete ng pangalan/email. Siguraduhing patakbuhin ang `omarchy-restart-xcompose` pagkatapos gumawa ng mga pagbabago. |

Kung marami ka nang gagawing pagbabago para i-tweak ang sarili mong setup, magandang ideya na i-backup ang lahat ng dotfile na ito. [Magandang paraan ang Stow para gawin iyon](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Pagsisimula ng sarili mong mga app kasama ng session

Kung gusto mong may tumakbo tuwing magla-log in ka — isang sync daemon, isang chat app, sarili mong script — ilagay ito sa `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Sinisimulan niyan ang command bilang bahagi ng session, kaya maayos itong nililinis kapag nag-log out ka ulit.

### Pagpapatakbo ng mga script sa mga event ng system

Nagpapagana ang Omarchy ng mga hook sa ilang mga sandali, at maaari mong ikabit ang sarili mong mga script sa mga ito. Nasa `~/.config/omarchy/hooks/<event>.d/` ang mga ito, isang directory bawat event, at tumatakbo ang bawat executable na file doon kapag nangyari ang event:

| Event | Kailan ito tumatakbo |
| ----- | ------------ |
| `post-boot` | Kaagad pagkatapos magsimula ng desktop |
| `post-update` | Malapit sa dulo ng `omarchy update`, pagkatapos ng mga package, migration, at pag-restart ng mga service, bago i-update ang mise tools |
| `pre-refresh-pacman` | Pagkatapos muling i-sync ng `omarchy refresh pacman` ang config ng package, bago nito i-update ang mga package; pinapatakbo ito ng pagpalit ng channel sa parehong hakbang ng refresh na iyon |
| `theme-set` | Pagkatapos ng pagbabago ng theme (pangalan ng theme sa `$1`) |
| `font-set` | Pagkatapos ng pagbabago ng font (pangalan ng font sa `$1`) |
| `battery-low` | Kapag mababa na ang baterya (porsyento sa `$1`) |

Ang `pre-refresh-pacman` hook ang lugar kung saan dapat ilagay ang mga custom repository o mga linyang `IgnorePkg`, dahil tumatakbo ito bago ang transaksyon ng package. Tumatakbo ang parehong hook na may kaugnayan sa update bilang user mo pagkatapos burahin ng Omarchy ang naka-cache nitong awtorisasyon sa sudo, kaya ang hook na gumagamit ng `sudo` ay nangangailangan ng sarili nitong awtorisasyon at maaaring humingi ng password mo.

Mayroon nang `.sample` file ang bawat isa sa mga directory na iyon na nagpapakita ng hugis ng isang hook — alisin ang `.sample` sa pangalan para magamit ito. Para mag-install ng script na isinulat mo sa ibang lugar, gamitin ang `omarchy hook install post-boot ~/my-hook`, na kokopya nito roon at gagawin itong executable.

### Pagdaragdag ng sarili mong mga entry sa menu

Maaaring palawakin ang Omarchy menu (`Super + Space`) gamit ang sarili mong mga row sa pamamagitan ng pag-edit sa `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Naka-key ang mga entry sa isang dotted id, at ang id ang naglalagay sa mga ito sa tree, kaya lumalabas ang `personal` sa root menu at lumalabas ang `personal.notes` sa loob nito:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Muling gamitin ang isang umiiral na id at io-override mo ang row na iyon sa halip na magdagdag ng bago. Kasama sa file ang lahat ng available na field na nakadokumento bilang mga comment.

### Pagdaragdag ng sarili mong shell exports, functions, at aliases

Nagbibigay ang Omarchy ng maraming ergonomic na alias at kapaki-pakinabang na function, pero napakakaraniwan na gusto mong magdagdag ng sarili mo. Dapat mong idagdag ang mga alias, function, at export sa `~/.bashrc`. Hindi io-overwrite ang file na ito sa mga update. Kung gusto mong baguhin ang alinman sa mga default ng Omarchy, ligtas mo ring maidagdag ang mga ito rito.

### Pagtatakda ng mga environment variable para sa desktop

Ang mga export ng desktop session ay dapat nasa `~/.config/uwsm/env.d/`. Tumatakbo ang mga file na ito bago magsimula ang desktop mo, kaya maaari kang ibalik ng isang error sa shell sa login screen. Panatilihing bukas ang isang gumaganang terminal habang ine-edit ang mga ito. Para i-disable ang isang override, ilipat ito palabas ng `env.d`. Tingnan ang [pagbawi sa pag-login](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) kung pinipigilan ng isang pagbabago ang pag-login.

### Pagbabago ng mga internal na file ng Omarchy

Tingnan mo, computer mo ito. Maaari mong gawin ang anumang gusto mo rito, pero ipapayo kong huwag kang gumawa ng mga pagbabago nang direkta sa mga file sa `/usr/share/omarchy`. Pag-aari ang mga ito ng Omarchy pacman package, kaya io-overwrite lang ang mga pagbabago mo sa susunod na update. Mas mabuti pang i-overwrite mo na lang sa `~/.config/*` folder ang anumang default value na hindi mo gusto.

Maaari mong baguhin ang halos lahat ng bagay sa ganoong paraan, tulad ng mga default na keybinding. I-edit lang ang `~/.config/hypr/bindings.lua` para, halimbawa, palitan ang [Obsidian](https://obsidian.md/) ng [Joplin](https://joplinapp.org/) (i-install gamit ang `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Inaalis ng `o.rebind` ang umiiral na binding bago idagdag ang kapalit nito. Pareho ang mga argument na tinatanggap nito sa `o.bind`, kasama ang mga launch helper at binding option. Gamitin ang `o.bind` para magdagdag ng binding, o ang `hl.unbind` para mag-alis ng isa nang hindi ito pinapalitan.

Kung igigiit mong pakialaman ang mga internal na file ng Omarchy, lumipat sa dev channel sa pamamagitan ng _Update > Channel > Dev_. Ikinakabit niyan ang Omarchy sa isang git checkout ng source code sa `~/omarchy`, na malaya mong mababago nang buong puso. Wala namang sinuman dito na magdidikta sa iyo!

### Pag-reset ng anumang mga pagbabago

Kung magulo na ang mga configuration mo sa huli, maaari mong ibalik ang mga ito sa mga default anumang oras sa pamamagitan ng _Update > Config_ sa Omarchy menu. O sa pamamagitan ng pagpapatakbo ng `omarchy reinstall configs` para i-reset ang lahat.
