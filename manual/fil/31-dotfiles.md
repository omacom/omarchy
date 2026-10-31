# Mga Dotfile

Pangunahing kino-configure ang Omarchy sa pamamagitan ng tinatawag na mga dotfile na nasa `~/.config`. Itinuturing ang mga iyon na iyong mga file para sa iyong mga pagbabago. Ang mga file na nasa `/usr/share/omarchy` ay pag-aari ng Omarchy mismo, at hindi mo dapat pinapakialaman ang mga iyon. Kung may kailangan kang baguhin sa `/usr/share/omarchy`, dapat mo itong i-overwrite sa halip sa `~/.config`.

Maaaring i-edit ang mahahalagang config nang diretso mula sa menu ng Omarchy (`Super + Space`), tulad ng _Setup > Keybindings_, _Setup > Input_, at _Setup > Config > [file]_. Kapag ganito mo ito ginawa, awtomatikong magre-restart pagkatapos mong isara ang editor ang anumang prosesong kailangang i-restart pagkatapos ng mga pag-edit sa config (Neovim bilang default — `:wq`, tandaan mo! — pero maaari mong baguhin iyon sa pamamagitan ng _Setup > Defaults > Editor_).

Narito ang listahan ng mahahalagang file sa `~/.config` at kung ano ang kinokontrol ng mga ito:

| File                  | Layunin              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Ang pangunahing config ng Hyprland. Nilo-load nito ang mga default ng Omarchy pati ang iyong mga override file sa ibaba. [Matuto pa tungkol sa mga config ng Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Ang iyong sariling mga keybinding at mga override sa mga default. |
| `~/.config/hypr/monitors.lua` | Mga setting ng monitor na hindi sakop ng panel ng monitor, tulad ng rotation, mga dagdag na mode, o pagpapanatiling naka-off ng isang monitor. |
| `~/.config/hypr/input.lua` | Kinokontrol nito ang layout ng iyong keyboard, mouse, at mga setting ng trackpad. |
| `~/.config/hypr/looknfeel.lua` | Kinokontrol nito ang mga gap, border, animation, at ang iba pang bahagi ng hitsura. |
| `~/.config/hypr/autostart.lua` | Kinokontrol nito ang mga dagdag na prosesong sinisimulan kasama ng session. |
| `~/.config/omarchy/shell.json` | Kinokontrol nito ang shell ng Omarchy: posisyon ng bar, layout, at mga widget, pati ang screensaver, lock, at mga timing ng idle. |
| `~/.config/foot/foot.ini` | Kinokontrol nito ang iyong terminal (foot ang default). |
| `~/.XCompose` | Tinutukoy nito ang iyong quick-access na emoji at autocomplete para sa pangalan/email. Siguraduhing patakbuhin ang `omarchy-restart-xcompose` pagkatapos gumawa ng mga pagbabago. |

Kung marami ka nang pagbabagong gagawin para i-tweak ang sarili mong setup, magandang ideya na i-backup ang lahat ng dotfile na ito. [Magandang paraan ang Stow para gawin iyan](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Pagsisimula ng sarili mong mga app kasama ng session

Kung gusto mong may tumakbo tuwing magla-log in ka — isang sync daemon, isang chat app, sarili mong script — ilagay ito sa `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Sinisimulan nito ang command bilang bahagi ng session, kaya maayos itong nalilinis kapag nag-log out ka ulit.

### Pagpapatakbo ng mga script sa mga event ng system

Nagpapagana ang Omarchy ng mga hook sa ilang sandali, at maaari mong ikabit ang sarili mong mga script sa mga iyon. Nasa `~/.config/omarchy/hooks/<event>.d/` ang mga ito, isang directory bawat event, at tumatakbo ang bawat executable na file doon kapag nangyari ang event:

| Event | Kailan ito tumatakbo |
| ----- | ------------ |
| `post-boot` | Kaagad pagkatapos magsimula ng desktop |
| `post-update` | Malapit sa dulo ng `omarchy update`, pagkatapos ng mga package, migration, at pag-restart ng mga service, bago i-update ang mga tool ng mise |
| `pre-refresh-pacman` | Pagkatapos muling i-sync ng `omarchy refresh pacman` ang config ng package, bago nito i-update ang mga package; pinapatakbo ito ng pagpalit ng channel sa mismong hakbang na iyon ng refresh |
| `theme-set` | Pagkatapos ng pagbabago ng theme (pangalan ng theme sa `$1`) |
| `font-set` | Pagkatapos ng pagbabago ng font (pangalan ng font sa `$1`) |
| `battery-low` | Kapag mababa na ang battery (porsyento sa `$1`) |

Ang `pre-refresh-pacman` hook ang lugar kung saan dapat ilagay ang mga custom na repository o mga linyang `IgnorePkg`, dahil tumatakbo ito bago ang transaction ng package. Tumatakbo ang dalawang hook na may kaugnayan sa update bilang iyong user pagkatapos burahin ng Omarchy ang naka-cache nitong awtorisasyon sa sudo, kaya ang isang hook na gumagamit ng `sudo` ay nangangailangan ng sarili nitong awtorisasyon at maaaring humingi ng iyong password.

Mayroon nang `.sample` na file ang bawat isa sa mga directory na iyon na nagpapakita ng hugis ng isang hook — tanggalin ang `.sample` sa pangalan para magamit ito. Para mag-install ng script na isinulat mo sa ibang lugar, gamitin ang `omarchy hook install post-boot ~/my-hook`, na kokopya nito roon at gagawin itong executable.

### Pagdaragdag ng sarili mong mga entry sa menu

Maaaring palawakin ang menu ng Omarchy (`Super + Space`) gamit ang sarili mong mga row sa pamamagitan ng pag-edit sa `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Naka-key ang mga entry sa pamamagitan ng isang dotted id, at ang id ang naglalagay sa mga ito sa tree, kaya lumalabas ang `personal` sa root menu at lumalabas ang `personal.notes` sa loob nito:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Gumamit ulit ng isang umiiral nang id at io-override mo ang row na iyon sa halip na magdagdag ng bago. Kasama sa file ang lahat ng available na field na nakadokumento bilang mga komento.

### Pagdaragdag ng sarili mong mga shell export, function, at alias

May kasamang maraming ergonomic na alias at kapaki-pakinabang na function ang Omarchy, pero napakakaraniwan na gusto mong magdagdag ng sarili mo. Dapat mong idagdag ang mga alias, function, at export sa `~/.bashrc`. Hindi io-overwrite ang file na ito sa mga update. Kung gusto mong baguhin ang alinman sa mga default ng Omarchy, ligtas mo ring maidagdag ang mga iyon dito.

### Pagbabago sa mga internal na file ng Omarchy

Tingnan mo, computer mo ito. Maaari mong gawin ang kahit anong gusto mo rito, pero ipapayo ko sa iyo na huwag direktang gumawa ng mga pagbabago sa mga file sa `/usr/share/omarchy`. Pag-aari ang mga iyon ng pacman package ng Omarchy, kaya io-overwrite lang ang iyong mga pagbabago sa susunod na update. Mas mabuti pang i-overwrite mo na lang ang anumang default na value na hindi mo gusto sa folder na `~/.config/*` sa halip.

Halos lahat ay maaari mong baguhin sa paraang iyan, tulad ng mga default na keybinding. I-edit mo lang ang `~/.config/hypr/bindings.lua` para, halimbawa, palitan ang [Obsidian](https://obsidian.md/) ng [Joplin](https://joplinapp.org/) (i-install gamit ang `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Tinatanggal ng `o.rebind` ang umiiral nang binding bago idagdag ang kapalit nito. Tumatanggap ito ng parehong mga argument gaya ng `o.bind`, kabilang ang mga launch helper at mga opsyon sa binding. Gamitin ang `o.bind` para magdagdag ng binding, o ang `hl.unbind` para magtanggal ng isa nang hindi ito pinapalitan.

Kung ipipilit mong pakialaman ang mga internal na file ng Omarchy, lumipat ka sa dev channel sa pamamagitan ng _Update > Channel > Dev_. Ini-link nito ang Omarchy sa isang git checkout ng source code sa `~/omarchy`, na malaya mong baguhin hanggang sa gusto mo. Walang sinuman dito ang magsasabi sa iyo kung ano ang dapat mong gawin!

### Pag-reset ng anumang mga pagbabago

Kung magulo na ang mga configuration mo, maaari mo itong palaging ibalik sa mga default sa pamamagitan ng _Update > Config_ sa menu ng Omarchy. O sa pamamagitan ng pagpapatakbo ng `omarchy reinstall configs` para i-reset ang lahat.
