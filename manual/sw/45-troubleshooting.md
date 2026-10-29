# Utatuzi wa Matatizo

### Nimeharibu mfumo wangu kwa kusasisha!

Kwanza jaribu [kurudisha mfumo wako](47-system-snapshots.md) kwenye toleo la kabla ya usasishaji wako wa hivi karibuni. Ikiwa hiyo haifanyi kazi, tumia `omarchy-debug` kushiriki tatizo lako kwenye #omarchy-help katika Discord. Na ikiwa yote hayo yatashindikana, unaweza kusakinisha upya usanidi na vifurushi chaguo-msingi kwa kutumia `omarchy-reinstall`.

### Kwa nini baadhi ya programu ni kubwa sana kwenye skrini yangu?

Omarchy huchukulia kuwa una skrini yenye ubora wa juu ya 2x, ambayo inahitaji kuweka `GDK_SCALE` kuwa 2 katika `~/.config/hypr/monitors.lua`. Lakini ikiwa uko kwenye skrini ya 1x, unaweza kubadilisha `local omarchy_gdk_scale = 2` kuwa 1 (kisha uanzishe upya programu yoyote iliyo kubwa kupita kiasi). Tazama [mwongozo kuhusu skrini](33-monitors.md).

Kwa Spotify, unaweza kutumia `Ctrl + Minus` kupunguza ukubwa wa kiolesura (na `Ctrl + Plus` kuifanya iwe kubwa zaidi).

### Kwa nini vifungo vyote vya kitufe cha Super vimeacha kufanya kazi?

Kwenye baadhi ya kompyuta mpakato za ASUS ROG na TUF, `Fn + Super` ni mchanganyiko rahisi kupitwa ambao huwasha na kuzima kufuli ya programu dhibiti ya kitufe cha Windows (iliyokusudiwa kwa michezo ili usiondoke kwenye mchezo kwa bahati mbaya). Hakuna kinachoonekana kwenye skrini kukwambia kuwa imetokea. Kufuli ikiwa imewashwa, Super haitoi chochote kabisa — kwa hivyo kila kifungo cha Omarchy kinachotumia Super huacha tu kufanya kazi, na inaonekana kama Hyprland imeharibika.

Bonyeza `Fn + Super` mara moja kabla ya kuanza kuchimba katika `~/.config/hypr/`, na ikiwa hiyo hairudishi Super, ibonyeze tena ili usiache kufuli ikiwa imewashwa. Hii si Fn-lock, ambayo hubadilisha tu jinsi safu ya vitufe vya F inavyofanya kazi.

### Wi-Fi, Bluetooth, sauti, au padi yangu ya kugusa imeacha kufanya kazi ghafla

Kabla ya kuwasha upya, jaribu kuwasha upya mfumo mdogo unaosumbua peke yake. _Update > Hardware_ kwenye menyu ya Omarchy ina Wi-Fi, Bluetooth, Audio, na Trackpad, na kupakia upya mojawapo ya hizo hutatua hali nyingi za "ilikuwa inafanya kazi dakika tano zilizopita" — vifaa vya sauti vya Bluetooth vinavyokataa kuunganishwa tena, padi ya kugusa iliyokufa baada ya kusimamisha, sauti iliyopotea ulipochomoa skrini.

### Kwa nini spika zangu za nje hazichezi sauti?

Pengine ni kwa sababu hazijawekwa kama kifaa kikuu cha kutoa sauti. Bofya aikoni ya spika upande wa kulia wa upau, nayo itafungua dirisha ibukizi la sauti ambapo unaweza kuchagua kifaa cha kutoa sauti (na pia kuchanganya viwango vya sauti kwa kila programu).

### Spika za kompyuta yangu mpakato zinasikika vibaya

Kwenye baadhi ya kompyuta mpakato, Omarchy hutumia kiotomatiki urekebishaji wa spika unaosahihisha mwitikio wa masafa wa spika zilizojengwa ndani. `omarchy audio tuning status` hukwambia ikiwa mmoja unafanya kazi kwenye mashine yako, na `omarchy audio tuning off` huuzima ikiwa ungependa kusikia spika zikiwa mbichi.

### Kwa nini siwezi kuingia au kutumia sudo kwa nenosiri langu?

Pengine umeliandika vibaya mara nyingi sana na ukajifungia nje. Ikiwa hii inatokea kwenye skrini ya kufuli, unaweza kubonyeza `CTRL + ALT + F2` kuanzisha TTY mpya ambapo unaweza kuingia kama root, kisha endesha `faillock --reset --user [your-username]`. Hiyo itaweka upya ufungaji, na uko tayari kuendelea.

### Kwa nini vidokezo vyangu vya idhini vya 1Password kwa 1Password SSH Agent / CLI havionekani?

Hii inaweza kutokea kwa sababu 2:

Ili kidokezo tajiri cha kuidhinisha kionekane, Settings > Advanced > Use Hardware Acceleration lazima kiwashwe. _Kumbuka: Hii inahitaji kuwasha upya ili ianze kufanya kazi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Au ikiwa hujazindua 1Password tangu ulipowasha kompyuta, kidokezo hakitaonekana.
