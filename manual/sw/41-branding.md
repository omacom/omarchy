# Chapa (Branding)

Omarchy hukuruhusu kuweka nembo ya kampuni yako au picha yako binafsi kwa kufungua kuwasha, kiokozi cha skrini, na skrini ya kuhusu.

### Kufungua kuwasha

Unaweza kutumia `omarchy plymouth preview` kuona jinsi nembo na rangi zako maalum zitakavyoonekana. Huchukua rangi ya mandhari ya nyuma, rangi ya maandishi, png ya nembo, na njia ya picha ya hakiki:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Kisha tumia usanidi kwa `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, ambayo pia itapa skrini ya kuingia ya SDDM rangi na nembo zile zile. Kama unataka kubatilisha, unaweza kutumia `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Kiokozi cha skrini

Unaweza kubadilisha nembo inayotumika kwa kiokozi cha skrini chini ya _Mtindo > Kiokozi cha skrini_. Ni nembo ya ASCII, kwa hivyo unaweza kuhariri maandishi moja kwa moja, lakini pia unaweza kuipa picha ya png au svg, na tutaigeuza kuwa ASCII. Inaonekana nzuri kabisa.

 ![branding-screensaver](images/branding-screensaver.webp)

Kuna maingizo matatu katika menyu hiyo:

- **Hariri maandishi** hufungua `~/.config/omarchy/branding/screensaver.txt` katika kihariri chako. Chapa au bandika unachopenda — sanaa ya ASCII, jina lako, neno baya. Hifadhi na kutoka, na kiokozi cha skrini huwaka mara moja ili uweze kukiona.
- **Weka kutoka picha** hufungua kichaguzi cha faili kwa png au svg, huigeuza kuwa ASCII, na kukuonyesha matokeo. Nembo zenye umbo wazi hufanya kazi vizuri zaidi kuliko picha.
- **Rejesha chaguomsingi** hurejesha nembo ya Omarchy.

### Skrini ya kuhusu

Chaguo hizo hizo tatu ziko chini ya _Mtindo > Kuhusu_ kwa skrini ya _Kuhusu_ unayoipata kutoka menyu ya Omarchy, na zinafanya kazi sawasawa — faili ni `~/.config/omarchy/branding/about.txt`, na dirisha la Kuhusu hujitokeza baada ya kila mabadiliko. Sanaa ya Kuhusu hugeuzwa kuwa ukubwa mdogo kuliko ile ya kiokozi cha skrini, kwani lazima iingie katika dirisha badala ya kujaza skrini yako.

Wakati dirisha limefunguliwa mwangaza wa kijani huegemea kwenye sanaa kila baada ya sekunde chache na kisha huiacha tuli tena. Sanaa yako mwenyewe pia huipata, mradi kila herufi ndani yake ni safu moja pana — chochote kinachotolewa na _Weka kutoka picha_ ni hivyo. Sanaa iliyojengwa kutoka emoji au herufi za upana-mbili hukaa tuli badala yake, na vivyo hivyo skrini kama unatunza usanidi wako wa fastfetch: nembo tuli katika hali hizo ni uhuishaji ukikaa mbali badala ya kushindwa, kwani kuteleza mwangaza juu yake kungeweka sehemu nyingine ya mstari mahali pasipo.

 ![branding-about](images/branding-about.webp)

### Kubadilisha picha mwenyewe

Chaguo zote mbili za _Weka kutoka picha_ zinaita tu `omarchy transcode ascii`, ambayo unaweza kuiendesha moja kwa moja kama unataka kudhibiti ubadilishaji:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Huchukua `--width` na `--height` katika safu na safu-wima za terminali, `--mode` ya `braille` (chaguomsingi, na laini zaidi) au `block`, asilimia ya `--threshold` ya kuamua ni pikseli zipi huhesabika kama sehemu ya nembo, na `--invert` wakati nembo yako ni nyepesi kwenye mandhari ya giza. Kama ubadilishaji unatoka kama dongo, kizingiti (threshold) kawaida ndicho kigezo cha kugeuza.

### Maneno badala ya nembo

`omarchy ascii` huchora maandishi katika Delta Corps Priest 1, fonti ya FIGlet ambayo neno la Omarchy lenyewe limechorwa humo, kwa hivyo kiokozi cha skrini kinaweza kusema kitu badala ya kuonyesha picha:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Huchukua maandishi kama hoja, au huyasoma kutoka bomba inapopewa bila chochote. Fonti hubeba herufi na nafasi tu — ilichorwa bila tarakimu au alama za uakifishaji — kwa hivyo chochote kingine huachwa na kutajwa kwenye stderr badala ya kumezwa kimya.
