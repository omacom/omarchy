# Fuasgladh dhuilgheadasan

### Bhris mi an siostam agam le ùrachadh!

An toiseach, feuch an [till thu an siostam agad](47-system-snapshots.md) chun an tionndaidh mus do rinn thu an t-ùrachadh mu dheireadh. Mura obraich sin, cleachd `omarchy-debug` gus an duilgheadas agad a cho-roinneadh air #omarchy-help air an Discord. Agus ma dh'fhàilligeas sin uile, 's urrainn dhut na rèiteachaidhean is na pacaidean bunaiteach ath-stàladh le `omarchy-reinstall`.

### Carson a tha cuid a dh'aplacaidean cho mòr air an sgrìn agam?

Tha Omarchy a' gabhail ris gu bheil sgrìn dùmhlachd àrd 2x agad, agus feumaidh sin `GDK_SCALE` a shuidheachadh gu 2 ann an `~/.config/hypr/monitors.lua`. Ach ma tha sgrìn 1x agad, 's urrainn dhut `local omarchy_gdk_scale = 2` atharrachadh gu 1 (agus aplacaid sam bith a tha ro mhòr ath-thòiseachadh an uairsin). Faic [an leabhar-mìneachaidh mu mhonatairean](33-monitors.md).

Airson Spotify, 's urrainn dhut `Ctrl + Minus` a chleachdadh gus an eadar-aghaidh a dhèanamh nas lugha (agus `Ctrl + Plus` gus a dhèanamh nas motha).

### Sguir an Wi-Fi, am Bluetooth, an fhuaim no am pada-suathaidh agam a dh'obair

Mus ath-thòisich thu, feuch is ath-thòisich am fo-shiostam a tha ri olc leis fhèin. Tha Wi-Fi, Bluetooth, Fuaim agus Pada-suathaidh ann an _Ùraich > Bathar-cruaidh_ ann an clàr-taice Omarchy, agus ma thèid fear dhiubh sin ath-luchdadh, fuasglaidh sin a' mhòr-chuid de shuidheachaidhean "bha e ag obair còig mionaidean air ais" — headset Bluetooth nach ceangail a-rithist, pada-suathaidh a stad gu tur an dèidh a chur na dhàil, fuaim a chaidh à sealladh nuair a dhì-phlugaich thu monatair.

### Carson nach eil na glaodhairean taobh a-muigh agam a' cluich?

Is dòcha nach eil iad air an suidheachadh mar am prìomh às-chur. Briog air ìomhaigheag a' ghlaodhaire air taobh deas a' bhàir, agus fosglaidh e priob-uinneag àirde na fuaime far an tagh thu an t-uidheam às-chuir (agus far am measgaich thu àirde na fuaime aig gach aplacaid cuideachd).

### Chan eil glaodhairean an laptop agam a' fuaimneachadh ceart

Air cuid a laptops, cuiridh Omarchy gleusadh glaodhaire an sàs gu fèin-obrachail a cheartaicheas freagairt tricead nan glaodhairean togte. Innsidh `omarchy audio tuning status` dhut a bheil fear an gnìomh air an inneal agad, agus cuiridh `omarchy audio tuning off` dheth e mas fheàrr leat na glaodhairean a chluinntinn amh.

### Carson nach urrainn dhomh clàradh a-steach no sudo a chleachdadh leis an fhacal-fhaire agam?

Is dòcha gun do sgrìobh thu ceàrr e cus thursan agus gun deach do ghlasadh a-mach. Ma tha seo a' tachairt air an sgrìn-ghlasaidh, 's urrainn dhut `CTRL + ALT + F2` a bhrùthadh gus TTY ùr a thòiseachadh far an clàraich thu a-steach mar root, agus `faillock --reset --user [d-ainm-cleachdaiche]` a ruith an uairsin. Ath-shuidhichidh sin a' ghlasadh-a-mach, agus bidh thu deiseil.

### Carson nach eil iarrtasan ùghdarrachaidh 1Password airson 1Password SSH Agent / CLI a' nochdadh?

Faodaidh seo tachairt air sgàth 2 adhbhar:

Airson 's gun nochd an t-iarrtas aontachaidh beairteach, feumaidh Settings > Advanced > Use Hardware Acceleration a bhith air. _An aire: Feumaidh tu ath-thòiseachadh mus obraich seo._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

No mura do chuir thu 1Password gu dol on a bhùt thu, cha nochd an t-iarrtas.
