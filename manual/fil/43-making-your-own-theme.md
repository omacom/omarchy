# Paggawa ng sarili mong tema

Maaari kang magdagdag ng sarili mong mga tema sa `~/.config/omarchy/themes`. Kopyahin lang ang isa sa mga umiiral na bilang base (tingnan sa `/usr/share/omarchy/themes`), pagkatapos ay baguhin ito ayon sa gusto mo. Hangga't nasa loob ng folder na iyon ang tema mo, isasama ito sa menu ng pagpili ng tema.

Ang pangunahing file na kailangan mong baguhin ay `colors.toml`. Iyon ang tumutukoy sa set ng kulay na gagamitin pagkatapos para bumuo ng mga configuration para sa terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, mga Qt app, backlight ng keyboard, input method, screen-share picker, mga icon ng app, ilang AI tool (Claude, Pi, Hermes, T3 Code, Herdr), at buong Omarchy shell (top bar, menu, mga notification, OSD, at lock screen).

Maaari mo ring gamitin ang kasamang Aether application para gumawa ng bagong tema gamit ang magandang GUI interface para paglaruan ang mga kulay at maghanap ng mga background. Simulan lang ito mula sa app grid sa `Super + Alt + Space`.

### Ano ang maaaring laman ng naka-install na tema

Ang temang ikaw mismo ang nagsulat sa `~/.config/omarchy/themes` ay maaaring maglaman ng kahit anong gusto mo — makina mo ito at file mo ito, at ilalapat ng Omarchy ang lahat ng iyon.

Ang temang ini-install mo mula sa repo ng ibang tao gamit ang `omarchy theme install` ay pinapanatili ang lahat ng tungkol sa kulay, at nawawala ang iilang file na magpapatakbo ng code sa makina mo: anumang `.lua` file, mga terminal config (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), at `vscode.json`. Ang `hyprland.lua` ng tema ay Lua na pinapatakbo ng compositor mo sa pag-login, pinapangalanan ng terminal config ang programang sinisimulan ng terminal mo, at pinapangalanan ng `vscode.json` ang isang VSCode extension na i-install. Ang pag-install ng tema ng ibang tao ay dapat magbago lang sa hitsura ng desktop mo, hindi kailanman sa pinapatakbo nito.

Gumagana pa rin ang lahat ng iba pa nang eksakto kung paano ito isinulat ng may-akda ng tema — pinapanatili ang `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, mga background at mga preview. Ang mga naalis lang ang muling bubuuin mula sa `colors.toml` sa makina mo.

Nakikilala ng Omarchy ang pagkakaiba ng dalawa sa kung may sarili bang git repo sa loob nito ang tema, na siyang iniiwan ng `omarchy theme install` kapag nag-clone ito. Kaya ang temang ikaw ang nagsulat ay nananatiling sa iyo, at ang hinila mo mula sa internet ay nananatiling mga kulay.

### Light mode

Kung gumagawa ka ng temang light mode, itakda ang `mode = "light"` sa itaas ng `colors.toml` mo. Pagkatapos, awtomatiko itong ipapares sa light mode para sa lahat ng app. (Gumagana pa rin ang lumang paraan ng paglalagay ng walang lamang file na tinatawag na `light.mode` sa root ng tema mo.)

### Larawan para sa pag-unlock

Ang mga temang may kasamang larawang `unlock.png` at `preview-unlock.png` ay ililista sa ilalim ng _Appearance > Unlock_. Mas mabuti kung transparent na png ang `unlock.png` mo. At maaari mong gawin ang preview na larawan gamit ang `omarchy plymouth preview`.

### Pagte-tema ng mga app na hindi sakop ng Omarchy

Kung gumagamit ka ng app na wala sa listahang iyon, maaari mong turuan ang Omarchy na i-tema ito nang mag-isa gamit ang isang template. Maglagay ng file sa `~/.config/omarchy/themed/` na ipinangalan sa config na bubuuin nito at dagdagan ng ekstensyong `.tpl`, at isulat ang config na may `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hanggang `{{ color15 }}`, at ang natitira pang palette bilang mga placeholder. Tuwing magpapalit ka ng tema, muling bubuuin ang file gamit ang mga kulay ng temang iyon.

May ganap na may komentong `alacritty.toml.tpl.sample` sa folder na iyon na maaari mong pag kopyahan — inililista nito ang bawat variable na maaari mong gamitin, pati ang mga modifier na `_strip` at `_rgb` para sa mga app na gustong makuha ang kanilang mga kulay nang walang `#` o bilang decimal RGB. Mas inuuna ang mga template mo kaysa sa sariling template ng Omarchy, kaya maaari mo rin itong gamitin para i-override kung paano tine-tema ang isang built-in na app.

### Pagpapamahagi ng tema mo

Kung gusto mong ipamahagi ang tema mo para magamit ito ng iba, kailangan mong ilagay ito sa isang pampublikong git server, tulad ng GitHub. Pagkatapos, mai-install ito ng mga tao gamit ang _Install > Style > Theme_ sa menu ng Omarchy gamit ang URL na iyon. Inirerekomenda na sundin mo ang convention sa pagpapangalan na `omarchy-[themename]-theme`, dahil lalabas nang tama ang tema bilang `[themename]` lamang sa menu ng pagpili ng tema pagkatapos ng pag-install.

Ang natitirang `[themename]` na iyon ang nagiging pangalan ng directory ng tema, kaya kailangan itong isa na ligtas na maipasa-pasa ng Omarchy: kailangan itong magsimula sa isang titik, isang digit, o isang underscore, at ang natitira ay maaaring maglaman ng mga titik, digit, `.`, `_`, `+`, at `-`. Gagawing lowercase ang mga malalaking titik para sa iyo, pero anumang iba pa — isang puwang, isang panipi, isang karakter na hindi Ingles — ay tatanggihan sa oras ng pag-install sa halip na gawing pangalan ng directory. Kaya maayos na nai-install ang `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, at `omarchy-c++-theme`.

Tandaan na kapag na-install na ito mula sa isang repo, aalisin ang anumang `.lua`, terminal config o `vscode.json` na kasama nito, kaya huwag mong itayo ang tema sa paligid ng mga iyon.

Maaari mong idagdag ang tema mo sa [pahina ng mga karagdagang tema](https://omarchy.org/themes/) sa pamamagitan ng pagpapadala ng pull request sa [repo ng omarchy-site](https://github.com/omacom-io/omarchy-site).
