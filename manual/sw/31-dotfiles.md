# Dotfiles

Omarchy husanidiwa hasa kupitia zinazoitwa dotfiles zinazokaa katika `~/.config`. Hizo zinachukuliwa kama faili zako kwa mabadiliko yako. Faili zinazokaa katika `/usr/share/omarchy` ni za Omarchy yenyewe, na haupaswi kuzichokoza hizo. Kama unahitaji kubadilisha kitu chochote katika `/usr/share/omarchy`, unapaswa kuandika juu ya thamani katika `~/.config` badala yake.

Usanidi muhimu unaweza kuhaririwa moja kwa moja kutoka menyu ya Omarchy (`Super + Space`), kama _Sanidi > Skrini_, _Sanidi > Mikato ya vitufe_, _Sanidi > Ingizo_, na _Sanidi > Usanidi > [file]_. Unapoifanya kwa njia hii, mchakato wowote unaohitajika kuwashwa upya baada ya uhariri wa usanidi kiotomatiki utafanywa baada ya kuacha kihariri (Neovim kwa chaguomsingi — `:wq`, kumbuka! — lakini unaweza kubadilisha hilo kupitia _Sanidi > Chaguomsingi > Kihariri_).

Hapa kuna orodha ya faili muhimu katika `~/.config` na kile zinachodhibiti:

| Faili                  | Madhumuni              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Usanidi mkuu wa Hyprland. Hupakia chaguomsingi za Omarchy pamoja na faili zako za kubatilisha hapa chini. [Jifunze zaidi kuhusu usanidi wa Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Mikato yako mwenyewe ya vitufe na ubatilishaji wa chaguomsingi. |
| `~/.config/hypr/monitors.lua` | Hudhibiti skrini zako, ubora, na nafasi. |
| `~/.config/hypr/input.lua` | Hudhibiti mpangilio wa kibodi yako, kipanya, na mipangilio ya kiguso. |
| `~/.config/hypr/looknfeel.lua` | Hudhibiti mapengo, mipaka, uhuishaji, na mwonekano wote. |
| `~/.config/hypr/autostart.lua` | Hudhibiti michakato ya ziada inayoanzishwa na kikao. |
| `~/.config/omarchy/shell.json` | Hudhibiti shell ya Omarchy: nafasi ya upau, mpangilio, na wijeti, pamoja na kiokozi cha skrini, kufuli, na muda wa kutotenda. |
| `~/.config/foot/foot.ini` | Hudhibiti terminali yako (foot ndiyo chaguomsingi). |
| `~/.XCompose` | Hufafanua emoji zako za ufikiaji wa haraka na ukamilishaji wa jina/barua pepe. Hakikisha unaendesha `omarchy-restart-xcompose` baada ya kufanya mabadiliko. |

Kama utamaliza kufanya mabadiliko mengi ili kurekebisha usanidi wako mwenyewe, ni wazo zuri kuhifadhi nakala rudufu za dotfiles hizi zote. [Stow ni njia bora ya kufanya hivyo](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Kuanzisha programu zako mwenyewe na kikao

Kama unataka kitu kiendeshwe kila unapoingia — daemon ya kusawazisha, programu ya gumzo, hati yako mwenyewe — kiweke katika `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Hiyo huanzisha amri kama sehemu ya kikao, hivyo husafishwa ipasavyo unapotoka tena.

### Kuendesha hati kwenye matukio ya mfumo

Omarchy hufyatua ndoano (hooks) kwa nyakati chache, na unaweza kunyongea hati zako mwenyewe kwazo. Zinakaa katika `~/.config/omarchy/hooks/<event>.d/`, saraka moja kwa tukio, na kila faili inayoweza kutekelezwa humo huendeshwa tukio linapotokea:

| Tukio | Inapoendeshwa |
| ----- | ------------ |
| `post-boot` | Mara baada ya eneo-kazi kuanza |
| `post-update` | Karibu na mwisho wa `omarchy update`, baada ya vifurushi, uhamaji, na kuwashwa upya kwa huduma, kabla zana za mise kusasishwa |
| `pre-refresh-pacman` | Baada ya `omarchy refresh pacman` kusawazisha upya usanidi wa kifurushi, kabla husasisha vifurushi; ubadilishaji wa kituo huiendesha wakati wa hatua ile ile ya kuonyesha upya |
| `theme-set` | Baada ya mabadiliko ya mandhari (jina la mandhari katika `$1`) |
| `font-set` | Baada ya mabadiliko ya fonti (jina la fonti katika `$1`) |
| `battery-low` | Wakati betri inapokuwa chini (asilimia katika `$1`) |

Ndoano ya `pre-refresh-pacman` ndipo hazina maalum au mistari ya `IgnorePkg` inapostahili, kwa kuwa huendeshwa kabla ya muamala wa kifurushi. Ndoano zote mbili zinazohusu sasisho huendeshwa kama mtumiaji wako baada ya Omarchy kufuta idhini yake ya sudo iliyohifadhiwa, hivyo ndoano inayotumia `sudo` inahitaji idhini yake mwenyewe na inaweza kukuuliza nenosiri lako.

Kila moja ya saraka hizo tayari inashikilia faili ya `.sample` inayoonyesha umbo la ndoano — ondoa `.sample` kutoka jina kuiweka kazini. Ili kusakinisha hati ambayo umeiandika mahali pengine, tumia `omarchy hook install post-boot ~/my-hook`, ambayo huinakili ndani na kuifanya iweze kutekelezwa.

### Kuongeza viingilio vyako mwenyewe vya menyu

Menyu ya Omarchy (`Super + Space`) inaweza kupanuliwa na safu zako mwenyewe kwa kuhariri `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Viingilio vimefungwa kwa kitambulisho chenye matone, na kitambulisho ndicho kinachoviweka katika mti, hivyo `personal` huonekana kwenye menyu ya mzizi na `personal.notes` huonekana ndani yake:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Tumia tena kitambulisho kilichopo na unabatilisha safu hiyo badala ya kuongeza mpya. Faili huja na sehemu zote zilizopo zikiwa zimeandikwa kama maoni.

### Kuongeza uhamishaji wako mwenyewe wa shell, vitendakazi, na vifupisho

Omarchy huja na vifupisho vingi vya ergonomic na vitendakazi vya kusaidia, lakini ni kawaida sana kutaka kuongeza vyako mwenyewe. Unapaswa kuongeza vifupisho, vitendakazi, na uhamishaji katika `~/.bashrc`. Faili hii haitaandikwa juu kwenye visasisho. Kama unataka kubadilisha chaguomsingi yoyote ya Omarchy, unaweza pia kuziongeza kwa usalama hapa.

### Kubadilisha faili za ndani za Omarchy

Angalia, hii ni kompyuta yako. Unaweza kufanya chochote unachokitaka nayo, lakini ningekushauri dhidi ya kufanya mabadiliko kwenye faili katika `/usr/share/omarchy` moja kwa moja. Ni za kifurushi cha pacman cha Omarchy, hivyo mabadiliko yako yataandikwa juu tu kwenye sasisho linalofuata. Ni bora uandike juu tu thamani zozote chaguomsingi ambazo hupendi katika folda ya `~/.config/*` badala yake.

Unaweza kubadilisha karibu kila kitu kwa njia hiyo, kama mikato chaguomsingi ya vitufe. Hariri tu `~/.config/hypr/bindings.lua` ili, kwa mfano, kubadilisha [Obsidian](https://obsidian.md/) na [Joplin](https://joplinapp.org/) (sakinisha kwa `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` huondoa kiunganishi kilichopo kabla ya kuongeza mbadala wake. Inachukua hoja zile zile kama `o.bind`, ikiwa ni pamoja na wasaidizi wa uzinduzi na chaguo za kiunganishi. Tumia `o.bind` kuongeza kiunganishi, au `hl.unbind` kuondoa kimoja bila kukibadilisha.

Kama unasisitiza kuhack faili za ndani za Omarchy, badilisha hadi kituo cha dev kupitia _Sasisha > Kituo > Dev_. Hiyo huunganisha Omarchy na nakala ya git ya msimbo wa chanzo katika `~/omarchy`, ambayo uko huru kuibadilisha utakavyo. Hakuna mtu hapa wa kukuambia ufanye nini!

### Kuweka upya mabadiliko yoyote

Kama utamaliza kufanya fujo ya usanidi, unaweza kila wakati kuyarejesha kwenye chaguomsingi kupitia _Sasisha > Usanidi_ katika menyu ya Omarchy. Au kwa kuendesha `omarchy reinstall configs` kuweka upya kila kitu.
