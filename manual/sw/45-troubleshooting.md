# Utatuzi wa Matatizo

### Nimeharibu mfumo wangu kwa sasisho!

Jaribu kwanza [kurudisha mfumo wako](47-system-snapshots.md) kwenye toleo la kabla ya sasisho lako la hivi karibuni. Ikiwa hilo halifanyi kazi, tumia `omarchy-debug` kushiriki tatizo lako kwenye #omarchy-help katika Discord. Na ikiwa yote hayo yatashindikana, unaweza kusakinisha upya usanidi na vifurushi chaguomsingi kwa kutumia `omarchy-reinstall`.

### Kwa nini baadhi ya programu ni kubwa sana kwenye onyesho langu?

Omarchy huchukulia kuwa una onyesho la ubora wa juu la 2x, kwa hivyo huweka `GDK_SCALE` kuwa 2 hadi uchague kipimo kwenye paneli ya monita. Ikiwa uko kwenye onyesho la 1x na programu za GTK au X11 zinatokea kubwa kupita kiasi, lichagulie 1x kwenye paneli ya monita, au ongeza `hl.env("GDK_SCALE", "1")` kwenye `~/.config/hypr/monitors.lua` (na kisha uanzishe upya programu yoyote iliyo kubwa kupita kiasi). Tazama [mwongozo kuhusu monita](33-monitors.md).

Kwa Spotify, unaweza kutumia `Ctrl + Minus` kupunguza ukubwa wa UI (na `Ctrl + Plus` kuifanya iwe kubwa zaidi).

### Kwa nini vifungo vyangu vyote vya kitufe cha Super vimeacha kufanya kazi?

Kwenye baadhi ya laptopu za ASUS ROG na TUF, `Fn + Super` ni mchanganyiko rahisi kukosa unaowasha na kuzima kufuli ya programu dhibiti ya kitufe cha Windows (iliyokusudiwa kwa michezo ya video ili usitoke kwenye mchezo kwa bahati mbaya). Hakuna chochote kwenye skrini kinachokuambia kuwa imetokea. Kufuli ikiwa imewashwa, Super haitoi chochote kabisa — kwa hivyo kila kifungo cha Omarchy kinachotumia Super huacha tu kufanya kazi, na inaonekana kama Hyprland imeharibika.

Bonyeza `Fn + Super` mara moja kabla ya kuchimba ndani ya `~/.config/hypr/`, na ikiwa hiyo hairudishi Super, ibonyeze tena ili usiache kufuli ikiwa imewashwa. Hii si Fn-lock, ambayo hubadilisha tu kile safu ya vitufe vya F hufanya.

### Wi-Fi, Bluetooth, sauti, au trackpad yangu imeacha tu kufanya kazi

Kabla ya kuwasha upya, jaribu kuwasha upya mfumo mdogo unaosababisha tatizo peke yake. _Update > Hardware_ kwenye menyu ya Omarchy ina Wi-Fi, Bluetooth, Audio, na Trackpad, na kupakia upya mojawapo kati ya hizo huondoa tatizo katika hali nyingi za "ilikuwa inafanya kazi dakika tano zilizopita" — vifaa vya masikioni vya Bluetooth visivyotaka kuunganishwa tena, trackpad iliyokufa baada ya kusitisha, sauti iliyopotea ulipochomoa monita.

### Kwa nini spika zangu za nje hazichezi?

Labda kwa sababu hazijawekwa kama kifaa kikuu cha kutoa sauti. Bofya aikoni ya spika iliyo upande wa kulia wa upau, na itafungua dirisha ibukizi la sauti ambapo unaweza kuchagua kifaa cha kutoa sauti (na pia kuchanganya sauti kwa kila programu).

### Spika za laptopu yangu zinasikika vibaya

Kwenye baadhi ya laptopu, Omarchy hutumia kiotomatiki urekebishaji wa spika unaosahihisha mwitikio wa masafa wa spika zilizojengwa ndani. `omarchy audio tuning status` inakuambia kama mmoja unafanya kazi kwenye mashine yako, na `omarchy audio tuning off` huizima ikiwa unapendelea kusikia spika kama zilivyo bila urekebishaji.

### Kwa nini siwezi kuingia au kutumia sudo kwa nenosiri langu?

Labda uliliandika vibaya mara kumi na ukafungiwa nje. Kufungiwa huondoka peke yake baada ya dakika mbili. Ikiwa huwezi kusubiri, na hili linatokea kwenye skrini ya kufuli, unaweza kubonyeza `CTRL + ALT + F2` kuanzisha TTY mpya ambapo unaweza kuingia kama root, kisha endesha `faillock --reset --user [your-username]`. Hiyo itaweka upya kufungiwa, na uko tayari kuendelea.

### Nenosiri langu linakubaliwa, lakini narudi kwenye skrini ya kuingia

Faili ya mazingira ya kipindi iliyoharibika inaweza kuzuia eneo-kazi kuanza hata wakati nenosiri lako ni sahihi. Hii inafaa hasa kuangaliwa baada ya kuhariri `~/.config/uwsm/env.d/`.

Bonyeza `Ctrl + Alt + F2`, ingia kwa jina lako la kawaida la mtumiaji na nenosiri, na kagua jarida la mtumiaji la kuwasha kwa sasa:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Tafuta hitilafu inayotaja moja ya faili zako za mazingira, kama vile `bad substitution`, kabla tu ya ujumbe kuwa alama ya matokeo ya env haikupatikana. Hamisha faili hiyo nje ya `env.d` kabla ya kujaribu kuingia tena. Kwa mfano, ikiwa hitilafu inataja `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM huruka faili yenye hitilafu ya sintaksia, lakini hitilafu mbaya inayoonekana tu wakati faili inaendeshwa, kama `bad substitution`, bado inaweza kuzuia eneo-kazi kuanza. Kurudisha nakala ya mfumo hakurekebishi faili hizi, kwa sababu `/home` hairudishwi.

Ukishaweza kuingia, rekebisha nakala iliyohifadhiwa kabla ya kuirudisha. `sh -n` hugundua hitilafu za sintaksia bila kuendesha faili, lakini haiwezi kugundua kila hitilafu inayotokea inapotumiwa kama chanzo. Weka terminal inayofanya kazi wazi wakati wa kujaribu mabadiliko.

### Kwa nini vishawishi vyangu vya uidhinishaji vya 1Password kwa 1Password SSH Agent / CLI havionekani?

Hili linaweza kutokea kwa sababu 2:

Ili kishawishi kamili cha uidhinishaji kionekane, Settings > Advanced > Use Hardware Acceleration lazima iwe imewashwa. _Kumbuka: Hii inahitaji kuwasha upya ili kuanza kufanya kazi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Au ikiwa hujazindua 1Password tangu kuwasha, kishawishi hakitaonekana.
