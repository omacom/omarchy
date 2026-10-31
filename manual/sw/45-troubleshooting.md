# Utatuzi wa Matatizo

### Niliharibu mfumo wangu kwa sasisho!

Kwanza jaribu [kurejesha mfumo wako](47-system-snapshots.md) hadi toleo la kabla ya sasisho lako la hivi karibuni. Ikiwa hiyo haifanyi kazi, tumia `omarchy-debug` kushiriki tatizo lako kwenye #omarchy-help katika Discord. Na ikiwa yote hayo yatashindikana, unaweza kusakinisha upya usanidi na vifurushi vya chaguo-msingi kwa kutumia `omarchy-reinstall`.

### Kwa nini baadhi ya programu ni kubwa sana kwenye onyesho langu?

Omarchy huchukulia kuwa una onyesho lenye ubora wa juu la 2x, kwa hivyo huweka `GDK_SCALE` kuwa 2 hadi uchague kipimo kwenye paneli ya kionyeshi. Ikiwa uko kwenye onyesho la 1x na programu za GTK au X11 zinatokea zikiwa kubwa kupita kiasi, chagua 1x kwa ajili yake kwenye paneli ya kionyeshi, au ongeza `hl.env("GDK_SCALE", "1")` kwenye `~/.config/hypr/monitors.lua` (na kisha uanzishe upya programu yoyote iliyo kubwa kupita kiasi). Tazama [mwongozo kuhusu vionyeshi](33-monitors.md).

Kwa Spotify, unaweza kutumia `Ctrl + Minus` kupunguza ukubwa wa UI (na `Ctrl + Plus` kuifanya kuwa kubwa zaidi).

### Kwa nini vifungo vyangu vyote vya kitufe cha Super vimeacha kufanya kazi?

Kwenye baadhi ya kompyuta mpakato za ASUS ROG na TUF, `Fn + Super` ni mchanganyiko ambao ni rahisi kuukosa unaogeuza kufuli ya programu dhibiti ya kitufe cha Windows (iliyokusudiwa kwa michezo ili usitoke kwenye mchezo kwa bahati mbaya). Hakuna chochote kwenye skrini kinachokuambia kuwa imetokea. Wakati kufuli iko wazi, Super haitoi chochote kabisa — kwa hivyo kila kifungo cha Omarchy kinachotumia Super huacha tu kufanya kazi, na inaonekana kama Hyprland imeharibika.

Bonyeza `Fn + Super` mara moja kabla ya kuchimba ndani ya `~/.config/hypr/`, na ikiwa hiyo hairudishi Super, ibonyeze tena ili usiache kufuli ikiwa wazi. Hii si Fn-lock, ambayo hubadilisha tu kile safu ya vitufe vya F inafanya.

### Wi-Fi, Bluetooth, sauti, au padi yangu ya mguso imeacha tu kufanya kazi

Kabla ya kuwasha upya, jaribu kuwasha upya mfumo mdogo unaosababisha tatizo peke yake. _Sasisha > Vifaa_ kwenye menyu ya Omarchy ina Wi-Fi, Bluetooth, Sauti, na Padi ya Mguso, na kupakia upya mojawapo ya hizo huondoa sehemu kubwa ya hali za "ilikuwa inafanya kazi dakika tano zilizopita" — kichwa cha sauti cha Bluetooth kisichotaka kuunganishwa tena, padi ya mguso iliyokufa baada ya kusitishwa kwa muda, sauti iliyopotea ulipochomoa kionyeshi.

### Kwa nini spika zangu za nje hazichezi?

Pengine ni kwa sababu hazijawekwa kuwa kifaa kikuu cha kutoa sauti. Bofya aikoni ya spika iliyo upande wa kulia wa upau, na itafungua dirisha ibukizi la sauti ambapo unaweza kuchagua kifaa cha kutoa sauti (na kuchanganya viwango vya sauti vya kila programu pia).

### Spika za kompyuta yangu mpakato zinasikika vibaya

Kwenye baadhi ya kompyuta mpakato, Omarchy hutumia kiotomatiki urekebishaji wa spika unaosahihisha mwitikio wa masafa wa spika zilizojengwa ndani. `omarchy audio tuning status` inakuambia ikiwa mojawapo inatumika kwenye mashine yako, na `omarchy audio tuning off` huizima ikiwa ungependa kusikia spika zikiwa kama zilivyo bila urekebishaji.

### Kwa nini siwezi kuingia au kutumia sudo kwa nenosiri langu?

Pengine umeliandika vibaya mara nyingi sana na ukafungiwa nje. Ikiwa hii inatokea kwenye skrini ya kufuli, unaweza kubonyeza `CTRL + ALT + F2` kuanzisha TTY mpya ambapo unaweza kuingia kama root, kisha endesha `faillock --reset --user [your-username]`. Hiyo itaweka upya ufungiwaji huo, na utakuwa tayari kuendelea.

### Kwa nini madokezo ya idhini ya 1Password kwa 1Password SSH Agent / CLI hayaonekani?

Hii inaweza kutokea kwa sababu 2:

Ili kidokezo kizuri cha idhini kionekane, Mipangilio > Ya Juu > Tumia Uharakishaji wa Vifaa lazima iwashwe. _Kumbuka: Hii inahitaji kuwasha upya ili kuanza kufanya kazi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Au ikiwa hujazindua 1Password tangu ulipowasha kompyuta, kidokezo hakitaonekana.
