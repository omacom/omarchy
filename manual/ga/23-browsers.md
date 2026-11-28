# Brabhsálaithe

Tagann Omarchy le [Google Chrome](https://www.google.com/chrome/) mar an brabhsálaí réamhshocraithe. Tá sé téamaithe chun meaitseáil leis an gcuid eile de do chóras, agus is é an rud a osclaíonn `Super + Shift + Return` (nó `Super + Shift + B`), le `Super + Shift + Alt + B` le haghaidh fuinneog phríobháideach, agus an rud a ritheann gach [aip ghréasáin](25-web-apps.md) taobh istigh de. Osclaíonn sé díreach go fuinneog brabhsálaí: níl aon scáileán fáilte ná leid síniú isteach ann, ní sheoltar staitisticí úsáide agus tuairiscí tuairte chuig Google, agus tá na leideanna príobháideachais fógraíochta múchta. Is féidir leat síniú isteach i do chuntas Google ón gcnaipe próifíle fós aon uair is mian leat sioncronú.

Mura bhfuil Chrome de do rogha, níl tú sáinnithe leis. Faoi _Install > Browser_ sa roghchlár Omarchy gheobhaidh tú [Chromium](https://www.chromium.org/) (an leagan plain foinse oscailte a ndéantar Chrome as), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/), agus [Ladybird](https://ladybird.org/) (Edge ar mheaisíní x86 amháin). Roghnaigh ceann agus suiteálann Omarchy é, socraíonn sé a eolaire polasaí, agus cuireann sé do théama reatha i bhfeidhm air.

## Ceann a dhéanamh réamhshocraithe

Ní chuireann suiteáil brabhsálaí chun cinn mar réamhshocrú é. Chun athrú, téigh go _Setup > Defaults > Browser_ agus roghnaigh ceann. Tá an réamhshocrú reatha marcáilte le tic, agus má roghnaíonn tú brabhsálaí nach bhfuil agat fós, suiteálfar é ar dtús.

Ón teirminéal is é seo é:

```bash
omarchy default browser firefox
```

Rith gan argóint é agus inseoidh sé duit an réamhshocrú reatha. Socraíonn sé seo an láimhseálaí XDG, mar sin ní heochracha te Omarchy amháin a leanann leis — téann aon rud a osclaíonn nasc, ó aip comhrá go ordú teirminéil, chuig an brabhsálaí a roghnaigh tú.

## URL a Chóipeáil agus Físeán a Íoslódáil

Tagann na brabhsálaithe den teaghlach Chromium (Chromium féin, Chrome, Edge, Brave, agus Brave Origin) le trí shíneadh Omarchy: dhá cheann a shíneann amach ón mbrabhsálaí agus isteach sa chuid eile de do chóras, agus ceann a thugann cuma níos néata ar WhatsApp.

Cuireann **Copy URL** seoladh an táb reatha ar do ghearrthaisce le `Alt + Shift + L`. Tá sé sin níos tapúla ná cliceáil isteach sa bharra seoltaí agus cóipeáil, agus toisc go dtéann sé tríd an ngearrthaisce córais seachas gearrthaisce an brabhsálaí, faigheann tú fógra Omarchy á dheimhniú agus bíonn an URL ar fáil láithreach i [stair na gearrthaisce](08-unified-clipboard-history.md) agus i ngach aip eile. Tá cnaipe barra uirlisí ann freisin, más fearr leat cliceáil.

Faigheann **Download Video** an físeán atá á sheinm ar an leathanach a bhfuil tú ag breathnú air le `Alt + Shift + D`. Cuireann sé an URL ar aghaidh chuig [yt-dlp](https://github.com/yt-dlp/yt-dlp), mar sin oibríonn sé ar i bhfad níos mó ná YouTube, agus críochnaíonn an íoslódáil i `~/Videos`. Taispeántar an dul chun cinn san taispeántas céanna ar an scáileán a úsáideann toirt agus gile, agus déantar é a nuashonrú ar an láthair seachas fógraí a chruachadh suas. Socraigh `OMARCHY_YTDLP_DIR` más fearr leat go rachadh na comhaid go dtí áit éigin eile — féach an [FAQ](46-faq.md) le haghaidh cá háit le hathróga timpeallachta a chur.

Labhraíonn an dá shíneadh le Omarchy trí óstach teachtaireachtaí dúchasach beag, a shuiteáiltear duit mar aon leis an mbrabhsálaí. Sin é an píosa a ligeann d’fhíseán ar leathanach gréasáin críochnú i d’eolaire baile agus do URL críochnú i do bhainisteoir gearrthaisce, rud nach féidir le síneadh gnáth a dhéanamh leis féin.

Déanann **WhatsApp Slim** go leanann WhatsApp Web do théama córais agus comhdhlúthaíonn sé a liosta comhráite nuair atá an fhuinneog cúng.

Is don teaghlach Chromium amháin iad seo. Ní fhaigheann Firefox agus Zen iad.

## Firefox agus Zen

Is teaghlach difriúil iad Firefox agus Zen, mar sin faigheann siad cóireáil dhifriúil: suiteálann Omarchy comhad polasaithe le haghaidh réamhshocruithe ciallmhara agus athraíonn sé iad go mód dúchasach Wayland, rud atá uait le haghaidh scálú codánach agus scrollú réidh ar an gceapán tadhaill.

Ní fhaigheann siad na síntí Chromium thuas, agus ní dhéanann Omarchy téamú orthu, mar sin is fútsa na codanna sin den eispéireas a shocrú.

## Ladybird

Is brabhsálaí é Ladybird atá scríofa ón tús, lena inneall féin seachas inneall Chromium nó Firefox. Tá sé fós in alfa, mar sin bí ag súil le suíomhanna nach n-oibríonn fós, agus suiteálann Omarchy é mar a thagann sé: gan síntí, gan téama, gan polasaithe. Níl fuinneog phríobháideach aige ach oiread, mar sin osclaíonn `Super + Shift + Alt + B` é le próifíl shealadach a scriostar nuair a dhúnann tú é. Leanfaidh [aipeanna gréasáin](25-web-apps.md) orthu ag rith i Chrome nó Chromium.

## Ceann a bhaint arís

Is féidir aon cheann de na brabhsálaithe seo, Chrome san áireamh, a bhaint arís faoi _Remove > Browser_. Téann naisc ansin go Chrome nó Chromium má tá an ceann eile fós suiteáilte.
