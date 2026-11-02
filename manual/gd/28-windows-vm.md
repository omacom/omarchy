# VM Windows

Tha Omarchy a' tabhann dòigh fhurasta air Windows a ruith tro VM Docker. 'S urrainn dhut a stàladh le _Stàlaich > Windows_ o chlàr-taice Omarchy (`Super + Space`).

Feumaidh an t-inneal agad brìgheachadh KVM airson seo, rud a th' aig a' mhòr-chuid — ach uaireannan bidh e air a chur dheth sa BIOS, agus innsidh an stàlaichear dhut ma tha. Bidh feum agad air àite air an diosga cuideachd: ge b' e dè bheir thu do Windows, agus mu 10GB a bharrachd airson an ìomhaigh fhèin.

Faighnichidh an stàlaichear dè na tha thu airson a thoirt seachad de RAM, de choraichean CPU agus de dhiosga (64GB no barrachd, sin an ìre as ìsle a tha ciallach), agus an uairsin ainm-cleachdaiche is facal-faire Windows. Fàg iad bàn agus gheibh thu `docker` / `admin`. Bheir an luchdadh a-nuas greis — tha 10-15 mionaidean àbhaisteach — agus 's urrainn dhut sùil a chumail air an adhartas sa bhrabhsair aig `http://127.0.0.1:8006`. Iarraidh am brabhsair an aon ainm-cleachdaiche is facal-faire mus fhosgail e a' chonsoil.

 ![windows-vm](images/windows-vm.webp)

## Ga chleachdadh

Nuair a bhios e stàlaichte, tòisich _Windows_ o lòinsear nan aplacaidean. Tòisichidh sin am VM mur eil e a' ruith mu thràth agus ceanglaidh e thu thar RDP, air làn-sgrìn. Thoir 15-30 diog dha air tòiseachadh fuar.

Giùlainidh an seisean RDP fuaim, am micreofon agad agus stòr-bhòrd co-roinnte, mar sin obraichidh lethbhreac de theacsa eadar Linux is Windows gun dragh. Leanaidh an dùmhlachd-bhreacaidh an uinneag agad, agus bheir Omarchy sgèileadh an uidheim-taisbeanaidh agad troimhe, mar sin cha bhi e na bhrochan doilleir air sgrìn HiDPI.

Nuair a dhùineas tu uinneag RDP, thèid am VM a chur dheth gu fèin-obrachail. Nam b' fheàrr leat a fhàgail a' ruith — can gu bheil rudeigin ag obair air falbh an sin — tòisich e le `omarchy windows vm launch --keep-alive` na àite.

Tha an còrr dhe na h-uidheaman-smachd air an aon àithne:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Co-roinneadh fhaidhlichean

Tha am pasgan `~/Windows` sa phasgan dachaigh agad air a cho-roinneadh leis a' VM gu fèin-obrachail. Cuir faidhlichean an sin ma tha thu airson 's gum faigh Windows thuca. Chan fhaigh am VM gu pàirt sam bith eile dhen t-siostam-fhaidhlichean agad, mar sin tha thu sàbhailte o rud mì-chàilear sam bith air taobh Windows. Tha an diosga brìgheil aige fhèin ri fhaighinn aig `~/.windows`.

Fanaidh na slighean dachaigh eòlach sin air na siostaman-fhaidhlichean aca fhèin. Faodaidh iad cuideachd a bhith nan ceanglaichean samhlachail gu pasganan leatsa, rud a tha feumail nuair a tha an diosga brìgheil a' fuireach air draibh nas motha. Tomhaisidh an stàlaichear an t-àite saor air an t-siostam-fhaidhlichean sa bheil `~/.windows` dha-rìribh, chan ann air an t-siostam-fhaidhlichean sa bheil am pasgan dachaigh agad, mar as trice.

Cùm slighe an diosga agus an t-slighe cho-roinnte mar phasganan fa leth nach eil a' dol thar a chèile. Falmhaichidh an toirt air falbh pasgan an diosga a dh'aona-ghnothach ach glèidhidh e am pasgan co-roinnte. Dìreach mus sguab e às, nì Omarchy sgrùdadh cuibhreachaidh le crìoch-ùine agus diùltaidh e dad a thoirt air falbh ma ruitheas an sgrùdadh sin a-mach à ùine no mur urrainn dha dearbhadh gu bheil an dà chraobh air leth.

Mus tòisich am VM, fosglaidh is prìnichidh Omarchy an dà phasgan sin, agus an uairsin nì e bind-mount air na dearbh inodes phasgan air acraichean prìobhaideach gach cleachdaiche fo `/var/lib/omarchy/windows/mounts`. Chan fhaic Docker ach na h-acraichean sin, a tha fo dhìon root. Glèidhidh seo ionadan diosga gnàthaichte agus aig an aon àm cuiridh e casg air pròiseas eile a tha a' ruith mar thusa slighe a chaidh a sgrùdadh a mhalairt mus cleachd an soitheach le sochairean i. Thèid pasganan diosga is co-roinnte a th' ann mu thràth a theannachadh gu modh `0700` rè an imrich ach nach urrainn do chunntasan ionadail eile brabhsadh tron t-susbaint aca.

Tha puirt a' VM ceangailte ri localhost a-mhàin, mar sin chan urrainn do rud sam bith air an lìonra agad an t-inneal Windows a ruigsinn. Feumaidh a' chonsoil-lìn cuideachd an t-ainm-cleachdaiche is am facal-faire Windows a chaidh a rèiteachadh, rud a chuireas casg air cunntas ionadail eile am VM a stiùireadh tro phort 8006.

## Crìochan is ceadachas

Chan eil GPU passthrough aig an t-suidheachadh seo, mar sin chan eil e freagarrach airson geamachd no deasachadh video. 'S e dòigh sgoinneil a th' ann airson Microsoft Office a ruith no ge b' e dè eile a dh'fheumas tu gu cinnteach.

'S e Windows 11 Pro gun ghnìomhachadh an tionndadh a thèid a stàladh. Bidh feum agad air an iuchair cheadachais agad fhèin airson na gleusan glaiste a chleachdadh.

Ma thàinig an coimpiutair seo le Windows, tha an iuchair OEM fhathast sa bhathar-daingeann fiù 's às dèidh Omarchy a stàladh. Clò-bhuail i le `omarchy windows key`. Tha an iuchair sin ceangailte ris an inneal seo — gnìomhaichidh i Windows a chaidh ath-stàladh air a' bhathar-chruaidh seo, ach mar as trice cha ghnìomhaich i am VM.

'S urrainn dhut riarachadh nan goireasan atharrachadh às dèidh làimhe le `omarchy-windows-vm install` a ruith a-rithist; ath-sgrìobhaidh seo rèiteachadh a' VM o na freagairtean agad. Tha am faidhle compose fhèin a-nis a' fuireach aig `/var/lib/omarchy/windows/docker-compose.yml` agus 's ann le root a tha e — tha sin a dh'aona-ghnothach, ach nach urrainn do phròiseas a tha a' ruith mar thusa ath-sgrìobhadh agus toirt air an tòiseachadh le sochairean an diosga gu lèir agad a mhunntachadh san t-soitheach. Ma dh'fheumas tu a dheasachadh de làimh (mar eisimpleir airson uidheam USB a mhunntachadh), deasaich e le `sudo` agus faic gach roghainn air [pròiseact Dockur Windows](https://github.com/dockur/windows).

Airson cuidhteas fhaighinn dhen rud gu lèir, cleachd _Thoir air falbh > Windows_ o chlàr-taice Omarchy. Sguabaidh sin às diosga a' VM agus an dàta aige gu lèir, mar sin dèan cinnteach gu bheil rud sam bith a tha cudromach dhut air a thoirt a-mach à `~/Windows` an toiseach.
