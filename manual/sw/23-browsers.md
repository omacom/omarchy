# Vivinjari

Omarchy huja na [Google Chrome](https://www.google.com/chrome/) kama kivinjari chaguo-msingi. Kimepewa mandhari yanayolingana na mfumo wako wote, na ndicho kinachofunguliwa na `Super + Shift + Return` na ambacho kila [programu ya wavuti](25-web-apps.md) huendeshwa ndani yake. Hufunguka moja kwa moja kwenye dirisha la kivinjari: hakuna skrini ya kukaribisha wala kidokezo cha kuingia, takwimu za matumizi na ripoti za kuanguka hazitumwi kwa Google, na vidokezo vya faragha ya matangazo vimezimwa. Bado unaweza kuingia katika akaunti yako ya Google kutoka kwenye kitufe cha wasifu wakati wowote unapotaka usawazishaji.

Ikiwa Chrome si chaguo lako, hulazimiki kubaki nacho. Chini ya _Install > Browser_ katika menyu ya Omarchy utapata [Chromium](https://www.chromium.org/) (toleo la wazi la kawaida ambalo Chrome imetengenezwa kutokana nalo), Edge, Brave, Brave Origin, Firefox, na [Zen](https://zen-browser.app/). Chagua kimoja na Omarchy itakisakinisha, itaandaa saraka yake ya sera, na itakitumia mandhari yako ya sasa.

## Kukifanya kimoja kiwe chaguo-msingi

Kusakinisha kivinjari hakukifanyi kiwe chaguo-msingi. Kikishakuwa kwenye mashine, nenda kwenye _Setup > Defaults > Browser_ na ukichague — menyu huorodhesha tu vivinjari ambavyo umesakinisha kweli, na huweka alama ya tiki kwenye chaguo-msingi cha sasa.

Kutoka kwenye terminal ni:

```bash
omarchy default browser firefox
```

Kiendeshe bila hoja yoyote na kitakuambia chaguo-msingi cha sasa. Hii huweka kidhibiti cha XDG, kwa hiyo si hotkeys za Omarchy pekee zinazofuata — kitu chochote kinachofungua kiungo, kutoka programu ya mazungumzo hadi amri ya terminal, huenda kwenye kivinjari ulichochagua.

## Copy URL na Download Video

Vivinjari vya familia ya Chromium (Chromium chenyewe, Chrome, Edge, na Brave) huja na viendelezi viwili vya Omarchy vinavyotoka nje ya kivinjari na kuingia kwenye mfumo wako wote.

**Copy URL** huweka anwani ya kichupo cha sasa kwenye clipboard yako kwa `Alt + Shift + L`. Hiyo ni haraka zaidi kuliko kubofya kwenye upau wa anwani na kunakili, na kwa sababu hupitia clipboard ya mfumo badala ya ya kivinjari, unapata arifa ya Omarchy inayothibitisha na URL inapatikana mara moja katika [historia ya clipboard](08-unified-clipboard-history.md) na kila programu nyingine. Kuna kitufe cha upau wa zana pia, ikiwa unapendelea kubofya.

**Download Video** huchukua video inayocheza kwenye ukurasa unaoutazama kwa `Alt + Shift + D`. Huiwasilisha URL kwa [yt-dlp](https://github.com/yt-dlp/yt-dlp), kwa hiyo hufanya kazi kwenye mengi zaidi ya YouTube, na upakuaji huishia katika `~/Videos`. Maendeleo huonekana katika onyesho lile lile la skrini ambalo sauti na mwangaza hutumia, likisasishwa papo hapo badala ya kurundika arifa. Weka `OMARCHY_YTDLP_DIR` ikiwa ungependa faili ziende mahali pengine — angalia [FAQ](46-faq.md) kwa mahali pa kuweka vigezo vya mazingira.

Viendelezi vyote viwili huwasiliana na Omarchy kupitia mpangishaji mdogo wa ujumbe asilia, ambao husakinishwa kwa ajili yako pamoja na kivinjari. Hiyo ndiyo sehemu inayoruhusu video ya ukurasa wa wavuti kuishia katika saraka yako ya nyumbani na URL kuishia katika kidhibiti chako cha clipboard, jambo ambalo kiendelezi cha kawaida hakiwezi kufanya chenyewe.

Hivi ni vya familia ya Chromium pekee. Firefox na Zen havipati.

## Firefox na Zen

Firefox na Zen ni familia tofauti, kwa hiyo hupata mtindo tofauti: Omarchy husakinisha faili ya sera kwa chaguo-msingi zinazofaa na huziweka katika hali asilia ya Wayland, ambayo unaihitaji kwa ukuzaji wa sehemu na usogeaji laini wa trackpad.

Havipati viendelezi vya Chromium vilivyo hapo juu, na havipewi mandhari na Omarchy, kwa hiyo sehemu hizo za matumizi ni zako kuziweka mwenyewe.

## Kukiondoa tena

Kivinjari chochote kati ya hivi, Chrome ikiwemo, kinaweza kuondolewa tena chini ya _Remove > Browser_. Kisha viungo huenda kwa Chrome au Chromium ikiwa kingine bado kimesakinishwa.
