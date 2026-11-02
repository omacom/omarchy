# Picha za Skrini na Kurekodi

Kila kitu unachoweza kuchukua kutoka kwenye skrini kinategemea kitufe cha Print Screen. Kitufe hicho pekee hupiga picha, na vitufe vya kusaidia huchukua rekodi, rangi, au maandishi yaliyo ndani ya eneo. Ikiwa kibodi yako haina kitufe cha Print Screen kabisa, `Super + Ctrl + Alt + C` hupiga picha ya skrini ile ile, na `Super + Ctrl + C` hufungua seti nzima kama menyu.

| Kitufe cha mkato | Kazi |
| ------ | -------- |
| `Print Screen` | Picha ya skrini |
| `Super + Ctrl + Alt + C` | Picha ya skrini |
| `Alt + Print Screen` | Rekodi ya skrini (au simamisha inayoendelea) |
| `Super + Print Screen` | Kiteua rangi |
| `Super + Ctrl + Print Screen` | Dondoa maandishi kutoka kwenye eneo |
| `Super + Ctrl + C` | Menyu ya kunasa |
| `Super + Ctrl + .` | Badilisha umbizo la picha au video |

## Picha za Skrini

Bonyeza `Print Screen` (au `Super + Ctrl + Alt + C`) na Omasnap hunasa monita iliyolengwa kabla ya safu yake ya juu kuonekana, kwa hiyo hakuna kinachosogea chini yako unapolenga. Buruta eneo la umbo lolote, bofya dirisha ili kulinasa, au bofya nafasi tupu ili kunasa monita nzima. Bonyeza `S` kabla ya kuchora ili kunasa eneo la kusogeza. Umabadili mawazo? Bonyeza kitufe kile kile tena ili kuondoa Omasnap.

Baada ya kuchagua eneo, Omasnap huhifadhi nasaji, huinakili kwenye ubao wa kunakili, na huonyesha arifa yenye kijipicha chake, kama rekodi ya skrini iliyohifadhiwa inavyofanya. Chagua Open ili kuona picha iliyohifadhiwa kwenye kitazama picha chako, au Edit ili kuifanyia maelezo.

Kihariri cha maelezo kinaweza kuchora mishale, mistari, maumbo, vivutio, alama zenye namba, maandishi, na ufichaji salama; kukata au kuondoa sehemu ya picha; ku-OCR maandishi yake; na kuongeza mandharinyuma. Kwenye kihariri, bonyeza `Enter` ili kunakili na kuhifadhi PNG iliyokamilika, `Ctrl + C` ili kuinakili bila kuhifadhi, au `Ctrl + S` ili kuihifadhi bila kunakili.

Picha za skrini zilizohifadhiwa huishia kwenye `~/Pictures/Screenshots` kwa chaguo-msingi, zikiwa na jina kama `screenshot-2026-08-13_14-22-05-firefox.png`. Weka `OMASNAP_SCREENSHOT_DIR` ili kutumia saraka nyingine — angalia [Maswali Yanayoulizwa Mara kwa Mara](46-faq.md) ili kujua mahali pa kuweka vigezo vya mazingira ya kipindi. Omasnap huunda saraka hiyo inapohifadhi picha ya kwanza. Weka `[output] autosave = false` kwenye `~/.config/omasnap/omasnap.conf` ili kuzima uhifadhi wa kiotomatiki; nasaji basi hunakiliwa tu, na huonyeshwa kwenye hakikisho kwa sekunde 10 ambalo unaweza kuliweka kwenye skrini kwa kitufe chake cha kubandika au `Ctrl + P`.

Kutoka kwenye terminal, `omarchy screenshot` hufungua safu ile ile ya juu, na unaweza kuchagua hali yake ya kuanzia: `omarchy capture screenshot region`, `windows`, `fullscreen`, au `scroll`. Hoja ya pili ya `copy` au `save` hutuma picha moja kwa moja kwenye lengo hilo. Ili kuhariri kabla ya kutoa, tumia `omarchy screenshot --editor=overlay` kwa kihariri cha skrini nzima au `omarchy screenshot --editor=window` kwa dirisha tofauti.

### Kuendesha kiteuzi kwa kibodi

Wakati uteuzi umeonekana, si lazima utumie kipanya hata kidogo:

| Kitufe | Kazi |
| --- | -------- |
| `S` | Washa/zima hali ya eneo la kusogeza |
| `Super + Arrow keys` | Sogea kati ya madirisha katika hali ya Window |
| `Return` | Nasa dirisha lililovutiwa |
| `Ctrl + A` | Nasa monita nzima iliyolengwa |
| `R` | Rejesha eneo la mwisho lililochorwa katika kipindi hiki |
| `Esc` | Ondoa Omasnap |

Miunganisho hii ipo tu wakati Omasnap imefunguliwa, kwa hiyo haiwezi kugongana na chochote kwenye usanidi wako mwenyewe.

## Kurekodi skrini

`Alt + Print Screen` hufungua _Trigger > Capture > Screenrecord_, ambayo huuliza unachotaka kwenye sauti: hakuna sauti, sauti ya eneo-kazi, sauti ya eneo-kazi pamoja na kipaza sauti, au sauti ya eneo-kazi pamoja na kipaza sauti pamoja na kamera ya wavuti. Chaguo hilo la mwisho huonekana tu ikiwa kweli una kamera iliyochomekwa. Chagua moja na kiteua rekodi cha Omarchy hukuruhusu kuburuta eneo au kubofya dirisha au monita.

Kurekodi huendeshwa kwenye gpu-screen-recorder, ambayo husimba kwenye GPU kwa 60fps na hurudi kwenye CPU ikilazimika. Matokeo ni MP4 kwenye `~/Videos`, yenye jina `screenrecording-2026-08-13_14-22-05.mp4`. Weka `OMARCHY_SCREENRECORD_DIR` ili kubadilisha hilo — lakini kumbuka kuwa tofauti na saraka ya picha za skrini, hii lazima iwepo tayari, vinginevyo rekodi hukataa kuanza.

Unapore kodi, kiashirio kidogo huonekana kwenye upau. Kibofye ili kusimamisha. Unaweza pia kusimamisha kwa `Alt + Print Screen` tena, au kwa kipengee cha _Stop Screenrecording_ chini ya _Trigger > Capture > Screenrecord_, ambacho huonekana tu wakati kitu kinarekodiwa kweli.

Kusimamisha hufanya usafishaji kidogo kabla ya kukukabidhi faili: fremu ya kwanza hukatwa, na ikiwa kuna sauti husawazishwa hadi -14 LUFS huku mlio wa kunasa wa PipeWire ulio mwanzoni kabisa ukinyamazishwa. Kisha arifa huonekana yenye kijipicha kutoka kwenye rekodi. Ibofye ili kucheza faili kwenye mpv.

### Dirisha la kamera ya wavuti lililo juu

Unapore kodi ukiwa na kamera ya wavuti, kamera huonekana kama dirisha lililobandikwa, lililokatwa la picha ya wima kwenye kona ya chini kulia ya chochote unachorekodi. Ikiwa imekaa juu ya kitu unachohitaji, ibadilishe ukubwa papo hapo:

| Kitufe cha mkato | Kazi |
| ------ | -------- |
| `Super + Alt + [` | Fanya dirisha la kamera ya wavuti lililo juu kuwa dogo zaidi |
| `Super + Alt + ]` | Fanya dirisha la kamera ya wavuti lililo juu kuwa kubwa zaidi |

Kuna ukubwa tatu — ndogo, ya kati, na kubwa — na vitufe vya mkato husogea kati yake. Ya kati ndiyo chaguo-msingi. Ni sawia na rekodi, kwa hiyo kamera huchukua sehemu ile ile ya fremu iwe unarekodi monita ya 1080p au ya 6K. Na ikiwa ulirekodi eneo badala ya onyesho zima, dirisha lililo juu hujiegemeza kwenye kona ya eneo hilo badala ya ya monita, kwa hiyo hubaki ndani ya picha.

Unaweza pia kuliita moja kwa moja kwa `omarchy-capture-webcam-resize small`, au `reset` ili kurudi kwenye ya kati.

## Maandishi, misimbo ya QR, na rangi

`Super + Ctrl + Print Screen` huchagua eneo na kui-OCR kwenye ubao wa kunakili. Hilo limefafanuliwa ipasavyo kwenye [Utoaji wa Maandishi na Kuandikisha kwa Sauti](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ hufanya ujanja ule ule kwa misimbo ya QR. Chagua eneo lenye msimbo ndani yake, na thamani iliyofumbuliwa huenda kwenye ubao wa kunakili. Hutafuta misimbo ya QR tu — maudhui mazito ya skrini yana tabia ya kujitokeza kwa uongo kama msimbomilia vinginevyo. Inafaa kujua: thamani iliyofumbuliwa huenda kwenye ubao wa kunakili na hakuna mahali pengine. Haichapishwi, haipo kwenye arifa, na imewekewa alama kuwa nyeti kwa hiyo haibaki kwenye [historia ya ubao wa kunakili](08-unified-clipboard-history.md). Misimbo ya QR mara kwa mara hubeba siri — URI ya `otpauth://` iliyo nyuma ya msimbo wa kusanidi 2FA, kwa mfano — na hutaki hiyo kwenye kumbukumbu. Kubandika bado hufanya kazi vizuri.

`Super + Print Screen` (au _Trigger > Capture > Color_) hugeuza kielekezi kuwa kidondoshi cha macho. Bofya chochote kwenye skrini na rangi huishia kwenye ubao wa kunakili. Bonyeza kitufe cha mkato tena ili kutoka bila kuchagua.

## Kubadilisha umbizo kabla ya kushiriki

Rekodi ya skrini ya 4K au HEIC mbichi kutoka kwenye simu yako mara nyingi ni kubwa mno kuweza kuituma tu. `Super + Ctrl + .` (au _Trigger > Transcode_) hurekebisha hilo. Hukupa kiteua faili kisicho makini juu ya `~/Pictures` na `~/Videos`, kisha huuliza umbizo na ukubwa.

Picha huenda kwenye jpg au png kwa juu, kati, au chini, ambazo huweka kikomo cha upana kwa pikseli 3160, 2160, na 1080. Video huenda kwenye mp4 au gif inayotembea kwa 4k, 1080p, au 720p. Faili iliyobadilishwa huandikwa karibu na la asili ikiwa na ubora kwenye jina — `demo-1080p.mp4` — na njia hunakiliwa kwenye ubao wa kunakili kama URI ya faili, kwa hiyo unaweza kuibandika moja kwa moja kwenye programu inayokubali udondoshaji wa faili.

Hufanya kazi kutoka kwenye terminal pia, ikiwa tayari unajua unachotaka: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Pia kuna `omarchy transcode ascii`, ambayo hugeuza picha kuwa sanaa ya ASCII — hiyo ni zaidi kwa ajili ya [utambulisho wa chapa](41-branding.md).

## Kuituma mahali

Ukishapata faili, `Super + Ctrl + S` hufungua menyu ya Share na kuituma kwenye kifaa kingine kwenye mtandao wako kupitia LocalSend. Angalia [GUIs](22-guis.md) kwa hilo.
