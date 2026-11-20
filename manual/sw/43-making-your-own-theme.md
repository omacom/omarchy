# Kutengeneza mandhari yako mwenyewe

Unaweza kuongeza mandhari zako mwenyewe kwenye `~/.config/omarchy/themes`. Nakili tu mojawapo iliyopo kama msingi (angalia katika `/usr/share/omarchy/themes`), kisha irekebishe unavyopenda. Mradi mandhari yako iko ndani ya folda hiyo, itajumuishwa kwenye menyu ya kuchagua mandhari.

Faili kuu unayopaswa kurekebisha ni `colors.toml`. Hiyo hufafanua seti ya rangi ambayo kisha hutumika kutengeneza usanidi wa terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, na ganda zima la Omarchy (baa ya juu, menyu, arifa, OSD, na skrini ya kufunga).

Unaweza pia kutumia programu iliyojumuishwa ya Aether kuunda mandhari mpya kwa kutumia kiolesura kizuri cha GUI kucheza na rangi na kutafuta mandharinyuma. Ianzishe tu kutoka kwenye gridi ya programu kwa `Super + Alt + Space`.

### Mandhari iliyosakinishwa inaweza kuwa na nini

Mandhari unayoiandika mwenyewe katika `~/.config/omarchy/themes` inaweza kuwa na chochote unachotaka — ni mashine yako na faili yako, na Omarchy hutumia yote.

Mandhari unayoisakinisha kutoka kwenye repo ya mtu mwingine kwa `omarchy theme install` huhifadhi kila kitu ambacho ni rangi, na hupoteza faili chache ambazo zingeendesha msimbo kwenye mashine yako: faili yoyote ya `.lua`, usanidi wa terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), na `vscode.json`. `hyprland.lua` ya mandhari ni Lua ambayo compositor yako huendesha unapoingia, usanidi wa terminal hutaja programu ambayo terminal yako huanzisha, na `vscode.json` hutaja kiendelezi cha VSCode cha kusakinisha. Kusakinisha mandhari ya mtu kunapaswa kubadilisha mwonekano wa eneo-kazi lako, kamwe si kile kinachoendeshwa.

Kila kitu kingine bado hufanya kazi haswa kama mwandishi wa mandhari alivyokiandika — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, mandharinyuma na hakiki zote huhifadhiwa. Ni kile tu kilichoondolewa ndicho hutengenezwa upya kutoka kwenye `colors.toml` kwenye mashine yako.

Omarchy hutofautisha hizo mbili kwa kuangalia kama mandhari ina git repo yake yenyewe ndani yake, ambacho ndicho `omarchy theme install` huacha nyuma inapoclone. Kwa hiyo mandhari uliyoiandika hubaki yako, na ile uliyoipakua kutoka kwenye intaneti hubaki rangi tu.

### Hali ya mwanga

Ikiwa unatengeneza mandhari ya hali ya mwanga, weka `mode = "light"` juu ya `colors.toml` yako. Kisha itaoanishwa kiotomatiki na hali ya mwanga kwa programu zote. (Njia ya zamani ya kuweka faili tupu inayoitwa `light.mode` kwenye mzizi wa mandhari yako bado inafanya kazi pia.)

### Picha ya kufungua

Mandhari zinazotolewa na picha za `unlock.png` na `preview-unlock.png` zitaorodheshwa chini ya _Mwonekano > Fungua_. `unlock.png` yako ikiwezekana inapaswa kuwa png yenye uwazi. Na unaweza kuunda picha ya hakiki kwa kutumia `omarchy plymouth preview`.

### Kutia mandhari programu ambazo Omarchy haizishughulikii

Ikiwa unatumia programu ambayo haipo kwenye orodha hiyo, unaweza kuifundisha Omarchy kuitia mandhari mwenyewe kwa kiolezo. Weka faili katika `~/.config/omarchy/themed/` iliyopewa jina la usanidi inaoutengeneza pamoja na kiendelezi cha `.tpl`, na uandike usanidi kwa `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` kupitia `{{ color15 }}`, na paleti iliyobaki kama vishika nafasi. Kila unapobadilisha mandhari, faili hutengenezwa upya kwa rangi za mandhari hiyo.

Kuna `alacritty.toml.tpl.sample` yenye maelezo kamili katika folda hiyo ya kunakili — inaorodhesha kila kigezo unachoweza kutumia, pamoja na vibadilishi vya `_strip` na `_rgb` kwa programu zinazotaka rangi zao bila `#` au kama RGB ya desimali. Violezo vyako huchukua kipaumbele kuliko vya Omarchy yenyewe, kwa hiyo unaweza pia kutumia hii kubatilisha jinsi programu iliyojengewa ndani inavyotiwa mandhari.

### Kusambaza mandhari yako

Ikiwa unataka kusambaza mandhari yako ili wengine waweze kuitumia, unahitaji kuiweka kwenye seva ya git ya umma, kama GitHub. Kisha watu wanaweza kuisakinisha kwa kutumia _Sakinisha > Mtindo > Mandhari_ kwenye menyu ya Omarchy kwa kutumia URL hiyo. Inapendekezwa ufuate kanuni ya majina ya `omarchy-[themename]-theme`, kwani mandhari itaonyeshwa vizuri kama `[themename]` tu kwenye menyu ya kuchagua mandhari baada ya kusakinishwa.

Hiyo `[themename]` iliyobaki inakuwa jina la saraka ya mandhari, kwa hiyo inapaswa kuwa moja ambayo Omarchy inaweza kuishughulikia kwa usalama: lazima ianze na herufi, tarakimu, au mstari wa chini, na sehemu iliyobaki inaweza kuwa na herufi, tarakimu, `.`, `_`, `+`, na `-`. Herufi kubwa hubadilishwa kwako kuwa herufi ndogo, lakini kitu kingine chochote — nafasi, nukuu, herufi isiyo ya Kiingereza — hukataliwa wakati wa kusakinisha badala ya kugeuzwa kuwa jina la saraka. Kwa hiyo `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, na `omarchy-c++-theme` zote husakinishwa vizuri.

Kumbuka kwamba mara tu inapokuwa imesakinishwa kutoka kwenye repo, `.lua` yoyote, usanidi wa terminal au `vscode.json` inayokuja nayo huondolewa, kwa hiyo usijenge mandhari kuzunguka hizo.

Unaweza kufanya mandhari yako iongezwe kwenye [ukurasa wa mandhari za ziada](https://omarchy.org/themes/) kwa kutuma pull request kwenye [repo ya omarchy-site](https://github.com/omacom-io/omarchy-site).
