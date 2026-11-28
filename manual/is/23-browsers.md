# Vafrar

Omarchy kemur með [Google Chrome](https://www.google.com/chrome/) sem sjálfgefnum vafra. Hann er þemaður til að passa við afganginn af kerfinu þínu, og það er hann sem `Super + Shift + Return` (eða `Super + Shift + B`) opnar, með `Super + Shift + Alt + B` fyrir einkaglugga, og það sem öll [vefforrit](25-web-apps.md) keyra inni í. Hann opnast beint í vafraglugga: það er enginn velkominn skjár eða innskráningarkvaðning, notkunartölfræði og hrunskýrslur eru ekki sendar til Google, og kvaðningar um næði auglýsinga eru slökktar. Þú getur samt skráð þig inn á Google-reikninginn þinn með prófílhnappnum hvenær sem þú vilt samstillingu.

Ef Chrome er ekki eftir þínum smekk ertu ekki fastur með hann. Undir _Install > Browser_ í Omarchy-valmyndinni finnur þú [Chromium](https://www.chromium.org/) (hreina opna útgáfuna sem Chrome er byggður á), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) og [Ladybird](https://ladybird.org/) (Edge aðeins á x86-vélum). Veldu einn og Omarchy setur hann upp, setur upp stefnumöppu hans og setur núverandi þema þitt á hann.

## Að gera einn að sjálfgefnum

Að setja upp vafra gerir hann ekki að sjálfgefnum. Til að skipta ferðu í _Setup > Defaults > Browser_ og velur einn. Núverandi sjálfgefni vafri er merktur með haki, og ef þú velur vafra sem þú átt ekki enn setur það hann upp fyrst.

Frá skipanalínunni er það:

```bash
omarchy default browser firefox
```

Keyrðu það án viðfangs og það segir þér hver núverandi sjálfgefni vafri er. Þetta stillir XDG-meðhöndlarann, svo það eru ekki bara flýtilyklar Omarchy sem fylgja með — allt sem opnar tengil, frá spjallforriti til skipunar í skipanalínu, fer í vafrann sem þú valdir.

## Copy URL og Download Video

Vafrarnir í Chromium-fjölskyldunni (Chromium sjálfur, Chrome, Edge, Brave og Brave Origin) koma með þremur Omarchy-viðbótum: tveimur sem ná út úr vafranum og inn í afganginn af kerfinu þínu, og einni sem snyrtir til í WhatsApp.

**Copy URL** setur vistfang núverandi flipa á klemmuspjaldið þitt með `Alt + Shift + L`. Það er hraðara en að smella í vistfangsstikuna og afrita, og af því að það fer í gegnum klemmuspjald kerfisins frekar en vafrans færðu tilkynningu frá Omarchy sem staðfestir það og vefslóðin er strax aðgengileg í [klemmuspjaldsferli](08-unified-clipboard-history.md) og öllum öðrum forritum. Það er líka hnappur á tækjastikunni ef þú kýst að smella.

**Download Video** nær í myndbandið sem spilast á síðunni sem þú ert að skoða með `Alt + Shift + D`. Hún réttir vefslóðina til [yt-dlp](https://github.com/yt-dlp/yt-dlp), svo hún virkar á miklu fleiru en YouTube, og niðurhalið lendir í `~/Videos`. Framvinda birtist í sama skjábirtingu og hljóðstyrkur og birta nota, og uppfærist á staðnum í stað þess að stafla tilkynningum. Stilltu `OMARCHY_YTDLP_DIR` ef þú vilt frekar að skrárnar fari eitthvað annað — sjá [FAQ](46-faq.md) um hvar eigi að setja umhverfisbreytur.

Báðar viðbæturnar tala við Omarchy í gegnum lítinn innfæddan skilaboðahýsil, sem er settur upp fyrir þig ásamt vafranum. Það er hluturinn sem gerir myndbandi á vefsíðu kleift að lenda í heimamöppunni þinni og vefslóð að lenda í klemmuspjaldsstjóranum þínum, sem venjuleg viðbót getur ekki gert ein síns liðs.

**WhatsApp Slim** lætur WhatsApp Web fylgja þema kerfisins þíns og fellir saman spjalllistann hans þegar glugginn er þröngur.

Þessar eru aðeins fyrir Chromium-fjölskylduna. Firefox og Zen fá þær ekki.

## Firefox og Zen

Firefox og Zen eru önnur fjölskylda, svo þeir fá aðra meðhöndlun: Omarchy setur upp stefnuskjal fyrir skynsamleg sjálfgildi og skiptir þeim yfir í innfæddan Wayland-ham, sem þú vilt fyrir brotakvörðun og mjúka skruni með snertifleti.

Þeir fá ekki Chromium-viðbæturnar hér að ofan, og þeir eru ekki þemaðir af Omarchy, svo þeir hlutar upplifunarinnar eru þínir að setja upp.

## Ladybird

Ladybird er vafri skrifaður frá grunni, með eigin vél frekar en vél Chromium eða Firefox. Hann er enn á alpha-stigi, svo búist við vefsíðum sem virka ekki enn, og Omarchy setur hann upp eins og hann kemur: engar viðbætur, ekkert þema, engar stefnur. Hann hefur heldur engan einkaglugga, svo `Super + Shift + Alt + B` opnar hann með tímabundnum prófíl sem er eytt þegar þú lokar honum. [Vefforrit](25-web-apps.md) halda áfram að keyra í Chrome eða Chromium.

## Að fjarlægja einn aftur

Hvern sem er þessara vafra, Chrome meðtalinn, má taka aftur af undir _Remove > Browser_. Tenglar fara þá í Chrome eða Chromium ef hinn er enn uppsettur.
