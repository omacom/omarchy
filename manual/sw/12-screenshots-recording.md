# Picha za Skrini na Kurekodi

Kila kitu unachoweza kuchukua kutoka kwenye skrini kinategemea kitufe cha Print Screen. Kitufe kimoja peke yake hupiga picha, na vibadilishi huchukua rekodi, rangi, au maandishi yaliyo ndani ya eneo. Ikiwa kibodi yako haina kitufe cha Print Screen kabisa, `Super + Ctrl + Alt + C` hupiga picha ya skrini hiyo hiyo, na `Super + Ctrl + C` hufungua seti nzima kama menyu.

| Kitufe cha haraka | Kazi |
| ------ | -------- |
| `Print Screen` | Picha ya skrini |
| `Super + Ctrl + Alt + C` | Picha ya skrini |
| `Alt + Print Screen` | Rekodi ya skrini (au simamisha ile inayoendelea) |
| `Super + Print Screen` | Kichagua rangi |
| `Super + Ctrl + Print Screen` | Toa maandishi kutoka kwenye eneo |
| `Super + Ctrl + C` | Menyu ya kunasa |
| `Super + Ctrl + .` | Badilisha umbizo la picha au video |

## Picha za skrini

Bonyeza `Print Screen` (au `Super + Ctrl + Alt + C`) na Omasnap hunasa kifuatilizi kilicholengwa kabla ya ufunikaji wake kuonekana, hivyo hakuna kinachohama chini yako unapolenga. Buruta eneo huru, bofya dirisha ili kulinasa, au bofya nafasi wazi ili kunasa kifuatilizi kizima. Bonyeza `S` kabla ya kuchora ili kunasa eneo linalosogeza. Umebadili mawazo? Bonyeza kitufe hicho hicho tena ili kuondoa Omasnap.

Baada ya kuchagua eneo, Omasnap huhifadhi nasaji, huinakili kwenye ubao wa kunakili, na huonyesha hakiki kwa sekunde 10. Tumia kitufe cha kubandika cha hakiki au `Ctrl + P` kuiweka kwenye skrini, au chagua Edit ili kuiweka maelezo.

Kihariri cha maelezo kinaweza kuchora mishale, mistari, maumbo, vivutio, alama zenye nambari, maandishi, na ufichaji salama; kukata au kuondoa sehemu ya picha; kusoma maandishi yake kwa OCR; na kuongeza mandharinyuma. Katika kihariri, bonyeza `Enter` kunakili na kuhifadhi PNG iliyokamilika, `Ctrl + C` kuinakili bila kuhifadhi, au `Ctrl + S` kuihifadhi bila kunakili.

Picha za skrini zilizohifadhiwa huenda kwenye `~/Pictures/Screenshots` kwa chaguo-msingi, zikiwa na jina kama `screenshot-2026-08-13_14-22-05-firefox.png`. Weka `OMASNAP_SCREENSHOT_DIR` kutumia saraka nyingine — angalia [maswali yanayoulizwa mara kwa mara](46-faq.md) ili kujua mahali pa kuweka vigezo vya mazingira ya kikao. Omasnap huunda saraka inapohifadhi picha ya kwanza. Weka `[output] autosave = false` katika `~/.config/omasnap/omasnap.conf` ili kuzima uhifadhi wa kiotomatiki.

Kutoka kwenye terminali, `omarchy screenshot` hufungua ufunikaji huo huo, na unaweza kuchagua hali yake ya kuanzia: `omarchy capture screenshot region`, `windows`, `fullscreen`, au `scroll`. Hoja ya pili ya `copy` au `save` huruka hakiki na kutuma picha moja kwa moja kwenye lengwa hilo. Ili kuhariri kabla ya kutoa, tumia `omarchy screenshot --editor=overlay` kwa kihariri cha skrini nzima au `omarchy screenshot --editor=window` kwa dirisha tofauti.

### Kuendesha kichaguzi kwa kibodi

Wakati uteuzi umeonekana, si lazima utumie kipanya kabisa:

| Kitufe | Kazi |
| --- | -------- |
| `S` | Washa/zima hali ya eneo linalosogeza |
| `Super + Arrow keys` | Sogea kati ya madirisha katika hali ya Dirisha |
| `Return` | Nasa dirisha lililovutiwa |
| `Ctrl + A` | Nasa kifuatilizi kizima kilicholengwa |
| `R` | Rejesha eneo la mwisho lililochorwa katika kikao hiki |
| `Esc` | Ondoa Omasnap |

Miunganisho hii ipo tu wakati Omasnap iko wazi, hivyo haiwezi kugongana na chochote katika usanidi wako mwenyewe.

## Kurekodi skrini

`Alt + Print Screen` hufungua _Trigger > Capture > Screenrecord_, ambayo huuliza unachotaka kwenye wimbo wa sauti: hakuna sauti, sauti ya eneo-kazi, sauti ya eneo-kazi pamoja na maikrofoni, au sauti ya eneo-kazi pamoja na maikrofoni pamoja na webcam. Hiyo ya mwisho huonekana tu ikiwa kweli una kamera iliyochomekwa. Chagua moja na kichagua rekodi cha Omarchy hukuruhusu kuburuta eneo au kubofya dirisha au kifuatilizi.

Kurekodi huendeshwa na gpu-screen-recorder, ambayo husimba kwenye GPU kwa 60fps na hurudi kwenye CPU ikiwa inabidi. Matokeo yake ni MP4 katika `~/Videos`, yenye jina `screenrecording-2026-08-13_14-22-05.mp4`. Weka `OMARCHY_SCREENRECORD_DIR` kubadilisha hilo — lakini kumbuka kuwa tofauti na saraka ya picha za skrini, hii lazima iwepo tayari, au rekodi itakataa kuanza.

Unaporekodia, kiashirio kidogo huonekana kwenye upau. Kibofye ili kusimamisha. Unaweza pia kusimamisha kwa `Alt + Print Screen` tena, au kwa kiingilio cha _Stop Screenrecording_ chini ya _Trigger > Capture > Screenrecord_, ambacho huonekana tu wakati kitu kweli kinarekodiwa.

Kusimamisha hufanya usafishaji kidogo kabla ya kukukabidhi faili: fremu ya kwanza hukatwa, na ikiwa kuna sauti hunormalishwa hadi -14 LUFS huku mlio wa kunasa wa PipeWire mwanzoni kabisa ukinyamazishwa. Kisha arifa huonekana ikiwa na kijipicha kutoka kwenye rekodi. Ibofye ili kucheza faili katika mpv.

### Ufunikaji wa webcam

Unaporekodia ukiwa na webcam, kamera huonekana kama dirisha la picha ya wima lililobandikwa na kukatwa katika kona ya chini kulia ya chochote unachorekodi. Ikiwa imekaa juu ya kitu unachohitaji, ibadilishe ukubwa papo hapo:

| Kitufe cha haraka | Kazi |
| ------ | -------- |
| `Super + Alt + [` | Fanya ufunikaji wa webcam uwe mdogo zaidi |
| `Super + Alt + ]` | Fanya ufunikaji wa webcam uwe mkubwa zaidi |

Kuna ukubwa tatu — ndogo, ya kati, na kubwa — na vitufe vya haraka husogea kati yake. Ya kati ndiyo chaguo-msingi. Zinalingana sawia na rekodi, hivyo kamera huchukua sehemu ile ile ya fremu iwe unarekodi kifuatilizi cha 1080p au cha 6K. Na ikiwa ulirekodi eneo badala ya onyesho zima, ufunikaji hujikita kwenye kona ya eneo hilo badala ya ya kifuatilizi, hivyo hubaki ndani ya picha.

Unaweza pia kuiita moja kwa moja kwa `omarchy-capture-webcam-resize small`, au `reset` kurudi kwenye ya kati.

## Maandishi, misimbo ya QR, na rangi

`Super + Ctrl + Print Screen` huchagua eneo na kusoma maandishi yake kwa OCR hadi kwenye ubao wa kunakili. Hilo limeelezwa vizuri katika [Utoaji wa Maandishi na Uimlishaji](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ hufanya hila hiyo hiyo kwa misimbo ya QR. Chagua eneo lenye msimbo ndani yake, na thamani iliyosimbuliwa huenda kwenye ubao wa kunakili. Hutafuta misimbo ya QR tu — maudhui mazito ya skrini yana tabia ya kujitokeza kwa uongo kama barcode vinginevyo. Inafaa kujua: thamani iliyosimbuliwa huenda kwenye ubao wa kunakili na hakuna mahali pengine. Haijachapishwa, haiko katika arifa, na imewekwa alama kuwa nyeti hivyo haibaki katika [historia ya ubao wa kunakili](08-unified-clipboard-history.md). Misimbo ya QR mara nyingi hubeba siri — URI ya `otpauth://` iliyo nyuma ya msimbo wa usanidi wa 2FA, kwa mfano — na hutaki hiyo katika kumbukumbu. Kubandika bado hufanya kazi vizuri.

`Super + Print Screen` (au _Trigger > Capture > Color_) hubadilisha kielekezi kuwa kidondoshi cha macho. Bofya chochote kwenye skrini na rangi huenda kwenye ubao wa kunakili. Bonyeza kitufe cha haraka tena ili kurudi nyuma bila kuchagua.

## Kubadilisha umbizo kabla ya kushiriki

Rekodi ya skrini ya 4K au HEIC mbichi kutoka kwenye simu yako mara nyingi ni kubwa mno kutuma tu. `Super + Ctrl + .` (au _Trigger > Transcode_) hutengeneza hilo. Hukupa kichagua faili kisicho sahihi kabisa juu ya `~/Pictures` na `~/Videos`, kisha huuliza umbizo na ukubwa.

Picha huenda kwenye jpg au png kwa juu, kati, au chini, ambazo huweka kikomo cha upana kwa pikseli 3160, 2160, na 1080. Video huenda kwenye mp4 au gif inayosogea kwa 4k, 1080p, au 720p. Faili iliyobadilishwa huandikwa kando ya asili ikiwa na azimio katika jina — `demo-1080p.mp4` — na njia hunakiliwa kwenye ubao wa kunakili kama URI ya faili, hivyo unaweza kuibandika moja kwa moja kwenye programu inayochukua matone ya faili.

Inafanya kazi kutoka kwenye terminali pia, ikiwa tayari unajua unachotaka: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Pia kuna `omarchy transcode ascii`, ambayo hubadilisha picha kuwa sanaa ya ASCII — hiyo ni zaidi kwa ajili ya [utambulisho wa chapa](41-branding.md).

## Kuituma mahali fulani

Ukishapata faili, `Super + Ctrl + S` hufungua menyu ya Shiriki na kuituma kwenye kifaa kingine kwenye mtandao wako kupitia LocalSend. Angalia [GUIs](22-guis.md) kwa hilo.
