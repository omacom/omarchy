# Chapa

Omarchy hukuruhusu kuweka nembo ya kampuni yako au picha yako binafsi kwa ajili ya kiokoa skrini na skrini ya kuhusu.

### Kiokoa skrini

Unaweza kubadilisha nembo inayotumika kwa kiokoa skrini chini ya _Muonekano > Chapa > Kiokoa skrini_. Ni nembo ya ASCII, kwa hivyo unaweza kuhariri maandishi moja kwa moja, lakini pia unaweza kuipa picha ya png au svg, nasi tutaibadilisha kuwa ASCII. Inaonekana nzuri sana.

 ![branding-screensaver](images/branding-screensaver.webp)

Kuna vipengee vitatu katika menyu hiyo:

- **Hariri Maandishi** hufungua `~/.config/omarchy/branding/screensaver.txt` katika kihariri chako. Andika au bandika chochote unachopenda — sanaa ya ASCII, jina lako, neno chafu. Hifadhi na uondoke, na kiokoa skrini huwaka mara moja ili uweze kukiona.
- **Weka Kutoka kwenye Picha** hufungua kiteua faili kwa ajili ya png au svg, huibadilisha kuwa ASCII, na kukuonyesha matokeo. Nembo zenye umbo lililo wazi hufanya kazi vizuri zaidi kuliko picha za kawaida.
- **Rejesha Chaguo-msingi** huirudisha nembo ya Omarchy.

### Skrini ya Kuhusu

Chaguo hizo hizo tatu ziko chini ya _Muonekano > Chapa > Kuhusu_ kwa ajili ya skrini ya _Kuhusu_ unayoipata kutoka kwenye menyu ya Omarchy, na hufanya kazi kwa njia ile ile — faili ni `~/.config/omarchy/branding/about.txt`, na dirisha la Kuhusu hujitokeza baada ya kila mabadiliko. Sanaa ya Kuhusu hubadilishwa kuwa ukubwa mdogo zaidi kuliko ya kiokoa skrini, kwa kuwa inapaswa kutoshea ndani ya dirisha badala ya kujaza onyesho lako.

Dirisha linapokuwa wazi, mkanda wa mwanga mweupe mkali huelekea kuvuka sanaa kila baada ya sekunde chache na kisha huiacha ikiwa imetulia tena. Sanaa yako mwenyewe pia huupata, ilimradi kila herufi ndani yake ina upana wa safu wima moja — chochote ambacho _Weka Kutoka kwenye Picha_ huzalisha ni hivyo. Sanaa iliyojengwa kwa emoji au herufi za upana wa safu wima mbili badala yake hubaki imetulia, na vivyo hivyo skrini ikiwa unatunza config yako mwenyewe ya fastfetch: nembo iliyotulia katika hali hizo ni uhuishaji ukijiepusha badala ya kushindwa, kwa kuwa kutelezesha mwangaza kuvuka hizo kungesababisha sehemu iliyobaki ya mstari kufika mahali pasipofaa.

 ![branding-about](images/branding-about.webp)

### Kubadilisha picha mwenyewe

Chaguo zote mbili za _Weka Kutoka kwenye Picha_ huita tu `omarchy transcode ascii`, ambayo unaweza kuiendesha moja kwa moja ikiwa unataka udhibiti wa ubadilishaji:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Huchukua `--width` na `--height` katika safu wima na safu mlalo za terminal, `--mode` ya aidha `braille` (chaguo-msingi, na yenye undani zaidi) au `block`, asilimia ya `--threshold` kwa ajili ya kuamua ni pikseli zipi huhesabiwa kama sehemu ya nembo, na `--invert` kwa wakati nembo yako ni nyepesi kwenye mandharinyuma meusi. Ikiwa ubadilishaji unatokea kama donge, threshold kwa kawaida ndicho kitufe cha kugeuza.

### Maneno badala ya nembo

`omarchy ascii` huchora maandishi katika Delta Corps Priest 1, fonti ya FIGlet ambayo neno la chapa la Omarchy lenyewe limechorwa kwayo, kwa hivyo kiokoa skrini kinaweza kusema kitu badala ya kuonyesha picha:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Huchukua maandishi kama hoja, au huisoma kutoka kwenye pipe ikiwa hakuna iliyotolewa. Fonti hubeba herufi na nafasi pekee — ilichorwa bila tarakimu au alama za uakifishaji — kwa hivyo chochote kingine huachwa na kutajwa kwenye stderr badala ya kumezwa kimya kimya.
