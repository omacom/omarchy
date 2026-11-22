# Kuunda mandhari yako mwenyewe

Unaweza kuongeza mandhari yako mwenyewe kwenye `~/.config/omarchy/themes`. Nakili tu mojawapo ya zilizopo kama msingi (angalia katika `/usr/share/omarchy/themes`), kisha irekebishe upendavyo. Kadiri mandhari yako ipo ndani ya folda hiyo, itajumuishwa katika menyu ya kuchagua mandhari.

Faili kuu unayopaswa kurekebisha ni `colors.toml`. Hiyo hufafanua seti ya rangi ambayo kisha hutumika kutengeneza usanidi kwa ajili ya terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, programu za Qt, mwangaza wa nyuma wa kibodi, mbinu ya kuingiza data, kichaguzi cha kushiriki skrini, aikoni za programu, zana kadhaa za AI (Claude, Pi, Hermes, T3 Code, Herdr), na shell nzima ya Omarchy (upau wa juu, menyu, arifa, OSD, na skrini ya kufunga).

Unaweza pia kutumia programu iliyojumuishwa ya Aether kuunda mandhari mpya kwa kutumia kiolesura kizuri cha GUI kucheza na rangi na kutafuta mandharinyuma. Ianzishe tu kutoka kwenye gridi ya programu kwa `Super + Alt + Space`.

### Mandhari iliyosakinishwa inaweza kuwa na nini

Mandhari unayoiandika mwenyewe katika `~/.config/omarchy/themes` inaweza kuwa na chochote unachotaka — ni mashine yako na faili yako, na Omarchy hutumia yote.

Mandhari unayoisakinisha kutoka kwenye repo ya mtu mwingine kwa `omarchy theme install` huhifadhi kila kitu ambacho ni rangi, na hupoteza faili chache ambazo zingeendesha msimbo kwenye mashine yako: faili yoyote ya `.lua`, usanidi wa terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), na `vscode.json`. Faili ya `hyprland.lua` ya mandhari ni Lua ambayo compositor yako huendesha unapoingia, usanidi wa terminal hutaja programu ambayo terminal yako huanzisha, na `vscode.json` hutaja kiendelezi cha VSCode cha kusakinisha. Kusakinisha mandhari ya mtu kunapaswa kubadilisha jinsi desktop yako inavyoonekana, kamwe si kile inachoendesha.

Kila kitu kingine bado hufanya kazi haswa kama mtunzi wa mandhari alivyoiandika — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, mandharinyuma na hakiki zote huhifadhiwa. Ni kile tu kilichoondolewa ndicho hutengenezwa upya kutoka kwenye `colors.toml` kwenye mashine yako.

Omarchy hutofautisha hayo mawili kwa kuangalia kama mandhari ina repo yake yenyewe ya git ndani yake, ambayo ndiyo `omarchy theme install` huacha nyuma inapoclone. Kwa hiyo mandhari uliyoiandika hubaki yako, na ile uliyoitoa kwenye intaneti hubaki rangi tu.

### Hali ya mwangaza

Ikiwa unaunda mandhari ya hali ya mwangaza, weka `mode = "light"` juu ya `colors.toml` yako. Kisha itaoanishwa kiotomatiki na hali ya mwangaza kwa programu zote. (Njia ya zamani ya kuweka faili tupu inayoitwa `light.mode` katika mzizi wa mandhari yako bado hufanya kazi pia.)

### Picha ya kufungua

Mandhari zinazotolewa na picha za `unlock.png` na `preview-unlock.png` zitaorodheshwa chini ya _Appearance > Unlock_. `unlock.png` yako inapaswa ikiwezekana kuwa png yenye uwazi. Na unaweza kuunda picha ya hakiki kwa kutumia `omarchy plymouth preview`.

### Kuweka mandhari kwa programu ambazo Omarchy haizishughulikii

Ikiwa unatumia programu ambayo haipo katika orodha hiyo, unaweza kuifundisha Omarchy kuiwekea mandhari mwenyewe kwa kiolezo. Weka faili katika `~/.config/omarchy/themed/` iliyopewa jina la usanidi inayozalisha pamoja na kiendelezi cha `.tpl`, na uandike usanidi kwa `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hadi `{{ color15 }}`, na paleti iliyobaki kama vishikilia nafasi. Kila unapobadilisha mandhari, faili hutengenezwa upya kwa rangi za mandhari hiyo.

Kuna `alacritty.toml.tpl.sample` iliyoelezewa kikamilifu katika folda hiyo ya kunakili kutoka kwayo — inaorodhesha kila kigezo unachoweza kutumia, pamoja na virekebishaji vya `_strip` na `_rgb` kwa programu zinazotaka rangi zao bila `#` au kama RGB ya desimali. Violezo vyako huchukua kipaumbele kuliko vya Omarchy yenyewe, kwa hiyo unaweza pia kutumia hii kubatilisha jinsi programu iliyojengwa ndani inavyowekewa mandhari.

### Kusambaza mandhari yako

Ikiwa unataka kusambaza mandhari yako ili wengine waweze kuitumia, unahitaji kuiweka kwenye seva ya umma ya git, kama GitHub. Kisha watu wanaweza kuisakinisha kwa kutumia _Install > Style > Theme_ katika menyu ya Omarchy kwa kutumia URL hiyo. Inapendekezwa ufuate kanuni ya kutaja ya `omarchy-[themename]-theme`, kwa kuwa mandhari itaonyeshwa kwa usahihi kama `[themename]` tu katika menyu ya kuchagua mandhari baada ya kusakinishwa.

Hilo `[themename]` lililobaki huwa jina la saraka ya mandhari, kwa hiyo lazima liwe jina ambalo Omarchy inaweza kulishughulikia kwa usalama: lazima lianze na herufi, tarakimu, au mstari wa chini, na sehemu iliyobaki inaweza kuwa na herufi, tarakimu, `.`, `_`, `+`, na `-`. Herufi kubwa hubadilishwa kuwa ndogo kwa ajili yako, lakini kitu kingine chochote — nafasi, nukuu, herufi isiyo ya Kiingereza — hukataliwa wakati wa kusakinisha badala ya kubadilishwa kuwa jina la saraka. Kwa hiyo `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, na `omarchy-c++-theme` zote husakinishwa vizuri.

Kumbuka kwamba mara tu inapokuwa imesakinishwa kutoka kwenye repo, faili yoyote ya `.lua`, usanidi wa terminal au `vscode.json` inayokuja nayo huondolewa, kwa hiyo usiijenge mandhari kuzunguka hizo.

Unaweza kuifanya mandhari yako iongezwe kwenye [ukurasa wa mandhari za ziada](https://omarchy.org/themes/) kwa kutuma pull request kwenye [repo ya omarchy-site](https://github.com/omacom-io/omarchy-site).
