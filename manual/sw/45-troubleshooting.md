# Utatuzi wa Matatizo

### Niliharibu mfumo wangu kwa usasishaji!

Kwanza jaribu [kurudisha mfumo wako](47-system-snapshots.md) kwenye toleo la kabla ya usasishaji wako wa hivi karibuni. Ikiwa hilo halifanyi kazi, tumia `omarchy-debug` kushiriki tatizo lako kwenye #omarchy-help katika Discord. Na ikiwa yote hayo yatashindikana, unaweza kusakinisha upya usanidi na vifurushi chaguo-msingi kwa kutumia `omarchy-reinstall`.

### Kwa nini baadhi ya programu ni kubwa sana kwenye skrini yangu?

Omarchy hudhani una skrini yenye ubora wa juu wa 2x, kwa hivyo huweka `GDK_SCALE` kuwa 2 hadi uchague kipimo katika paneli ya monita. Ikiwa uko kwenye skrini ya 1x na programu za GTK au X11 zinatokea kubwa kupita kiasi, chagua 1x kwa ajili yake katika paneli ya monita, au ongeza `hl.env("GDK_SCALE", "1")` kwenye `~/.config/hypr/monitors.lua` (kisha uanzishe upya programu yoyote iliyo kubwa kupita kiasi). Tazama [mwongozo kuhusu monita](33-monitors.md).

Kwa Spotify, unaweza kutumia `Ctrl + Minus` kupunguza kiolesura (na `Ctrl + Plus` kukifanya kikubwa zaidi).

### Kwa nini vifungo vyangu vyote vya kitufe cha Super vimeacha kufanya kazi?

Kwenye baadhi ya kompyuta mpakato za ASUS ROG na TUF, `Fn + Super` ni mchanganyiko rahisi kuukosa ambao hubadilisha ufungaji wa kitufe cha Windows wa programu dhibiti (uliokusudiwa kwa michezo ili usiondoke kwenye mchezo kwa bahati mbaya). Hakuna kinachoonekana kwenye skrini kinachokuambia kuwa limetokea. Wakati ufungaji umewashwa, Super haitoi chochote kabisa — kwa hivyo kila kifungo cha Omarchy kinachotumia Super huacha tu kufanya kazi, na inaonekana kama Hyprland imeharibika.

Bonyeza `Fn + Super` mara moja kabla ya kuanza kuchimba kwenye `~/.config/hypr/`, na ikiwa hilo halirudishi Super, libonyeze tena ili usiache ufungaji umewashwa. Hii si Fn-lock, ambayo hubadilisha tu kile safu ya vitufe vya F inafanya.

### Wi-Fi, Bluetooth, sauti, au padi yangu ya mguso imeacha tu kufanya kazi

Kabla ya kuwasha upya, jaribu kuanzisha upya mfumo mdogo unaosumbua peke yake. _Update > Hardware_ katika menyu ya Omarchy ina Wi-Fi, Bluetooth, Audio, na Trackpad, na kupakia upya mojawapo ya hayo huondoa sehemu kubwa ya hali za "ilifanya kazi dakika tano zilizopita" — vifaa vya sauti vya Bluetooth vinavyokataa kuunganishwa tena, padi ya mguso iliyokufa baada ya kusimamishwa, sauti iliyopotea ulipounganua monita.

### Kwa nini spika zangu za nje hazichezi?

Pengine ni kwa sababu hazijawekwa kama kifaa kikuu cha kutoa sauti. Bofya kwenye aikoni ya spika kwenye upande wa kulia wa upau, na itafungua dirisha ibukizi la sauti ambapo unaweza kuchagua kifaa cha kutoa sauti (na kuchanganya sauti kwa kila programu pia).

### Spika za kompyuta yangu mpakato zinasikika vibaya

Kwenye baadhi ya kompyuta mpakato, Omarchy hutumia kiotomatiki urekebishaji wa spika ambao hurekebisha mwitikio wa masafa wa spika zilizojengwa ndani. `omarchy audio tuning status` hukuambia ikiwa mojawapo inatumika kwenye mashine yako, na `omarchy audio tuning off` huizima ikiwa ungependa kusikia spika kama zilivyo.

### Kwa nini siwezi kuingia au kutumia sudo kwa nenosiri langu?

Pengine uliliandika vibaya mara nyingi sana na ukafungiwa nje. Ikiwa hii inatokea kwenye skrini ya kufunga, unaweza kubonyeza `CTRL + ALT + F2` kuanzisha TTY mpya ambapo unaweza kuingia kama root, kisha uendeshe `faillock --reset --user [your-username]`. Hilo litaweka upya ufungaji, na uko tayari kuendelea.

### Nenosiri langu limekubaliwa, lakini narudi kwenye skrini ya kuingia

Faili iliyoharibika ya mazingira ya kipindi inaweza kuzuia eneo-kazi kuanza hata wakati nenosiri lako ni sahihi. Hii inafaa hasa kukaguliwa baada ya kuhariri `~/.config/uwsm/env.d/`.

Bonyeza `Ctrl + Alt + F2`, ingia kwa jina lako la kawaida la mtumiaji na nenosiri, na ukague jarida la mtumiaji la kuwasha kwa sasa:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Tafuta hitilafu inayotaja mojawapo ya faili zako za mazingira, kama vile `bad substitution`, kabla tu ya ujumbe kwamba alama ya matokeo ya mazingira haikupatikana. Hamisha faili hiyo kutoka `env.d` kabla ya kujaribu kuingia tena. Kwa mfano, ikiwa hitilafu inataja `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM huruka faili yenye hitilafu ya sintaksia, lakini hitilafu mbaya inayoonekana tu wakati faili inaendeshwa, kama `bad substitution`, bado inaweza kuzuia eneo-kazi kuanza. Kurudisha mfumo kwa picha ya mfumo hakurekebishi faili hizi, kwa sababu `/home` hairudishwi.

Mara tu unapoweza kuingia, rekebisha nakala iliyohifadhiwa kabla ya kuirudisha. `sh -n` hukamata hitilafu za sintaksia bila kuendesha faili, lakini haiwezi kukamata kila hitilafu inayotokea inapoletwa. Weka terminali inayofanya kazi wazi wakati wa kujaribu mabadiliko.

### Kwa nini vidokezo vyangu vya uidhinishaji vya 1Password kwa 1Password SSH Agent / CLI havionekani?

Hii inaweza kutokea kwa sababu 2:

Ili kidokezo tajiri cha uidhinishaji kionekane, Settings > Advanced > Use Hardware Acceleration lazima kiwashwe. _Kumbuka: Hii inahitaji kuwasha upya ili kuanza kufanya kazi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Au ikiwa hujazindua 1Password tangu ulipowasha, kidokezo hakitaonekana.
