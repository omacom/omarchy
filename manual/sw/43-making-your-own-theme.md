# Kutengeneza mandhari yako mwenyewe

Unaweza kuongeza mandhari yako mwenyewe kwenye `~/.config/omarchy/themes`. Nakili tu mojawapo ya zilizopo kama msingi (angalia katika `/usr/share/omarchy/themes`), kisha irekebishe upendavyo. Ilimradi mandhari yako iko ndani ya folda hiyo, itajumlishwa katika menyu ya kuchagua mandhari.

Faili kuu unayopaswa kurekebisha ni `colors.toml`. Hiyo hufafanua seti ya rangi ambayo kisha hutumika kutengeneza usanidi wa terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, programu za Qt, mwanga wa nyuma wa kibodi, mbinu ya uingizaji, kiteua cha kushiriki skrini, aikoni za programu, zana kadhaa za AI (Claude, Pi, Hermes, T3 Code, Herdr), na ganda zima la Omarchy (upau wa juu, menyu, arifa, OSD, na skrini ya kufunga).

Unaweza pia kutumia programu iliyojumuishwa ya Aether kutengeneza mandhari mpya kwa kutumia kiolesura kizuri cha GUI kucheza na rangi na kutafuta mandharinyuma. Ianzishe tu kutoka kwenye gridi ya programu kwa `Super + Alt + Space`.

### Mandhari iliyosakinishwa inaweza kuwa na nini

Mandhari unayojiandikia mwenyewe katika `~/.config/omarchy/themes` inaweza kuwa na chochote unachopenda — ni mashine yako na faili yako, na Omarchy hutumia yote.

Mandhari unayoisakinisha kutoka kwenye hazina ya mtu mwingine kwa `omarchy theme install` hubakiza kila kitu kilicho rangi, na hupoteza faili chache ambazo zingeendesha msimbo kwenye mashine yako: faili yoyote ya `.lua`, usanidi wa terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), na `vscode.json`. `hyprland.lua` ya mandhari ni Lua ambayo kitunzi chako huendesha unapoingia, usanidi wa terminal hutaja programu ambayo terminal yako huanzisha, na `vscode.json` hutaja kiendelezi cha VSCode cha kusakinisha. Kusakinisha mandhari ya mtu kunapaswa kubadilisha mwonekano wa eneo-kazi lako, kamwe si kile inachoendesha.

Kila kitu kingine bado hufanya kazi haswa kama mwandishi wa mandhari alivyokiandika — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, mandharinyuma na hakiki zote hubakizwa. Ni kile tu kilichoondolewa ndicho hutengenezwa upya kutoka `colors.toml` kwenye mashine yako.

Omarchy hutofautisha hayo mawili kwa iwapo mandhari ina hazina yake yenyewe ya git ndani yake, ambayo ndiyo `omarchy theme install` huacha nyuma inapokiloni. Kwa hivyo mandhari uliyoandika hubaki yako, na uliyoivuta kutoka kwenye intaneti hubaki rangi.

### Hali nyepesi

Ikiwa unatengeneza mandhari ya hali nyepesi, weka `mode = "light"` juu ya `colors.toml` yako. Kisha itaoanishwa kiotomatiki na hali nyepesi kwa programu zote. (Njia ya zamani ya kudondosha faili tupu inayoitwa `light.mode` kwenye mzizi wa mandhari yako bado inafanya kazi pia.)

### Skrini za kuwasha na kuingia

Skrini inayoomba nenosiri la diski wakati wa kuwasha, na skrini ya kuingia, huchora nembo ya Omarchy kwa rangi ya `accent` ya mandhari yako kwenye `background` yake, huku sehemu ya nenosiri ikiwa katika `foreground` yake na `red` kwa nenosiri lisilo sahihi. Hakuna cha ziada cha kutuma kwa ajili yao: Omarchy haitumii tena `unlock.png` au `preview-unlock.png` ya mandhari. Kwenye Apple Silicon Macs, skrini ya nenosiri la diski hubakiza mwonekano chaguo-msingi wa Omarchy haijalishi mandhari.

### Kuwekea mandhari programu ambazo Omarchy haizishughulikii

Ikiwa unatumia programu ambayo haimo kwenye orodha hiyo, unaweza kuifundisha Omarchy kuiwekea mandhari mwenyewe kwa kiolezo. Dondosha faili katika `~/.config/omarchy/themed/` iliyopewa jina la usanidi inaoutengeneza pamoja na kiendelezi cha `.tpl`, na uandike usanidi kwa `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hadi `{{ color15 }}`, na paleti iliyobaki kama vishikilia nafasi. Kila unapobadilisha mandhari, faili hutengenezwa upya kwa rangi za mandhari hiyo.

Kuna `alacritty.toml.tpl.sample` iliyoelezewa kikamilifu katika folda hiyo ya kunakili kutoka kwayo — inaorodhesha kila kigezo unachoweza kutumia, pamoja na virekebishaji vya `_strip` na `_rgb` kwa programu zinazotaka rangi zao bila `#` au kama RGB ya desimali. Violezo vyako huchukua kipaumbele kuliko vya Omarchy yenyewe, kwa hivyo unaweza pia kutumia hii kubatilisha jinsi programu iliyojengwa ndani inavyowekewa mandhari.

### Kusambaza mandhari yako

Ikiwa unataka kusambaza mandhari yako ili wengine waweze kuitumia, unahitaji kuiweka kwenye seva ya umma ya git, kama GitHub. Kisha watu wanaweza kuisakinisha kwa kutumia _Sakinisha > Mtindo > Mandhari_ katika menyu ya Omarchy kwa kutumia URL hiyo. Inapendekezwa ufuate kanuni ya upeaji majina ya `omarchy-[themename]-theme`, kwani mandhari itaonyeshwa kwa usahihi kama `[themename]` tu katika menyu ya kuchagua mandhari baada ya usakinishaji.

Hiyo `[themename]` iliyobaki huwa jina la saraka ya mandhari, kwa hivyo inapaswa kuwa ambayo Omarchy inaweza kuisambaza kwa usalama: lazima ianze na herufi, tarakimu, au mstari chini, na iliyobaki inaweza kuwa na herufi, tarakimu, `.`, `_`, `+`, na `-`. Herufi kubwa hubadilishwa kwako kuwa herufi ndogo, lakini kitu kingine chochote — nafasi, alama ya nukuu, herufi isiyo ya Kiingereza — hukataliwa wakati wa kusakinisha badala ya kugeuzwa kuwa jina la saraka. Kwa hivyo `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, na `omarchy-c++-theme` zote husakinishwa vizuri.

Kumbuka kwamba mara inapoisakinisha kutoka kwenye hazina, `.lua` yoyote, usanidi wa terminal au `vscode.json` inayoituma huondolewa, kwa hivyo usijenge mandhari kuzunguka hizo.

Unaweza kuifanya mandhari yako iongezwe kwenye [ukurasa wa mandhari za ziada](https://omarchy.org/themes/) kwa kutuma pull request kwenye [hazina ya omarchy-site](https://github.com/omacom-io/omarchy-site).
