# Paggawa ng sarili mong theme

Maaari kang magdagdag ng sarili mong mga theme sa `~/.config/omarchy/themes`. Kopyahin lang ang isa sa mga umiiral na bilang base (tingnan sa `/usr/share/omarchy/themes`), pagkatapos ay baguhin ito ayon sa gusto mo. Hangga't nasa loob ng folder na iyon ang theme mo, isasama ito sa menu ng pagpili ng theme.

Ang pangunahing file na kailangan mong baguhin ay `colors.toml`. Tinutukoy nito ang set ng kulay na pagkatapos ay ginagamit para bumuo ng mga configuration para sa terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, mga Qt app, backlight ng keyboard, input method, screen-share picker, mga icon ng app, ilang AI tool (Claude, Pi, Hermes, T3 Code, Herdr), at buong Omarchy shell (top bar, menu, mga notification, OSD, at lock screen).

Maaari mo ring gamitin ang kasamang Aether application para gumawa ng bagong theme gamit ang magandang GUI interface para paglaruan ang mga kulay at maghanap ng mga background. Simulan lang ito mula sa app grid sa `Super + Alt + Space`.

### Ano ang maaaring laman ng isang naka-install na theme

Ang theme na ikaw mismo ang sumulat sa `~/.config/omarchy/themes` ay maaaring maglaman ng kahit ano na gusto mo — makina mo ito at file mo ito, at ilalapat ng Omarchy ang lahat ng ito.

Ang theme na ini-install mo mula sa repo ng ibang tao gamit ang `omarchy theme install` ay pinapanatili ang lahat ng tungkol sa kulay, at tinatanggal ang iilang file na magpapatakbo ng code sa makina mo: anumang `.lua` file, ang mga terminal config (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), at `vscode.json`. Ang `hyprland.lua` ng isang theme ay Lua na pinapatakbo ng compositor mo sa pag-login, pinapangalanan ng isang terminal config ang program na sinisimulan ng terminal mo, at pinapangalanan ng `vscode.json` ang isang VSCode extension na i-install. Ang pag-install ng theme ng ibang tao ay dapat magbago sa hitsura ng desktop mo, hindi kailanman sa pinapatakbo nito.

Gumagana pa rin ang lahat ng iba pa nang eksakto kung paano ito isinulat ng author ng theme — pinapanatili ang `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, ang mga background at ang mga preview. Ang mga tinanggal lang ang muling binubuo mula sa `colors.toml` sa makina mo.

Nakikilala ng Omarchy ang dalawa sa pamamagitan ng kung may sarili itong git repo sa loob, na siyang iniiwan ng `omarchy theme install` kapag nag-clone ito. Kaya ang theme na isinulat mo ay mananatiling sa iyo, at ang isa na kinuha mo mula sa internet ay mananatiling mga kulay.

### Light mode

Kung gumagawa ka ng light mode na theme, itakda ang `mode = "light"` sa itaas ng iyong `colors.toml`. Pagkatapos ay awtomatiko itong ipapares sa light mode para sa lahat ng app. (Gumagana pa rin ang lumang paraan ng paglagay ng walang laman na file na tinatawag na `light.mode` sa root ng theme mo.)

### Mga screen sa boot at login

Ang screen na humihingi ng password ng drive sa boot, at ang login screen, ay gumuguhit ng logo ng Omarchy sa `accent` na kulay ng theme mo sa `background` nito, na may password field sa `foreground` nito at `red` para sa maling password. Wala nang extra na kailangan mong isama para sa mga ito: hindi na ginagamit ng Omarchy ang `unlock.png` o `preview-unlock.png` ng isang theme. Sa Apple Silicon Macs, pinapanatili ng screen ng password ng drive ang default na hitsura ng Omarchy kahit ano pa ang theme.

### Pag-theme ng mga app na hindi saklaw ng Omarchy

Kung gumagamit ka ng app na wala sa listahang iyon, maaari mong turuan ang Omarchy na i-theme ito nang sarili mo gamit ang isang template. Maglagay ng file sa `~/.config/omarchy/themed/` na pinangalanan ayon sa config na binubuo nito plus isang `.tpl` extension, at isulat ang config gamit ang `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hanggang `{{ color15 }}`, at ang natitira pang palette bilang mga placeholder. Sa bawat pagpalit mo ng mga theme, muling binubuo ang file gamit ang mga kulay ng theme na iyon.

May isang `alacritty.toml.tpl.sample` na may buong mga komento sa folder na iyon na maaari mong kopyahin — nakalista roon ang bawat variable na maaari mong gamitin, plus ang mga `_strip` at `_rgb` modifier para sa mga app na gusto ang kanilang mga kulay nang walang `#` o bilang decimal RGB. Inuuna ang mga template mo kaysa sa sariling mga template ng Omarchy, kaya magagamit mo rin ito para i-override kung paano nate-theme ang isang built-in na app.

### Pamamahagi ng theme mo

Kung gusto mong ipamahagi ang theme mo para magamit ito ng iba, kailangan mong ilagay ito sa isang pampublikong git server, tulad ng GitHub. Pagkatapos ay mai-install ito ng mga tao gamit ang _Install > Style > Theme_ sa menu ng Omarchy gamit ang URL na iyon. Inirerekomenda na sundin mo ang naming convention na `omarchy-[themename]-theme`, dahil ang theme ay tamang lalabas bilang `[themename]` lang sa menu ng pagpili ng theme pagkatapos ng pag-install.

Ang natitirang `[themename]` na iyon ang nagiging pangalan ng directory ng theme, kaya kailangang isa itong ligtas na maipasa-pasa ng Omarchy: dapat itong magsimula sa isang letra, digit, o underscore, at ang natitira ay maaaring maglaman ng mga letra, digit, `.`, `_`, `+`, at `-`. Ang mga malaking letra ay ginagawang maliliit na letra para sa iyo, ngunit anumang iba pa — puwang, panipi, karakter na hindi Ingles — ay tinatanggihan sa oras ng pag-install sa halip na gawing pangalan ng directory. Kaya ang `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, at `omarchy-c++-theme` ay pawang maayos na mai-install.

Tandaan na kapag na-install na ito mula sa isang repo, anumang `.lua`, terminal config o `vscode.json` na kasama nito ay tinatanggal, kaya huwag mong itayo ang theme sa paligid ng mga iyon.

Maaari mong idagdag ang theme mo sa [pahina ng mga extra na theme](https://omarchy.org/themes/) sa pamamagitan ng pagpapadala ng pull request sa [repo ng omarchy-site](https://github.com/omacom-io/omarchy-site).
