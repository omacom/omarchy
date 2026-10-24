# Paggawa ng sarili mong tema

Maaari kang magdagdag ng sarili mong mga tema sa `~/.config/omarchy/themes`. Kopyahin mo lang ang isa sa mga umiiral bilang base (tingnan ang `/usr/share/omarchy/themes`), pagkatapos ay i-tweak ayon sa gusto mo. Basta't nasa loob ng folder na iyon ang tema mo, isasama ito sa menu ng pagpili ng tema.

Ang pangunahing file na kailangan mong i-tweak ay `colors.toml`. Tinutukoy niyon ang hanay ng kulay na ginagamit pagkatapos para gumawa ng mga konpigurasyon para sa terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, at ang buong shell ng Omarchy (bar sa itaas, menu, notipikasyon, OSD, at lock screen).

Maaari mo ring gamitin ang kasamang aplikasyong Aether para gumawa ng bagong tema gamit ang isang magandang GUI interface para paglaruan ang mga kulay at maghanap ng mga background. Simulan mo lang ito mula sa app grid sa `Super + Alt + Space`.

### Ano ang maaaring lamanin ng isang naka-install na tema

Ang temang isinulat mo mismo sa `~/.config/omarchy/themes` ay maaaring maglaman ng anumang gusto mo — makina mo ito at file mo ito, at inilalapat ng Omarchy ang lahat nito.

Ang temang ini-install mo mula sa repo ng iba gamit ang `omarchy theme install` ay pinapanatili ang lahat ng nauugnay sa kulay, at nawawala ang iilang file na magpapatakbo ng code sa makina mo: anumang file na `.lua`, ang mga config ng terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), at `vscode.json`. Ang `hyprland.lua` ng isang tema ay Lua na pinapatakbo ng compositor mo sa pag-login, ang config ng terminal ay nagpapangalan sa programang sisimulan ng terminal mo, at ang `vscode.json` ay nagpapangalan sa extension ng VSCode na i-i-install. Ang pag-install ng tema ng iba ay dapat magbago sa hitsura ng desktop mo, hindi kailanman sa pinapatakbo nito.

Ang lahat ng iba pa ay gumagana pa rin nang eksakto tulad ng isinulat ng may-akda ng tema — ang `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, ang mga background at ang mga preview ay pawang pinapanatili. Tanging ang naalis lamang ang muling binubuo mula sa `colors.toml` sa makina mo.

Pinag-iiba ng Omarchy ang dalawa batay sa kung ang tema ay may sarili nitong git repo sa loob nito, na siyang iniiwan ng `omarchy theme install` kapag nagko-clone ito. Kaya ang temang isinulat mo ay nananatiling sa iyo, at ang isa na hinila mo mula sa internet ay nananatiling mga kulay lamang.

### Light mode

Kung gumagawa ka ng tema para sa light mode, itakda ang `mode = "light"` sa itaas ng `colors.toml` mo. Pagkatapos ay awtomatiko itong ipapares sa light mode para sa lahat ng app. (Ang lumang paraan ng paghulog ng walang laman na file na tinatawag na `light.mode` sa root ng tema mo ay gumagana pa rin.)

### Mga kulay ng icon

Kung gusto mong itugma ang kulay ng mga icon ng file manager sa tema mo, magdagdag ng file na tinatawag na `icons.theme` na may pangalan ng hanay ng icon na gusto mong gamitin. Bilang default, ang mga opsyon ay: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Larawan para sa unlock

Ang mga temang may kasamang larawang `unlock.png` at `preview-unlock.png` ay ililista sa ilalim ng _Estilo > I-unlock_. Ang `unlock.png` mo ay mas mainam na maging isang transparent na png. At maaari mong gawin ang preview image gamit ang `omarchy plymouth preview`.

### Pag-tema ng mga app na hindi sakop ng Omarchy

Kung gumagamit ka ng app na wala sa listahang iyon, maaari mong turuan ang Omarchy na i-tema ito nang sarili mo gamit ang isang template. Maghulog ng file sa `~/.config/omarchy/themed/` na pinangalanan ayon sa config na binubuo nito kasama ang extension na `.tpl`, at isulat ang config gamit ang `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hanggang `{{ color15 }}`, at ang natitirang palette bilang mga placeholder. Tuwing magpapalit ka ng tema, muling binubuo ang file gamit ang mga kulay ng temang iyon.

May isang ganap na nakakomentong `alacritty.toml.tpl.sample` sa folder na iyon na maaari mong kopyahin — inililista nito ang bawat variable na maaari mong gamitin, kasama ang mga modifier na `_strip` at `_rgb` para sa mga app na gusto ang kanilang mga kulay nang walang `#` o bilang decimal na RGB. Ang iyong mga template ay nangunguna kaysa sa mga template ng Omarchy mismo, kaya maaari mo rin itong gamitin para i-override kung paano tine-tema ang isang built-in na app.

### Pamamahagi ng tema mo

Kung gusto mong ipamahagi ang tema mo para magamit ito ng iba, kailangan mo itong ilagay sa isang pampublikong git server, tulad ng GitHub. Pagkatapos ay mai-install ito ng mga tao gamit ang _I-install > Estilo > Tema_ sa menu ng Omarchy gamit ang URL na iyon. Inirerekomenda na sundin mo ang kumbensyon ng pagbibigay-pangalan na `omarchy-[themename]-theme`, dahil ang tema ay lalabas nang tama bilang `[themename]` lamang sa menu ng pagpili ng tema pagkatapos ng pag-install.

Ang natitirang `[themename]` na iyon ay nagiging pangalan ng direktoryo ng tema, kaya kailangan itong isa na ligtas na maipapasa-pasa ng Omarchy: dapat itong magsimula sa isang titik, isang digit, o isang underscore, at ang natitira ay maaaring maglaman ng mga titik, digit, `.`, `_`, `+`, at `-`. Ang mga malalaking titik ay ginagawang maliit para sa iyo, pero anumang iba pa — isang espasyo, isang quote, isang character na hindi Ingles — ay tinatanggihan sa oras ng pag-install imbes na gawing pangalan ng direktoryo. Kaya ang `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, at `omarchy-c++-theme` ay pawang mai-install nang maayos.

Tandaan na kapag na-install na ito mula sa isang repo, ang anumang `.lua`, config ng terminal o `vscode.json` na kasama nito ay aalisin, kaya huwag mong buuin ang tema sa paligid ng mga iyon.

Maaari mong ipadagdag ang tema mo sa [pahina ng mga dagdag na tema](https://omarchy.org/themes/) sa pamamagitan ng pagpapadala ng pull request sa [repo ng omarchy-site](https://github.com/omacom-io/omarchy-site).
