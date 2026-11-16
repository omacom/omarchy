# Picha za Skrini na Kurekodi

Kila kitu unachoweza kuchukua kutoka skrini hutegemea kitufe cha Print Screen. Kitufe hicho peke yake hupiga picha, na virekebishaji huchukua rekodi, rangi, au maandishi yaliyo ndani ya eneo. Ikiwa kibodi yako haina kitufe cha Print Screen kabisa, `Super + Ctrl + Alt + C` hupiga picha ya skrini hiyo hiyo, na `Super + Ctrl + C` hufungua seti nzima kama menyu.

| Kitufe cha mkato | Kazi |
| ------ | -------- |
| `Print Screen` | Picha ya skrini |
| `Super + Ctrl + Alt + C` | Picha ya skrini |
| `Alt + Print Screen` | Rekodi ya skrini (au simamisha inayoendelea) |
| `Super + Print Screen` | Kichagua rangi |
| `Super + Ctrl + Print Screen` | Toa maandishi kutoka eneo |
| `Super + Ctrl + C` | Menyu ya kunasa |
| `Super + Ctrl + .` | Badilisha umbizo la picha au video |

## Picha za skrini

Gonga `Print Screen` (au `Super + Ctrl + Alt + C`) na Omasnap hunasa monita iliyolengwa kabla kiolesura chake kinachoelea kuonekana, kwa hivyo hakuna kinachohama chini yako unapolenga. Buruta eneo huru, bofya dirisha ili kulinasa, au bofya nafasi wazi ili kunasa monita nzima. Bonyeza `S` kabla ya kuchora ili kunasa eneo la kusogeza. Umebadili mawazo? Gonga kitufe hicho hicho tena ili kumwondoa Omasnap.

Baada ya kuchagua eneo, Omasnap huhifadhi kilichonaswa, hukinakili kwenye ubao wa kunakili, na huonyesha arifa yenye taswira yake ndogo, kama rekodi ya skrini iliyohifadhiwa inavyofanya. Chagua Open ili kutazama picha iliyohifadhiwa katika kitazamaji chako cha picha, au Edit ili kuiwekea maelezo.

Kihariri cha maelezo kinaweza kuchora mishale, mistari, maumbo, vivutio, alama zenye namba, maandishi, na ufichaji salama; kukata au kuondoa sehemu ya picha; ku-OCR maandishi yake; na kuongeza mandharinyuma. Katika kihariri, bonyeza `Enter` ili kunakili na kuhifadhi PNG iliyokamilika, `Ctrl + C` ili kuinakili bila kuihifadhi, au `Ctrl + S` ili kuihifadhi bila kuinakili.

Picha za skrini zilizohifadhiwa huenda kwenye `~/Pictures/Screenshots` kwa chaguo-msingi, zikiwa na jina kama `screenshot-2026-08-13_14-22-05-firefox.png`. Weka `OMASNAP_SCREENSHOT_DIR` ili kutumia saraka nyingine — angalia [Maswali Yanayoulizwa Mara kwa Mara](46-faq.md) kwa mahali pa kuweka vigezo vya mazingira ya kipindi. Omasnap huunda saraka hiyo inapohifadhi picha ya kwanza. Weka `[output] autosave = false` katika `~/.config/omasnap/omasnap.conf` ili kuzima uhifadhi wa kiotomatiki; picha zilizonaswa baadaye hunakiliwa tu, na huonyeshwa katika hakikisho kwa sekunde 10 ambalo unaweza kuliweka skrini kwa kitufe chake cha kubandika au `Ctrl + P`.

Kutoka kwenye terminali, `omarchy screenshot` hufungua kiolesura hicho hicho kinachoelea, na unaweza kuchagua hali yake ya kuanzia: `omarchy capture screenshot region`, `windows`, `fullscreen`, au `scroll`. Hoja ya pili ya `copy` au `save` hutuma picha moja kwa moja kwenye lengwa hilo. Ili kuhariri kabla ya kutoa, tumia `omarchy screenshot --editor=overlay` kwa kihariri cha skrini nzima au `omarchy screenshot --editor=window` kwa dirisha tofauti.

### Kuendesha kichaguaji kwa kibodi

Wakati uteuzi unaonekana, si lazima utumie kipanya kabisa:

| Kitufe | Kazi |
| --- | -------- |
| `S` | Washa/zima hali ya eneo la kusogeza |
| `Super + Arrow keys` | Sogeza kati ya madirisha katika hali ya Dirisha |
| `Return` | Nasa dirisha lililovutiwa |
| `Ctrl + A` | Nasa monita nzima iliyolengwa |
| `R` | Rejesha eneo la mwisho lililochorwa katika kipindi hiki |
| `Esc` | Mwandoshe Omasnap |

Miunganiko hii ipo tu wakati Omasnap imefunguliwa, kwa hivyo haiwezi kugongana na chochote katika usanidi wako mwenyewe.

## Kurekodi skrini

`Alt + Print Screen` hufungua _Trigger > Capture > Screenrecord_, ambayo huuliza unachotaka kwenye wimbo wa sauti: hakuna sauti, sauti ya eneo-kazi, sauti ya eneo-kazi pamoja na maikrofoni, au sauti ya eneo-kazi pamoja na maikrofoni pamoja na kamera ya wavuti. Hiyo ya mwisho huonekana tu ikiwa kweli una kamera iliyochomekwa. Chagua moja na kichaguaji cha kurekodi cha Omarchy hukuwezesha kuburuta eneo au kubofya dirisha au monita.

Kurekodi huendeshwa na gpu-screen-recorder, ambayo husimba kwenye GPU kwa 60fps na hurudi kwenye CPU ikilazimika. Matokeo yake ni MP4 katika `~/Videos`, yenye jina `screenrecording-2026-08-13_14-22-05.mp4`. Weka `OMARCHY_SCREENRECORD_DIR` ili kubadilisha hilo — lakini kumbuka kuwa tofauti na saraka ya picha za skrini, hii lazima iwepo tayari, vinginevyo rekodi hukataa kuanza.

Unaporekodi, kiashirio kidogo huonekana kwenye upau. Kibofye ili kusimamisha. Unaweza pia kusimamisha kwa `Alt + Print Screen` tena, au kwa kipengee cha _Stop Screenrecording_ chini ya _Trigger > Capture > Screenrecord_, ambacho huonekana tu wakati kitu kinarekodiwa kweli.

Kusimamisha hufanya usafishaji kidogo kabla ya kukukabidhi faili: fremu ya kwanza hukatwa, na ikiwa kuna sauti hurekebishwa viwango vyake hadi -14 LUFS huku mlio wa kukamata wa PipeWire mwanzoni kabisa ukinyamazishwa. Kisha arifa huonekana ikiwa na taswira ndogo kutoka kwenye rekodi. Ibobye ili kucheza faili katika Omaview.

### Dirisha linaloelea la kamera ya wavuti

Unaporekodi ukiwa na kamera ya wavuti, kamera huonekana kama dirisha la picha wima lililobandikwa na lililokatwa katika kona ya chini-kulia ya chochote unachorekodi. Ikiwa imekaa juu ya kitu unachohitaji, ibadilishe ukubwa papo hapo:

| Kitufe cha mkato | Kazi |
| ------ | -------- |
| `Super + Alt + [` | Fanya dirisha linaloelea la kamera ya wavuti kuwa dogo zaidi |
| `Super + Alt + ]` | Fanya dirisha linaloelea la kamera ya wavuti kuwa kubwa zaidi |

Kuna ukubwa tatu — dogo, la kati, na kubwa — na vitufe vya mkato husogeza kati yake. La kati ni chaguo-msingi. Ni sawia na rekodi, kwa hivyo kamera huchukua sehemu hiyo hiyo ya fremu iwe unarekodi monita ya 1080p au ya 6K. Na ikiwa ulirekodi eneo badala ya onyesho zima, dirisha linaloelea hushikamana na kona ya eneo hilo badala ya ya monita, kwa hivyo hubaki ndani ya picha.

Unaweza pia kuiita moja kwa moja kwa `omarchy-capture-webcam-resize small`, au `reset` ili kurudi kwenye la kati.

## Maandishi, misimbo ya QR, na rangi

`Super + Ctrl + Print Screen` huchagua eneo na ku-OCR maandishi yake hadi kwenye ubao wa kunakili. Hilo limeelezwa vizuri katika [Utoaji wa Maandishi na Udiktishaji](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ hufanya ujanja huo huo kwa misimbo ya QR. Chagua eneo lenye msimbo ndani yake, na thamani iliyofasiriwa huenda kwenye ubao wa kunakili. Hutafuta misimbo ya QR tu — maudhui mazito ya skrini yana tabia ya kujitokeza kwa uongo kama msimbopau vinginevyo. Inafaa kujua: thamani iliyofasiriwa huenda kwenye ubao wa kunakili na hakuna mahali pengine. Haijachapishwa, haiko katika arifa, na imewekwa alama kuwa nyeti kwa hivyo haibaki katika [historia ya ubao wa kunakili](08-unified-clipboard-history.md). Misimbo ya QR mara nyingi hubeba siri — URI ya `otpauth://` iliyo nyuma ya msimbo wa usanidi wa 2FA, kwa mfano — na hutaki hiyo katika kumbukumbu. Kubandika bado hufanya kazi vizuri tu.

`Super + Print Screen` (au _Trigger > Capture > Color_) hubadilisha kishale kuwa kidondoshi cha rangi. Bofya chochote skrini na rangi huenda kwenye ubao wa kunakili. Bonyeza kitufe cha mkato tena ili kurudi nyuma bila kuchagua.

## Kubadilisha umbizo kabla ya kushiriki

Rekodi ya skrini ya 4K au HEIC mbichi kutoka simuni kwako mara nyingi ni kubwa mno kuweza kuituma tu. `Super + Ctrl + .` (au _Trigger > Transcode_) hutatua hilo. Inakupa kichagua faili chenye utafutaji hafifu juu ya `~/Pictures` na `~/Videos`, kisha huuliza umbizo na ukubwa.

Picha huenda kwenye jpg au png kwa juu, kati, au chini, ambazo huweka kikomo cha upana kwa pikseli 3160, 2160, na 1080. Video huenda kwenye mp4 au gif ya uhuishaji kwa 4k, 1080p, au 720p. Faili iliyobadilishwa huandikwa kando ya asilia ikiwa na azimio katika jina — `demo-1080p.mp4` — na njia hunakiliwa kwenye ubao wa kunakili kama URI ya faili, kwa hivyo unaweza kuibandika moja kwa moja katika programu inayokubali kudondosha faili.

Inafanya kazi kutoka kwenye terminali pia, ikiwa tayari unajua unachotaka: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Pia kuna `omarchy transcode ascii`, ambayo hubadilisha picha kuwa sanaa ya ASCII — hiyo ni zaidi kwa [chapa](41-branding.md).

## Kuituma mahali fulani

Ukishapata faili, `Super + Ctrl + S` hufungua menyu ya Kushiriki na huituma kwenye kifaa kingine kwenye mtandao wako kupitia LocalSend. Angalia [GUIs](22-guis.md) kwa hilo.
