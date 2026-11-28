# Dotfiles

Pangunahing kinokonpigura ang Omarchy sa pamamagitan ng tinatawag na dotfiles na nasa `~/.config`. Itinuturing ang mga iyon na mga file mo para sa mga pagbabago mo. Ang mga file na nasa `/usr/share/omarchy` ay pag-aari ng Omarchy mismo, at hindi mo dapat pinakikialaman ang mga iyon. Kung kailangan mong baguhin ang anuman sa `/usr/share/omarchy`, dapat ay pinapalitan mo na lang ang halaga sa `~/.config`.

Maaaring i-edit ang mga pangunahing config nang direkta mula sa menu ng Omarchy (`Super + Space`), tulad ng _Setup > Keyboard > Keybindings_, _Setup > Input_, at _Setup > Config > [file]_. Kapag ginawa mo ito sa ganitong paraan, awtomatikong magre-restart pagkatapos mong isara ang editor ang anumang proseso na kailangang i-restart pagkatapos ng mga pag-edit sa config (Neovim bilang default — `:wq`, tandaan mo! — pero maaari mong baguhin iyon sa pamamagitan ng _Setup > Defaults > Editor_).

Narito ang listahan ng mga pangunahing file sa `~/.config` at kung ano ang kinokontrol ng mga ito:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Ang pangunahing config ng Hyprland. Nilo-load nito ang mga default ng Omarchy pati ang mga override file mo sa ibaba. [Matuto pa tungkol sa mga config ng Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Ang sarili mong mga keybinding at mga override sa mga default. |
| `~/.config/hypr/monitors.lua` | Mga setting ng monitor na hindi sakop ng monitor panel, tulad ng rotation, mga karagdagang mode, o pagpapanatiling nakapatay ng isang monitor. |
| `~/.config/hypr/input.lua` | Kinokontrol nito ang layout ng keyboard mo, mouse, at mga setting ng trackpad. |
| `~/.config/hypr/looknfeel.lua` | Kinokontrol nito ang mga gap, border, animation, at ang iba pang bahagi ng hitsura. |
| `~/.config/hypr/autostart.lua` | Kinokontrol nito ang mga karagdagang prosesong sinisimulan kasama ng session. |
| `~/.config/omarchy/shell.json` | Kinokontrol nito ang shell ng Omarchy: posisyon ng bar, layout, at mga widget, pati ang screensaver, lock, at mga timing ng idle. |
| `~/.config/foot/foot.ini` | Kinokontrol nito ang terminal mo (foot ang default). |
| `~/.XCompose` | Tinutukoy nito ang mabilisang emoji mo at ang autocomplete para sa pangalan/email. Siguraduhing patakbuhin ang `omarchy-restart-xcompose` pagkatapos gumawa ng mga pagbabago. |

Kung marami ka nang gagawing pagbabago para ayusin ang sarili mong setup, magandang ideya na i-backup ang lahat ng dotfiles na ito. [Magandang paraan ang Stow para gawin iyan](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Pagsisimula ng sarili mong mga app kasama ng session

Kung gusto mong may tumakbo sa tuwing magla-log in ka — isang sync daemon, isang chat app, sarili mong script — ilagay ito sa `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Sinisimulan niyan ang command bilang bahagi ng session, kaya maayos itong nililinis kapag nag-log out ka ulit.

### Pagpapatakbo ng mga script sa mga event ng system

Nagpapagana ang Omarchy ng mga hook sa ilang sandali, at maaari mong ikabit ang sarili mong mga script sa mga ito. Nasa `~/.config/omarchy/hooks/<event>.d/` ang mga ito, isang directory bawat event, at tumatakbo gamit ang bash ang bawat file doon na hindi nagtatapos sa `.sample` kapag nangyari ang event:

| Event | Kailan ito tumatakbo |
| ----- | ------------ |
| `post-boot` | Kaagad pagkatapos magsimula ng desktop |
| `post-update` | Malapit sa dulo ng `omarchy update`, pagkatapos ng mga package, migration, at pag-restart ng mga service, bago i-update ang mga tool ng mise |
| `pre-refresh-pacman` | Pagkatapos muling i-sync ng `omarchy refresh pacman` ang config ng package, bago nito i-update ang mga package; pinapatakbo ito ng paglipat ng channel sa parehong hakbang ng refresh na iyon |
| `theme-set` | Pagkatapos ng pagbabago ng theme (pangalan ng theme sa `$1`) |
| `font-set` | Pagkatapos ng pagbabago ng font (pangalan ng font sa `$1`) |
| `battery-low` | Kapag mababa na ang baterya (porsyento sa `$1`) |

Ang hook na `pre-refresh-pacman` ang lugar kung saan dapat ilagay ang mga custom na repository o mga linya ng `IgnorePkg`, dahil tumatakbo ito bago ang transaksyon ng package. Parehong tumatakbo ang dalawa bilang user mo. Tumatakbo ang `post-update` habang sariwa pa ang awtorisasyon ng sudo ng `omarchy update`, kaya hindi na muling hihingin ng hook na gumagamit ng `sudo` ang password mo; tumatakbo ang `pre-refresh-pacman` kaagad pagkatapos gumamit ng sudo ang `omarchy refresh pacman` mismo.

May hawak nang `.sample` na file ang bawat isa sa mga directory na iyon na nagpapakita ng anyo ng isang hook — alisin mo lang ang `.sample` sa pangalan para paganahin ito. Para mag-install ng script na isinulat mo sa ibang lugar, gamitin ang `omarchy hook install post-boot ~/my-hook`, na kumokopya nito papasok at ginagawa itong executable.

### Pagdaragdag ng sarili mong mga entry sa menu

Maaaring palawakin ang menu ng Omarchy (`Super + Space`) gamit ang sarili mong mga row sa pamamagitan ng pag-edit sa `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Nakabatay ang mga entry sa isang dotted id, at ang id ang naglalagay sa mga ito sa tree, kaya lumalabas ang `personal` sa root menu at lumalabas ang `personal.notes` sa loob nito:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Muling gamitin ang isang umiiral na id at papalitan mo ang row na iyon sa halip na magdagdag ng bago. Kasama sa file ang lahat ng available na field na nakadokumento bilang mga komento.

### Pagdaragdag ng sarili mong mga shell export, function, at alias

May kasamang maraming ergonomic na alias at kapaki-pakinabang na function ang Omarchy, pero napakakaraniwan na gustuhin mong magdagdag ng sarili mo. Dapat mong idagdag ang mga alias, function, at export sa `~/.bashrc`. Hindi mapapalitan ang file na ito sa mga update. Kung gusto mong baguhin ang alinman sa mga default ng Omarchy, ligtas mo ring maidagdag ang mga ito rito.

### Pagtatakda ng mga environment variable para sa desktop

Ang mga export ng desktop session ay nasa `~/.config/uwsm/env.d/`. Tumatakbo ang mga file na ito bago magsimula ang desktop mo, kaya maaaring ibalik ka ng isang error sa shell sa login screen. Panatilihing nakabukas ang isang gumaganang terminal habang ine-edit mo ang mga ito. Para i-disable ang isang override, ilipat ito palabas ng `env.d`. Tingnan ang [pagbawi sa login](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) kung pinipigilan ng isang pagbabago ang pag-login.

### Pagbabago ng mga panloob na file ng Omarchy

Tingnan mo, computer mo ito. Maaari mong gawin ang anumang gusto mo rito, pero ipapayo ko laban sa direktang pagbabago ng mga file sa `/usr/share/omarchy`. Pag-aari ang mga iyon ng pacman package ng Omarchy, kaya mapapalitan lang ang mga pagbabago mo sa susunod na update. Mas mabuti pang palitan mo na lang sa folder na `~/.config/*` ang anumang default na halaga na hindi mo gusto.

Halos lahat ay maaari mong baguhin sa ganoong paraan, tulad ng mga default na keybinding. I-edit mo lang ang `~/.config/hypr/bindings.lua` para, halimbawa, palitan ang [Obsidian](https://obsidian.md/) ng [Joplin](https://joplinapp.org/) (i-install gamit ang `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Inaalis ng `o.rebind` ang umiiral na binding bago idagdag ang kapalit nito. Tumatanggap ito ng parehong mga argument gaya ng `o.bind`, kabilang ang mga launch helper at mga opsyon sa binding. Gamitin ang `o.bind` para magdagdag ng binding, o ang `hl.unbind` para mag-alis ng isa nang hindi ito pinapalitan.

Kung ipipilit mong pakialaman ang mga panloob na file ng Omarchy, lumipat sa dev channel sa pamamagitan ng _Update > Channel > Dev_. Ini-uugnay niyan ang Omarchy sa isang git checkout ng source code sa `~/omarchy`, na malaya mong mababago nang buong puso. Walang sinumang nandito para sabihan ka kung ano ang gagawin!

### Pag-reset ng anumang mga pagbabago

Kung magkakagulo ka sa mga configuration, maaari mong palaging ibalik ang mga ito sa mga default sa pamamagitan ng _Update > Config_ sa menu ng Omarchy. O sa pamamagitan ng pagpapatakbo ng `omarchy reinstall configs` para i-reset ang lahat.
