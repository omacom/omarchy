# Brabhsálaithe

Tagann [Google Chrome](https://www.google.com/chrome/) mar bhrabhsálaí réamhshocraithe le Omarchy. Tá sé téamáilte chun meaitseáil leis an gcuid eile de do chóras, agus is é a osclaíonn `Super + Shift + Return` (nó `Super + Shift + B`), le `Super + Shift + Alt + B` le haghaidh fuinneog phríobháideach, agus is é a ritheann gach [aip gréasáin](25-web-apps.md) istigh ann. Osclaíonn sé díreach chuig fuinneog bhrabhsálaí: níl aon scáileán fáilte ná leid sínithe isteach ann, ní sheoltar staitisticí úsáide ná tuairiscí tuairteála chuig Google, agus tá leideanna príobháideachais fógraí múchta. Is féidir leat síniú isteach i do chuntas Google ón gcnaipe próifíle fós aon uair is mian leat sioncronú.

Mura bhfuil Chrome oiriúnach duit, níl tú sáite leis. Faoi _Install > Browser_ i roghchlár Omarchy gheobhaidh tú [Chromium](https://www.chromium.org/) (an leagan glan foinse oscailte a ndéantar Chrome as), Edge, Brave, Brave Origin, Firefox, agus [Zen](https://zen-browser.app/) (Edge ar mheaisíní x86 amháin). Roghnaigh ceann agus suiteálfaidh Omarchy é, socróidh sé a eolaire polasaí, agus cuirfidh sé do théama reatha i bhfeidhm air.

## Ceann acu a dhéanamh mar an réamhshocrú

Ní chuireann suiteáil brabhsálaí chun cinn mar réamhshocrú é. Chun athrú, téigh chuig _Setup > Defaults > Browser_ agus roghnaigh ceann. Tá an réamhshocrú reatha marcáilte le tic, agus má roghnaíonn tú brabhsálaí nach bhfuil agat fós, suiteálfar é ar dtús.

Ón teirminéal is é seo é:

```bash
omarchy default browser firefox
```

Rith gan argóint é agus inseoidh sé duit cad é an réamhshocrú reatha. Socraíonn sé seo an láimhseálaí XDG, mar sin ní heochracha te Omarchy amháin a leanann leis — téann aon rud a osclaíonn nasc, ó aip chomhrá go hordú teirminéil, chuig an mbrabhsálaí a roghnaigh tú.

## Copy URL agus Download Video

Tagann trí shíneadh Omarchy leis na brabhsálaithe de theaghlach Chromium (Chromium féin, Chrome, Edge, Brave, agus Brave Origin): dhá cheann a shíneann amach ón mbrabhsálaí agus isteach sa chuid eile de do chóras, agus ceann a thugann ord do WhatsApp.

**Copy URL** cuireann sé seoladh an táb reatha ar do ghearrthaisce le `Alt + Shift + L`. Tá sé sin níos tapúla ná cliceáil isteach sa bharra seoltaí agus cóipeáil, agus toisc go dtéann sé tríd an ngearrthaisce córais seachas ceann an bhrabhsálaí, faigheann tú fógra Omarchy á dheimhniú agus bíonn an URL ar fáil láithreach i [stair na gearrthaisce](08-unified-clipboard-history.md) agus i ngach aip eile. Tá cnaipe ar an mbarra uirlisí freisin, más fearr leat cliceáil.

**Download Video** tógann sé an físeán atá á sheinm ar an leathanach a bhfuil tú ag féachaint air le `Alt + Shift + D`. Tugann sé an URL do [yt-dlp](https://github.com/yt-dlp/yt-dlp), mar sin oibríonn sé ar i bhfad níos mó ná YouTube amháin, agus tuirlingíonn an íoslódáil i `~/Videos`. Taispeántar an dul chun cinn sa taispeántas ar an scáileán céanna a úsáideann an fhuaim agus an gile, á nuashonrú san áit chéanna seachas fógraí a chruachadh ar a chéile. Socraigh `OMARCHY_YTDLP_DIR` más fearr leat go rachadh na comhaid go háit eile — féach an [FAQ](46-faq.md) le fáil amach cá gcuirfidh tú athróga timpeallachta.

Labhraíonn an dá shíneadh le Omarchy trí óstach beag teachtaireachtaí dúchasach, a shuiteáiltear duit mar aon leis an mbrabhsálaí. Sin é an píosa a ligeann d'fhíseán ó leathanach gréasáin teacht isteach i d'eolaire baile agus do URL teacht isteach i do bhainisteoir gearrthaisce, rud nach féidir le síneadh rialta a dhéanamh leis féin.

**WhatsApp Slim** a chuireann ar WhatsApp Web do théama córais a leanúint agus a dhéanann a liosta comhrá a chrapadh nuair a bhíonn an fhuinneog cúng.

Tá siad seo do theaghlach Chromium amháin. Ní fhaigheann Firefox agus Zen iad.

## Firefox agus Zen

Is teaghlach difriúil iad Firefox agus Zen, mar sin faigheann siad cóireáil dhifriúil: suiteálann Omarchy comhad polasaithe do réamhshocruithe ciallmhara agus athraíonn sé iad go mód dúchasach Wayland, rud a theastaíonn uait do scálú codánach agus do scrollú réidh leis an gceap tadhaill.

Ní fhaigheann siad na síntí Chromium thuas, agus ní théamaíonn Omarchy iad, mar sin is ortsa atá sé na codanna sin den taithí a shocrú.

## Ceann a bhaint arís

Is féidir aon cheann de na brabhsálaithe seo, Chrome san áireamh, a bhaint arís faoi _Remove > Browser_. Rachaidh naisc ansin chuig Chrome nó Chromium má tá an ceann eile fós suiteáilte.
