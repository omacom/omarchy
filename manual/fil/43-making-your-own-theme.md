# Paggawa ng sarili mong theme

Maaari kang magdagdag ng sarili mong mga theme sa `~/.config/omarchy/themes`. Kopyahin lang ang isa sa mga umiiral na bilang base (tingnan sa `/usr/share/omarchy/themes`), pagkatapos ay baguhin ayon sa gusto mo. Hangga't nasa loob ng folder na iyon ang theme mo, isasama ito sa menu ng pagpili ng theme.

Ang pangunahing file na kailangan mong baguhin ay `colors.toml`. Tinutukoy niyon ang set ng kulay na ginagamit pagkatapos para bumuo ng mga configuration para sa terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, at sa buong Omarchy shell (top bar, menu, mga notification, OSD, at lock screen).

Maaari mo ring gamitin ang kasamang Aether application para gumawa ng bagong theme gamit ang magandang GUI interface para paglaruan ang mga kulay at maghanap ng mga background. Simulan lang ito mula sa app grid sa `Super + Alt + Space`.

### Ano ang maaaring lamanin ng isang naka-install na theme

Ang theme na ikaw mismo ang sumulat sa `~/.config/omarchy/themes` ay maaaring maglaman ng kahit ano — makina mo ito at file mo ito, at ilalapat ng Omarchy ang lahat nito.

Ang theme na ini-install mo mula sa repo ng iba gamit ang `omarchy theme install` ay pinapanatili ang lahat ng tungkol sa kulay, at tinatanggal ang iilang file na magpapatakbo ng code sa makina mo: anumang `.lua` file, ang mga terminal config (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), at `vscode.json`. Ang `hyprland.lua` ng isang theme ay Lua na pinapatakbo ng compositor mo sa pag-login, pinapangalanan ng terminal config ang program na sinisimulan ng terminal mo, at pinapangalanan ng `vscode.json` ang isang VSCode extension na i-install. Dapat baguhin ng pag-install ng theme ng iba kung ano ang hitsura ng desktop mo, hindi kailanman kung ano ang pinapatakbo nito.

Gumagana pa rin ang lahat ng iba pa nang eksakto kung paano ito isinulat ng author ng theme — pinapanatili lahat ang `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, ang mga background at ang mga preview. Tanging ang tinanggal lang ang muling bubuuin mula sa `colors.toml` sa makina mo.

Nakikilala ng Omarchy ang dalawa sa pamamagitan kung may sarili itong git repo sa loob, na siyang iniiwan ng `omarchy theme install` kapag nag-clone ito. Kaya ang theme na isinulat mo ay nananatiling sa iyo, at ang isang kinuha mo sa internet ay nananatiling mga kulay.

### Light mode

Kung gumagawa ka ng light mode na theme, itakda ang `mode = "light"` sa itaas ng `colors.toml` mo. Pagkatapos ay awtomatiko itong ipapares sa light mode para sa lahat ng app. (Gumagana pa rin ang lumang paraan ng paglalagay ng walang lamang file na tinatawag na `light.mode` sa root ng theme mo.)

### Larawan para sa unlock

Ang mga theme na may kasamang mga larawang `unlock.png` at `preview-unlock.png` ay ililista sa ilalim ng _Appearance > Unlock_. Mas mainam na transparent na png ang `unlock.png` mo. At maaari mong gawin ang preview image gamit ang `omarchy plymouth preview`.

### Pag-theme sa mga app na hindi sakop ng Omarchy

Kung gumagamit ka ng app na wala sa listahang iyon, maaari mong turuan ang Omarchy na i-theme ito nang sarili mo gamit ang isang template. Maglagay ng file sa `~/.config/omarchy/themed/` na ipinangalan sa config na binubuo nito plus isang `.tpl` extension, at isulat ang config gamit ang `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hanggang `{{ color15 }}`, at ang natitira pang palette bilang mga placeholder. Sa bawat pagpalit mo ng mga theme, muling bubuuin ang file gamit ang mga kulay ng theme na iyon.

May isang `alacritty.toml.tpl.sample` na may kumpletong mga komento sa folder na iyon na maaari mong kopyahan — inililista nito ang bawat variable na maaari mong gamitin, pati ang mga `_strip` at `_rgb` modifier para sa mga app na gusto ang kanilang mga kulay nang walang `#` o bilang decimal RGB. Nauuna ang mga template mo kaysa sa Omarchy mismo, kaya maaari mo rin itong gamitin para i-override kung paano tine-theme ang isang built-in na app.

### Pamamahagi ng theme mo

Kung gusto mong ipamahagi ang theme mo para magamit ito ng iba, kailangan mong ilagay ito sa isang public na git server, tulad ng GitHub. Pagkatapos ay mai-install ito ng mga tao gamit ang _Install > Style > Theme_ sa Omarchy menu gamit ang URL na iyon. Inirerekomenda na sundin mo ang naming convention na `omarchy-[themename]-theme`, dahil lalabas nang tama ang theme bilang `[themename]` lang sa menu ng pagpili ng theme pagkatapos ng installation.

Ang natitirang `[themename]` na iyon ang nagiging pangalan ng directory ng theme, kaya kailangan itong isang pangalang ligtas na maipapasa-pasa ng Omarchy: dapat itong magsimula sa isang titik, isang digit, o isang underscore, at ang natitira ay maaaring maglaman ng mga titik, mga digit, `.`, `_`, `+`, at `-`. Gagawing lowercase para sa iyo ang malalaking titik, pero anumang iba pa — isang space, isang quote, isang character na hindi Ingles — ay tatanggihan sa oras ng pag-install sa halip na gawing pangalan ng directory. Kaya ang `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, at `omarchy-c++-theme` ay pawang maayos na nai-install.

Tandaan na kapag na-install na ito mula sa isang repo, anumang `.lua`, terminal config o `vscode.json` na kasama nito ay tatanggalin, kaya huwag mong itayo ang theme sa paligid ng mga iyon.

Maaari mong ipadagdag ang theme mo sa [pahina ng mga extra theme](https://omarchy.org/themes/) sa pamamagitan ng pagpapadala ng pull request sa [repo ng omarchy-site](https://github.com/omacom-io/omarchy-site).
