# Dotfiles

Omarchy husanidiwa hasa kupitia kile kinachoitwa dotfiles vinavyoishi katika `~/.config`. Hizo huchukuliwa kama faili zako kwa ajili ya mabadiliko yako. Faili zinazoishi katika `/usr/share/omarchy` ni za Omarchy yenyewe, na hupaswi kuzichezea. Ikiwa unahitaji kubadilisha chochote katika `/usr/share/omarchy`, unapaswa kuandika upya thamani hiyo katika `~/.config` badala yake.

Mipangilio muhimu inaweza kuhaririwa moja kwa moja kutoka kwenye menyu ya Omarchy (`Super + Space`), kama _Setup > Keybindings_, _Setup > Input_, na _Setup > Config > [file]_. Unapofanya hivi, mchakato wowote unaohitaji kuanzishwa upya baada ya kuhariri mipangilio utaanzishwa upya kiotomatiki baada ya kufunga kihariri (Neovim kwa chaguo-msingi — `:wq`, kumbuka! — lakini unaweza kubadilisha hilo kupitia _Setup > Defaults > Editor_).

Hii hapa orodha ya faili muhimu katika `~/.config` na kile zinachodhibiti:

| Faili                  | Kusudi              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Faili kuu ya mipangilio ya Hyprland. Hupakia chaguo-msingi za Omarchy pamoja na faili zako za kuandika upya zilizo hapa chini. [Jifunze zaidi kuhusu mipangilio ya Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vifungo vyako mwenyewe vya vitufe na uandikaji upya wa chaguo-msingi. |
| `~/.config/hypr/monitors.lua` | Mipangilio ya monita ambayo paneli ya monita haishughulikii, kama mzunguko, modi za ziada, au kuacha monita ikiwa imezimwa. |
| `~/.config/hypr/input.lua` | Hudhibiti mpangilio wa kibodi yako, kipanya, na mipangilio ya trackpad. |
| `~/.config/hypr/looknfeel.lua` | Hudhibiti mapengo, mipaka, uhuishaji, na mwonekano uliosalia. |
| `~/.config/hypr/autostart.lua` | Hudhibiti michakato ya ziada inayoanzishwa pamoja na kipindi. |
| `~/.config/omarchy/shell.json` | Hudhibiti ganda la Omarchy: nafasi ya upau, mpangilio, na wijeti, pamoja na muda wa kinga-skrini, kufunga, na kutotumika. |
| `~/.config/foot/foot.ini` | Hudhibiti terminali yako (foot ndiyo chaguo-msingi). |
| `~/.XCompose` | Hufafanua emoji zako za ufikiaji wa haraka na ukamilishaji otomatiki wa jina/barua pepe. Hakikisha unaendesha `omarchy-restart-xcompose` baada ya kufanya mabadiliko. |

Ukiishia kufanya mabadiliko mengi ili kubinafsisha usanidi wako mwenyewe, ni wazo zuri kuhifadhi nakala rudufu ya dotfiles hizi zote. [Stow ni njia nzuri ya kufanya hivyo](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Kuanzisha programu zako mwenyewe pamoja na kipindi

Ikiwa unataka kitu kiendeshe kila unapoingia — daemoni ya kusawazisha, programu ya gumzo, skripti yako mwenyewe — kiweke katika `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Hiyo huanzisha amri kama sehemu ya kipindi, kwa hivyo husafishwa ipasavyo unapotoka tena.

### Kuendesha skripti kwenye matukio ya mfumo

Omarchy huanzisha hooks katika nyakati chache, na unaweza kutundika skripti zako mwenyewe juu yake. Zinaishi katika `~/.config/omarchy/hooks/<event>.d/`, saraka moja kwa kila tukio, na kila faili inayoweza kuendeshwa iliyomo humo huendeshwa tukio linapotokea:

| Tukio | Lini huendeshwa |
| ----- | ------------ |
| `post-boot` | Mara tu baada ya eneo-kazi kuanza |
| `post-update` | Karibu na mwisho wa `omarchy update`, baada ya vifurushi, uhamiaji, na kuanzishwa upya kwa huduma, kabla ya zana za mise kusasishwa |
| `pre-refresh-pacman` | Baada ya `omarchy refresh pacman` kusawazisha upya mipangilio ya vifurushi, kabla ya kusasisha vifurushi; kubadilisha chaneli huiendesha wakati wa hatua hiyo hiyo ya kuonyesha upya |
| `theme-set` | Baada ya kubadilisha mandhari (jina la mandhari katika `$1`) |
| `font-set` | Baada ya kubadilisha fonti (jina la fonti katika `$1`) |
| `battery-low` | Betri inapokuwa chini (asilimia katika `$1`) |

Hook ya `pre-refresh-pacman` ndipo hazina maalum au mistari ya `IgnorePkg` inapaswa kuwekwa, kwani huendeshwa kabla ya muamala wa kifurushi. Hooks zote mbili zinazohusiana na usasishaji huendeshwa kama mtumiaji wako baada ya Omarchy kufuta idhini yake ya sudo iliyohifadhiwa, kwa hivyo hook inayotumia `sudo` inahitaji idhini yake yenyewe na inaweza kukuomba nenosiri lako.

Kila moja ya saraka hizo tayari ina faili ya `.sample` inayoonyesha umbo la hook — ondoa `.sample` kutoka kwenye jina ili kuitumia. Ili kusakinisha skripti uliyoandika kwingine, tumia `omarchy hook install post-boot ~/my-hook`, ambayo huinakili ndani na kuifanya iweze kuendeshwa.

### Kuongeza vipengee vyako mwenyewe vya menyu

Menyu ya Omarchy (`Super + Space`) inaweza kupanuliwa kwa safu zako mwenyewe kwa kuhariri `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Vipengee huwekwa kwa ufunguo wa kitambulisho chenye nukta, na kitambulisho ndicho kinachoviweka kwenye mti, kwa hivyo `personal` huonekana kwenye menyu ya mizizi na `personal.notes` huonekana ndani yake:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Tumia tena kitambulisho kilichopo na utaandika upya safu hiyo badala ya kuongeza mpya. Faili huja na sehemu zote zinazopatikana zikiwa zimeandikwa kama maoni.

### Kuongeza uhamishaji wako mwenyewe wa ganda, vitendakazi, na alias

Omarchy huja na rundo la alias zinazorahisisha kazi na vitendakazi vinavyosaidia, lakini ni kawaida sana kutaka kuongeza vyako mwenyewe. Unapaswa kuongeza alias, vitendakazi, na uhamishaji wote katika `~/.bashrc`. Faili hii haitaandikwa upya kwenye masasisho. Ikiwa unataka kubadilisha chaguo-msingi chochote cha Omarchy, unaweza pia kuviongeza hapa kwa usalama.

### Kubadilisha faili za ndani za Omarchy

Sikia, hii ni kompyuta yako. Unaweza kufanya chochote unachotaka nayo, lakini ningekushauri usifanye mabadiliko kwenye faili zilizo katika `/usr/share/omarchy` moja kwa moja. Ni za kifurushi cha pacman cha Omarchy, kwa hivyo mabadiliko yako yataandikwa upya tu kwenye sasisho linalofuata. Afadhali uandike upya tu thamani zozote chaguo-msingi usizozipenda katika folda ya `~/.config/*` badala yake.

Unaweza kubadilisha karibu kila kitu kwa njia hiyo, kama vifungo chaguo-msingi vya vitufe. Hariri tu `~/.config/hypr/bindings.lua` ili, kwa mfano, kubadilisha [Obsidian](https://obsidian.md/) na [Joplin](https://joplinapp.org/) (sakinisha kwa `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` huondoa kifungo kilichopo kabla ya kuongeza mbadala wake. Huchukua hoja zile zile kama `o.bind`, ikiwa ni pamoja na visaidizi vya kuzindua na chaguo za vifungo. Tumia `o.bind` kuongeza kifungo, au `hl.unbind` kuondoa kimoja bila kukibadilisha.

Ukiisisitiza kucheza na faili za ndani za Omarchy, badilisha hadi chaneli ya dev kupitia _Update > Channel > Dev_. Hiyo huunganisha Omarchy na git checkout ya msimbo chanzo katika `~/omarchy`, ambayo uko huru kuibadilisha upendavyo. Hakuna mtu hapa wa kukuambia la kufanya!

### Kuweka upya mabadiliko yoyote

Ukiishia kuvuruga mipangilio, unaweza kuirejesha daima kwenye chaguo-msingi kupitia _Update > Config_ katika menyu ya Omarchy. Au kwa kuendesha `omarchy reinstall configs` ili kuweka upya kila kitu.
