# Vivinjari

Omarchy huja na [Google Chrome](https://www.google.com/chrome/) kama kivinjari chaguo-msingi. Kimepewa mandhari yanayolingana na mfumo wako wote, na ndicho kinachofunguliwa na `Super + Shift + Return` (au `Super + Shift + B`), na `Super + Shift + Alt + B` kwa dirisha la faragha, na ndicho ambacho kila [programu ya wavuti](25-web-apps.md) hufanya kazi ndani yake. Hufunguka moja kwa moja kwenye dirisha la kivinjari: hakuna skrini ya kukaribisha au kidokezo cha kuingia, takwimu za matumizi na ripoti za kuanguka hazitumwi kwa Google, na vidokezo vya faragha ya matangazo vimezimwa. Bado unaweza kuingia katika akaunti yako ya Google kutoka kwenye kitufe cha wasifu wakati wowote unapotaka usawazishaji.

Ikiwa Chrome si ladha yako, hujakwama nacho. Chini ya _Sakinisha > Kivinjari_ katika menyu ya Omarchy utapata [Chromium](https://www.chromium.org/) (toleo safi la chanzo huria ambalo Chrome imetengenezwa kutoka kwake), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/), na [Ladybird](https://ladybird.org/) (Edge kwenye mashine za x86 pekee). Chagua kimoja nayo Omarchy hukisakinisha, huweka saraka yake ya sera, na hukiwekea mandhari yako ya sasa.

## Kukifanya kimoja kiwe chaguo-msingi

Kusakinisha kivinjari hakukifanyi kiwe chaguo-msingi. Ili kubadilisha, nenda kwenye _Sanidi > Chaguo-msingi > Kivinjari_ na uchague kimoja. Chaguo-msingi cha sasa kimewekwa alama ya tiki, na kuchagua kivinjari ambacho bado huna hukisakinisha kwanza.

Kutoka kwenye terminal ni:

```bash
omarchy default browser firefox
```

Iendeshe bila hoja yoyote nayo itakuambia chaguo-msingi cha sasa. Hii huweka kidhibiti cha XDG, kwa hiyo si vifunguo vya mkato vya Omarchy pekee vinavyofuata — kitu chochote kinachofungua kiungo, kuanzia programu ya mazungumzo hadi amri ya terminal, huenda kwenye kivinjari ulichochagua.

## Copy URL na Download Video

Vivinjari vya familia ya Chromium (Chromium chenyewe, Chrome, Edge, Brave, na Brave Origin) huja na viendelezi vitatu vya Omarchy: viwili vinavyotoka nje ya kivinjari na kuingia kwenye mfumo wako wote, na kimoja kinachopanga WhatsApp.

**Copy URL** huweka anwani ya kichupo cha sasa kwenye ubao wako wa kunakili kwa `Alt + Shift + L`. Hiyo ni haraka zaidi kuliko kubofya kwenye upau wa anwani na kunakili, na kwa sababu hupitia ubao wa kunakili wa mfumo badala ya wa kivinjari, unapata arifa ya Omarchy inayothibitisha hilo na URL inapatikana mara moja katika [historia ya ubao wa kunakili](08-unified-clipboard-history.md) na kila programu nyingine. Kuna kitufe cha upau wa zana pia, ikiwa unapendelea kubofya.

**Download Video** huchukua video inayocheza kwenye ukurasa unaoutazama kwa `Alt + Shift + D`. Huikabidhi URL kwa [yt-dlp](https://github.com/yt-dlp/yt-dlp), kwa hiyo hufanya kazi kwenye mengi zaidi ya YouTube, na upakuaji hutua katika `~/Videos`. Maendeleo huonekana katika onyesho lile lile la skrini ambalo sauti na mwangaza hutumia, likisasishwa palepale badala ya kurundika arifa. Weka `OMARCHY_YTDLP_DIR` ikiwa unapendelea faili ziende mahali pengine — angalia [FAQ](46-faq.md) kwa mahali pa kuweka vigezo vya mazingira.

Viendelezi vyote viwili huwasiliana na Omarchy kupitia kipokezi kidogo asilia cha ujumbe, ambacho husakinishwa kwa ajili yako pamoja na kivinjari. Hicho ndicho kipande kinachoruhusu video ya ukurasa wa wavuti kuishia katika saraka yako ya nyumbani na URL kuishia katika kidhibiti chako cha ubao wa kunakili, ambacho kiendelezi cha kawaida hakiwezi kufanya peke yake.

**WhatsApp Slim** hufanya WhatsApp Web ifuate mandhari ya mfumo wako na hukunja orodha yake ya mazungumzo dirisha linapokuwa jembamba.

Hivi ni vya familia ya Chromium pekee. Firefox na Zen havipati.

## Firefox na Zen

Firefox na Zen ni familia tofauti, kwa hiyo hupata mtindo tofauti: Omarchy husakinisha faili ya sera kwa chaguo-msingi zinazofaa na huziwasha katika hali asilia ya Wayland, ambayo unaitaka kwa upanuzi wa sehemu na usogeaji laini wa trackpad.

Hazipati viendelezi vya Chromium vilivyo hapo juu, na hazipewi mandhari na Omarchy, kwa hiyo sehemu hizo za matumizi ni zako kuziweka.

## Ladybird

Ladybird ni kivinjari kilichoandikwa kuanzia mwanzo, chenye injini yake badala ya ya Chromium au Firefox. Bado kiko katika alpha, kwa hiyo tarajia tovuti ambazo bado hazifanyi kazi, na Omarchy hukisakinisha kama kilivyo: hakuna viendelezi, hakuna mandhari, hakuna sera. Hakina dirisha la faragha pia, kwa hiyo `Super + Shift + Alt + B` hukifungua kwa wasifu wa muda unaofutwa unapokifunga. [Programu za wavuti](25-web-apps.md) huendelea kufanya kazi katika Chrome au Chromium.

## Kukiondoa tena

Kivinjari chochote kati ya hivi, Chrome ikiwemo, kinaweza kuondolewa tena chini ya _Ondoa > Kivinjari_. Viungo basi huenda Chrome au Chromium ikiwa kingine bado kimesakinishwa.
