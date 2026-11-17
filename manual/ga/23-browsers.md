# Brabhsálaithe

Tagann [Google Chrome](https://www.google.com/chrome/) le hOmarchy mar an brabhsálaí réamhshocraithe. Tá téama air a mheaitseálann an chuid eile de do chóras, agus is é a osclaíonn `Super + Shift + Return` é agus an ceann a ritheann gach [aip ghréasáin](25-web-apps.md) ann. Osclaíonn sé díreach chuig fuinneog bhrabhsálaí: níl aon scáileán fáilte ná leid síniú isteach ann, ní sheoltar staitisticí úsáide ná tuairiscí tuairteála chuig Google, agus tá na leideanna príobháideachais fógraí múchta. Is féidir leat síniú isteach i do chuntas Google ón gcnaipe próifíle fós aon uair is mian leat sioncronú.

Mura bhfuil Chrome de réir do bhlais, níl tú sáite leis. Faoi _Install > Browser_ i roghchlár Omarchy gheobhaidh tú [Chromium](https://www.chromium.org/) (an leagan glan foinse oscailte a ndéantar Chrome as), Edge, Brave, Brave Origin, Firefox, agus [Zen](https://zen-browser.app/). Roghnaigh ceann agus suiteálfaidh Omarchy é, socróidh sé a eolaire polasaí, agus cuirfidh sé do théama reatha i bhfeidhm air.

## Ceann a dhéanamh mar an réamhshocrú

Ní chuireann suiteáil brabhsálaí chun cinn mar réamhshocrú é. Nuair a bhíonn sé ar an meaisín, téigh chuig _Setup > Defaults > Browser_ agus roghnaigh é — ní liostaíonn an roghchlár ach brabhsálaithe atá suiteáilte agat i ndáiríre, agus marcálann sé an réamhshocrú reatha le tic.

Ón teirminéal is é seo é:

```bash
omarchy default browser firefox
```

Rith gan argóint é agus inseoidh sé an réamhshocrú reatha duit. Socraíonn sé seo an láimhseálaí XDG, mar sin ní hiad hotkeys Omarchy amháin a leanann é — téann aon rud a osclaíonn nasc, ó aip comhrá go hordú teirminéil, chuig an mbrabhsálaí a roghnaigh tú.

## Copy URL agus Download Video

Tagann dhá shíneadh Omarchy leis na brabhsálaithe de theaghlach Chromium (Chromium féin, Chrome, Edge, agus Brave) a shíneann amach as an mbrabhsálaí agus isteach sa chuid eile de do chóras.

**Copy URL** cuireann sé seoladh an chluaisín reatha ar do ghearrthaisce le `Alt + Shift + L`. Tá sin níos tapúla ná cliceáil isteach sa bharra seoltaí agus cóipeáil, agus toisc go dtéann sé tríd an ngearrthaisce córais seachas gearrthaisce an bhrabhsálaí, faigheann tú fógra Omarchy á dheimhniú agus bíonn an URL ar fáil láithreach i [stair na gearrthaisce](08-unified-clipboard-history.md) agus i ngach aip eile. Tá cnaipe ar an mbarra uirlisí ann freisin, más fearr leat cliceáil.

**Download Video** a ghabhann an físeán atá á sheinm ar an leathanach a bhfuil tú ag féachaint air le `Alt + Shift + D`. Tugann sé an URL do [yt-dlp](https://github.com/yt-dlp/yt-dlp), mar sin oibríonn sé ar i bhfad níos mó ná YouTube, agus tuirlingíonn an íoslódáil i `~/Videos`. Taispeántar an dul chun cinn sa taispeáint ar an scáileán chéanna a úsáideann toirt agus gile, á nuashonrú ina áit féin seachas fógraí a chruachadh. Socraigh `OMARCHY_YTDLP_DIR` más fearr leat go rachadh na comhaid áit éigin eile — féach an [FAQ](46-faq.md) le fáil amach cá gcuirtear athróga timpeallachta.

Labhraíonn an dá shíneadh le hOmarchy trí óstach beag teachtaireachtaí dúchasach, a shuiteáiltear duit in éineacht leis an mbrabhsálaí. Sin é an píosa a ligeann d'fhíseán ar leathanach gréasáin críochnú i d'eolaire baile agus do URL críochnú i do bhainisteoir gearrthaisce, rud nach féidir le síneadh gnáth a dhéanamh leis féin.

Is do theaghlach Chromium amháin iad seo. Ní fhaigheann Firefox agus Zen iad.

## Firefox agus Zen

Is teaghlach difriúil iad Firefox agus Zen, mar sin faigheann siad cóireáil dhifriúil: suiteálann Omarchy comhad polasaithe dóibh le haghaidh réamhshocruithe ciallmhara agus aistríonn sé iad go mód dúchasach Wayland, rud a theastaíonn uait le haghaidh scálú codánach agus scrollú réidh ar an gceap tadhaill.

Ní fhaigheann siad na síntí Chromium thuas, agus ní chuireann Omarchy téama orthu, mar sin is fútsa na codanna sin den eispéireas a shocrú.

## Ceann a bhaint arís

Is féidir aon cheann de na brabhsálaithe seo, Chrome san áireamh, a bhaint arís faoi _Remove > Browser_. Téann naisc ansin chuig Chrome nó Chromium má tá an ceann eile fós suiteáilte.
