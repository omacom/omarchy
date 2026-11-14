# Vafrar

Omarchy kemur með [Google Chrome](https://www.google.com/chrome/) sem sjálfgefinn vafra. Hann er settur í þema sem passar við restina af kerfinu þínu, og það er hann sem `Super + Shift + Return` opnar og sem hvert [vefforrit](25-web-apps.md) keyrir inni í. Hann opnast beint í vafraglugga: það er enginn velkomuskjár eða innskráningarbeiðni, notkunartölfræði og hrunaskýrslur eru ekki sendar til Google, og slökkt er á persónuverndarbeiðnum fyrir auglýsingar. Þú getur samt skráð þig inn á Google-reikninginn þinn með prófílhnappnum hvenær sem þú vilt samstillingu.

Ef Chrome er ekki eftir þínum smekk ertu ekki fastur með hann. Undir _Install > Browser_ í Omarchy-valmyndinni finnur þú [Chromium](https://www.chromium.org/) (hreina opna útgáfuna sem Chrome er byggður á), Edge, Brave, Brave Origin, Firefox og [Zen](https://zen-browser.app/). Veldu einn og Omarchy setur hann upp, setur upp stefnumöppuna hans og setur núverandi þema þitt á hann.

## Að gera einn að sjálfgefnum

Að setja upp vafra gerir hann ekki sjálfgefinn. Þegar hann er kominn á vélina skaltu fara í _Setup > Defaults > Browser_ og velja hann — valmyndin sýnir aðeins vafra sem þú hefur í raun sett upp og merkir núverandi sjálfgefinn vafra með hakmerki.

Frá útstöðinni er það:

```bash
omarchy default browser firefox
```

Keyrðu það án viðfangs og það segir þér hver er sjálfgefinn núna. Þetta stillir XDG-meðhöndlarann, svo það eru ekki bara flýtilyklar Omarchy sem fylgja með — allt sem opnar tengil, allt frá spjallforriti til skipunar í útstöð, fer í vafrann sem þú valdir.

## Copy URL og Download Video

Vafrar úr Chromium-fjölskyldunni (Chromium sjálfur, Chrome, Edge og Brave) koma með tvær Omarchy-viðbætur sem ná út úr vafranum og inn í restina af kerfinu þínu.

**Copy URL** setur vistfang núverandi flipa á klippiborðið þitt með `Alt + Shift + L`. Það er hraðara en að smella í vistfangsstikuna og afrita, og af því að það fer í gegnum klippiborð kerfisins frekar en vafrans færðu tilkynningu frá Omarchy sem staðfestir það og slóðin er strax tiltæk í [klippiborðssögu](08-unified-clipboard-history.md) og öllum öðrum forritum. Það er líka hnappur á tækjastikunni ef þú kýst að smella.

**Download Video** grípur myndbandið sem spilast á síðunni sem þú ert að skoða með `Alt + Shift + D`. Hún afhendir [yt-dlp](https://github.com/yt-dlp/yt-dlp) slóðina, svo hún virkar á miklu fleiru en YouTube, og niðurhalið lendir í `~/Videos`. Framvindan birtist í sama skjáviðmóti og hljóðstyrkur og birta nota, uppfærist á staðnum í stað þess að hrúga upp tilkynningum. Stilltu `OMARCHY_YTDLP_DIR` ef þú vilt frekar að skrárnar fari annað — sjá [FAQ](46-faq.md) um hvar á að setja umhverfisbreytur.

Báðar viðbæturnar tala við Omarchy í gegnum lítinn innfæddan skilaboðahýsil, sem er settur upp fyrir þig ásamt vafranum. Það er sá hluti sem gerir myndbandi af vefsíðu kleift að enda í heimamöppunni þinni og slóð að enda í klippiborðsstjóranum þínum, sem venjuleg viðbót getur ekki gert ein síns liðs.

Þetta á aðeins við um Chromium-fjölskylduna. Firefox og Zen fá þær ekki.

## Firefox og Zen

Firefox og Zen eru önnur fjölskylda, svo þau fá aðra meðferð: Omarchy setur upp stefnuskrá fyrir skynsamlegar sjálfgefnar stillingar og setur þau í innfæddan Wayland-ham, sem þú vilt fyrir brotakvarðann og mjúka skrunun á snertifleti.

Þau fá ekki Chromium-viðbæturnar hér að ofan og þau eru ekki þemuð af Omarchy, svo þá hluta upplifunarinnar er þitt að setja upp.

## Að fjarlægja einn aftur

Hvern sem er af þessum vöfrum, Chrome þar með talinn, er hægt að fjarlægja aftur undir _Remove > Browser_. Tenglar fara þá í Chrome eða Chromium ef hinn þeirra er enn settur upp.
