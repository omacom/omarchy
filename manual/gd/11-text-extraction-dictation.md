# Às-tarraing teacsa & deachdadh

### Às-tarraing teacsa

Brùth `Super + Ctrl + PrtScr` gus raon dhen sgrìn a thaghadh airson às-tarraing teacsa. Iompaichidh am modail OCR tesseract, a tha na bhathar-bog le còd fosgailte, an taghadh sin gu teacsa gu luath agus cuiridh e air an stòr-bhòrd e. An uairsin cha leig thu leas ach `Super + V` a bhrùthadh gus a chur ann.

Tha seo glè fheumail airson seòlaidhean a ghlacadh à bunan-duilleige ann an dealbhan no àireamhan fòn a tha falaichte ann an ceann-naidheachdan làraich-lìn.

 ![text-extraction](images/text-extraction.webp)

### Deachdadh

Air stàlaidhean ùra, is e [Superwhisper](https://superwhisper.com/) an backend deachdaidh bunaiteach, a' cleachdadh pròiseasadh san neul gun mhodailean far loidhne a luchdadh a-nuas. Tagh Superwhisper no [Voxtype](https://voxtype.io/) le _Suidheachadh > Bun-roghainnean > Deachdadh_ ann an clàr-taice Omarchy. Ma thaghas tu backend, stàlaichidh sin e ma bhios feum air agus nì e am backend bunaiteach airson deachdadh dheth. Luchdaichidh Voxtype bun-mhodail Beurla a ghabhas 150MB; atharraich am modail le `voxtype setup model` agus roghainnean eile le `~/.config/voxtype/config.toml`. Fosglaidh Superwhisper na roghainnean aige gus pròiseasadh san neul no gu h-ionadail a thaghadh, agus cumaidh OPR an aplacaid ùraichte.

Nì thu deachdadh le bhith a' cumail sìos `Right Alt` no `F9`, no le toglachadh le `Super + Ctrl + X`, agus nochdaidh an teacsa a dheachd thu san raon ion-chuir le fòcas. Cleachdaidh na h-ath-ghoiridean seo am backend a thagh thu. Tòisichidh Right Alt air deachdadh cuideachd nuair a chleachdas tu e ann an corda atharraichidh; cleachd Left Alt airson nan cordaichean sin. Air co-dhealbhachdan meur-chlàir far an e AltGr a th' ann an Right Alt, cleachd `F9` gus AltGr a chumail ri làimh airson sgrìobhadh.

Obraichidh na h-aon ath-ghoiridean leis an dàrna backend. Tagh am backend agad le Suidheachadh > Bun-roghainnean > Deachdadh. Rèitichidh stàlaichear a' bhackend e agus sàbhailidh e an taghadh. Ruith `omarchy default dictation` gus faicinn cò am fear a thagh thu. Thèid an taghadh a shàbhaladh ann an `~/.config/omarchy/defaults/dictation`. Taghaidh stàlaidhean ùra Superwhisper gu fèin-obrachail.

Luchdaichidh Omarchy amalachadh deasga a' bhackend a thagh thu gu fèin-obrachail. Chan fheum thu rèiteachadh Superwhisper sam bith ann an `~/.config/hypr/`.

'S urrainn do cheanglaichean is sgriobtaichean gnàthaichte `omarchy dictation start`, `omarchy dictation stop` agus `omarchy dictation toggle` a chleachdadh. Làimhsichidh am backend a thagh thu an clàradh agus an tar-sgrìobhadh. Ma thaghas tu Superwhisper, cuiridh sin an ath-ghoirid cumail thùsail aige à comas agus suidhichidh e an toglachan tùsail aige gu `Alt + Space`, ach am bi e air leth o iuchraichean clàraidh Omarchy. Feumaidh Superwhisper co-dhiù aon ath-ghoirid clàraidh tùsail, agus bidh an ath-ghoirid sgur dheth aige ri làimh fhathast.

'S urrainn do bhackends eile amalachadh gun Omarchy atharrachadh. Solair faidhle so-ghnìomhaichte air a bheil `omarchy-dictation-<backend>` air PATH a ghabhas ri `start`, `stop` agus `toggle` agus a thilleas gu luath, le staid nach eil na neoni ma dh'fhàilligeas e. Rèitichidh an stàlaichear aige an solaraiche agus gairmidh e `omarchy-dictation-use <backend>` an dèidh suidheachadh soirbheachail. Cuiridh seo stad air a' bhackend roimhe agus sàbhailidh e an taghadh gu h-atamach; feumaidh `stop` soirbheachadh nuair a bhios an solaraiche na thàmh no nach eil e ri làimh. Cleachdaidh ainmean bhackends litrichean beaga, àireamhan agus tàthanan. Solair `omarchy-install-dictation-<backend>` airson an t-suidheachaidh; cuiridh `omarchy default dictation <backend>` gu dol e. Cuir innteart ris a' chlàr-taice Bun-roghainnean le leudachan air clàr-taice Omarchy gus an roghnaichear sin a ghairm. Faodaidh amalachadh deasga roghainneil a bhith ann an `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
