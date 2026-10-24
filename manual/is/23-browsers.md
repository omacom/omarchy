# Vafrar

Omarchy kemur með [Chromium](https://www.chromium.org/) sem sjálfgefnum vafra. Þetta er venjulega opna útgáfan, með þema sem passar við restina af kerfinu þínu, og það er það sem `Super + Shift + Return` opnar og það sem hvert [vefforrit](25-web-apps.md) keyrir inni í.

Ef Chromium er ekki þinn smekkur ertu ekki fastur með það. Undir _Setja upp > Vafri_ í Omarchy-valmyndinni finnurðu Chrome, Edge, Brave, Brave Origin, Firefox og [Zen](https://zen-browser.app/). Veldu einn og Omarchy setur hann upp, setur upp stefnumöppuna hans og beitir núverandi þema þínu á hann.

## Að gera einn að sjálfgildi

Að setja upp vafra gerir hann ekki að sjálfgildi. Þegar hann er kominn á vélina skaltu fara í _Uppsetning > Sjálfgildi > Vafri_ og velja hann — valmyndin listar aðeins vafra sem þú hefur raunverulega sett upp, og merkir núverandi sjálfgildi með hak.

Úr terminalinu er það:

```bash
omarchy default browser firefox
```

Keyrðu það án viðfangs og það segir þér núverandi sjálfgildi. Þetta stillir XDG-meðhöndlarann, þannig að það eru ekki bara flýtilyklar Omarchy sem fylgja með — allt sem opnar tengil, allt frá spjallforriti til terminal-skipunar, fer í vafrann sem þú valdir.

## Copy URL og Download Video

Vafrarnir í Chromium-fjölskyldunni (Chromium sjálfur, Chrome, Edge og Brave) koma með tveimur Omarchy-viðbótum sem ná út úr vafranum og inn í restina af kerfinu þínu.

**Copy URL** setur vistfang núverandi flipa á klippiborðið þitt með `Alt + Shift + L`. Það er hraðara en að smella í vistfangastikuna og afrita, og vegna þess að það fer í gegnum kerfisklippiborðið frekar en vafrans færðu Omarchy-tilkynningu sem staðfestir það og vefslóðin er strax tiltæk í [klippiborðssögu](08-unified-clipboard-history.md) og hverju öðru forriti. Það er líka hnappur á tækjastikunni, ef þú kýst frekar að smella.

**Download Video** grípur myndbandið sem spilast á síðunni sem þú ert að skoða með `Alt + Shift + D`. Það afhendir vefslóðina til [yt-dlp](https://github.com/yt-dlp/yt-dlp), þannig að það virkar á miklu fleira en YouTube, og niðurhalið lendir í `~/Videos`. Framvinda birtist í sama skjábirtingu og hljóðstyrkur og birta nota, uppfærist á staðnum frekar en að staflast upp sem tilkynningar. Stilltu `OMARCHY_YTDLP_DIR` ef þú vilt frekar að skrárnar fari annað — sjá [FAQ](46-faq.md) um hvar eigi að setja umhverfisbreytur.

Báðar viðbæturnar tala við Omarchy í gegnum lítinn innfæddan skilaboðahýsil, sem er settur upp fyrir þig ásamt vafranum. Það er sá hluti sem leyfir myndbandi vefsíðu að enda í heimamöppunni þinni og vefslóð að enda í klippiborðsstjóranum þínum, sem venjuleg viðbót getur ekki gert ein síns liðs.

Þessar eru aðeins fyrir Chromium-fjölskylduna. Firefox og Zen fá þær ekki.

## Firefox og Zen

Firefox og Zen eru önnur fjölskylda, þannig að þau fá aðra meðferð: Omarchy setur upp stefnuskrá fyrir skynsamleg sjálfgildi og skiptir þeim í innfæddan Wayland-ham, sem þú vilt fyrir brotakennda kvörðun og mjúka snertifletisskrunun.

Þau fá ekki Chromium-viðbæturnar hér að ofan, og þau fá ekki þema frá Omarchy, þannig að þeir hlutar upplifunarinnar eru þínir að setja upp.

## Að fjarlægja einn aftur

Allt sem þú settir upp hér er hægt að taka aftur af undir _Fjarlægja > Vafri_. Chromium er ekki á þeim lista — hann er hluti af grunnkerfinu.
