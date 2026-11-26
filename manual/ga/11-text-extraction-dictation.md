# Eastóscadh Téacs & Deachtú

### Eastóscadh Téacs

Buail `Super + Ctrl + PrtScr` chun réigiún a roghnú ar an scáileán le haghaidh eastóscadh téacs. Ansin tiontóidh an tsamhail OCR foinse oscailte tesseract an rogha sin go téacs go tapa agus cuirfidh sí ar an ngearrthaisce é. Ansin ní gá duit ach `Super + V` a bhualadh chun greamú.

Tá sé seo an-chabhrach chun seoltaí a ghabháil as buntásca íomhánna nó uimhreacha gutháin atá leabaithe i gceannlínte suíomhanna gréasáin.

 ![text-extraction](images/text-extraction.webp)

### Deachtú

Ar shuiteálacha úra, is é [Superwhisper](https://superwhisper.com/) an cúlra deachtaithe réamhshocraithe, ag úsáid próiseála néil gan íoslódálacha samhla as líne. Roghnaigh Superwhisper, [Voxtype](https://voxtype.io/), nó [Hex](https://anoma.ly/hex/) trí _Socrú > Réamhshocruithe > Deachtú_ sa roghchlár Omarchy. Nuair a roghnaíonn tú cúlra, suiteálfar é más gá agus déanfar é an réamhshocrú don deachtú. Lódálann Voxtype samhail bhunúsach Béarla a thógann 150MB; athraigh an tsamhail le `voxtype setup model` agus socruithe eile trí `~/.config/voxtype/config.toml`. Osclaíonn Superwhisper a shocruithe chun próiseáil néil nó áitiúil a roghnú, agus coinníonn OPR an feidhmchlár cothrom le dáta. Íoslódálann Hex a shamhail urlabhra ar an ngléas le linn an tsocraithe agus ritheann sé mar an tseirbhís úsáideora `hex.service`; oscail a fhuinneog ó dheilbhín tráidire an bharra nó trí `hex` a rith chun an tsamhail agus socruithe eile a athrú.

Deachtaíonn tú trí `Right Alt` a choinneáil síos, nó trí scoránú le `Alt + Space`, agus beidh an téacs deachtaithe le feiceáil sa limistéar ionchuir atá i bhfócas. Úsáideann na haicearraí seo an cúlra roghnaithe. Tosaíonn Right Alt an deachtú freisin nuair a úsáidtear é i gcorda modhnóra; úsáid Left Alt do na cordaí sin. Ar leagan amach méarchláir ina bhfuil Right Alt ina AltGr, lena n-áirítear nuair is leagan amach a aistríonn tú chuige é, coinnigh síos é leis féin ar feadh nóiméid chun deachtú; clóscríobhann AltGr a bhrúitear in éineacht le heochair eile a charachtar fós. Coinníonn suiteálacha ó sular tháinig `Alt + Space` chun bheith ina réamhshocrú `F9` le haghaidh brúigh-chun-labhairt agus `Super + Ctrl + X` chun scoránú, curtha le `~/.config/hypr/bindings.lua`, áit a nglacann an `Super + Ctrl + X` sin áit phainéal na ngníomhairí; bain ansin iad chun na heochracha sin a thabhairt ar ais d'fheidhmchláir agus don phainéal.

Oibríonn na haicearraí céanna le gach cúlra. Roghnaigh do chúlra trí Socrú > Réamhshocruithe > Deachtú. Cumraíonn suiteálaí an chúlra é agus sábhálann sé an rogha. Rith `omarchy default dictation` chun a fheiceáil cé acu ceann a roghnaíodh. Sábháiltear an rogha i `~/.config/omarchy/defaults/dictation`. Roghnaíonn suiteálacha úra Superwhisper go huathoibríoch.

Lódálann Omarchy comhtháthú deisce an chúlra roghnaithe go huathoibríoch. Níl aon chumraíocht Superwhisper ag teastáil i `~/.config/hypr/`.

Is féidir le ceangail agus scripteanna saincheaptha `omarchy dictation start`, `omarchy dictation stop`, agus `omarchy dictation toggle` a úsáid. Láimhseálann an cúlra roghnaithe an taifeadadh agus an trascríobh. Nuair a roghnaítear Superwhisper, díchumasaítear a aicearra dúchasach coinnigh-síos agus socraítear a scoránú dúchasach go `Ctrl + Alt + Space`, á choinneáil ar leith ó eochracha taifeadta Omarchy. Teastaíonn ar a laghad aicearra taifeadta dúchasach amháin ó Superwhisper, agus fanann a aicearra cealaithe ar fáil.

Is féidir le cúlraí breise comhtháthú gan Omarchy a athrú. Cuir ar fáil inrite darb ainm `omarchy-dictation-<backend>` ar PATH a ghlacann le `start`, `stop`, agus `toggle` agus a fhilleann go pras, le stádas neamhnialasach ar theip. Cumraíonn a shuiteálaí an soláthraí agus glaonn sé `omarchy-dictation-use <backend>` tar éis socrú rathúil. Stopann sé seo an cúlra roimhe agus sábhálann sé an rogha go hatómach; caithfidh `stop` éirí leis nuair atá an soláthraí díomhaoin nó neamh ar fáil. Úsáideann ainmneacha cúlra litreacha beaga, digití, agus fleiscíní. Cuir `omarchy-install-dictation-<backend>` ar fáil le haghaidh an tsocraithe; seolann `omarchy default dictation <backend>` é. Cuir iontráil sa roghchlár Réamhshocruithe leis trí bhreisíocht roghchláir Omarchy chun an roghnóir sin a ghlaoch. Is féidir le comhtháthú deisce roghnach a bheith ina chónaí i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
