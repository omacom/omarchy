# Picha za Skrini na Kurekodi

Kila kitu unachoweza kuchukua kutoka kwenye skrini kinategemea kitufe cha Print Screen. Kitufe kimoja peke yake hupiga picha, na virekebishaji huchukua rekodi, rangi, au maandishi yaliyo ndani ya eneo. Kama kibodi yako haina kitufe cha Print Screen kabisa, `Super + Ctrl + Alt + C` hupiga picha ya skrini ile ile, na `Super + Ctrl + C` hufungua seti nzima kama menyu.

| Kitufe cha Mkato | Kazi |
| ------ | -------- |
| `Print Screen` | Picha ya skrini |
| `Super + Ctrl + Alt + C` | Picha ya skrini |
| `Alt + Print Screen` | Kurekodi skrini (au kusimamisha inayofanya kazi) |
| `Super + Print Screen` | Kichagua rangi |
| `Super + Ctrl + Print Screen` | Toa maandishi kutoka kwenye eneo |
| `Super + Ctrl + C` | Menyu ya kunasa |
| `Super + Ctrl + .` | Badilisha umbizo la picha au video |

## Picha za skrini

Gonga `Print Screen` (au `Super + Ctrl + Alt + C`) na Omasnap hunasa kifuatilizi kilicholengwa kabla ya kiwekeleo chake kuonekana, kwa hiyo hakuna kinachohama chini yako wakati unalenga. Buruta eneo la umbo huru, bofya dirisha ili kulinasa, au bofya nafasi wazi ili kunasa kifuatilizi kizima. Bonyeza `S` kabla ya kuchora ili kunasa eneo linalosogeza. Umebadili mawazo? Gonga kitufe kile kile tena ili kuondoa Omasnap.

Baada ya kuchagua eneo, Omasnap huhifadhi nasaji, huinakili kwenye ubao wa kunakili, na huonyesha arifa yenye kijipicha chake, kama rekodi ya skrini iliyohifadhiwa inavyofanya. Chagua Open ili kuona picha iliyohifadhiwa katika kitazamaji chako cha picha, au Edit ili kuifafanua.

Kihariri cha ufafanuzi kinaweza kuchora mishale, mistari, maumbo, vivutio, alama zenye namba, maandishi, na ufichaji salama; kupunguza au kukata sehemu ya picha; kusoma maandishi yake kwa OCR; na kuongeza mandharinyuma. Katika kihariri, bonyeza `Enter` ili kunakili na kuhifadhi PNG iliyokamilika, `Ctrl + C` ili kuikopi bila kuhifadhi, au `Ctrl + S` ili kuihifadhi bila kunakili.

Picha za skrini zilizohifadhiwa huenda kwenye `~/Pictures/Screenshots` kwa chaguo-msingi, zikiwa na jina kama `screenshot-2026-08-13_14-22-05-firefox.png`. Weka `OMASNAP_SCREENSHOT_DIR` ili kutumia saraka nyingine — angalia [maswali yanayoulizwa mara kwa mara](46-faq.md) kwa mahali pa kuweka vigezo vya mazingira ya kipindi. Omasnap huunda saraka inapohifadhi picha ya kwanza. Weka `[output] autosave = false` katika `~/.config/omasnap/omasnap.conf` ili kuzima uhifadhi wa kiotomatiki; nasaji basi hunakiliwa tu, na huonyeshwa katika onyesho la awali kwa sekunde 7 ambalo unaweza kuliweka kwenye skrini kwa kitufe chake cha kubandika au `Ctrl + P`.

Kutoka kwenye terminali, `omarchy screenshot` hufungua kiwekeleo kile kile, na unaweza kuchagua hali yake ya kuanzia: `omarchy capture screenshot region`, `windows`, `fullscreen`, au `scroll`. Hoja ya pili ya `copy` au `save` hutuma picha moja kwa moja kwenye lengo hilo. Ili kuhariri kabla ya kutoa, tumia `omarchy screenshot --editor=overlay` kwa kihariri cha skrini nzima au `omarchy screenshot --editor=window` kwa dirisha tofauti.

### Kuendesha kichaguzi kwa kibodi

Wakati uteuzi unaonekana, si lazima utumie kipanya kabisa:

| Kitufe | Kazi |
| --- | -------- |
| `S` | Washa/zima hali ya eneo linalosogeza |
| `Super + Arrow keys` | Sogeza kati ya madirisha katika hali ya Dirisha |
| `Return` | Nasa dirisha lililovutiwa |
| `Ctrl + A` | Nasa kifuatilizi kizima kilicholengwa |
| `R` | Rejesha eneo la mwisho lililochorwa katika kipindi hiki |
| `Esc` | Ondoa Omasnap |

Vifungo hivi vipo tu wakati Omasnap iko wazi, kwa hiyo haviwezi kugongana na chochote katika usanidi wako mwenyewe.

## Kurekodi skrini

`Alt + Print Screen` hufungua _Trigger > Capture > Screenrecord_, ambayo huuliza unachotaka kwenye sauti: hakuna sauti, sauti ya eneo-kazi, sauti ya eneo-kazi pamoja na maikrofoni, au sauti ya eneo-kazi pamoja na maikrofoni pamoja na kamera ya wavuti. Hiyo ya mwisho huonekana tu kama kweli una kamera iliyounganishwa. Chagua moja na kichaguzi cha kurekodi cha Omarchy hukuwezesha kuburuta eneo au kubofya dirisha au kifuatilizi.

Kurekodi huendeshwa kwa gpu-screen-recorder, ambayo husimba kwenye GPU kwa 60fps na hurudi kwenye CPU ikibidi; kwenye GPU ambazo haiwezi kuzitumia, kama za Apple Silicon, Omarchy hurekodi kwa wf-recorder badala yake. Matokeo yake ni MP4 katika `~/Videos`, yenye jina `screenrecording-2026-08-13_14-22-05.mp4`. Weka `OMARCHY_SCREENRECORD_DIR` ili kubadilisha hilo — lakini kumbuka kwamba tofauti na saraka ya picha za skrini, hii lazima iwepo tayari, au kurekodi kutakataa kuanza.

Wakati unarekodi, kiashirio kidogo huonekana kwenye upau. Kibofye ili kusimamisha. Unaweza pia kusimamisha kwa `Alt + Print Screen` tena, au kwa ingizo la _Stop Screenrecording_ chini ya _Trigger > Capture > Screenrecord_, ambalo huonekana tu wakati kitu kweli kinarekodi.

Kusimamisha hufanya usafi kidogo kabla ya kukukabidhi faili: fremu ya kwanza hukatwa, na kama kuna sauti hunormalishwa hadi -14 LUFS huku mlio wa kunasa wa PipeWire mwanzoni kabisa ukinyamazishwa. Kisha arifa huonekana yenye kijipicha kutoka kwenye rekodi. Chagua _Open_ ili kucheza faili katika Omaview, au _Cut_ ili kuikata katika Omacut.

### Kiwekeleo cha kamera ya wavuti

Unapore kodi na kamera ya wavuti, kamera huonekana kama dirisha la picha ya wima lililobandikwa na kupunguzwa katika kona ya chini kulia ya chochote unachorekodi. Kama iko juu ya kitu unachohitaji, ibadilishe ukubwa papo hapo:

| Kitufe cha Mkato | Kazi |
| ------ | -------- |
| `Super + Alt + [` | Fanya kiwekeleo cha kamera ya wavuti kiwe kidogo |
| `Super + Alt + ]` | Fanya kiwekeleo cha kamera ya wavuti kiwe kikubwa |

Kuna ukubwa tatu — ndogo, ya kati, na kubwa — na vitufe vya mkato husogeza kati yake. Ya kati ndiyo chaguo-msingi. Zinalingana na rekodi, kwa hiyo kamera huchukua sehemu ile ile ya fremu iwe unarekodi kifuatilizi cha 1080p au cha 6K. Na kama ulirekodi eneo badala ya onyesho zima, kiwekeleo hujikita kwenye kona ya eneo hilo badala ya ya kifuatilizi, kwa hiyo hubaki ndani ya picha.

Unaweza pia kuiita moja kwa moja kwa `omarchy-capture-webcam-resize small`, au `reset` ili kurudi kwenye ya kati.

## Maandishi, misimbo ya QR, na rangi

`Super + Ctrl + Print Screen` huchagua eneo na kulisoma kwa OCR hadi kwenye ubao wa kunakili. Hilo limeelezwa vizuri katika [Utoaji wa Maandishi na Kuandikisha kwa Sauti](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ hufanya mbinu ile ile kwa misimbo ya QR. Chagua eneo lenye msimbo ndani yake, na thamani iliyotambuliwa huenda kwenye ubao wa kunakili. Hutafuta misimbo ya QR tu — maudhui mazito ya skrini yana tabia ya kujifanya msimbo pau vinginevyo. Inafaa kujua: thamani iliyotambuliwa huenda kwenye ubao wa kunakili na hakuna mahali pengine. Haijachapishwa, haiko katika arifa, na imewekwa alama kuwa nyeti kwa hiyo haibaki katika [historia ya ubao wa kunakili](08-unified-clipboard-history.md). Misimbo ya QR mara kwa mara hubeba siri — URI ya `otpauth://` nyuma ya msimbo wa usanidi wa 2FA, kwa mfano — na hutaki hiyo katika kumbukumbu. Kubandika bado hufanya kazi vizuri.

`Super + Print Screen` (au _Trigger > Capture > Color_) hugeuza kishale kuwa kidondoshi cha macho. Bofya chochote kwenye skrini na rangi huenda kwenye ubao wa kunakili. Bonyeza kitufe cha mkato tena ili kurudi nyuma bila kuchagua.

## Kubadilisha umbizo kabla ya kushiriki

Rekodi ya skrini ya 4K au HEIC mbichi kutoka kwenye simu yako mara nyingi ni kubwa mno kuweza kuituma tu. `Super + Ctrl + .` (au _Trigger > Transcode_) hurekebisha hilo. Inakupa kichaguzi cha faili kisicho na mpangilio mkali juu ya `~/Pictures` na `~/Videos`, kisha huuliza umbizo na ukubwa.

Picha huenda kwenye jpg au png kwa juu, kati, au chini, ambazo huweka kikomo cha upana kwa pikseli 3160, 2160, na 1080. Video huenda kwenye mp4 au gif inayotembea kwa 4k, 1080p, au 720p. Faili iliyobadilishwa huandikwa karibu na asili ikiwa na azimio katika jina — `demo-1080p.mp4` — na njia hunakiliwa kwenye ubao wa kunakili kama URI ya faili, kwa hiyo unaweza kuibandika moja kwa moja katika programu inayokubali udondoshaji wa faili.

Inafanya kazi kutoka kwenye terminali pia, kama tayari unajua unachotaka: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Pia kuna `omarchy transcode ascii`, ambayo hugeuza picha kuwa sanaa ya ASCII — hiyo ni zaidi kwa [utambulisho wa chapa](41-branding.md).

## Kuituma mahali fulani

Ukishaipata faili, `Super + Ctrl + S` hufungua menyu ya Shiriki na kuituma kwenye kifaa kingine kwenye mtandao wako kupitia LocalSend. Angalia [GUIs](22-guis.md) kwa hilo.
