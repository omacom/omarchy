# Vivinjari

Omarchy huja na [Google Chrome](https://www.google.com/chrome/) kama kivinjari chaguo-msingi. Kimepewa mandhari yanayolingana na mfumo wako wote, na ndicho kinachofunguliwa na `Super + Shift + Return` (au `Super + Shift + B`), huku `Super + Shift + Alt + B` ikifungua dirisha la faragha, na ndani yake ndimo kila [programu ya wavuti](25-web-apps.md) huendeshwa. Hufunguka moja kwa moja kwenye dirisha la kivinjari: hakuna skrini ya kukaribisha wala kidokezo cha kuingia, takwimu za matumizi na ripoti za kuanguka hazitumwi kwa Google, na vidokezo vya faragha ya matangazo vimezimwa. Bado unaweza kuingia kwenye akaunti yako ya Google kutoka kwenye kitufe cha wasifu wakati wowote unapotaka usawazishaji.

Kama Chrome si chaguo lako, huja kwama nacho. Chini ya _Install > Browser_ kwenye menyu ya Omarchy utapata [Chromium](https://www.chromium.org/) (toleo tupu la chanzo huria ambalo Chrome imetengenezwa kutoka kwalo), Edge, Brave, Brave Origin, Firefox, na [Zen](https://zen-browser.app/) (Edge kwenye mashine za x86 pekee). Chagua kimoja na Omarchy hukisakinisha, huandaa saraka yake ya sera, na kukipaka mandhari yako ya sasa.

## Kufanya kimoja kiwe chaguo-msingi

Kusakinisha kivinjari hakikipandishi cheo. Ili kubadilisha, nenda kwenye _Setup > Defaults > Browser_ na uchague kimoja. Chaguo-msingi la sasa limewekewa alama ya tiki, na kuchagua kivinjari ambacho bado huna hukisakinisha kwanza.

Kutoka kwenye terminal ni:

```bash
omarchy default browser firefox
```

Kiendeshe bila hoja yoyote na kitakuambia chaguo-msingi la sasa. Hii huweka kidhibiti cha XDG, kwa hiyo si hotkey za Omarchy pekee zinazofuata — kitu chochote kinachofungua kiungo, kutoka programu ya gumzo hadi amri ya terminal, huenda kwenye kivinjari ulichochagua.

## Copy URL na Download Video

Vivinjari vya familia ya Chromium (Chromium chenyewe, Chrome, Edge, Brave, na Brave Origin) huja na viendelezi vitatu vya Omarchy: viwili vinavyotoka nje ya kivinjari na kuingia kwenye mfumo wako wote, na kimoja kinachopanga WhatsApp.

**Copy URL** huweka anwani ya kichupo cha sasa kwenye ubao wako wa kunakili kwa `Alt + Shift + L`. Hiyo ni haraka kuliko kubofya kwenye upau wa anwani na kunakili, na kwa sababu hupitia ubao wa kunakili wa mfumo badala ya wa kivinjari, unapata arifa ya Omarchy inayothibitisha na URL inapatikana mara moja kwenye [historia ya ubao wa kunakili](08-unified-clipboard-history.md) na kila programu nyingine. Kuna kitufe cha upau wa zana pia, kama unapendelea kubofya.

**Download Video** huchukua video inayocheza kwenye ukurasa unaouangalia kwa `Alt + Shift + D`. Hukabidhi URL kwa [yt-dlp](https://github.com/yt-dlp/yt-dlp), kwa hiyo hufanya kazi kwenye mengi zaidi ya YouTube, na upakuaji hutua kwenye `~/Videos`. Maendeleo huonekana kwenye onyesho lile lile la skrini ambalo sauti na mwangaza hutumia, likijisasisha papo hapo badala ya kurundika arifa. Weka `OMARCHY_YTDLP_DIR` kama ungependa faili ziende mahali pengine — angalia [FAQ](46-faq.md) kwa mahali pa kuweka vigezo vya mazingira.

Viendelezi vyote viwili huzungumza na Omarchy kupitia kipangishi kidogo cha ujumbe asilia, ambacho husakinishwa kwa ajili yako pamoja na kivinjari. Hicho ndicho kipande kinachoruhusu video ya ukurasa wa wavuti kuishia kwenye saraka yako ya nyumbani na URL kuishia kwenye kidhibiti chako cha ubao wa kunakili, jambo ambalo kiendelezi cha kawaida hakiwezi kufanya peke yake.

**WhatsApp Slim** hufanya WhatsApp Web ifuate mandhari ya mfumo wako na hukunja orodha yake ya gumzo wakati dirisha ni jembamba.

Hivi ni vya familia ya Chromium pekee. Firefox na Zen havipati.

## Firefox na Zen

Firefox na Zen ni familia tofauti, kwa hiyo hupata utunzaji tofauti: Omarchy husakinisha faili ya sera kwa chaguo-msingi zinazofaa na huzibadilisha ziwe kwenye hali asilia ya Wayland, ambayo unaitaka kwa upanuzi wa sehemu na usogeaji laini wa trackpad.

Hazipati viendelezi vya Chromium vilivyo hapo juu, na hazipewi mandhari na Omarchy, kwa hiyo sehemu hizo za matumizi ni zako kuziandaa.

## Kukiondoa tena

Kivinjari chochote kati ya hivi, Chrome ikiwemo, kinaweza kuondolewa tena chini ya _Remove > Browser_. Viungo basi huenda Chrome au Chromium kama kingine bado kimesakinishwa.
