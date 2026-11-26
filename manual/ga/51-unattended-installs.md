# Suiteálacha Gan Freastal

Is féidir le ISO Omarchy é féin a shuiteáil gan éinne ag an méarchlár. Má aimsíonn an suiteálaí an dara tiomántán leis an lipéad `cidata` air agus a chomhaid chumraíochta á n-iompar aige, cóipeálann sé as iad, scipeálann sé an treoraí socraithe ar fad, agus atosaíonn sé isteach sa chóras críochnaithe leis féin. Níl aon tógáil speisialta ISO de dhíth, níl aon iontráil bhreise sa roghchlár tosaithe — gan tiomántán mar sin ceangailte, ní athraíonn rud ar bith agus faigheann tú an treoraí gnáth.

Dá bharr sin tá Omarchy ar fheabhas mar bhuníomhá do thimpeallachtaí forbartha indiúscartha: cruthaigh VM in Proxmox nó le Packer, tosaigh é, siúl uait, téigh isteach le SSH. Is é `cidata` an lipéad `NoCloud` de chuid cloud-init, mar sin tá a fhios ag na huirlisí fíorúlaithe coitianta go léir cheana conas tiomántán mar sin a cheangal.

## Na comhaid chumraíochta

Is iad na comhaid go díreach a scríobhann treoraí an tsuiteálaí féin, mar sin is é an bealach is éasca tacar tosaigh a fháil ná suiteáil idirghníomhach amháin a rith (in VM, abair) agus a scríobh sé a chóipeáil isteach in `/root`:

| Comhad | Riachtanach | Cuspóir |
|------|----------|---------|
| `user_configuration.json` | Tá | Diosca, óstainm, crios ama, méarchlár |
| `user_credentials.json` | Tá | Ainm úsáideora agus haise an phasfhocail, agus pasfhrása LUKS le haghaidh suiteála criptithe |
| `user_encrypt_installation.txt` | Níl | `true` nuair a bhíonn bloc `disk_encryption` sa chumraíocht |
| `authorized_keys` | Níl | Eochracha poiblí SSH, ceann amháin in aghaidh na líne |
| `tailscale_authkey` | Níl | Eochair údaraithe Tailscale chun dul isteach i do tailnet ar an gcéad tosú |

Gin haise an phasfhocail le haghaidh `user_credentials.json` le `openssl passwd -6 "yourpassword"`.

Níl an t-ainm agus an ríomhphost le haghaidh coimití git mar chuid den suiteáil. Socraigh iad nuair atá an meaisín ar bun, thar SSH mar shampla, le `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Is féidir leat comhad folamh darb ainm `defer-provisioning` a chur isteach freisin in áit `user_credentials.json`. Ritheann sé sin an [suiteáil ullmhaithe d'úinéir eile](02-getting-started.md) chéanna is féidir leat a spreagadh go hidirghníomhach: suiteálann an meaisín gan aon sonraí pearsanta, agus roghnaíonn cibé duine a thosaíonn ar dtús é a mhéarchlár agus cruthaíonn sé a úsáideoir. Sin é an mód do rigí íomháithe, áit nár cheart don tiomántán dintiúir éinne ar chor ar bith a iompar.

## Rochtain SSH

Nuair a bhíonn `authorized_keys` ann, socraíonn an tsuiteáil na heochracha mar `~/.ssh/authorized_keys` an úsáideora, cumasaíonn sí `sshd`, agus osclaíonn sí an balla dóiteáin dó. (Tagann openssh le suiteáil stoc Omarchy agus an tseirbhís díchumasaithe agus an port dúnta, mar sin ní bheadh meaisín gan freastal insroichte murach sin.) Ní chuireann an tsuiteáil isteach ach d'eochracha — ní scaoileann sí aon cheann de shocruithe fíordheimhnithe eile an daeomain SSH.

Nuair a bhíonn `tailscale_authkey` ann, téann an meaisín isteach i do tailnet ar an gcéad tosú ina ionad sin: suiteáiltear Tailscale ó phacáistí cuachta an ISO, ceadaíonn an balla dóiteáin an comhéadan tailnet, agus ritheann jab cúlra an teacht isteach chomh luath agus a bhíonn líonra ag an meaisín i ndáiríre, ag athiarraidh go dtí go n-éireoidh leis. Úsáid eochair in-athúsáidte, réamhúdaraithe ionas gur féidir le híomhá tiomántáin amháin freastal ar go leor meaisíní.

## An tiomántán cidata a thógáil

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

Tá an diosca ar dtús san ord tosaithe d'aon ghnó: titeann an diosca folamh tríd go dtí an ISO ar an gcéad tosú, agus tosaíonn an córas suiteáilte ón diosca as sin go deo.

## Dhá rabhadh

Níl suiteálacha criptithe gan freastal go hiomlán gan freastal — caithfidh duine pasfhrása LUKS a chlóscríobh fós ag an gcéad tosú. Agus téann an pasfhrása sin ag barrleibhéal `user_credentials.json` mar `encryption_password` — léann archinstall ansin é, ní ón mbloc `disk_encryption` in `user_configuration.json` — mar sin caith le tiomántán cidata a tógadh ó shuiteáil chriptithe mar an rún is ea é.
