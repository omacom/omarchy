# Ùrachaidhean

Cumaidh tu Omarchy is na pacaidean agad ris an latha le _Ùraich > Omarchy_ ann an clàr-taice Omarchy (`Super + Space`).

Tha Omarchy fhèin air a stàladh mar phacaidean pacman àbhaisteach o [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), mar sin stàlaichidh ùrachadh [an sgaoileadh Omarchy as ùire](https://github.com/omacom/omarchy/releases), ruithidh e imrichean sam bith a tha a' feitheamh gus an siostam agad a shioncronachadh leis an fheadhainn as ùire, agus ùraichidh e pacaidean an t-siostaim uile o [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) agus [AUR](https://aur.archlinux.org/) (ma stàlaich thu pacaidean AUR sam bith).

Nuair a thig sgaoilidhean ùra a-mach, nochdaidh ìomhaigheag saighde cuairteig air taobh deas an uaireadair agad. Briog oirre agus tòisichidh am pròiseas ùrachaidh.

![update-available](images/update-available.webp)

### Ceithir seanailean

Thèid Omarchy ùrachadh air ceithir seanailean: Seasmhach (stable), RC, Edge agus Dev. Tòisichidh stàlaidhean ùra air an t-seanail Seasmhach, a leanas na [sgaoilidhean oifigeil](https://github.com/omacom/omarchy/releases/), cho math ri [sgàthan Arch Omarchy seasmhach](https://github.com/omacom-io/omarchy-mirror) a tha mìos air dheireadh air an fheadhainn as ùire, ach an urrainn dhuinn mì-cho-chòrdalachdan ùra sam bith a ghlacadh a dh'fheumas atharraichean rèiteachaidh mus adhbharaich iad duilgheadasan do dhaoine.

Ach ma bu toil leat cuideachadh leis na duilgheadasan sin a lorg, 's urrainn dhut ruith air an t-seanail Edge. Cumaidh sin na pacaidean Omarchy agad a' leantainn nan togalach leasachaidh as ùire, agus leigidh e leat ùrachadh gu na pacaidean Arch as ùire cho luath 's a bhios iad ri fhaighinn. Cha bu chòir dhut seo a dhèanamh ach ma tha eòlas agad air Linux, agus fios agad mar a gheibh thu siostam air ais aig a bheil duilgheadasan.

Ro sgaoileadh mòr ùr sam bith, nì sinn an dearbhadh deireannach leis an t-seanail RC. Ma tha ùidh agad cuideachadh leis an lìomhadh dheireannach, thig a chèilidh oirnn ann an #omarchy-release-candidates air an Discord.

Mu dheireadh, tha an t-seanail Dev ann, a cheanglas Omarchy gu dìreach ri git checkout dhen chòd tùsail ann an `~/omarchy`, còmhla ris na pacaidean Edge. Cha bu chòir dhut an t-seanail seo a chleachdadh ach mas e cleachdaiche Linux eòlach a th' annad, ag obair gu dìreach air Omarchy, agus deònach briseadh fhulang.

'S urrainn dhut leum eadar seanailean le _Ùraich > Seanail_ o chlàr-taice Omarchy (no `omarchy-channel-set` san tèirmineal).

### Ag atharrachadh nan eitean

Bùtaichidh Omarchy an eitean `linux-omarchy` aige fhèin, ach 's urrainn dhut eiteanan eile a chumail stàlaichte ri thaobh, mar an eitean `linux` àbhaisteach aig Arch no togalach deuchainneach a tha thu a' feuchainn. Nuair a bhios barrachd air aon ann, seallaidh _Ùraich > Eitean_ ann an clàr-taice Omarchy liosta dhiubh le comharra ri taobh an fhir a bhùtas gu bunaiteach. Tagh fear eile, cuir a-steach am facal-faire agad aon turas, agus bùtaichidh e às dèidh an ath ath-thòiseachaidh. Fanaidh na h-eiteanan eile ann an clàr-taice a' bhùtaidh, mar sin 's urrainn dhut fear a thaghadh de làimh fhathast ma bheir am bun-roghainn ùr trioblaid dhut. San tèirmineal, 's e `omarchy-kernel` a sheallas am bun-roghainn làithreach, `omarchy-kernel list` a sheallas na tha stàlaichte, agus `omarchy-kernel set <kernel>` airson atharrachadh.

### Ùrachaidhean bathair-dhaingnich

Chan e na pacaidean agad an aon rud a dh'fhàsas seann-fhasanta. Bidh iomadh laptop is uidheam-taoibh a' cur bathar-daingeann BIOS, SSD is dock tro Linux Vendor Firmware Service, agus faighnichidh is stàlaichidh _Ùraich > Bathar-daingeann_ ann an clàr-taice Omarchy ge b' e dè a tha a' feitheamh airson a' bhathair-chruaidh agad. Stàlaichidh e `fwupd` a' chiad turas a ruitheas tu e. Chan urrainnear tòrr bathair-dhaingnich a sgrìobhadh ach rè ath-thòiseachaidh, mar sin na cuireadh e iongnadh ort ma thèid fear iarraidh ort.

### Rabhadh mu ùrachaidhean dìreach le pacman/yay

Ma tha thu eòlach air Arch mu thràth, dh'fhaoidte gum biodh tu airson `pacman -Syu` no `yay -Syu` a ruith thu fhèin, ach ma nì thu sin, caillidh tu an dealbh-chlàir, na h-imrichean agus na h-ùrachaidhean rèiteachaidh a ruitheas Omarchy còmhla ri pacaidean ùra. Sin as adhbhar gun cuir Omarchy stad air àrdachadh siostaim dìreach agus gun seall e `omarchy update` dhut na àite. (Ma tha thu dha-rìribh eòlach air na tha thu a' dèanamh, innsidh an geàrd dhut mar a thèid thu seachad air airson aon ghluasad.)

### A' tilleadh o dhroch ùrachaidhean

Ma bhios duilgheadas agad uair sam bith às dèidh ùrachaidh, 's urrainn dhut an siostam agad a thilleadh dhan dealbh-chlàir a chaidh a ghabhail ron ùrachadh. Dìreach ath-thòisich agus tagh an dealbh-chlàir o mus do thòisich thu an t-ùrachadh ann an clàr-taice luchdadh a' bhùtaidh.

![bootloader](images/bootloader.webp)

Ma chaidh na faidhlichean rèiteachaidh agad a thruailleadh air dòigh air choreigin, 's urrainn dhut Omarchy ath-stàladh cuideachd le `omarchy reinstall` san tèirmineal. Ath-stàlaichidh seo pacaidean bunaiteach Omarchy uile, cuiridh e air an t-seanail Seasmhach thu agus ìslichidh e pacaidean sam bith a tha ro ùr, agus ath-shuidhichidh e na faidhlichean rèiteachaidh uile. Thoir an aire gun tèid sgrìobhadh thairis air gach atharrachadh rèiteachaidh a rinn thu fhèin air bun-roghainnean Omarchy le seo!
