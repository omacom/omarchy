# Ceistean cumanta

### Ciamar a leumas mi eadar co-dhealbhachdan meur-chlàir?

Deasaich am faidhle `~/.config/hypr/input.lua` agad agus cuir seo ris gus leum eadar co-dhealbhachdan le `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Seallaidh am bàr co-dhealbhachd làithreach a' mheur-chlàir agad gu fèin-obrachail nuair a bhios barrachd air aon cho-dhealbhachd air a rèiteachadh agad (agus 's urrainn dhut briogadh air gus leum eatarra cuideachd).

### Ciamar a dh'atharraicheas mi fòrmat an uaireadair gu 12 uair a thìde?

Dèan briogadh deas air an uaireadair sa bhàr gus cuairteachadh tro na fòrmatan cumanta, a' gabhail a-steach an fheadhainn 12 uair a thìde. 'S urrainn dhut am fòrmat a shuidheachadh gu dìreach cuideachd:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Seallaidh seo Sunday 10:55 AM.

### Ciamar a dh'atharraicheas mi an roinn-tìde agam?

Ruith _Ùraich > Roinn-tìde_ ann an clàr-taice Omarchy agus tagh tè on liosta. Ma tha an roinn-tìde ceart ach gun do ghluais an t-uaireadair fhèin, ath-thòisichidh _Ùraich > Àm_ sioncronachadh an ama dhut.

### Ciamar a dh'atharraicheas mi an DNS agam, a cho-roinneas mi an Wi-Fi agam, no a nì mi sgrùdadh air astar a' cheangail agam?

Tha iad sin uile ann an [lìonraidheachd](35-networking.md).

### Ciamar a nì mi sgrùdadh air cho luath 's a tha an diosga agam?

Tomhaisidh _Cuir gu dol > Deuchainn astair > Deuchainn astair an diosga_ astar leughaidh is sgrìobhaidh beò an draibh agad, no cleachd `omarchy disk speedtest` on tèirmineal.

### Carson nach urrainn dhomh clàradh a-steach dhan chunntas Google agam ann an Chromium?

Cha tig teisteanasan OAuth, a dh'iarras Google airson clàradh a-steach do chunntas, an lùib togail lom Chromium le bun-tùs fosgailte. Ruith _Stàlaich > Seirbheis > Cunntas Chromium_ ann an clàr-taice Omarchy gus an cur ris, ath-thòisich am brabhsair, agus obraichidh an clàradh a-steach.

### Ciamar a chuireas mi clò-bhualadair ris?

Tha clò-bhualadh air a shuidheachadh is a' ruith às a' bhogsa, agus cuiridh tu gach clò-bhualadair ris thu fhèin o _Print Settings_ ann an lòinsear nan aplacaidean (`Super + Space`).

Tagh _Add_, agus thoir mionaid dha airson coimhead: lorgar clò-bhualadair a tha air a phlugadh a-steach le USB, agus a' mhòr-chuid de chlò-bhualadairean lìonra, dhut. Mura bheil am fear agad air an liosta, tagh _Network Printer > Internet Printing Protocol (ipp)_ agus cuir a-steach an seòladh aige — innsidh sgrìn a' chlò-bhualadair fhèin no an duilleag-lìn aige dhut dè th' ann, mar as trice rudeigin mar `192.168.1.50` le ciudha `ipp/print`. Tairgidh _Forward_ draibhear an uairsin, agus obraichidh clò-bhualadair ùr-nodha as fheàrr air a' phròifil gun draibhear _IPP Everywhere_, ach bidh seann fhear ag iarraidh draibhear a' mhodail fhèin.

Dèan briogadh deas air clò-bhualadair agus tagh _Set as Default_ gus taghadh cò am fear a chleachdas na h-aplacaidean agad an toiseach, agus _Properties_ gus meud a' phàipeir, clò-bhualadh dà-thaobhach agus càileachd a shuidheachadh.

Tha lorg fèin-obrachail, far an nochd clò-bhualadairean air an lìonra gun an cur ris, air a chur dheth rè seal fhad 's a tha e 'ga ath-obrachadh, agus sin as adhbhar gur ann agadsa a tha a' chiad cheum gu h-àrd seach a bhith fèin-obrachail. Obraichidh clò-bhualadh gu faidhle PDF gun chlò-bhualadair sam bith idir.

### Ciamar a dh'atharraicheas mi far an tèid glacaidhean-sgrìn no clàraidhean na sgrìn a shàbhaladh?

Thèid glacaidhean-sgrìn a shàbhaladh ann an `~/Pictures/Screenshots` a thaobh bun-roghainn. Gus pasgan eile a chleachdadh, cuir seo ri faidhle fo `~/.config/uwsm/env.d/` (mar `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

'S urrainn dhut an aon rud a dhèanamh airson clàraidhean na sgrìn le `OMARCHY_SCREENRECORD_DIR`.

Cruthaichidh Omasnap am pasgan airson glacaidhean-sgrìn gu fèin-obrachail. Cruthaich am pasgan airson clàraidhean na sgrìn thu fhèin, agus ath-thòisich Omarchy an uairsin gus an tig an dàrna atharrachadh àrainneachd seo no an tèile gu buil.

### Ciamar a gheibh mi na glaodhairean + an camara-lìn ag obair air an Apple Studio Display agam?

Shaoileadh tu gun obraicheadh e uile dìreach le bhith a' plugadh a-steach USB C, ach gu mì-fhortanach chan ann mar sin a tha. 'S e am fuasgladh a lorg mi gus toirt air obrachadh gu earbsach [càball WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) a chleachdadh. An uairsin, obraichidh na glaodhairean is an camara-lìn gun chnap-starra.

Cuimhnich gu bheil smachd soilleireachd togte agad ann an Omarchy airson nan Apple Displays (an dà chuid Studio agus XDR) le putanan soilleireachd àbhaisteach a' mheur-chlàir.

### Ciamar a gheibh mi cuidhteas am bathar-bog a bharrachd uile?

Mura bheil thu ag iarraidh prògraman mar Obsidian no LibreOffice no gin dhen stuth eile a tha ro-stàlaichte, 's urrainn dhut an toirt air falbh gu furasta.

Ruith _Thoir air falbh > Pacaid_ gus gach pacaid a tha stàlaichte fhaicinn. An uairsin, 's urrainn dhut pacaid sam bith a tha thu airson toirt air falbh a thaghadh le Tab, agus tòiseachadh air na thagh thu uile a thoirt air falbh le Return.

Agus 's urrainn dhut _Thoir air falbh > Aplacaid-lìn_ a chleachdadh o chlàr-taice Omarchy gus aplacaid-lìn ro-stàlaichte sam bith nach eil thu ag iarraidh a thoirt air falbh.

No ruith _Thoir air falbh > Ro-stàlaidhean_ gus na rudan a bharrachd ro-stàlaichte uile a sguabadh a-mach — aplacaidean-lìn, TUIs agus aplacaidean roghainneil — ann an aon turas. Falbhaidh na hotkeys a chuir gu dol iad còmhla riutha, agus bidh sglèat glan de cheanglaichean iuchrach agad a lìonas tu leis an fheadhainn agad fhèin ann an `~/.config/hypr/bindings.lua`.

---

Airson mhearachdan is rudan briste, faic [an earrann mu fhuasgladh dhuilgheadasan](45-troubleshooting.md).
