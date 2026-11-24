# Vafrar

Omarchy kemur með [Google Chrome](https://www.google.com/chrome/) sem sjálfgefnum vafra. Hann er stilltur til að passa við restina af kerfinu þínu, og það er hann sem `Super + Shift + Return` (eða `Super + Shift + B`) opnar, með `Super + Shift + Alt + B` fyrir einkaglugga, og það sem sérhvert [vefforrit](25-web-apps.md) keyrir inni í. Hann opnar beint í vafraglugga: það er enginn upphafsskjár og engin innskráningarbeiðni, notkunartölfræði og hrunskýrslur eru ekki sendar til Google, og beiðnir um næði auglýsinga eru slökktar. Þú getur samt skráð þig inn á Google-reikninginn þinn með prófílhnappinum hvenær sem þú vilt samstillingu.

Ef Chrome er ekki eftir þínum smekk ertu ekki fastur með hann. Undir _Install > Browser_ í Omarchy-valmyndinni finnur þú [Chromium](https://www.chromium.org/) (hreinu opnu útgáfuna sem Chrome er gerður úr), Edge, Brave, Brave Origin, Firefox og [Zen](https://zen-browser.app/) (Edge aðeins á x86-vélum). Veldu einn og Omarchy setur hann upp, setur upp stefnumöppuna hans og beitir núverandi þema þínu á hann.

## Að gera einn að sjálfgefnum

Að setja upp vafra gerir hann ekki að sjálfgefnum. Til að skipta skaltu fara í _Setup > Defaults > Browser_ og velja einn. Núverandi sjálfgefni vafrinn er merktur með hak, og ef þú velur vafra sem þú átt ekki enn setur hann hann upp fyrst.

Frá skipanalínunni er það:

```bash
omarchy default browser firefox
```

Keyrðu það án viðfangs og það segir þér hver núverandi sjálfgefni vafrinn er. Þetta stillir XDG-meðhöndlarann, svo það eru ekki bara flýtilyklar Omarchy sem fylgja með — allt sem opnar tengil, frá spjallforriti til skipanalínuskipunar, fer í vafrann sem þú valdir.

## Copy URL og Download Video

Vafrarnir í Chromium-fjölskyldunni (Chromium sjálfur, Chrome, Edge, Brave og Brave Origin) koma með þremur Omarchy-viðbótum: tveimur sem ná út úr vafranum og inn í restina af kerfinu þínu, og einni sem snyrtir til í WhatsApp.

**Copy URL** setur vistfang núverandi flipa á klippiborðið þitt með `Alt + Shift + L`. Það er hraðara en að smella í vistfangastiku og afrita, og af því að það fer í gegnum klippiborð kerfisins frekar en vafrans færðu Omarchy-tilkynningu sem staðfestir það og vefslóðin er strax tiltæk í [sögu klippiborðs](08-unified-clipboard-history.md) og öllum öðrum forritum. Það er líka hnappur á tækjastikunni ef þú kýst að smella.

**Download Video** nær í myndbandið sem spilast á síðunni sem þú ert að skoða með `Alt + Shift + D`. Hún réttir vefslóðina til [yt-dlp](https://github.com/yt-dlp/yt-dlp), svo hún virkar á miklu fleiru en YouTube, og niðurhalið lendir í `~/Videos`. Framvindan birtist í sama skjábirtingunni sem hljóðstyrkur og birtustig nota, uppfærist á staðnum í stað þess að hrúga upp tilkynningum. Stilltu `OMARCHY_YTDLP_DIR` ef þú vilt frekar að skrárnar fari annað — sjá [FAQ](46-faq.md) um hvar eigi að setja umhverfisbreytur.

Báðar viðbæturnar tala við Omarchy í gegnum lítinn innfæddan skilaboðahýsil, sem er settur upp fyrir þig ásamt vafranum. Það er sá hluti sem lætur myndband af vefsíðu enda í heimamöppunni þinni og vefslóð enda í klippiborðsstjóranum þínum, sem venjuleg viðbót getur ekki gert ein og sér.

**WhatsApp Slim** lætur WhatsApp Web fylgja kerfisþemanu þínu og fellur saman spjallalistann hans þegar glugginn er þröngur.

Þetta er aðeins fyrir Chromium-fjölskylduna. Firefox og Zen fá þær ekki.

## Firefox og Zen

Firefox og Zen eru önnur fjölskylda, svo þeir fá aðra meðferð: Omarchy setur upp stefnuskrá fyrir skynsamlegar sjálfgefnar stillingar og skiptir þeim yfir í innfæddan Wayland-ham, sem þú vilt fyrir brotakvarðann og mjúka skruni með snertifleti.

Þeir fá ekki Chromium-viðbæturnar hér að ofan, og þeir eru ekki þemaðir af Omarchy, svo þeir hlutar upplifunarinnar eru þínir að setja upp.

## Að fjarlægja einn aftur

Sérhvern þessara vafra, Chrome meðtalinn, er hægt að taka aftur af undir _Remove > Browser_. Tenglar fara þá í Chrome eða Chromium ef hinn er enn uppsettur.
