# Lìonraidheachd

Tha an lìonraidheachd ann an Omarchy an urra ri NetworkManager, agus stiùirichidh tu e le ìomhaigheag an lìonra sa [bhàr gu h-àrd](05-the-top-bar.md) no le `Super + Ctrl + N`.

Nì am panail sin sganadh airson lìonraidhean Wi-Fi, seallaidh e neart nan siognail, agus ceanglaidh e. Chan fheum Ethernet càil idir — cuir a-steach e agus obraichidh e. Nam b' fheàrr leat fuireach san tèirmineal, bheir `nmtui` na h-aon uidheaman-smachd dhut, agus tha buidheann àitheantan `omarchy network` ann cuideachd.

## Do Wi-Fi a cho-roinneadh

Seach facal-faire fada a leughadh a-mach, ruith _Suidheachadh > Lìonra > Còd QR_ fhad 's a tha thu air Wi-Fi. Cuiridh sin còd QR air an sgrìn as urrainn do chamara fòn sam bith a sganadh gus a dhol dhan lìonra. 'S e seo fear dhe na rudan sin a chleachdas tu nas trice na shaoileadh tu nuair a bhios fios agad gu bheil e ann.

Ma tha feum agad air an fhacal-fhaire fhèin dha-rìribh, clò-bhuailidh `omarchy network password <interface>` e.

## DNS

Cleachdaidh Omarchy ge b' e dè an DNS a bheir an lìonra agad seachad thar DHCP. 'S urrainn dhut sgrìobhadh thairis air sin airson an inneil air fad fo _Suidheachadh > Lìonra > DNS_, far a bheil Cloudflare agus Google aon bhriogadh air falbh. Tagh _Gnàthaichte_ gus na frithealaichean agad fhèin a chur a-steach.

On tèirmineal, clò-bhuailidh `omarchy dns` an solaraiche làithreach agus suidhichidh `omarchy dns Cloudflare` fear.

## Bann an Wi-Fi a cheangal

Ma chuireas an rùtair agad 2.4GHz, 5GHz agus 6GHz air an aon ainm lìonraidh, bidh an laptop agad a' steigeadh ris an fhear shlaodach uaireannan. Seallaidh `omarchy network band` dè am bann air a bheil thu, agus ceanglaidh `omarchy network band 5` e. Cleachd `auto` gus leigeil leis taghadh a-rithist.

Ceanglaidh seo am bann seach puing-inntrigidh shònraichte, mar sin cumaidh tu a' gluasad eadar puingean-inntrigidh mar as àbhaist.

## Dè cho luath 's a tha e?

Tomhaisidh _Cuir gu dol > Deuchainn astair > Deuchainn astair an lìonra_ an fhìor astar luchdaidh suas is a-nuas agad le dà chlàr-tomhais. On tèirmineal, 's e `omarchy network speedtest down` no `up` a th' ann. Tomhaisidh e an aghaidh seirbheis Omarchy fhèin agus cha chunnt e ach na tar-chuir deuchainn aige fhèin. Faodaidh luchdaidhean a-nuas eile a bhith a' farpais airson leud-bann, ach cha tèid an cur ri toradh na deuchainn astair. (Tha deuchainn astair an diosga ri thaobh san aon chlàr-taice, ma tha thu a' tomhas a' chnap-starra eile.)

## A' chachaileith-theine

Tha a' chachaileith-theine air mar bhun-roghainn agus bacaidh i gach trafaig a tha a' tighinn a-steach, le aon eisgeachd: port 53317, ach an obraich [LocalSend](22-guis.md) sa bhad.

Tha SSH dheth gus an cuir thu air e le _Suidheachadh > Tèarainteachd > SSHD_, a thòisicheas an deamhan, a dh'fhosglas port 22 le cuingeachadh reat an aghaidh feachd bhrùideil, agus a dh'ùghdarraicheas iuchair. Tha Docker glaiste cuideachd, ach nach nochd soithichean iad fhèin dhan t-saoghal gun fhiosta. Faic [tèarainteachd](48-security.md) airson na sgeòil air fad.

## Tailscale

'S e VPN mogaill a th' ann an [Tailscale](https://tailscale.com/) a nì ruigsinn nan coimpiutairean is nam frithealaichean agad uile thar an eadar-lìn sìmplidh agus tèarainte. Stàlaich e le _Stàlaich > Seirbheis > Tailscale_.

Bheir sin panail Tailscale dhut sa bhàr, a cheanglas agus a dhì-cheanglas an tailnet, a dh'atharraicheas cunntasan, agus a thaghas nòd fàgail — nochdaidh na h-innealan agad fhèin agus roinnean Mullvad le chèile air an liosta. Brabhsaichidh e na h-innealan agad cuideachd, agus 's ann an-sin a tha Taildrop a' fuireach: tagh inneal agus brùth `s` gus faidhlichean a chur thuige, no `c`, `n` agus `d` gus lethbhreac a dhèanamh dhen IP, dhen ainm no dhen làn ainm DNS aige. 'S e `omarchy tailscale send <machine> [file...]` an co-ionnan san tèirmineal, agus thig faidhlichean a thèid a chur thugad gu tìr ann an `~/Downloads` gu fèin-obrachail. Fuirichidh am brath a dh'innseas gun do ràinig rudeigin gus am briog thu air gus fhosgladh no gus an leig thu seachad e, mar sin ma ruigeas faidhle fhad 's a tha thu air falbh on inneal, bidh e fhathast ann a' feitheamh ort nuair a thilleas tu.

Cuiridh a stàladh aplacaid-lìn ris cuideachd airson consoil rianachd Tailscale.

## Nuair a sguireas e a dh'obair

Mus ath-thòisich thu, feuch ris a' phìos a tha ri aimhreit ath-thòiseachadh leis fhèin. Tha Wi-Fi, Bluetooth, Fuaim agus Pada-suathaidh ann an _Ùraich > Bathar-cruaidh_, agus ma dh'ath-luchdaicheas tu fear dhiubh sin, rèitichidh sin a' mhòr-chuid de shuidheachaidhean "bha e ag obair o chionn còig mionaidean". Faic [fuasgladh dhuilgheadasan](45-troubleshooting.md).
