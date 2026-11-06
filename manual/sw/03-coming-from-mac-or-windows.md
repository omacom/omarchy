# Kutoka Mac au Windows

Kama umetumia miaka mingi kwenye macOS au Windows, vidole vyako vinajua mambo mia moja ambayo ubongo wako umesahau kuwa uliwahi kuyajifunza. Sura hii ndiyo safu ya tafsiri: ni wapi silika hizo huenda katika Omarchy. Vipengele vyenyewe vimeelezwa kwa kina mahali pengine — hii ni ramani tu.

### Super ndiyo kitovu cha kila kitu

Kumbukumbu yote ya misuli uliyoijenga kuhusu Cmd au kitufe cha Windows huhamia kwenye kitufe kimoja: Super. Hicho ni kitufe cha Windows kwenye kibodi ya PC, na ndicho nanga ya karibu kila mkato wa kibodi katika Omarchy.

Silika yako ya Spotlight au Raycast au menyu ya Start inakuwa `Super + Space`. Hiyo hufungua menyu ya Omarchy, ambayo huzindua programu, hubadilisha mipangilio, husakinisha programu, hunasa skrini — karibu kila kitu. Anza kuandika ili kuchuja. `Super + Alt + Space` huonyesha kila programu kwenye gridi moja, jinsi Launchpad inavyofanya. Tazama [urambazaji](04-navigation.md).

### Hakuna dock na hakuna aikoni za eneo-kazi

Hakuna cha kubofya ili kuzindua vitu, hakuna aikoni za kupanga kwenye eneo-kazi. Programu huanza kwa mkato wa kibodi (`Super + Return` kwa terminal, `Super + Shift + Return` kwa kivinjari, na `Super + K` kwa orodha ya kila kitu kilichopangwa) au kutoka kwenye menyu. Kipande kimoja cha UI kinachodumu ni [upau wa juu](05-the-top-bar.md), ambao hufanya yale ambayo upau wa menyu, trei ya mfumo, na Notification Center vilikufanyia awali — na karibu kila wijeti iliyo juu yake hufanya jambo fulani kwa kubofya kushoto, kulia, na katikati.

### Madirisha hujiweka yenyewe

Mabadiliko makubwa zaidi ya mtazamo: huburuti madirisha huku na kule wala kuyaambatisha kwenye nusu za skrini. Fungua dirisha na linachukua skrini nzima. Fungua la pili na yanaigawanya. Kamwe huvui dirisha kutoka chini ya jingine, kwa sababu madirisha hayaingiliani.

Unapohitaji kweli dirisha linaloelea, `Super + T` hubadilisha lililo hai kutoka kwenye upangaji wa vigae (na kulirudisha). Lakini upe upangaji wa vigae nafasi halisi kwanza — ndio moyo wa jambo zima. [Urambazaji](04-navigation.md) hukuongoza kupitia hilo.

Nafasi za kazi zitajisikia za kawaida: ni kama Spaces za macOS au eneo-kazi pepe za Windows, isipokuwa utaztumia kweli, kwa sababu `Super + 1/2/3/4` huruka moja kwa moja hadi moja na `Super + Shift + 1/2/3/4` hutuma dirisha hai huko. Hakuna ucheleweshaji wa uhuishaji, ni kuruka kwa papo hapo tu. Hii inamaanisha huenda hata usihitaji monita nyingi, kama ulikuwa umezoea hivyo awali.

### Kunakili na kubandika hufanya kazi tu

Kwenye Mac ulikuwa na Cmd + C kila mahali. Kwenye Windows ulikuwa na Ctrl + C kila mahali — isipokuwa terminal, ambapo huua programu yako. Omarchy hukupa `Super + C`, `Super + X`, na `Super + V`, na hufanya kazi kila mahali, pamoja na terminal. Hakuna silika tofauti ya kujifunza kwa shell.

Watu wa Windows: historia yako ya ubao wa kunakili ya Win + V huishi kwenye `Super + Ctrl + V`, na hushikilia picha pamoja na maandishi. Tazama [ubao wa kunakili uliounganishwa & historia](08-unified-clipboard-history.md).

### Jedwali la tafsiri

| Unachotafuta | Katika Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menyu ya Start | `Super + Space` — menyu ya Omarchy |
| AirDrop | LocalSend, kupitia `Super + Ctrl + S` — tazama [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` au `Print Screen` — tazama [picha za skrini & kurekodi](12-screenshots-recording.md) |
| Notification Center | Historia ya arifa kwenye `Super + Shift + Alt + ,` |
| Time Machine (kwa mfumo) | [Picha za mfumo](47-system-snapshots.md) za kiotomatiki kwenye kila sasisho |
| App Store / kupakua kisakinishaji | _Install_ katika menyu, au `omarchy pkg add` — tazama [vifurushi vingine](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ katika menyu, ambayo huhariri faili za usanidi za kawaida — tazama [dotfiles](31-dotfiles.md) |

### Baadhi ya mambo ni tofauti kweli

Mipangilio mingi huishi katika faili za maandishi unazohariri, si paneli unazobofya kupitia. Hiyo husikika kama ya kizamani hadi utambue inamaanisha kila marekebisho yanaweza kuonekana, kunakiliwa kwenye mashine yako inayofuata, na kuwekwa katika udhibiti wa matoleo. Menyu ya _Setup_ hukuweka moja kwa moja kwenye faili sahihi na huwasha upya chochote kinachohitaji kuwashwa upya ukimaliza.

Masasisho huja kupitia amri moja — _Update > Omarchy_ — ambayo husasisha Omarchy yenyewe na kila kifurushi kwenye mfumo, ikichukua picha kwanza. Hakuna visasisishaji vya kila programu vinavyokusumbua bila mpangilio. Tazama [masasisho](30-updates.md).

Programu hutoka kwa kidhibiti cha vifurushi, si kutoka kwa visakinishaji vilivyopakuliwa.

Na unapofunga dirisha, programu hujiondoa kweli. Hakuna hali ya kusubiri ya macOS ambapo programu huendelea kufanya kazi bila madirisha. `Super + W` — au `Super + Q`, kama hiyo ndiyo kumbukumbu ya vidole uliyokuja nayo — inamaanisha imekwisha.

### Kwenye vifaa vya Mac

Omarchy hufanya kazi vizuri kwenye Mac za Intel — tazama [msaada wa Mac](44-mac-support.md). Na kibodi ni mpole kwako: Omarchy haibadilishi mpangilio wa chochote, na Linux huchukulia kitufe cha Command kama Super, kwa hivyo Super hukaa pale pale Cmd ilipokuwa daima. Kidole chako gumba hakitaona uhamaji.

### Ipe wiki mbili

Silika huhama haraka kuliko unavyodhani. Pitia sura ya [mikato ya kibodi](07-hotkeys.md) mara moja, na kila unapokwama kuhusu ufungaji, bonyeza `Super + K` — hukuonyesha yote. Huo ndio mkato pekee wa kibodi unaopaswa kukariri kweli.
