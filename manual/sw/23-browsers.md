# Vivinjari

Omarchy huja na [Chromium](https://www.chromium.org/) kama kivinjari chaguomsingi. Ni ujenzi wazi wa chanzo huria, wenye mandhari kulingana na mfumo wako wote, na ndicho kinachofunguliwa na `Super + Shift + Return` na ndicho kila [programu ya wavuti](25-web-apps.md) huendeshwa ndani yake.

Kama Chromium si ladha yako, hujakwama nacho. Chini ya _Sakinisha > Kivinjari_ katika menyu ya Omarchy utakuta Chrome, Edge, Brave, Brave Origin, Firefox, na [Zen](https://zen-browser.app/). Chagua kimoja na Omarchy inakisakinisha, inasanidi saraka yake ya sera, na kuweka mandhari yako ya sasa kwake.

## Kukifanya kimoja kuwa chaguomsingi

Kusakinisha kivinjari hakikipandishi cheo. Mara kikiwa kwenye mashine, nenda kwenye _Sanidi > Chaguomsingi > Kivinjari_ na ukichague — menyu huorodhesha tu vivinjari ambavyo kwa kweli umevisakinisha, na huweka alama ya tiki kwenye chaguomsingi cha sasa.

Kutoka terminali ni:

```bash
omarchy default browser firefox
```

Endesha bila hoja na inakuambia chaguomsingi cha sasa. Hii inaweka kidhibiti cha XDG, hivyo si mikato ya Omarchy tu inayofuata — chochote kinachofungua kiungo, kutoka programu ya gumzo hadi amri ya terminali, huenda kwenye kivinjari ulichochagua.

## Nakili URL na Pakua Video

Vivinjari vya familia ya Chromium (Chromium yenyewe, Chrome, Edge, na Brave) huja na viendelezi viwili vya Omarchy vinavyotoka nje ya kivinjari na kuingia katika mfumo wako wote.

**Copy URL** huweka anwani ya kichupo cha sasa kwenye ubao wako wa kunakili kwa `Alt + Shift + L`. Hiyo ni haraka kuliko kubofya kwenye upau wa anwani na kunakili, na kwa sababu hupitia ubao wa kunakili wa mfumo badala ya kivinjari, unapata arifa ya Omarchy inayothibitisha na URL inapatikana mara moja katika [historia ya ubao wa kunakili](08-unified-clipboard-history.md) na kila programu nyingine. Pia kuna kitufe cha upau wa zana, kama unapendelea kubofya.

**Download Video** hunyakua video inayochezwa kwenye ukurasa unaoutazama kwa `Alt + Shift + D`. Hupeana URL kwa [yt-dlp](https://github.com/yt-dlp/yt-dlp), hivyo hufanya kazi kwenye zaidi ya YouTube tu, na upakuaji hutua katika `~/Videos`. Maendeleo huonekana katika onyesho lile lile la skrini ambalo sauti na mwangaza hutumia, likisasishwa mahali pake badala ya kurundika arifa. Weka `OMARCHY_YTDLP_DIR` kama ungependa faili ziende mahali pengine — tazama [Maswali Yanayoulizwa Mara kwa Mara](46-faq.md) kwa mahali pa kuweka vigeugeu vya mazingira.

Viendelezi vyote viwili huzungumza na Omarchy kupitia mwenyeji mdogo wa ujumbe asili, ambao husakinishwa kwa ajili yako pamoja na kivinjari. Hicho ndicho kipande kinachoruhusu video ya ukurasa wa wavuti kuishia katika saraka yako ya nyumbani na URL kuishia katika meneja wako wa ubao wa kunakili, jambo ambalo kiendelezi cha kawaida hakiwezi kufanya chenyewe.

Hivi ni vya familia ya Chromium tu. Firefox na Zen hazizipati.

## Firefox na Zen

Firefox na Zen ni familia tofauti, hivyo hupata matibabu tofauti: Omarchy husakinisha faili ya sera kwa chaguomsingi zenye maana na kuzibadilisha kuwa hali asili ya Wayland, ambayo unataka kwa upanuzi wa sehemu na usogeaji laini wa kiguso.

Hawapati viendelezi vya Chromium hapo juu, na hawapewi mandhari na Omarchy, hivyo sehemu hizo za uzoefu ni zako kusanidi.

## Kuondoa kimoja tena

Kitu chochote ulichosakinisha hapa kinaweza kuondolewa tena chini ya _Ondoa > Kivinjari_. Chromium haipo katika orodha hiyo — ni sehemu ya mfumo wa msingi.
