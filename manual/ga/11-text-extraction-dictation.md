# Eastóscadh Téacs & Deachtú

### Eastóscadh Téacs

Brúigh `Super + Ctrl + PrtScr` chun réigiún a roghnú ar an scáileán le haghaidh eastóscadh téacs. Ansin tiontóidh samhail OCR foinse oscailte tesseract an roghnúchán sin go téacs go tapa agus cuirfidh sí ar an gearrthaisce é. Ansin níl le déanamh agat ach `Super + V` a bhrú chun é a ghreamú.

Tá sé seo an-chabhrach chun seoltaí a ghabháil as buntásca íomhánna nó uimhreacha gutháin atá leabaithe i gceannlínte suíomhanna gréasáin.

 ![text-extraction](images/text-extraction.webp)

### Deachtú

Ar shuiteálacha úra, is é [Superwhisper](https://superwhisper.com/) an t-inneall deachtaithe réamhshocraithe, agus é ag úsáid próiseála néil gan íoslódálacha samhlacha as líne. Roghnaigh Superwhisper, [Voxtype](https://voxtype.io/), nó [Hex](https://anoma.ly/hex/) trí _Setup > Defaults > Dictation_ i roghchlár Omarchy. Má roghnaítear inneall, suiteálfar é más gá agus déanfar an réamhshocrú deachtaithe de. Lódálann Voxtype bunmhúnla Béarla a thógann 150MB; athraigh an tsamhail le `voxtype setup model` agus socruithe eile trí `~/.config/voxtype/config.toml`. Osclaíonn Superwhisper a shocruithe chun próiseáil néil nó áitiúil a roghnú, agus coinníonn OPR an feidhmchlár cothrom le dáta. Íoslódálann Hex a mhúnla cainte ar an ngléas le linn na suiteála agus ritheann sé mar sheirbhís úsáideora `hex.service`; oscail a fhuinneog ó dheilbhín tráchtaire an bharra nó trí `hex` a rith chun an tsamhail agus socruithe eile a athrú.

Deachtaíonn tú trí `Right Alt` a choinneáil síos, nó trí athrú le `Alt + Space`, agus beidh an téacs deachtaithe le feiceáil sa limistéar ionchuir atá i bhfócas. Úsáideann na haicearraí seo an t-inneall roghnaithe. Tosaíonn Right Alt deachtú freisin nuair a úsáidtear é i gcorda modhnóra; úsáid Left Alt do na cordaí sin. Ar leagan amach méarchláir ina bhfuil Right Alt ina AltGr, úsáid `Alt + Space` chun AltGr a choinneáil ar fáil le haghaidh clóscríofa. Coinníonn suiteálacha ó sular tháinig Alt + Space chun bheith ina réamhshocrú `F9` le haghaidh brú-chun-caint agus `Super + Ctrl + X` chun athrú, curtha le `~/.config/hypr/bindings.lua`; bain ansin iad chun na heochracha sin a thabhairt ar ais d'fheidhmchláir.

Oibríonn na haicearraí céanna le gach inneall. Roghnaigh d'inneall trí Setup > Defaults > Dictation. Cumraíonn suiteálaí an innill é agus sábhálann sé an roghnúchán. Rith `omarchy default dictation` chun a fheiceáil cé acu ceann atá roghnaithe. Sábháiltear an roghnúchán in `~/.config/omarchy/defaults/dictation`. Roghnaíonn suiteálacha úra Superwhisper go huathoibríoch.

Lódálann Omarchy comhtháthú deisce an innill roghnaithe go huathoibríoch. Ní theastaíonn aon chumraíocht Superwhisper in `~/.config/hypr/`.

Is féidir le ceangail agus scripteanna saincheaptha `omarchy dictation start`, `omarchy dictation stop`, agus `omarchy dictation toggle` a úsáid. Láimhseálann an t-inneall roghnaithe an taifeadadh agus an trascríobh. Má roghnaítear Superwhisper, díchumasaítear a aicearra dúchasach coinneála agus socraítear a athrú dúchasach go `Ctrl + Alt + Space`, á choinneáil ar leithligh ó eochracha taifeadta Omarchy. Teastaíonn ar a laghad aicearra taifeadta dúchasach amháin ó Superwhisper, agus fanann a aicearra cealaithe ar fáil.

Is féidir le hinnill bhreise comhtháthú gan Omarchy a athrú. Cuir ar fáil comhad inrite darb ainm `omarchy-dictation-<backend>` ar PATH a ghlacann le `start`, `stop`, agus `toggle` agus a fhilleann go pras, le stádas neamh-nialasach ar theip. Cumraíonn a shuiteálaí an soláthraí agus glaonn sé `omarchy-dictation-use <backend>` tar éis suiteála rathúla. Stopann sé seo an t-inneall roimhe seo agus sábhálann sé an roghnúchán go hatamach; caithfidh `stop` éirí leis nuair atá an soláthraí díomhaoin nó neamh-infhaighte. Úsáideann ainmneacha inneall litreacha beaga, digití, agus fleiscíní. Cuir `omarchy-install-dictation-<backend>` ar fáil don suiteáil; seolann `omarchy default dictation <backend>` é. Cuir iontráil roghchláir Defaults leis trí shíneadh roghchláir Omarchy chun an roghnóir sin a ghlaoch. Is féidir le comhtháthú deisce roghnach a bheith in `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
