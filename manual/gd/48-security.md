# Tèarainteachd

Tha Omarchy a' gabhail tèarainteachd fìor dhà-rìribh. Tha seo gu bhith na shiostam-obrachaidh as urrainn dhut cleachdadh airson _Fìor Obair_ a dhèanamh san _Fhìor Shaoghal_. Far nach adhbharaich call laptop èiginn tèarainteachd. Mar sin, seo na nì sinn:

1. *Tha crioptachadh an diosga gu lèir riatanach*: 'S e seo an ceum as cudromaiche airson an dàta agad a dhìon gu corporra. Ma thèid an coimpiutair agad air chall no a ghoid, bidh an dàta air a chrioptachadh gu tur le LUKS (Linux Unified Key Setup) stannardach.
2. *Tha an cailbhe-teine an comas a thaobh bun-roghainn*: Thèid gach trafaig a-steach a bhacadh a thaobh bun-roghainn ach port 53317 airson [LocalSend](https://localsend.org/). Tha fiù 's ssh dheth gus an cuir thu air e le _Suidheachadh > Tèarainteachd > SSHD_, a dh'fhosglas port 22 (le crìoch astair an aghaidh brute force) mar phàirt dhen t-suidheachadh. Glasaidh sinn fiù 's inntrigeadh Docker leis an t-suidheachadh [ufw-docker](https://github.com/chaifeng/ufw-docker) gus nach tèid na soithichean agad fhoillseachadh dhan t-saoghal gun fhiosta.
3. *Tha na h-ùrachaidhean as ùire aig Arch an-còmhnaidh*: 'S e sgaoileadh leantainneach a th' ann an Arch, an distro air a bheil Omarchy stèidhichte. Tha seo a' ciallachadh gum bi leòntachd tèarainteachd sam bith a lorgar is a chàirear ann am pacaid sam bith ri fhaighinn airson stàladh a dh'aithghearr le `omarchy-update`. Mar sin, bidh thu an-còmhnaidh a' ruith nan tionndaidhean as ùire is as tèarainte dhen a h-uile càil.
4. *Cumaidh Omarchy a pacaidean is a sgàthan fhèin*: A thaobh bun-roghainn, chan earb Omarchy ach à pacaidean o ionadan-tasgaidh core/extra/multilib Arch fhèin agus o Omarchy Package Repository fhèin. 'S urrainn dhut bathar-bog a stàladh gu dìreach on AUR, ach cha dèan an stàladh bunaiteach sin — chan eil ach beagan stàlaidhean roghainneil, mar na brabhsairean treas-phàrtaidh, a' tarraing on AUR.
5. *Dìonaidh Cloudflare sinn o DDoS*: Tha bun-structar sgaoilidh Omarchy — na h-ISOs, pacaidean Omarchy, sgàthan Arch — air a dhìon air cùlaibh sgiath DDoS chumhachdach Cloudflare agus air òstadh air an CDN aca. Bheir seo dhuinn ruigsinneachd air leth math.

## Na faclan-faire agad atharrachadh

Tha dà fhacal-faire agad air stàladh crioptaichte: am fear a dh'fhuasglas an draibh aig àm a' bhùtaidh, agus am fear leis an clàraich thu a-steach is a chleachdas tu `sudo`. Nì an suidheachadh an aon rud dhiubh. Gabhaidh an dithis atharrachadh fo _Ùraich > Facal-faire_ ann an clàr-taice Omarchy — _Crioptachadh an diosga_ airson a' chiad fhir, _Cleachdaiche_ airson an dàrna fear. Nuair a dh'atharraicheas tu facal-faire an draibh, iarraidh e am fear làithreach an toiseach, mar sin cùm faisg ort e. Ma thèid bacadh air atharrachadh, ruith _Crioptachadh an diosga_ a-rithist: iarraidh e am facal-faire a dh'fhuasglas an draibh an-dràsta agus crìochnaichidh e an t-atharrachadh.

## Inneal a chleachd thu mu thràth a thoirt seachad

Ma tha thu a' toirt an inneil agad do chuideigin eile, cha leig thu leas a stàladh às ùr. Ruith _Suidheachadh > Ath-shuidhich an coimpiutair_ ann an clàr-taice Omarchy, sgrìobh `reset` airson dearbhadh, agus ath-thòisich. Suathaidh sin às gach cunntas cleachdaiche agus a h-uile càil ann an `/home`, tilgidh e air falbh gach pacaid is atharrachadh siostaim a rinn thu on stàladh, agus glanaidh e dearbh-aithne an inneil — ceanglaichean lìonra, iuchraichean an òstair, is an còrr. 'S e na thig an-àird an draoidh suidheachaidh on chiad bhùtadh, deiseil airson 's gun cuir an sealbhadair ùr a-steach an t-ainm, am facal-faire is facal-faire a' chrioptachaidh aca fhèin.

Obraichidh e le bhith ag aiseag an deilbh-làithrich bhunasaich a ghabhas an stàlaichear, mar sin chan eil e ri fhaighinn ach air innealan a chaidh a stàladh o ISO Omarchy. Agus air draibh gun chrioptachadh, 's e sguabadh às a th' ann an ath-shuidheachadh seach suathadh tèarainte, mar sin ma bha an dàta mothachail, dèan stàladh ùr na àite.

## Sudo gun fhacal-faire

Uaireannan bidh thu airson 's gun sguir `sudo` a dh'fhaighneachd, mar as trice nuair a bhios àidseant AI a' dèanamh greis mhòr de dh'obair siostaim dhut. Faighnichidh _Suidheachadh > Tèarainteachd > Sudo gun fhacal-faire_ dè cho fada 's a cheadaicheas e an t-inntrigeadh: **15 minutes**, **1 Hour**, **1 Day**, no **Permanently**. Nochdaidh ìomhaigheag rabhaidh dhearg ri taobh nan comharran eile air bàr a' chlàir-thaice fhad 's a bhios an t-inntrigeadh an gnìomh. Briog oirre no ruith an àithne a-rithist gus an t-inntrigeadh a chur dheth. 'S urrainn dhut cuideachd an àireamh de mhionaidean a thogras tu fhèin (eadar 1 agus 1440) a thoirt seachad le `omarchy-sudo-passwordless 30`, no `omarchy-sudo-passwordless permanent` a chleachdadh.

Falbhaidh an ùine air inntrigeadh le crìoch-ama gu fèin-obrachail, a' gabhail a-steach sa bhad an dèidh tilleadh à dàil a chaidh thar a' cheann-ama. Ma dh'ath-thòisicheas tu an coimpiutair, crìochnaichidh e tràth. Mairidh inntrigeadh buan thar ath-thòiseachaidhean is fanaidh e an comas gus an cuir thu à comas e.

Ma dh'ùraicheas no ma bheir thu air falbh pacaid roghainnean Omarchy, crìochnaichidh sin cead sealach sam bith mus atharraich an taic do dh'fhalbh na h-ùine aige. Ma dh'innseas an àithne mu mhearachd ùghdarrachaidh no glanaidh, rèitich i mus feuch thu ri cead eile a chur an comas; chan eil mearachd a' ciallachadh nach eil an t-inntrigeadh gun fhacal-faire an gnìomh.

Bi fosgailte mu dhèidhinn seo: fhad 's a bhios e air, 's urrainn do rud sam bith a ruitheas mar an cleachdaiche agad rud sam bith a dhèanamh mar root gun fhaighneachd. Sin an t-adhbhar air fad, agus sin an cunnart air fad cuideachd.

## Iuchraichean soidhnidh

'S e `40DFB630FF42BCFFB047046CF0134EE680CAC571` an iuchair phoblach airson gach soidhneadh ISO agus pacaid ionad-tasgaidh Omarchy ([dearbh e air openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Tha seo cuideachd sa phacaid `omarchy/omarchy-keyring`, agus thèid a cleachdadh gus ùrachadh sam bith a dh'fhaodadh a thighinn a sgaoileadh gun bhriseadh.

Gheibh thu an soidhneadh airson sgaoileadh ISO sam bith le bhith a' cur `.sig` ris an URL aige, mar `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
