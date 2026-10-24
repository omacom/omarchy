# Suiteálacha gan Freastal

Is féidir le ISO Omarchy é féin a shuiteáil gan aon duine ag an méarchlár. Má aimsíonn an suiteálaí an dara tiomáint lipéadaithe `cidata` a iompraíonn a chomhaid chumraíochta, cóipeálann sé amach iad, scipéann sé an treoraí socraithe go hiomlán, agus atosaíonn sé isteach sa chóras críochnaithe leis féin. Gan aon tógáil speisialta ISO, gan aon iontráil bhreise sa roghchlár tosaithe — gan aon tiomáint mar sin ceangailte, ní athraíonn aon rud agus faigheann tú an gnáth-threoraí.

Déanann sé seo Omarchy iontach mar bhuníomhá do thimpeallachtaí forbartha indiúscartha: cruthaigh VM i Proxmox nó le Packer, tosaigh é, siúil ar shiúl, SSH isteach. Is é `cidata` an lipéad cloud-init `NoCloud`, mar sin tá a fhios ag an uirlisiú fíorúlaithe coitianta go léir cheana conas tiomáint mar sin a cheangal.

## Na comhaid chumraíochta

Is iad na comhaid go díreach an méid a scríobhann treoraí an suiteálaí féin, mar sin is é an bealach is éasca chun tacar tosaigh a fháil ná suiteáil idirghníomhach amháin a rith (i VM, abair) agus an méid a scríobh sé isteach i `/root` a chóipeáil:

| Comhad | Riachtanach | Cuspóir |
|------|----------|---------|
| `user_configuration.json` | Sea | Diosca, óstainm, crios ama, méarchlár |
| `user_credentials.json` | Sea | Ainm úsáideora agus haise pasfhocail |
| `user_full_name.txt` | Níl | Ainm iomlán Git |
| `user_email_address.txt` | Níl | Ríomhphost Git |
| `user_encrypt_installation.txt` | Níl | `true` nuair a iompraíonn an chumraíocht bloc `disk_encryption` |
| `authorized_keys` | Níl | Eochracha poiblí SSH, ceann in aghaidh na líne |
| `tailscale_authkey` | Níl | Eochair fíordheimhnithe Tailscale chun dul isteach i do tailnet ar an gcéad tosú |

Gin an haise pasfhocail do `user_credentials.json` le `openssl passwd -6 "yourpassword"`.

Is féidir leat comhad folamh ar a dtugtar `defer-provisioning` a chur isteach freisin in áit `user_credentials.json`. Ritheann sé sin an tsuiteáil [prepare-for-another-owner](02-getting-started.md) céanna is féidir leat a spreagadh go hidirghníomhach: suiteálann an meaisín gan aon sonraí pearsanta, agus roghnaíonn cibé duine a thosaíonn é ar dtús a mhéarchlár agus cruthaíonn sé a úsáideoir. Sin é an mód do rigí íomháithe, áit nach chóir don tiomáint dintiúir aon duine a iompar ar chor ar bith.

## Rochtain SSH

Nuair atá `authorized_keys` i láthair, socraíonn an tsuiteáil na heochracha suas mar `~/.ssh/authorized_keys` an úsáideora, cumasaíonn sé `sshd`, agus osclaíonn sé an balla dóiteáin dó. (Seolann suiteáil stoic Omarchy openssh leis an tseirbhís díchumasaithe agus an port dúnta, mar sin bheadh meaisín gan freastal doshroichte murach sin.) Ní chuireann an tsuiteáil ach d'eochracha leis — ní scaoileann sé aon cheann de shocruithe fíordheimhnithe eile an deamhain SSH.

Nuair atá `tailscale_authkey` i láthair, téann an meaisín isteach i do tailnet ar an gcéad tosú ina áit sin: suiteáiltear Tailscale ó phacáistí cuachta an ISO, ceadaíonn an balla dóiteáin an comhéadan tailnet, agus ritheann post cúlra an cleamhnas a luaithe a bhíonn líonra ag an meaisín i ndáiríre, ag atriall go dtí go n-éireoidh leis. Úsáid eochair in-athúsáidte, réamhúdaraithe ionas gur féidir le híomhá tiománaithe amháin fónamh do go leor meaisíní.

## An tiomáint cidata a thógáil

Oibríonn aon chóras comhad leis an lipéad ceart. Is é ISO beag bídeach an bealach éasca:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Ansin ceangail é leis an VM taobh leis an ISO Omarchy. Seo sampla iomlán Proxmox:

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

Liostaíonn an t-ord tosaithe an diosca ar dtús d'aon ghnó: titeann an diosca folamh tríd chuig an ISO ar an gcéad tosú, agus tosaíonn an córas suiteáilte ón diosca go deo ina dhiaidh sin.

## Dhá rabhadh

Níl suiteálacha criptithe gan freastal go hiomlán gan freastal — caithfidh duine éigin an pasfhrása LUKS a chlóscríobh fós ag an gcéad tosú. Agus iompraíonn an bloc `disk_encryption` in `user_configuration.json` an pasfhrása sin i ngnáth-théacs, mar sin caith le tiomáint cidata a tógadh ó shuiteáil chriptithe mar an rún a bhfuil sé.
