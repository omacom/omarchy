# Kutoka Mac au Windows

Ikiwa umetumia miaka mingi kwenye macOS au Windows, vidole vyako vinajua mambo mia ambayo ubongo wako umesahau kwamba uliwahi kuyajifunza. Sura hii ndiyo tabaka la tafsiri: mahali ambapo silika hizo huenda katika Omarchy. Vipengele vyenyewe vimeelezwa kwa kina mahali pengine — hii ni ramani tu.

### Super ndiyo kitovu cha kila kitu

Kumbukumbu yote ya misuli uliyoijenga karibu na Cmd au kitufe cha Windows huhamia kwenye kitufe kimoja: Super. Hicho ndicho kitufe cha Windows kwenye kibodi ya PC, na ndicho nanga ya karibu kila hotkey katika Omarchy.

Reflexi yako ya Spotlight au Raycast au menyu ya Start inakuwa `Super + Space`. Hiyo hufungua menyu ya Omarchy, ambayo huzindua programu, hubadilisha mipangilio, husakinisha programu, hunasa skrini — karibu kila kitu. Anza kuandika ili kuchuja. `Super + Alt + Space` huonyesha kila programu kwenye gridi moja, kama Launchpad inavyofanya. Tazama [urambazaji](04-navigation.md).

### Hakuna aikoni za eneo-kazi, na dock hukaa mbali na njia

Hakuna aikoni za kupanga kwenye eneo-kazi, na dock hujificha mara tu nafasi ya kazi inapokuwa na dirisha, hadi usukume kielekezi kwenye ukingo wake wa skrini, ule wa chini isipokuwa ukaihamisha (tazama [urambazaji](04-navigation.md)). Programu huanza kwa hotkey (`Super + Return` kwa terminal, `Super + Shift + Return` kwa kivinjari, na `Super + K` kwa orodha ya kila kitu kilichopangwa) au kutoka kwenye menyu. Kipengele kimoja cha UI kinachoendelea kuwepo ni [upau wa juu](05-the-top-bar.md), ambao hufanya kile ambacho upau wa menyu, trei ya mfumo, na Notification Center vilikufanyia awali — na karibu kila wijeti iliyo juu yake hufanya kitu kwa kubofya kushoto, kulia, na kati.

### Madirisha hujiweka yenyewe

Mabadiliko makubwa zaidi ya mtazamo: huburuti madirisha huku na huko wala kuyaambatisha kwenye nusu za skrini. Fungua dirisha na linachukua skrini nzima. Fungua la pili na yanaigawanya. Hutafuti kamwe dirisha kutoka chini ya jingine, kwa sababu madirisha hayaingiliani.

Unapohitaji kweli dirisha linaloelea, `Super + T` huondoa dirisha linalotumika kutoka kwenye mpangilio wa vigae (na kulirudisha). Lakini upe mpangilio wa vigae nafasi halisi kwanza — ndio moyo wa jambo zima. [Urambazaji](04-navigation.md) hukuongoza kupitia hilo.

Nafasi za kazi zitaonekana za kawaida: ni kama macOS Spaces au eneo-kazi pepe za Windows, isipokuwa kwamba utaztumia kweli, kwa sababu `Super + 1/2/3/4` huruka moja kwa moja hadi moja na `Super + Shift + 1/2/3/4` hutuma dirisha linalotumika huko. Hakuna ucheleweshaji wa uhuishaji, ni miruko ya papo hapo tu. Hii inamaanisha kwamba huenda usihitaji hata vichunguzi vingi, ikiwa ulikuwa umezoea hivyo awali.

### Kunakili na kubandika hufanya kazi tu

Kwenye Mac ulikuwa na Cmd + C kila mahali. Kwenye Windows ulikuwa na Ctrl + C kila mahali — isipokuwa terminal, ambapo huua programu yako. Omarchy hukupa `Super + C`, `Super + X`, na `Super + V`, na hufanya kazi kila mahali, ikijumuisha terminal. Hakuna reflexi tofauti ya kujifunza kwa shell.

Watu wa Windows: historia yako ya ubao wa kunakili ya Win + V iko kwenye `Super + Ctrl + V`, na huhifadhi picha pamoja na maandishi. Tazama [ubao wa kunakili uliounganishwa & historia](08-unified-clipboard-history.md).

### Jedwali la tafsiri

| Unachotafuta | Katika Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menyu ya Start | `Super + Space` — menyu ya Omarchy |
| AirDrop | LocalSend, kupitia `Super + Ctrl + S` — tazama [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` au `Print Screen` — tazama [picha za skrini & kurekodi](12-screenshots-recording.md) |
| Notification Center | Historia ya arifa kwenye `Super + Shift + Alt + ,` |
| Time Machine (kwa mfumo) | [Picha za mfumo](47-system-snapshots.md) za kiotomatiki kwa kila sasisho |
| App Store / kupakua kisakinishi | _Install_ kwenye menyu, au `omarchy pkg add` — tazama [vifurushi vingine](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ kwenye menyu, ambayo huhariri faili rahisi za usanidi — tazama [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, kwenye `Super + Shift + F` — tazama [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome kwenye `Super + Shift + Return`; chagua nyingine chini ya _Setup > Defaults > Browser_ — tazama [vivinjari](23-browsers.md) |
| Preview / Photos | Omaview kwa picha, video na muziki, Document Viewer kwa PDF — tazama [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, kwenye `Super + Shift + N`; chagua nyingine chini ya _Setup > Defaults > Editor_ |

### Baadhi ya mambo ni tofauti kweli

Mipangilio mingi huishi katika faili za maandishi unazohariri, si paneli unazobofya. Hiyo inaonekana ya kizamani hadi utambue inamaanisha kila marekebisho yanaweza kuonekana, kunakiliwa kwenye mashine yako inayofuata, na kuwekwa katika udhibiti wa matoleo. Menyu ya _Setup_ hukupeleka moja kwa moja kwenye faili sahihi na kuwasha upya chochote kinachohitaji kuwashwa upya ukimaliza.

Masasisho huja kupitia amri moja — _Update > Omarchy_ — ambayo husasisha Omarchy yenyewe na kila kifurushi kwenye mfumo, ikichukua snapshot kwanza. Hakuna visasisishaji vya kila programu vinavyokusumbua bila mpangilio. Tazama [masasisho](30-updates.md).

Programu hutoka kwa kidhibiti vifurushi, si kutoka kwa visakinishi vilivyopakuliwa.

Na unapofunga dirisha, programu hujiondoa kweli. Hakuna hali ya kati ya macOS ambapo programu huendelea kufanya kazi bila madirisha. `Super + W` — au `Super + Q`, ikiwa hiyo ndiyo kumbukumbu ya vidole uliyokuja nayo — inamaanisha imekwenda.

### Kwenye maunzi ya Mac

Omarchy hufanya kazi vizuri kwenye Intel Macs, na kwenye M1, M2 na M3 Macs na Omarchy for Apple Silicon. Tazama [usaidizi wa Mac](44-mac-support.md). Na kibodi ni mpole kwako: Omarchy haipangi upya chochote, na Linux huchukulia kitufe cha Command kama Super, kwa hivyo Super hukaa pale pale Cmd ilipokuwa daima. Kidole chako gumba hakitaona mabadiliko.

### Ipe wiki mbili

Silika huhamia haraka kuliko unavyofikiria. Pitia sura ya [hotkeys](07-hotkeys.md) mara moja, na wakati wowote unaposahau uhusiano wa kitufe, bonyeza `Super + K` — hukuonyesha zote. Hiyo ndiyo hotkey pekee unayopaswa kukariri kweli.
