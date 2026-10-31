# Eastóscadh Téacs & Deachtú

### Eastóscadh Téacs

Buail `Super + Ctrl + PrtScr` chun réigiún a roghnú ar an scáileán le haghaidh eastóscadh téacs. Ansin tiontóidh an tsamhail OCR foinse oscailte tesseract an rogha sin go téacs go tapa agus cuirfidh sí ar an ngearrthaisce é. Ansin níl le déanamh agat ach `Super + V` a bhualadh chun greamú.

Is mór an chabhair é seo chun seoltaí a ghabháil as buntásca íomhánna nó uimhreacha gutháin atá leabaithe i gceannlínte suíomhanna gréasáin.

 ![text-extraction](images/text-extraction.webp)

### Deachtú

Ar shuiteálacha úra, is é [Superwhisper](https://superwhisper.com/) an t-inneall deachtúcháin réamhshocraithe, a úsáideann próiseáil scamall gan íoslódálacha samhlacha as líne. Roghnaigh Superwhisper nó [Voxtype](https://voxtype.io/) trí _Setup > Defaults > Dictation_ sa roghchlár Omarchy. Má roghnaíonn tú inneall, suiteálfar é más gá agus déanfar an réamhshocrú de le haghaidh deachtúcháin é. Lódálann Voxtype samhail bhunúsach Bhéarla a thógann 150MB; athraigh an tsamhail le `voxtype setup model` agus socruithe eile trí `~/.config/voxtype/config.toml`. Osclaíonn Superwhisper a shocruithe chun próiseáil scamall nó próiseáil áitiúil a roghnú, agus coinníonn OPR an feidhmchlár cothrom le dáta.

Deachtaíonn tú trí `Right Alt` a choinneáil síos, nó trí scoránú le `Alt + Space`, agus beidh an téacs deachtaithe le feiceáil sa limistéar ionchuir atá i bhfócas. Úsáideann na haicearraí seo an t-inneall roghnaithe. Tosaíonn Right Alt deachtú freisin nuair a úsáidtear é i gcorda modhnóra; úsáid Left Alt do na cordaí sin. Ar leagan amach méarchláir ina bhfuil Right Alt ina AltGr, úsáid `Alt + Space` chun AltGr a choinneáil ar fáil le haghaidh clóscríofa. Coinníonn suiteálacha ó sular tháinig Alt + Space chun bheith ina réamhshocrú `F9` le haghaidh brú-chun-labhairt agus `Super + Ctrl + X` le haghaidh scoránaithe, curtha le `~/.config/hypr/bindings.lua`; bain ansin iad chun na heochracha sin a thabhairt ar ais d'fheidhmchláir.

Oibríonn na haicearraí céanna le ceachtar inneall. Roghnaigh d'inneall trí Setup > Defaults > Dictation. Cumraíonn suiteálaí an innill é agus sábhálann sé an rogha. Rith `omarchy default dictation` chun a fheiceáil cé acu ceann a roghnaíodh. Sábháiltear an rogha i `~/.config/omarchy/defaults/dictation`. Roghnaíonn suiteálacha úra Superwhisper go huathoibríoch.

Lódálann Omarchy comhtháthú deisce an innill roghnaithe go huathoibríoch. Níl aon chumraíocht Superwhisper ag teastáil i `~/.config/hypr/`.

Is féidir le ceangail shaincheaptha agus scripteanna `omarchy dictation start`, `omarchy dictation stop`, agus `omarchy dictation toggle` a úsáid. Láimhseálann an t-inneall roghnaithe an taifeadadh agus an trascríobh. Má roghnaíonn tú Superwhisper, díchumasaítear a aicearra dúchasach coinneála agus socraítear a scorán dúchasach go `Ctrl + Alt + Space`, á choinneáil scartha ó eochracha taifeadta Omarchy. Teastaíonn ar a laghad aicearra taifeadta dúchasach amháin ó Superwhisper, agus fanann a aicearra cealaithe ar fáil.

Is féidir le hinnill bhreise comhtháthú gan Omarchy a athrú. Cuir ar fáil comhad inrite darb ainm `omarchy-dictation-<backend>` ar PATH a ghlacann le `start`, `stop`, agus `toggle` agus a fhilleann go pras, le stádas neamhnialasach ar theip. Cumraíonn a shuiteálaí an soláthraí agus glaonn sé `omarchy-dictation-use <backend>` tar éis suiteáil rathúil. Stopann sé seo an t-inneall roimhe seo agus sábhálann sé an rogha go hatómach; ní mór do `stop` éirí leis nuair atá an soláthraí díomhaoin nó dorochtana. Úsáideann ainmneacha inneall litreacha cás íochtair, digití, agus fleiscíní. Cuir ar fáil `omarchy-install-dictation-<backend>` le haghaidh suiteála; seolann `omarchy default dictation <backend>` é. Cuir iontráil roghchláir Defaults leis trí shíneadh roghchláir Omarchy chun an roghnóir sin a ghlaoch. Is féidir le comhtháthú deisce roghnach a bheith i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
