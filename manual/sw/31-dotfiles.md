# Dotfiles

Omarchy imesanidiwa hasa kupitia kile kinachoitwa dotfiles vinavyoishi katika `~/.config`. Hizo huchukuliwa kama faili zako kwa ajili ya mabadiliko yako. Faili zinazoishi katika `/usr/share/omarchy` ni za Omarchy yenyewe, na hupaswi kuzigusa. Ukihitaji kubadilisha chochote katika `/usr/share/omarchy`, unapaswa kuandika upya thamani hiyo katika `~/.config` badala yake.

Usanidi muhimu unaweza kuhaririwa moja kwa moja kutoka kwenye menyu ya Omarchy (`Super + Space`), kama vile _Setup > Keyboard > Keybindings_, _Setup > Input_, na _Setup > Config > [file]_. Unapofanya hivyo, mchakato wowote unaohitaji kuanzishwa upya baada ya kuhariri usanidi utafanya hivyo kiotomatiki baada ya kufunga kihariri (Neovim kwa chaguo-msingi — `:wq`, kumbuka! — lakini unaweza kubadilisha hiyo kupitia _Setup > Defaults > Editor_).

Hapa kuna orodha ya faili muhimu katika `~/.config` na kile wanachodhibiti:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Usanidi mkuu wa Hyprland. Hupakia chaguo-msingi za Omarchy pamoja na faili zako za kubatilisha zilizo hapa chini. [Jifunze zaidi kuhusu usanidi wa Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vifungo vyako vya vitufe na ubatilishaji wako wa chaguo-msingi. |
| `~/.config/hypr/monitors.lua` | Mipangilio ya monita ambayo paneli ya monita haishughulikii, kama vile mzunguko, hali za ziada, au kuacha monita ikiwa imezimwa. |
| `~/.config/hypr/input.lua` | Hudhibiti mpangilio wa kibodi yako, kipanya, na mipangilio ya trackpad. |
| `~/.config/hypr/looknfeel.lua` | Hudhibiti mapengo, mipaka, uhuishaji, na mwonekano uliobaki. |
| `~/.config/hypr/autostart.lua` | Hudhibiti michakato ya ziada inayoanzishwa na kipindi. |
| `~/.config/omarchy/shell.json` | Hudhibiti ganda la Omarchy: msimamo wa upau, mpangilio, na wijeti, pamoja na muda wa kinga-skrini, kufunga, na kutotumika. |
| `~/.config/foot/foot.ini` | Hudhibiti terminali yako (foot ndiyo chaguo-msingi). |
| `~/.XCompose` | Hufafanua emoji zako za ufikiaji wa haraka na ukamilishaji kiotomatiki wa jina/barua pepe. Hakikisha unaendesha `omarchy-restart-xcompose` baada ya kufanya mabadiliko. |

Ukiishia kufanya mabadiliko mengi ili kurekebisha usanidi wako mwenyewe, ni wazo zuri kuhifadhi nakala rudufu za dotfiles hizi zote. [Stow ni njia nzuri ya kufanya hivyo](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Kuanzisha programu zako mwenyewe pamoja na kipindi

Ukitaka kitu kiendeshe kila unapoingia — daemoni ya usawazishaji, programu ya gumzo, hati yako mwenyewe — kiweke katika `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Hiyo huanzisha amri kama sehemu ya kipindi, kwa hivyo husafishwa ipasavyo unapotoka tena.

### Kuendesha hati kwenye matukio ya mfumo

Omarchy huanzisha hook katika nyakati chache, na unaweza kutundika hati zako mwenyewe juu yake. Zinaishi katika `~/.config/omarchy/hooks/<event>.d/`, saraka moja kwa kila tukio, na kila faili inayoweza kutekelezwa iliyomo humo huendeshwa tukio linapotokea:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Mara tu baada ya eneo-kazi kuanza |
| `post-update` | Karibu na mwisho wa `omarchy update`, baada ya vifurushi, uhamiaji, na kuanzisha upya huduma, kabla ya zana za mise kusasishwa |
| `pre-refresh-pacman` | Baada ya `omarchy refresh pacman` kusawazisha upya usanidi wa vifurushi, kabla ya kusasisha vifurushi; ubadilishaji wa chaneli huiendesha wakati wa hatua hiyo hiyo ya kuonyesha upya |
| `theme-set` | Baada ya kubadilisha mandhari (jina la mandhari katika `$1`) |
| `font-set` | Baada ya kubadilisha fonti (jina la fonti katika `$1`) |
| `battery-low` | Betri inapokuwa chini (asilimia katika `$1`) |

Hook ya `pre-refresh-pacman` ndipo hazina maalum au mistari ya `IgnorePkg` inapopaswa kuwekwa, kwa kuwa huendeshwa kabla ya muamala wa vifurushi. Hook zote mbili zinazohusiana na usasishaji huendeshwa kama mtumiaji wako baada ya Omarchy kufuta idhini yake ya sudo iliyohifadhiwa, kwa hivyo hook inayotumia `sudo` inahitaji idhini yake yenyewe na inaweza kukuomba nenosiri lako.

Kila moja ya saraka hizo tayari ina faili ya `.sample` inayoonyesha umbo la hook — ondoa `.sample` kutoka kwenye jina ili kuifanya ifanye kazi. Kusakinisha hati uliyoandika kwingineko, tumia `omarchy hook install post-boot ~/my-hook`, ambayo huinakili ndani na kuifanya iweze kutekelezwa.

### Kuongeza maingizo yako mwenyewe ya menyu

Menyu ya Omarchy (`Super + Space`) inaweza kupanuliwa kwa safu zako mwenyewe kwa kuhariri `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Maingizo yamefungwa kwa kitambulisho chenye nukta, na kitambulisho ndicho kinachoyaweka kwenye mti, kwa hivyo `personal` huonekana kwenye menyu ya mzizi na `personal.notes` huonekana ndani yake:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Tumia tena kitambulisho kilichopo na unabatilisha safu hiyo badala ya kuongeza mpya. Faili huja na sehemu zote zinazopatikana zikiwa zimeandikwa kama maoni.

### Kuongeza maelekezo yako mwenyewe ya ganda, vitendakazi, na lakabu

Omarchy huja na rundo la lakabu za ergonomic na vitendakazi vinavyosaidia, lakini ni kawaida sana kutaka kuongeza vyako mwenyewe. Unapaswa kuongeza lakabu, vitendakazi, na maelekezo yote katika `~/.bashrc`. Faili hii haitabatilishwa kwenye masasisho. Ukitaka kubadilisha chaguo-msingi zozote za Omarchy, unaweza pia kuziongeza hapa kwa usalama.

### Kuweka vigezo vya mazingira kwa ajili ya eneo-kazi

Maelekezo ya kipindi cha eneo-kazi yanapaswa kuwa katika `~/.config/uwsm/env.d/`. Faili hizi huendeshwa kabla ya eneo-kazi lako kuanza, kwa hivyo hitilafu ya ganda inaweza kukurudisha kwenye skrini ya kuingia. Weka terminali inayofanya kazi wazi unapozihariri. Kuzima ubatilishaji, uhamishe kutoka `env.d`. Tazama [ujio wa kuingia](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) ikiwa mabadiliko yanazuia kuingia.

### Kubadilisha faili za ndani za Omarchy

Sikiliza, hii ni kompyuta yako. Unaweza kufanya lolote unalotaka nayo, lakini ningekushauri dhidi ya kufanya mabadiliko kwenye faili zilizo katika `/usr/share/omarchy` moja kwa moja. Ni za kifurushi cha pacman cha Omarchy, kwa hivyo mabadiliko yako yatabatilishwa tu kwenye sasisho linalofuata. Afadhali ubatilishe tu thamani zozote chaguo-msingi usizozipenda katika folda ya `~/.config/*` badala yake.

Unaweza kubadilisha karibu kila kitu kwa njia hiyo, kama vile vifungo vya vitufe vya chaguo-msingi. Hariri tu `~/.config/hypr/bindings.lua` ili, kwa mfano, kubadilisha [Obsidian](https://obsidian.md/) na [Joplin](https://joplinapp.org/) (sakinisha kwa `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` huondoa kifungo kilichopo kabla ya kuongeza kibadala chake. Huchukua hoja zile zile kama `o.bind`, ikiwa ni pamoja na visaidizi vya uzinduzi na chaguo za vifungo. Tumia `o.bind` kuongeza kifungo, au `hl.unbind` kuondoa kimoja bila kukibadilisha.

Ukiendelea kusisitiza kuhariri faili za ndani za Omarchy, badilisha hadi chaneli ya dev kupitia _Update > Channel > Dev_. Hiyo huunganisha Omarchy na nakala ya git ya msimbo chanzo katika `~/omarchy`, ambayo uko huru kuibadilisha upendavyo. Hakuna mtu hapa wa kukuambia la kufanya!

### Kuweka upya mabadiliko yoyote

Ukiishia kuvuruga usanidi, unaweza kuurudisha kwenye chaguo-msingi kila wakati kupitia _Update > Config_ katika menyu ya Omarchy. Au kwa kuendesha `omarchy reinstall configs` kuweka upya kila kitu.
