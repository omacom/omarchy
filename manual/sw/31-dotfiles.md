# Dotfiles

Omarchy imepangiliwa hasa kupitia kinachoitwa dotfiles vinavyoishi katika `~/.config`. Hizo huchukuliwa kama faili zako kwa ajili ya mabadiliko yako. Faili zinazoishi katika `/usr/share/omarchy` ni za Omarchy yenyewe, na hupaswi kuzichezea. Ikiwa unahitaji kubadilisha chochote katika `/usr/share/omarchy`, unapaswa kuandika upya thamani hiyo katika `~/.config` badala yake.

Mipangilio muhimu inaweza kuhaririwa moja kwa moja kutoka menyu ya Omarchy (`Super + Space`), kama _Setup > Keybindings_, _Setup > Input_, na _Setup > Config > [file]_. Unapofanya hivyo, mchakato wowote unaohitaji kuanzishwa upya baada ya kuhariri mipangilio utaanzishwa upya kiotomatiki baada ya kuacha kihariri (Neovim kwa chaguo-msingi — `:wq`, kumbuka! — lakini unaweza kuibadilisha kupitia _Setup > Defaults > Editor_).

Hii hapa ni orodha ya faili muhimu katika `~/.config` na kile zinachodhibiti:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Mipangilio mkuu ya Hyprland. Hupakia chaguo-msingi za Omarchy pamoja na faili zako za kubatilisha zilizo hapa chini. [Jifunze zaidi kuhusu mipangilio ya Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vifungo vyako vya vitufe na ubatilishaji wako wa chaguo-msingi. |
| `~/.config/hypr/monitors.lua` | Mipangilio ya kioo ambayo paneli ya kioo haishughulikii, kama mzunguko, hali za ziada, au kuacha kioo kimezimwa. |
| `~/.config/hypr/input.lua` | Hudhibiti mpangilio wa kibodi yako, kipanya, na mipangilio ya trackpad. |
| `~/.config/hypr/looknfeel.lua` | Hudhibiti mapengo, mipaka, uhuishaji, na mwonekano uliobaki. |
| `~/.config/hypr/autostart.lua` | Hudhibiti michakato ya ziada inayoanzishwa na kipindi. |
| `~/.config/omarchy/shell.json` | Hudhibiti shell ya Omarchy: nafasi ya upau, mpangilio, na wijeti, pamoja na muda wa kiokoa skrini, kufunga, na kutotumika. |
| `~/.config/foot/foot.ini` | Hudhibiti terminal yako (foot ni chaguo-msingi). |
| `~/.XCompose` | Hufafanua emoji zako za ufikiaji wa haraka na ukamilishaji otomatiki wa jina/barua pepe. Hakikisha unaendesha `omarchy-restart-xcompose` baada ya kufanya mabadiliko. |

Ikiwa mwishowe utafanya mabadiliko mengi ili kurekebisha usanidi wako mwenyewe, ni wazo zuri kuhifadhi nakala za dotfiles hizi zote. [Stow ni njia nzuri ya kufanya hivyo](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Kuanzisha programu zako mwenyewe na kipindi

Ikiwa unataka kitu kiendeshwe kila unapoingia — daemon ya kusawazisha, programu ya gumzo, skripti yako mwenyewe — kiweke katika `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Hiyo huanzisha amri kama sehemu ya kipindi, kwa hiyo husafishwa ipasavyo unapotoka tena.

### Kuendesha skripti kwenye matukio ya mfumo

Omarchy hurusha hooks katika nyakati chache, na unaweza kutundika skripti zako mwenyewe juu yake. Zinaishi katika `~/.config/omarchy/hooks/<event>.d/`, saraka moja kwa kila tukio, na kila faili inayoweza kutekelezwa iliyomo humo huendeshwa tukio linapotokea:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Mara tu baada ya eneo-kazi kuanza |
| `post-update` | Karibu na mwisho wa `omarchy update`, baada ya vifurushi, uhamishaji, na kuanzishwa upya kwa huduma, kabla ya zana za mise kusasishwa |
| `pre-refresh-pacman` | Baada ya `omarchy refresh pacman` kusawazisha upya mipangilio ya vifurushi, kabla ya kusasisha vifurushi; kubadilisha chaneli huendeshwa wakati wa hatua hiyo hiyo ya kuonyesha upya |
| `theme-set` | Baada ya kubadilisha mandhari (jina la mandhari katika `$1`) |
| `font-set` | Baada ya kubadilisha fonti (jina la fonti katika `$1`) |
| `battery-low` | Betri inapokuwa chini (asilimia katika `$1`) |

Hook ya `pre-refresh-pacman` ndipo hazina maalum au mistari ya `IgnorePkg` inapaswa kuwepo, kwa kuwa huendeshwa kabla ya muamala wa vifurushi. Hooks zote mbili zinazohusiana na usasishaji huendeshwa kama mtumiaji wako baada ya Omarchy kufuta idhini yake ya sudo iliyohifadhiwa, kwa hiyo hook inayotumia `sudo` inahitaji idhini yake yenyewe na inaweza kukuomba nenosiri lako.

Kila moja ya saraka hizo tayari ina faili ya `.sample` inayoonyesha umbo la hook — ondoa `.sample` kutoka kwenye jina ili kuifanya ifanye kazi. Ili kusakinisha skripti uliyoandika mahali pengine, tumia `omarchy hook install post-boot ~/my-hook`, ambayo huinakili ndani na kuifanya iweze kutekelezwa.

### Kuongeza vipengee vyako mwenyewe vya menyu

Menyu ya Omarchy (`Super + Space`) inaweza kupanuliwa kwa safu zako mwenyewe kwa kuhariri `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Vipengee vimewekewa funguo kwa kitambulisho chenye nukta, na kitambulisho ndicho kinachoviweka kwenye mti, kwa hiyo `personal` huonekana kwenye menyu kuu na `personal.notes` huonekana ndani yake:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ukikitumia tena kitambulisho kilichopo unabatilisha safu hiyo badala ya kuongeza mpya. Faili huja na sehemu zote zinazopatikana zimeandikwa kama maoni.

### Kuongeza exports, functions, na aliases zako mwenyewe za shell

Omarchy huja na lakabu nyingi zinazofaa na vitendakazi vya kusaidia, lakini ni jambo la kawaida sana kutaka kuongeza vyako mwenyewe. Unapaswa kuongeza lakabu, vitendakazi, na exports zote katika `~/.bashrc`. Faili hii haitabatilishwa wakati wa masasisho. Ikiwa unataka kubadilisha chaguo-msingi zozote za Omarchy, unaweza pia kuziongeza hapa kwa usalama.

### Kuweka vigezo vya mazingira kwa ajili ya eneo-kazi

Exports za kipindi cha eneo-kazi zinapaswa kuwa katika `~/.config/uwsm/env.d/`. Faili hizi huendeshwa kabla ya eneo-kazi lako kuanza, kwa hiyo hitilafu ya shell inaweza kukurudisha kwenye skrini ya kuingia. Acha terminal inayofanya kazi wazi unapozihariri. Ili kuzima ubatilishaji, uondoe kutoka `env.d`. Tazama [kuokoa kuingia](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) ikiwa mabadiliko yatakuzuia kuingia.

### Kubadilisha faili za ndani za Omarchy

Sikiliza, hii ni kompyuta yako. Unaweza kufanya chochote unachotaka nayo, lakini ningekushauri usifanye mabadiliko kwenye faili zilizo katika `/usr/share/omarchy` moja kwa moja. Ni za kifurushi cha pacman cha Omarchy, kwa hiyo mabadiliko yako yataandikwa upya tu wakati wa usasishaji unaofuata. Afadhali uandike upya tu thamani zozote chaguo-msingi usizozipenda katika folda ya `~/.config/*` badala yake.

Unaweza kubadilisha karibu kila kitu kwa njia hiyo, kama vifungo chaguo-msingi vya vitufe. Hariri tu `~/.config/hypr/bindings.lua` ili, kwa mfano, kubadilisha [Obsidian](https://obsidian.md/) na [Joplin](https://joplinapp.org/) (sakinisha kwa `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` huondoa kifungo kilichopo kabla ya kuongeza mbadala wake. Huchukua hoja zile zile kama `o.bind`, ikiwa ni pamoja na visaidizi vya uzinduzi na chaguo za vifungo. Tumia `o.bind` kuongeza kifungo, au `hl.unbind` kuondoa kimoja bila kukibadilisha.

Ikiwa unasisitiza kuchezea faili za ndani za Omarchy, badilisha kwenda chaneli ya dev kupitia _Update > Channel > Dev_. Hiyo huunganisha Omarchy na git checkout ya msimbo chanzo katika `~/omarchy`, ambayo uko huru kuibadilisha upendavyo kabisa. Hakuna mtu hapa wa kukuambia cha kufanya!

### Kuweka upya mabadiliko yoyote

Ikiwa mwishowe utachafua mipangilio, unaweza kuirejesha kwenye chaguo-msingi wakati wowote kupitia _Update > Config_ katika menyu ya Omarchy. Au kwa kuendesha `omarchy reinstall configs` ili kuweka upya kila kitu.
