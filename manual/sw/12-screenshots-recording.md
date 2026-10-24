# Picha za Skrini na Kurekodi

Kila kitu unachoweza kunyakua kutoka skrini hutegemea kitufe cha Print Screen. Kitufe kimoja peke yake huchukua picha, na virekebishaji huchukua rekodi, rangi, au maandishi ndani ya eneo. Ikiwa kibodi yako haina kitufe cha Print Screen kabisa, `Super + Ctrl + C` hufungua seti hiyo hiyo kama menyu.

| Mkato wa kitufe | Kazi |
| ------ | -------- |
| `Print Screen` | Picha ya skrini |
| `Alt + Print Screen` | Rekodi skrini (au simamisha inayoendeshwa) |
| `Super + Print Screen` | Kichaguzi cha rangi |
| `Super + Ctrl + Print Screen` | Chimba maandishi kutoka eneo |
| `Super + Ctrl + C` | Menyu ya kunasa |
| `Super + Ctrl + .` | Geuza msimbo wa picha au video |

## Picha za skrini

Bonyeza `Print Screen` na Omasnap hunasa skrini iliyozingatiwa kabla ya kiwekeleo chake kuonekana, hivyo hakuna kinachohamahamia chini yako unapolenga. Buruta eneo huru, bofya dirisha kulinasa, au bofya nafasi wazi kunasa skrini yote. Bonyeza `S` kabla ya kuchora kunasa eneo linalosogeza. Umebadili mawazo? Bonyeza `Print Screen` tena kuondoa Omasnap.

Baada ya kuchagua eneo, Omasnap huhifadhi nasa, huinakili kwenye ubao wa kunakili, na huonyesha onyesho la kukagua kwa sekunde 10. Tumia kitufe cha kubana cha onyesho la kukagua au `Ctrl + P` kuliweka kwenye skrini, au chagua Hariri kuliandikia maelezo.

Kihariri cha maelezo kinaweza kuchora mishale, mistari, maumbo, vivutio, vialama vyenye nambari, maandishi, na uzibaji salama; kukata au kuondoa sehemu ya picha; OCR maandishi yake; na kuongeza mandhari. Katika kihariri, bonyeza `Enter` kunakili na kuhifadhi PNG iliyokamilika, `Ctrl + C` kuinkili bila kuhifadhi, au `Ctrl + S` kuihifadhi bila kunakili.

Picha za skrini zilizohifadhiwa huishia katika `~/Pictures/Screenshots` kwa chaguomsingi, na jina kama `screenshot-2026-08-13_14-22-05-firefox.png`. Weka `OMASNAP_SCREENSHOT_DIR` kutumia saraka nyingine — tazama [FAQ](46-faq.md) kwa mahali pa kuweka vigezo vya mazingira ya kipindi. Omasnap huunda saraka hiyo inapohifadhi picha ya kwanza. Weka `[output] autosave = false` katika `~/.config/omasnap/omasnap.conf` kuzima uokolewaji otomatiki.

Kutoka terminali, `omarchy screenshot` hufungua kiwekeleo hicho hicho, na unaweza kuchagua hali yake ya kuanza: `omarchy capture screenshot region`, `windows`, `fullscreen`, au `scroll`. Hoja ya pili ya `copy` au `save` huruka onyesho la kukagua na kutuma picha moja kwa moja hadi lengo hilo. Kuhariri kabla ya kutoa, tumia `omarchy screenshot --editor=overlay` kwa kihariri cha skrini kamili au `omarchy screenshot --editor=window` kwa dirisha tofauti.

### Kuendesha kichaguzi kutoka kibodi

Wakati uteuzi uko wazi, huhitaji kutumia kipanya kabisa:

| Kitufe | Kazi |
| --- | -------- |
| `S` | Badilisha hali ya eneo linalosogeza |
| `Super + Arrow keys` | Sogeza kati ya madirisha katika hali ya Dirisha |
| `Return` | Nasa dirisha lililovutiwa |
| `Ctrl + A` | Nasa skrini kamili iliyozingatiwa |
| `R` | Rejesha eneo la mwisho lililochorwa katika kipindi hiki |
| `Esc` | Ondoa Omasnap |

Ufungaji huu upo tu wakati Omasnap iko wazi, hivyo hauwezi kugongana na chochote katika usanidi wako mwenyewe.

## Kurekodi skrini

`Alt + Print Screen` hufungua _Anzisha > Nasa > Rekodi skrini_, ambayo huuliza unataka nini kwenye sauti: bila sauti, sauti ya eneo-kazi, eneo-kazi pamoja na maikrofoni, au eneo-kazi pamoja na maikrofoni pamoja na kamera ya wavuti. Hiyo ya mwisho huonekana tu ikiwa kweli una kamera iliyochomekwa. Chagua moja na kichaguzi cha kurekodi cha Omarchy hukuruhusu kuburuta eneo au kubofya dirisha au skrini.

Kurekodi hufanya kazi kwenye gpu-screen-recorder, ambayo husimba kwenye GPU katika 60fps na hurudi kwenye CPU ikilazimika. Matokeo ni MP4 katika `~/Videos`, inayoitwa `screenrecording-2026-08-13_14-22-05.mp4`. Weka `OMARCHY_SCREENRECORD_DIR` kubadilisha hiyo — lakini kumbuka kwamba tofauti na saraka ya picha za skrini, hii lazima iwepo tayari, vinginevyo rekodi hukataa kuanza.

Unaporegodi, kiashiria kidogo huonekana kwenye upau. Bofya kusimamisha. Unaweza pia kusimamisha kwa `Alt + Print Screen` tena, au kwa ingizo la _Acha Kurekodi Skrini_ chini ya _Anzisha > Nasa > Rekodi skrini_, ambalo huonekana tu wakati kitu kweli kinaregodiwa.

Kusimamisha hufanya usafi kidogo kabla ya kukukabidhi faili: fremu ya kwanza hukatwa, na ikiwa kuna sauti hurekebishwa kuwa -14 LUFS na mlio wa kunasa wa PipeWire mwanzoni kabisa hunyamazishwa. Kisha arifa huonekana na kijipicha kutoka rekodi. Bofya kucheza faili katika mpv.

### Kiwekeleo cha kamera ya wavuti

Unaporegodi na kamera ya wavuti, kamera huonekana kama dirisha la picha lililobanwa, lililokatwa katika kona ya chini-kulia ya chochote unachorekodi. Ikiwa imekaa juu ya kitu unachohitaji, ibadilishe ukubwa papo hapo:

| Mkato wa kitufe | Kazi |
| ------ | -------- |
| `Super + Alt + [` | Fanya kiwekeleo cha kamera ya wavuti kiwe kidogo |
| `Super + Alt + ]` | Fanya kiwekeleo cha kamera ya wavuti kiwe kikubwa |

Kuna ukubwa tatu — mdogo, wa kati, na mkubwa — na mikato ya vitufe hupitia kati yake. Wa kati ndio chaguomsingi. Ni sawia na rekodi, hivyo kamera huchukua sehemu sawa ya fremu uwe unarekodi skrini ya 1080p au ya 6K. Na ikiwa ulirekodi eneo badala ya skrini yote, kiwekeleo hutia nanga kwenye kona ya eneo hilo badala ya ya skrini, hivyo hubaki ndani ya picha.

Unaweza pia kuiita moja kwa moja kwa `omarchy-capture-webcam-resize small`, au `reset` kurudi wa kati.

## Maandishi, misimbo ya QR, na rangi

`Super + Ctrl + Print Screen` huchagua eneo na kulifanya OCR kwenda ubao wa kunakili. Hiyo imefunikwa vizuri katika [Uchimbaji wa Maandishi na Imla](11-text-extraction-dictation.md).

_Anzisha > Nasa > Msimbo wa QR_ hufanya ujanja huo huo kwa misimbo ya QR. Chagua eneo lenye msimbo, na thamani iliyosimbuliwa huenda kwenye ubao wa kunakili. Hutafuta tu misimbo ya QR — maudhui mnene ya skrini yana tabia ya kujitambua kimakosa kama msimbo pau vinginevyo. Inafaa kujua: thamani iliyosimbuliwa huenda kwenye ubao wa kunakili na hakuna pengine. Hachapishwi, haimo katika arifa, na imetambulishwa kuwa nyeti hivyo haibaki katika [historia ya ubao wa kunakili](08-unified-clipboard-history.md). Misimbo ya QR mara nyingi hubeba siri — URI ya `otpauth://` nyuma ya msimbo wa kuanzisha 2FA, kwa mfano — na hutaki hiyo katika kumbukumbu. Kubandika bado hufanya kazi vizuri.

`Super + Print Screen` (au _Anzisha > Nasa > Rangi_) hubadilisha kishale kuwa kitone. Bofya chochote kwenye skrini na rangi huishia kwenye ubao wa kunakili. Bonyeza mkato wa kitufe tena kutoka bila kuchagua.

## Kugeuza msimbo kabla ya kushiriki

Rekodi ya skrini ya 4K au HEIC mbichi kutoka simu yako mara nyingi ni kubwa sana kutuma tu. `Super + Ctrl + .` (au _Anzisha > Geuza msimbo_) hurekebisha hilo. Hukupa kichaguzi cha faili kisicho dhahiri juu ya `~/Pictures` na `~/Videos`, kisha huuliza umbizo na ukubwa.

Picha huenda jpg au png katika juu, kati, au chini, ambazo hupunguza upana kuwa pikseli 3160, 2160, na 1080. Video huenda mp4 au gif ya uhuishaji katika 4k, 1080p, au 720p. Faili iliyobadilishwa huandikwa karibu na asili na azimio katika jina — `demo-1080p.mp4` — na njia hunakiliwa kwenye ubao wa kunakili kama URI ya faili, hivyo unaweza kuibandika moja kwa moja katika programu inayochukua kudondosha faili.

Inafanya kazi kutoka terminali pia, ukijua tayari unachotaka: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Kuna pia `omarchy transcode ascii`, ambayo hubadilisha picha kuwa sanaa ya ASCII — hiyo ni zaidi kwa [utambulisho](41-branding.md).

## Kuituma mahali fulani

Ukishakuwa na faili, `Super + Ctrl + S` hufungua menyu ya Shiriki na kuituma kwenye kifaa kingine kwenye mtandao wako kupitia LocalSend. Tazama [GUIs](22-guis.md) kwa hiyo.
