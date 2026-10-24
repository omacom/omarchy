# Kutengeneza mandhari yako mwenyewe

Unaweza kuongeza mandhari zako mwenyewe kwenye `~/.config/omarchy/themes`. Nakili tu moja ya zilizopo kama msingi (angalia katika `/usr/share/omarchy/themes`), kisha rekebisha kwa furaha yako. Mradi mandhari yako iko ndani ya folda hiyo, itajumuishwa katika menyu ya kuchagua mandhari.

Faili kuu unayopaswa kurekebisha ni `colors.toml`. Hiyo hufafanua seti ya rangi ambayo kisha hutumika kuzalisha usanidi kwa terminali (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, na shell nzima ya Omarchy (upau wa juu, menyu, arifa, OSD, na skrini ya kufunga).

Unaweza pia kutumia programu iliyojumuishwa ya Aether kuunda mandhari mpya kwa kutumia kiolesura kizuri cha GUI kuchezea rangi na kutafuta mandhari za nyuma. Ianzishe tu kutoka gridi ya programu kwa `Super + Alt + Space`.

### Mandhari iliyosakinishwa inaweza kuwa na nini

Mandhari unayojiandikia mwenyewe katika `~/.config/omarchy/themes` inaweza kuwa na unachopenda — ni mashine yako na faili yako, na Omarchy hutumia yote.

Mandhari unayosakinisha kutoka repo ya mtu mwingine kwa `omarchy theme install` hutunza kila kitu ambacho ni rangi, na hupoteza faili chache ambazo zingeendesha msimbo kwenye mashine yako: faili yoyote ya `.lua`, usanidi wa terminali (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), na `vscode.json`. `hyprland.lua` ya mandhari ni Lua ambayo kiunzi chako huendesha wakati wa kuingia, usanidi wa terminali hutaja programu ambayo terminali yako huanzisha, na `vscode.json` hutaja kiendelezi cha VSCode cha kusakinisha. Kusakinisha mandhari ya mtu kunapaswa kubadilisha jinsi eneo-kazi lako linavyoonekana, kamwe lisiendeshe nini.

Kila kitu kingine bado kinafanya kazi sawa kabisa kama mwandishi wa mandhari alivyokiandika — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, mandhari za nyuma na hakiki zote hutunzwa. Ni kile kilichoachwa tu ndicho huzalishwa upya kutoka `colors.toml` kwenye mashine yako.

Omarchy hutofautisha hizo mbili kwa kama mandhari ina repo yake ya git ndani yake, ambayo ndiyo `omarchy theme install` huiacha nyuma inapoklonia. Kwa hivyo mandhari uliyoiandika inabaki yako, na ile uliyoivuta kutoka intaneti inabaki rangi.

### Hali nyepesi (light mode)

Kama unatengeneza mandhari ya hali nyepesi, weka `mode = "light"` juu ya `colors.toml` yako. Kisha itaunganishwa kiotomatiki na hali nyepesi kwa programu zote. (Njia ya zamani ya kudondosha faili tupu iitwayo `light.mode` katika mizizi ya mandhari yako bado inafanya kazi pia.)

### Rangi za aikoni

Kama ungependa kuoanisha rangi za aikoni za kidhibiti cha faili na mandhari yako, ongeza faili iitwayo `icons.theme` yenye jina la seti ya aikoni unayoitaka kutumia. Kwa chaguomsingi, chaguo ni: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Picha ya kufungua

Mandhari zilizotolewa na picha za `unlock.png` na `preview-unlock.png` zitaorodheshwa chini ya _Mtindo > Fungua_. `unlock.png` yako inapaswa kuwa png angavu. Na unaweza kuunda picha ya hakiki kwa kutumia `omarchy plymouth preview`.

### Kuweka mandhari programu ambazo Omarchy haishughulikii

Kama unatumia programu ambayo haipo katika orodha hiyo, unaweza kufundisha Omarchy kuiwekela mandhari mwenyewe kwa kiolezo. Dondosha faili katika `~/.config/omarchy/themed/` iitwayo kulingana na usanidi unaozalisha pamoja na kiendelezi cha `.tpl`, na andika usanidi kwa `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` kupitia `{{ color15 }}`, na paleti yote iliyobaki kama vishika nafasi. Kila mara unapobadilisha mandhari, faili huzalishwa upya na rangi za mandhari hiyo.

Kuna `alacritty.toml.tpl.sample` iliyotolewa maoni kikamilifu katika folda hiyo ya kunakili kutoka — huorodhesha kila kigeuzi unachoweza kutumia, pamoja na vibadilishi vya `_strip` na `_rgb` kwa programu zinazotaka rangi zao bila `#` au kama RGB ya desimali. Violezo vyako huchukua kipaumbele juu ya vya Omarchy yenyewe, kwa hivyo unaweza pia kutumia hii kubatilisha jinsi programu iliyojengwa ndani inavyoekwa mandhari.

### Kusambaza mandhari yako

Kama unataka kusambaza mandhari yako ili wengine waweze kuitumia, unahitaji kuiweka kwenye seva ya git ya umma, kama GitHub. Kisha watu wanaweza kuisakinisha kwa kutumia _Sakinisha > Mtindo > Mandhari_ katika menyu ya Omarchy kwa kutumia URL hiyo. Pendekezo ni kwamba ufuate utamaduni wa kutaja wa `omarchy-[themename]-theme`, kwani mandhari itaonekana kwa usahihi kama `[themename]` tu katika menyu ya kuchagua mandhari baada ya kusakinisha.

`[themename]` hiyo iliyobaki inakuwa jina la saraka ya mandhari, kwa hivyo lazima iwe moja ambayo Omarchy inaweza kupitisha kwa usalama: lazima ianze na herufi, tarakimu, au mstari wa chini, na iliyobaki inaweza kuwa na herufi, tarakimu, `.`, `_`, `+`, na `-`. Herufi kubwa hugeuzwa kuwa ndogo kwa ajili yako, lakini kitu kingine chochote — nafasi, nukuu, herufi isiyo ya Kiingereza — hukataliwa wakati wa kusakinisha badala ya kugeuzwa kuwa jina la saraka. Kwa hivyo `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, na `omarchy-c++-theme` zote husakinika sawa.

Kumbuka kwamba mara ikisakinishwa kutoka repo, `.lua` yoyote, usanidi wa terminali au `vscode.json` inayopeleka huachwa, kwa hivyo usiijenge mandhari karibu na hizo.

Unaweza kuifanya mandhari yako iongezwe kwenye [ukurasa wa mandhari za ziada](https://omarchy.org/themes/) kwa kutuma ombi la kuvuta (pull request) kwenye [repo ya omarchy-site](https://github.com/omacom-io/omarchy-site).
