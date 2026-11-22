# Dotfiles

Omarchy hasa imesanidiwa kupitia faili zinazoitwa dotfiles zinazoishi katika `~/.config`. Hizo zinachukuliwa kama faili zako kwa ajili ya mabadiliko yako. Faili zinazoishi katika `/usr/share/omarchy` ni za Omarchy yenyewe, na hupaswi kuzigusa. Ikiwa unahitaji kubadilisha chochote katika `/usr/share/omarchy`, unapaswa kubatilisha thamani hiyo katika `~/.config` badala yake.

Usanidi muhimu unaweza kuhaririwa moja kwa moja kutoka kwenye menyu ya Omarchy (`Super + Space`), kama vile _Mpangilio > Kibodi > Vifungo vya vitufe_, _Mpangilio > Ingizo_, na _Mpangilio > Usanidi > [file]_. Unapofanya hivyo, mchakato wowote unaohitaji kuanzishwa upya baada ya uhariri wa usanidi utafanya hivyo kiotomatiki baada ya kuondoka kwenye kihariri (Neovim kwa chaguo-msingi — `:wq`, kumbuka! — lakini unaweza kubadilisha hilo kupitia _Mpangilio > Chaguo-msingi > Kihariri_).

Hapa kuna orodha ya faili muhimu katika `~/.config` na kile zinachodhibiti:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Usanidi mkuu wa Hyprland. Hupakia chaguo-msingi za Omarchy pamoja na faili zako za kubatilisha zilizo hapa chini. [Pata maelezo zaidi kuhusu usanidi wa Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vifungo vyako vya vitufe na ubatilishaji wako wa chaguo-msingi. |
| `~/.config/hypr/monitors.lua` | Mipangilio ya monita ambayo paneli ya monita haishughulikii, kama vile mzunguko, hali za ziada, au kuweka monita ikiwa imezimwa. |
| `~/.config/hypr/input.lua` | Hudhibiti mpangilio wa kibodi yako, kipanya, na mipangilio ya trackpad. |
| `~/.config/hypr/looknfeel.lua` | Hudhibiti mapengo, mipaka, uhuishaji, na mwonekano uliobaki. |
| `~/.config/hypr/autostart.lua` | Hudhibiti michakato ya ziada inayoanzishwa na kipindi. |
| `~/.config/omarchy/shell.json` | Hudhibiti shell ya Omarchy: nafasi ya mwambaa, mpangilio, na wijeti, pamoja na nyakati za screensaver, za kufunga, na za kutofanya kazi. |
| `~/.config/foot/foot.ini` | Hudhibiti terminal yako (foot ndiyo chaguo-msingi). |
| `~/.XCompose` | Hufafanua emoji zako za ufikiaji wa haraka na ukamilishaji otomatiki wa jina/barua pepe. Hakikisha unaendesha `omarchy-restart-xcompose` baada ya kufanya mabadiliko. |

Ikiwa mwishowe utafanya mabadiliko mengi ili kurekebisha usanidi wako mwenyewe, ni wazo zuri kuhifadhi nakala za dotfiles hizi zote. [Stow ni njia nzuri ya kufanya hivyo](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Kuanzisha programu zako mwenyewe pamoja na kipindi

Ikiwa unataka kitu kiendeshwe kila unapoingia — daemon ya usawazishaji, programu ya gumzo, hati yako mwenyewe — kiweke katika `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Hiyo huanzisha amri hiyo kama sehemu ya kipindi, kwa hivyo husafishwa ipasavyo unapotoka tena.

### Kuendesha hati kwenye matukio ya mfumo

Omarchy huanzisha hooks katika nyakati chache, na unaweza kuambatisha hati zako mwenyewe juu yake. Zinaishi katika `~/.config/omarchy/hooks/<event>.d/`, saraka moja kwa kila tukio, na kila faili iliyo humo ambayo haiishii na `.sample` huendeshwa kwa bash tukio linapotokea:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Mara tu baada ya eneo-kazi kuanza |
| `post-update` | Karibu na mwisho wa `omarchy update`, baada ya vifurushi, uhamiaji, na kuanzisha upya huduma, kabla ya zana za mise kusasishwa |
| `pre-refresh-pacman` | Baada ya `omarchy refresh pacman` kusawazisha upya usanidi wa vifurushi, kabla ya kusasisha vifurushi; ubadilishaji wa kituo huendesha hii wakati wa hatua hiyo hiyo ya kuonyesha upya |
| `theme-set` | Baada ya mabadiliko ya mandhari (jina la mandhari katika `$1`) |
| `font-set` | Baada ya mabadiliko ya fonti (jina la fonti katika `$1`) |
| `battery-low` | Betri inapokuwa chini (asilimia katika `$1`) |

Hook ya `pre-refresh-pacman` ni mahali ambapo hazina maalum au mistari ya `IgnorePkg` inapaswa kuwa, kwa kuwa huendeshwa kabla ya muamala wa kifurushi. Zote mbili huendeshwa kama mtumiaji wako. `post-update` huendeshwa wakati idhini ya sudo ya `omarchy update` bado ni mpya, kwa hivyo hook inayotumia `sudo` haitaomba nenosiri lako tena; `pre-refresh-pacman` huendeshwa mara tu baada ya `omarchy refresh pacman` kutumia sudo yenyewe.

Kila moja ya saraka hizo tayari ina faili ya `.sample` inayoonyesha umbo la hook — ondoa `.sample` kutoka kwenye jina ili ianze kufanya kazi. Ili kusakinisha hati uliyoandika mahali pengine, tumia `omarchy hook install post-boot ~/my-hook`, ambayo huinakili ndani na kuifanya iweze kutekelezwa.

### Kuongeza maingizo yako mwenyewe ya menyu

Menyu ya Omarchy (`Super + Space`) inaweza kupanuliwa kwa safu zako mwenyewe kwa kuhariri `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Maingizo yamewekwa kwa kitambulisho chenye nukta, na kitambulisho ndicho kinachoyaweka kwenye mti, kwa hivyo `personal` huonekana kwenye menyu ya mizizi na `personal.notes` huonekana ndani yake:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Tumia tena kitambulisho kilichopo na unabatilisha safu hiyo badala ya kuongeza mpya. Faili huja na sehemu zote zinazopatikana zikiwa zimeandikwa kama maoni.

### Kuongeza exports, vitendaji, na alias zako mwenyewe za shell

Omarchy huja na alias nyingi zinazofaa na vitendaji vya kusaidia, lakini ni kawaida sana kutaka kuongeza vyako mwenyewe. Unapaswa kuongeza alias, vitendaji, na exports zote katika `~/.bashrc`. Faili hii haitaandikwa upya wakati wa masasisho. Ikiwa unataka kubadilisha chaguo-msingi zozote za Omarchy, unaweza pia kuziongeza hapa kwa usalama.

### Kuweka vigezo vya mazingira kwa ajili ya eneo-kazi

Exports za kipindi cha eneo-kazi zinapaswa kuwa katika `~/.config/uwsm/env.d/`. Faili hizi huendeshwa kabla ya eneo-kazi lako kuanza, kwa hivyo hitilafu ya shell inaweza kukurudisha kwenye skrini ya kuingia. Weka terminal inayofanya kazi ikiwa wazi unapozihariri. Ili kulemaza ubatilishaji, uhamishe nje ya `env.d`. Tazama [uokoaji wa kuingia](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) ikiwa mabadiliko yanazuia kuingia.

### Kubadilisha faili za ndani za Omarchy

Angalia, hii ni kompyuta yako. Unaweza kufanya chochote unachotaka nayo, lakini ningekushauri dhidi ya kufanya mabadiliko kwenye faili katika `/usr/share/omarchy` moja kwa moja. Ni za kifurushi cha pacman cha Omarchy, kwa hivyo mabadiliko yako yataandikwa upya tu kwenye sasisho linalofuata. Afadhali ubatilishe tu thamani zozote za chaguo-msingi usizozipenda katika folda ya `~/.config/*` badala yake.

Unaweza kubadilisha karibu kila kitu kwa njia hiyo, kama vile vifungo vya vitufe vya chaguo-msingi. Hariri tu `~/.config/hypr/bindings.lua` ili, tuseme, kubadilisha [Obsidian](https://obsidian.md/) na [Joplin](https://joplinapp.org/) (sakinisha kwa `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` huondoa kifungo kilichopo kabla ya kuongeza mbadala wake. Inachukua hoja sawa na `o.bind`, ikiwa ni pamoja na wasaidizi wa kuanzisha na chaguo za vifungo. Tumia `o.bind` kuongeza kifungo, au `hl.unbind` kuondoa kimoja bila kukibadilisha.

Ikiwa unasisitiza kuharibu faili za ndani za Omarchy, badilisha hadi kituo cha dev kupitia _Sasisha > Kituo > Dev_. Hiyo huunganisha Omarchy na git checkout ya msimbo wa chanzo katika `~/omarchy`, ambayo uko huru kubadilisha upendavyo. Hakuna mtu hapa wa kukuambia la kufanya!

### Kuweka upya mabadiliko yoyote

Ikiwa mwishowe utaharibu usanidi, unaweza kila wakati kuurejesha kwenye chaguo-msingi kupitia _Sasisha > Usanidi_ katika menyu ya Omarchy. Au kwa kuendesha `omarchy reinstall configs` kuweka upya kila kitu.
