# Kutatua matatizo

### Nilivunja mfumo wangu kwa sasisho!

Kwanza jaribu [kurudisha mfumo wako](47-system-snapshots.md) toleo kabla ya sasisho lako la hivi karibuni. Kama hiyo haifanyi kazi, tumia `omarchy-debug` kushiriki tatizo lako kwenye #omarchy-help katika Discord. Na kama yote hayo yanashindwa, unaweza kusakinisha upya usanidi na vifurushi chaguomsingi kwa kutumia `omarchy-reinstall`.

### Kwa nini programu nyingine ni kubwa sana kwenye skrini yangu?

Omarchy hudhani skrini ya ubora wa juu ya 2x, ambayo inahitaji kuweka `GDK_SCALE` kuwa 2 katika `~/.config/hypr/monitors.lua`. Lakini kama uko kwenye skrini ya 1x, unaweza kubadilisha `local omarchy_gdk_scale = 2` kuwa 1 (na kisha uwashe upya programu yoyote iliyokua kubwa kupita kiasi). Tazama [mwongozo kuhusu skrini](33-monitors.md).

Kwa Spotify, unaweza kutumia `Ctrl + Minus` kupunguza UI (na `Ctrl + Plus` kuikuza).

### Wi-Fi, Bluetooth, sauti, au kiguso changu kimesita kufanya kazi ghafla

Kabla ya kuwasha upya, jaribu kuwasha upya mfumo mdogo wenye tatizo wenyewe. _Sasisha > Vifaa_ katika menyu ya Omarchy ina Wi-Fi, Bluetooth, Sauti, na Kiguso, na kupakia upya moja ya hizo humaliza hali nyingi za "ilifanya kazi dakika tano zilizopita" — kisikika cha Bluetooth kisichotaka kuunganika tena, kiguso kilichokufa baada ya kusitisha, sauti iliyopotea ulipotoa skrini.

### Kwa nini spika zangu za nje hazichezi?

Pengine kwa sababu hazijachaguliwa kama tokeo la msingi. Bofya aikoni ya spika mkono wa kulia wa upau, na itafungua kidondosha sauti ambapo unaweza kuchagua kifaa cha tokeo (na kuchanganya sauti za kila programu pia).

### Spika za kompyuta yangu mpakato zinasikika vibaya

Kwenye kompyuta mpakato nyingine, Omarchy hutumia kiotomatiki upangaji wa spika unaorekebisha mwitikio wa masafa ya spika zilizojengwa ndani. `omarchy audio tuning status` hukuambia kama moja inatumika kwenye mashine yako, na `omarchy audio tuning off` huizima kama unapendelea kusikia spika mbichi.

### Kwa nini siwezi kuingia au sudo kwa nenosiri langu?

Pengine ulilichapa vibaya mara nyingi sana na ukafungiwa nje. Kama hii inatokea kwenye skrini ya kufunga, unaweza kubonyeza `CTRL + ALT + F2` kuanzisha TTY mpya ambapo unaweza kuingia kama root, kisha uendeshe `faillock --reset --user [your-username]`. Hiyo itaweka upya ufungaji nje, na uko tayari kwenda.

### Kwa nini madokezo yangu ya idhini ya 1Password kwa 1Password SSH Agent / CLI hayaonekani?

Hii inaweza kutokea kwa sababu 2:

Ili kidokezo cha idhini tajiri kionekane, Settings > Advanced > Use Hardware Acceleration lazima iweshwe. _Kumbuka: Hii inahitaji kuwasha upya ili kuanza kufanya kazi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Au kama hujaanzisha 1Password tangu kuwasha, kidokezo hakitaonekana.
