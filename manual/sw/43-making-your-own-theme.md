# Kutengeneza mandhari yako mwenyewe

Unaweza kuongeza mandhari zako mwenyewe kwenye `~/.config/omarchy/themes`. Nakili tu mojawapo ya zilizopo kama msingi (angalia katika `/usr/share/omarchy/themes`), kisha irekebishe upendavyo. Mradi mandhari yako iko ndani ya folda hiyo, itajumuishwa katika menyu ya kuchagua mandhari.

Faili kuu unayopaswa kurekebisha ni `colors.toml`. Hiyo hufafanua seti ya rangi inayotumika kisha kutengeneza usanidi wa terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, na shell nzima ya Omarchy (upau wa juu, menyu, arifa, OSD, na skrini ya kufunga).

Unaweza pia kutumia programu ya Aether iliyojumuishwa kuunda mandhari mpya kwa kutumia kiolesura kizuri cha GUI kucheza na rangi na kutafuta mandharinyuma. Ianzishe tu kutoka kwenye gridi ya programu kwa `Super + Alt + Space`.

### Mandhari iliyosakinishwa inaweza kuwa na nini

Mandhari unayoandika mwenyewe katika `~/.config/omarchy/themes` inaweza kuwa na chochote unachopenda — ni mashine yako na faili yako, na Omarchy hutumia yote.

Mandhari unayosakinisha kutoka kwenye hazina ya mtu mwingine kwa `omarchy theme install` huhifadhi kila kitu ambacho ni rangi, na hupoteza faili chache ambazo zingeendesha msimbo kwenye mashine yako: faili yoyote ya `.lua`, usanidi wa terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), na `vscode.json`. `hyprland.lua` ya mandhari ni Lua ambayo compositor wako huendesha unapoingia, usanidi wa terminal hutaja programu ambayo terminal yako huanzisha, na `vscode.json` hutaja kiendelezi cha VSCode cha kusakinisha. Kusakinisha mandhari ya mtu kunapaswa kubadilisha mwonekano wa desktop yako, kamwe si kile inachoendesha.

Kila kitu kingine bado hufanya kazi hasa kama mwandishi wa mandhari alivyoandika — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, mandharinyuma na hakiki zote huhifadhiwa. Ni kile tu kilichoondolewa ndicho hutengenezwa upya kutoka `colors.toml` kwenye mashine yako.

Omarchy hutofautisha hayo mawili kwa kuangalia kama mandhari ina hazina yake yenyewe ya git ndani yake, ambayo ndiyo `omarchy theme install` huacha nyuma inapokloni. Hivyo mandhari uliyoandika hubaki yako, na ile uliyochukua kutoka kwenye intaneti hubaki rangi tu.

### Hali nyepesi

Ikiwa unatengeneza mandhari ya hali nyepesi, weka `mode = "light"` juu ya `colors.toml` yako. Kisha itaoanishwa kiotomatiki na hali nyepesi kwa programu zote. (Njia ya zamani ya kuweka faili tupu iitwayo `light.mode` kwenye mzizi wa mandhari yako pia bado inafanya kazi.)

### Rangi za aikoni

Ikiwa ungependa kufanya aikoni za kidhibiti faili zilingane na rangi za mandhari yako, ongeza faili iitwayo `icons.theme` yenye jina la seti ya aikoni unayotaka kutumia. Kwa chaguo-msingi, chaguo ni: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Picha ya kufungua

Mandhari zinazotolewa na picha za `unlock.png` na `preview-unlock.png` zitaorodheshwa chini ya _Appearance > Unlock_. `unlock.png` yako inapaswa ikiwezekana kuwa png yenye uwazi. Na unaweza kuunda picha ya hakiki kwa kutumia `omarchy plymouth preview`.

### Kupaka mandhari programu ambazo Omarchy haishughulikii

Ikiwa unatumia programu ambayo haiko kwenye orodha hiyo, unaweza kuifundisha Omarchy kuipaka mandhari mwenyewe kwa kutumia kiolezo. Weka faili katika `~/.config/omarchy/themed/` yenye jina la usanidi inaotengeneza pamoja na kiendelezi cha `.tpl`, na uandike usanidi kwa `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hadi `{{ color15 }}`, na paleti iliyobaki kama vishikilia nafasi. Kila unapobadilisha mandhari, faili hutengenezwa upya kwa rangi za mandhari hiyo.

Kuna `alacritty.toml.tpl.sample` yenye maelezo kamili katika folda hiyo ya kunakili kutoka — inaorodhesha kila kigezo unachoweza kutumia, pamoja na virekebishaji vya `_strip` na `_rgb` kwa programu zinazotaka rangi zao bila `#` au kama RGB ya desimali. Violezo vyako huchukua kipaumbele kuliko vya Omarchy yenyewe, hivyo unaweza pia kutumia hii kubatilisha jinsi programu iliyojengewa ndani inavyopakiwa mandhari.

### Kusambaza mandhari yako

Ikiwa unataka kusambaza mandhari yako ili wengine waweze kuitumia, unahitaji kuiweka kwenye seva ya umma ya git, kama GitHub. Kisha watu wanaweza kuisakinisha kwa kutumia _Install > Style > Theme_ katika menyu ya Omarchy kwa kutumia URL hiyo. Inapendekezwa ufuate kanuni ya majina ya `omarchy-[themename]-theme`, kwani mandhari itaonekana kwa usahihi kama `[themename]` tu katika menyu ya kuchagua mandhari baada ya kusakinishwa.

Hiyo `[themename]` iliyobaki inakuwa jina la saraka ya mandhari, hivyo lazima iwe moja ambayo Omarchy inaweza kuisambaza kwa usalama: lazima ianze na herufi, tarakimu, au alama ya chini, na iliyobaki inaweza kuwa na herufi, tarakimu, `.`, `_`, `+`, na `-`. Herufi kubwa hubadilishwa kuwa ndogo kwa ajili yako, lakini kitu kingine chochote — nafasi, nukuu, herufi isiyo ya Kiingereza — hukataliwa wakati wa kusakinisha badala ya kugeuzwa kuwa jina la saraka. Hivyo `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, na `omarchy-c++-theme` zote husakinishwa vizuri.

Kumbuka kwamba mara inaposakinishwa kutoka kwenye hazina, `.lua` yoyote, usanidi wa terminal au `vscode.json` inayokuja nayo huondolewa, hivyo usiijenge mandhari kuzunguka hizo.

Unaweza kufanya mandhari yako iongezwe kwenye [ukurasa wa mandhari za ziada](https://omarchy.org/themes/) kwa kutuma pull request kwenye [hazina ya omarchy-site](https://github.com/omacom-io/omarchy-site).
