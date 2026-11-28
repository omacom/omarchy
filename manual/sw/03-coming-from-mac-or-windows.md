# Kuwasili kutoka Mac au Windows

Ikiwa umetumia miaka mingi kwenye macOS au Windows, vidole vyako vinajua mambo mamia ambayo ubongo wako umesahau kuwa uliwahi kuyajifunza. Sura hii ndiyo tabaka la tafsiri: pale ambapo silika hizo huenda katika Omarchy. Vipengele vyenyewe vimeelezwa kwa kina mahali pengine — hii ni ramani tu.

### Super ndiyo kiini cha kila kitu

Kumbukumbu yote ya misuli uliyoijenga karibu na Cmd au kitufe cha Windows huhamia kwenye kitufe kimoja: Super. Hicho ndicho kitufe cha Windows kwenye kibodi ya PC, na ndicho nanga ya karibu kila hotkey katika Omarchy.

Silika yako ya Spotlight au Raycast au menyu ya Start inakuwa `Super + Space`. Hiyo hufungua menyu ya Omarchy, ambayo huzindua programu, hubadilisha mipangilio, husakinisha programu, hunasa skrini — karibu kila kitu. Anza kuandika ili kuchuja. `Super + Alt + Space` huonyesha kila programu kwenye gridi moja, kama vile Launchpad hufanya. Tazama [urambazaji](04-navigation.md).

### Hakuna aikoni za eneo-kazi, na dock hujiepusha

Hakuna aikoni za kupanga kwenye eneo-kazi, na dock hujificha mara tu nafasi ya kazi inapokuwa na dirisha, hadi usukume kielekezi kwenye ukingo wake wa skrini, ule wa kulia isipokuwa ukiihamisha (tazama [urambazaji](04-navigation.md)). Programu huanza kutoka kwa hotkey (`Super + Return` kwa terminal, `Super + Shift + Return` kwa kivinjari, na `Super + K` kwa orodha ya kila kitu kilichopangiwa kitufe) au kutoka kwenye menyu. Kipande kimoja cha UI kinachodumu ni [upau wa juu](05-the-top-bar.md), ambao hufanya yale ambayo upau wa menyu, trei ya mfumo, na Notification Center vilikufanyia hapo awali — na karibu kila wijeti iliyo juu yake hufanya kitu unapobofya kushoto, kulia, na katikati.

### Madirisha hujipanga yenyewe

Mabadiliko makubwa zaidi ya mtazamo: huburuti madirisha huku na kule wala kuyaambatisha kwenye nusu za skrini. Fungua dirisha na linachukua skrini nzima. Fungua la pili na yanaisawazisha. Kamwe hulichokoa dirisha kutoka chini ya jingine, kwa sababu madirisha hayaingiliani.

Unapohitaji kweli dirisha linaloelea, `Super + T` hubadilisha dirisha amilifu kutoka kwenye upanuaji wa vigae (na kulirudisha). Lakini kwanza ipe upangaji wa vigae nafasi halisi — ndicho kiini cha jambo zima. [Urambazaji](04-navigation.md) hukupitisha humo.

Nafasi za kazi zitahisi za kawaida: ni macOS Spaces au eneo-kazi pepe za Windows, isipokuwa kwamba utaztumia kweli, kwa sababu `Super + 1/2/3/4` huruka moja kwa moja hadi kwenye moja na `Super + Shift + 1/2/3/4` hutuma dirisha amilifu huko. Hakuna ucheleweshaji wa uhuishaji, ni miruko ya papo hapo tu. Hii inamaanisha huenda hata usihitaji vichunguzi vingi, ikiwa ulikuwa umezoea hivyo hapo awali.

### Kunakili na kubandika hufanya kazi tu

Kwenye Mac ulikuwa na Cmd + C kila mahali. Kwenye Windows ulikuwa na Ctrl + C kila mahali — isipokuwa kwenye terminal, ambapo huua programu yako. Omarchy hukupa `Super + C`, `Super + X`, na `Super + V`, na hufanya kazi kila mahali, ikiwa ni pamoja na kwenye terminal. Hakuna silika tofauti ya kujifunza kwa shell.

Watu wa Windows: historia yako ya ubao wa kunakili ya Win + V ipo kwenye `Super + Ctrl + V`, na huhifadhi picha pamoja na maandishi. Tazama [ubao wa kunakili uliounganishwa & historia](08-unified-clipboard-history.md).

### Jedwali la tafsiri

| Unachotafuta | Katika Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menyu ya Start | `Super + Space` — menyu ya Omarchy |
| AirDrop | LocalSend, kupitia `Super + Ctrl + S` — tazama [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` au `Print Screen` — tazama [picha za skrini & kurekodi](12-screenshots-recording.md) |
| Notification Center | Historia ya arifa kwenye `Super + Shift + Alt + ,` |
| Time Machine (kwa mfumo) | [Picha za mfumo](47-system-snapshots.md) za kiotomatiki kwenye kila sasisho |
| App Store / kupakua kisakinishi | _Install_ kwenye menyu, au `omarchy pkg add` — tazama [vifurushi vingine](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ kwenye menyu, ambayo huhariri faili tupu za usanidi — tazama [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, kwenye `Super + Shift + F` — tazama [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome kwenye `Super + Shift + Return`; chagua nyingine chini ya _Setup > Defaults > Browser_ — tazama [vivinjari](23-browsers.md) |
| Preview / Photos | Omaview kwa picha, video na muziki, Document Viewer kwa PDF — tazama [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, kwenye `Super + Shift + N`; chagua nyingine chini ya _Setup > Defaults > Editor_ |

### Baadhi ya mambo ni tofauti kweli

Mipangilio mingi ipo katika faili za maandishi unazohariri, si paneli unazobofya. Hiyo inasikika ya kizamani hadi utambue inamaanisha kila marekebisho yanaweza kuonekana, kunakiliwa kwenye mashine yako inayofuata, na kuwekwa katika udhibiti wa matoleo. Menyu ya _Setup_ hukupeleka moja kwa moja kwenye faili sahihi na huwasha upya chochote kinachohitaji kuwashwa upya ukimaliza.

Masasisho huja kupitia amri moja — _Update > Omarchy_ — ambayo husasisha Omarchy yenyewe na kila kifurushi kwenye mfumo, ikichukua picha kwanza. Hakuna visasishe vya kila programu vinavyokusumbua bila mpangilio. Tazama [masasisho](30-updates.md).

Programu huja kutoka kwa kidhibiti cha vifurushi, si kutoka kwa visakinishi vilivyopakuliwa.

Na unapofunga dirisha, programu huacha kweli. Hakuna hali ya kati ya macOS ambapo programu huendelea kufanya kazi bila madirisha. `Super + W` — au `Super + Q`, ikiwa hiyo ndiyo kumbukumbu ya vidole uliyokuja nayo — inamaanisha imekwisha.

### Kwenye vifaa vya Mac

Omarchy hufanya kazi vyema kwenye Mac za Intel, na kwenye Mac za M1, M2 na M3 kwa Omarchy for Apple Silicon. Tazama [usasaidizi wa Mac](44-mac-support.md). Na kibodi ni mpole kwako: Omarchy haibadilishi mpangilio wa chochote, na Linux hulichukulia kitufe cha Command kama Super, kwa hivyo Super hukaa pale pale ambapo Cmd ilikuwa kila mara. Kidole chako gumba hakitaona mabadiliko.

### Ipe wiki mbili

Silika huhamia haraka kuliko unavyofikiria. Pitia sura ya [hotkeys](07-hotkeys.md) mara moja, na kila unapokosa uhusiano wa kitufe, bonyeza `Super + K` — inakuonyesha zote. Hiyo ndiyo hotkey pekee unayopaswa kukariri kweli.
