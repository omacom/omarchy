# Brabhsálaithe

Tagann Omarchy le [Chromium](https://www.chromium.org/) mar an brabhsálaí réamhshocraithe. Is é an leagan foinse oscailte glan é, téamaithe chun meaitseáil leis an gcuid eile de do chóras, agus is é a osclaíonn `Super + Shift + Return` agus a ritheann gach [aip gréasáin](25-web-apps.md) taobh istigh de.

Mura dtaitníonn Chromium leat, níl tú sáite leis. Faoi _Suiteáil > Brabhsálaí_ sa roghchlár Omarchy gheobhaidh tú Chrome, Edge, Brave, Brave Origin, Firefox, agus [Zen](https://zen-browser.app/). Pioc ceann agus suiteálann Omarchy é, socraíonn sé a eolaire beartais, agus cuireann sé do théama reatha i bhfeidhm air.

## Ceann a dhéanamh réamhshocraithe

Ní ardaíonn suiteáil brabhsálaí é. Nuair atá sé ar an meaisín, téigh chuig _Socrú > Réamhshocruithe > Brabhsálaí_ agus pioc é — ní liostálann an roghchlár ach brabhsálaithe atá suiteáilte agat i ndáiríre, agus marcálann sé an réamhshocrú reatha le tic.

Ón teirminéal is é:

```bash
omarchy default browser firefox
```

Rith é gan argóint agus inseoidh sé duit an réamhshocrú reatha. Socraíonn sé seo láimhseálaí XDG, mar sin ní hé amháin méarchláir Omarchy a leanann — téann aon rud a osclaíonn nasc, ó aip comhrá go ordú teirminéil, chuig an brabhsálaí a phioc tú.

## Cóipeáil URL agus Íoslódáil Físeáin

Tagann brabhsálaithe theaghlach Chromium (Chromium féin, Chrome, Edge, agus Brave) le dhá shíneadh Omarchy a shroicheann amach as an mbrabhsálaí agus isteach sa chuid eile de do chóras.

Cuireann **Cóipeáil URL** seoladh an chlibe reatha ar do ghearrthaisce le `Alt + Shift + L`. Tá sé sin níos tapúla ná cliceáil isteach sa bharra seoltaí agus cóipeáil, agus toisc go dtéann sé tríd an ngearrthaisce córais seachas gearrthaisce an bhrabhsálaí, faigheann tú fógra Omarchy á dhearbhú agus tá an URL ar fáil láithreach i [stair na gearrthaisce](08-unified-clipboard-history.md) agus i ngach aip eile. Tá cnaipe barra uirlisí ann freisin, más fhearr leat cliceáil.

Gabhann **Íoslódáil Físeáin** an físeán atá á sheinm ar an leathanach a bhfuil tú ag féachaint air le `Alt + Shift + D`. Cuireann sé an URL ar aghaidh chuig [yt-dlp](https://github.com/yt-dlp/yt-dlp), mar sin oibríonn sé ar i bhfad níos mó ná YouTube, agus tuirlingíonn an íoslódáil in `~/Videos`. Taispeántar an dul chun cinn sa taispeántas ar an scáileán céanna a úsáideann toirt agus gile, á nuashonrú san áit seachas fógraí a chruachadh. Socraigh `OMARCHY_YTDLP_DIR` más fhearr leat go rachadh na comhaid áit éigin eile — féach na [CC](46-faq.md) le haghaidh áit le hathróga timpeallachta a chur.

Labhraíonn an dá shíneadh le Omarchy trí óstach beag teachtaireachtaí dúchasach, a shuiteáiltear duit mar aon leis an mbrabhsálaí. Is é sin an píosa a ligeann d'fhíseán leathanaigh ghréasáin teacht i do eolaire baile agus do URL teacht i do bhainisteoir gearrthaisce, rud nach féidir le síneadh gnáth a dhéanamh leis féin.

Is do theaghlach Chromium amháin iad seo. Ní fhaigheann Firefox agus Zen iad.

## Firefox agus Zen

Is teaghlach difriúil iad Firefox agus Zen, mar sin faigheann siad cóireáil dhifriúil: suiteálann Omarchy comhad beartas do réamhshocruithe ciallmhara agus aistríonn sé iad isteach i mód dúchasach Wayland, rud atá uait le haghaidh scálú codáin agus scrollú réidh ar an eochaircheap.

Ní fhaigheann siad na síntí Chromium thuas, agus ní dhéanann Omarchy téama orthu, mar sin is leatsa na codanna sin den eispéireas a chur ar bun.

## Ceann a bhaint arís

Is féidir aon rud a shuiteáil tú anseo a thógáil as arís faoi _Bain > Brabhsálaí_. Níl Chromium ar an liosta sin — is cuid den bhunchóras é.
