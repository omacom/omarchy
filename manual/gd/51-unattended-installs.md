# Stàlaidhean gun neach an làthair

'S urrainn do dh'ISO Omarchy e fhèin a stàladh gun duine aig a' mheur-chlàr. Ma lorgas an stàlaichear dàrna draibh air a bheil an leubail `cidata` agus na faidhlichean rèiteachaidh aige air, dèanaidh e lethbhreac dhiubh, leumaidh e thar an draoidh suidheachaidh gu tur, agus ath-thòisichidh e leis fhèin dhan t-siostam chrìochnaichte. Chan fheum thu togail ISO shònraichte no innteart a bharrachd ann an clàr-taice a' bhùtaidh — gun draibh mar sin ceangailte, chan atharraich càil agus gheibh thu an draoidh àbhaisteach.

Tha seo a' dèanamh Omarchy air leth math mar dhealbh bunaiteach airson àrainneachdan leasachaidh a thilgeas tu air falbh: cruthaich VM ann am Proxmox no le Packer, bùt e, coisich air falbh, ceangail le SSH. 'S e `cidata` an leubail `NoCloud` aig cloud-init, mar sin tha fios aig na h-innealan biortalachaidh cumanta uile mar a cheanglas iad draibh mar sin mu thràth.

## Na faidhlichean rèiteachaidh

'S iad na faidhlichean dìreach na sgrìobhas draoidh an stàlaicheir fhèin, mar sin 's e an dòigh as fhasa air seata tòiseachaidh fhaighinn aon stàladh eadar-ghnìomhach a ruith (ann an VM, can) agus lethbhreac a dhèanamh de na sgrìobh e ann an `/root`:

| Faidhle | Riatanach | Adhbhar |
|------|----------|---------|
| `user_configuration.json` | Tha | Diosga, ainm an òstair, roinn-tìde, meur-chlàr |
| `user_credentials.json` | Tha | Ainm-cleachdaiche is hais an fhacail-fhaire |
| `user_encrypt_installation.txt` | Chan eil | `true` nuair a bhios bloca `disk_encryption` san rèiteachadh |
| `authorized_keys` | Chan eil | Iuchraichean poblach SSH, tè air gach loidhne |
| `tailscale_authkey` | Chan eil | Iuchair dhearbhaidh Tailscale airson a dhol a-steach dhan tailnet agad aig a' chiad bhùtadh |

Gin hais an fhacail-fhaire airson `user_credentials.json` le `openssl passwd -6 "yourpassword"`.

Chan eil an t-ainm is am post-d airson gealltanasan git nam pàirt dhen stàladh. Suidhich iad nuair a bhios an t-inneal na sheasamh, thar SSH mar eisimpleir, le `omarchy setup git --name "Jane Doe" --email jane@example.com`.

'S urrainn dhut cuideachd faidhle falamh air a bheil `defer-provisioning` a chur ann an àite `user_credentials.json`. Ruithidh sin an aon [stàladh ullachaidh airson sealbhadair eile](02-getting-started.md) as urrainn dhut a chur gu dol gu h-eadar-ghnìomhach: stàlaichidh an t-inneal gun fhiosrachadh pearsanta sam bith, agus taghaidh cò sam bith a bhùtas e an toiseach am meur-chlàr aca is cruthaichidh iad an cleachdaiche aca. Sin am modh airson innealan dealbhachaidh, far nach bu chòir teisteanasan duine sam bith a bhith air an draibh idir.

## Inntrigeadh SSH

Nuair a bhios `authorized_keys` ann, suidhichidh an stàladh na h-iuchraichean mar `~/.ssh/authorized_keys` a' chleachdaiche, cuiridh e `sshd` an comas, agus fosglaidh e an cailbhe-teine air a shon. (Thig stàladh Omarchy àbhaisteach le openssh agus an t-seirbheis à comas is am port dùinte, mar sin cha ghabhadh inneal gun neach an làthair a ruigsinn air dhòigh eile.) Chan eil an stàladh ach a' cur nan iuchraichean agad ris — cha lasaich e gin de roghainnean dearbhaidh eile an daemon SSH.

Nuair a bhios `tailscale_authkey` ann, thèid an t-inneal a-steach dhan tailnet agad aig a' chiad bhùtadh na àite: thèid Tailscale a stàladh o na pacaidean a tha an lùib an ISO, ceadaichidh an cailbhe-teine eadar-aghaidh an tailnet, agus ruithidh obair sa chùlaibh an ceangal cho luath 's a bhios lìonra aig an inneal dha-rìribh, a' feuchainn a-rithist gus an soirbhich leis. Cleachd iuchair ath-chleachdail ro-ùghdarraichte ach an urrainn do dh'aon dealbh draibh frithealadh do dh'iomadh inneal.

## An draibh cidata a thogail

Obraichidh siostam-fhaidhlichean sam bith leis an leubail cheart. 'S e ISO bheag bhìodach an dòigh fhurasta:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

An uairsin, ceangail ris an VM e ri taobh ISO Omarchy. Seo eisimpleir Proxmox slàn:

```bash
qm create 101 --name my-omarchy \
  --bios ovmf --machine q35 --cpu host --cores 4 --memory 8192 \
  --ostype l26 --scsihw virtio-scsi-single \
  --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=0 \
  --scsi0 local-lvm:40,discard=on,iothread=1 \
  --net0 virtio,bridge=vmbr0 --vga virtio --serial0 socket \
  --ide2 local:iso/omarchy.iso,media=cdrom \
  --ide3 local:iso/cidata.iso,media=cdrom \
  --boot order='scsi0;ide2'

qm start 101
```

Tha òrdugh a' bhùtaidh a' cur an diosga an toiseach a dh'aona-ghnothach: tuitidh an diosga falamh troimhe chun an ISO aig a' chiad bhùtadh, agus bùtaidh an siostam stàlaichte on diosga gu bràth tuilleadh.

## Dà rabhadh

Chan eil stàlaidhean crioptaichte gun neach an làthair gu tur gun neach an làthair — feumaidh cuideigin abairt-fhaire LUKS a sgrìobhadh aig a' chiad bhùtadh fhathast. Agus tha an abairt-fhaire sin ann an teacsa lom sa bhloca `disk_encryption` ann an `user_configuration.json`, mar sin dèilig ri draibh cidata a chaidh a thogail o stàladh crioptaichte mar an rùn-dìomhair a th' ann.
