# Suiteálacha Gan Duine i Láthair

Is féidir le ISO Omarchy é féin a shuiteáil gan aon duine ag an méarchlár. Má aimsíonn an suiteálaí an dara tiomántán leis an lipéad `cidata` a iompraíonn a chomhaid chumraíochta, cóipeálann sé uaidh iad, scipeálann sé an treoraí socraithe ar fad, agus atosaíonn sé isteach sa chóras críochnaithe leis féin. Ní theastaíonn aon ISO speisialta, aon iontráil bhreise sa roghchlár tosaithe — gan tiomántán den sórt sin ceangailte, ní athraíonn aon rud agus faigheann tú an gnáththreoraí.

Fágann sé sin go bhfuil Omarchy ar fheabhas mar bhuníomhá le haghaidh timpeallachtaí forbartha indiúscartha: cruthaigh VM in Proxmox nó le Packer, tosnaigh é, siúl uait, téigh isteach le SSH. Is é `cidata` lipéad `NoCloud` cloud-init, mar sin tá a fhios ag an uirlisiú fíorúlaithe coitianta ar fad cheana conas tiomántán den sórt sin a cheangal.

## Na comhaid chumraíochta

Is iad na comhaid go díreach a scríobhann treoraí an tsuiteálaí féin, mar sin is é an bealach is éasca chun sraith tosaigh a fháil ná suiteáil idirghníomhach amháin a rith (in VM, abair) agus a scríobh sé isteach in `/root` a chóipeáil:

| Comhad | Riachtanach | Cuspóir |
|------|----------|---------|
| `user_configuration.json` | Tá | Diosca, óstainm, crios ama, méarchlár |
| `user_credentials.json` | Tá | Ainm úsáideora agus haiseáil pasfhocail |
| `user_encrypt_installation.txt` | Níl | `true` nuair a iompraíonn an chumraíocht bloc `disk_encryption` |
| `authorized_keys` | Níl | Eochracha poiblí SSH, ceann amháin in aghaidh na líne |
| `tailscale_authkey` | Níl | Eochair údaraithe Tailscale chun dul isteach i do tailnet ar an gcéad tosú |

Gin an haiseáil pasfhocail le haghaidh `user_credentials.json` le `openssl passwd -6 "yourpassword"`.

Ní cuid den tsuiteáil iad an t-ainm agus an ríomhphost le haghaidh gealltanais git. Socraigh iad a luaithe a bheidh an meaisín ar bun, thar SSH mar shampla, le `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Is féidir leat comhad folamh darb ainm `defer-provisioning` a chur isteach in áit `user_credentials.json` freisin. Ritheann sé sin an tsuiteáil chéanna [ullmhú d'úinéir eile](02-getting-started.md) is féidir leat a thionscnamh go hidirghníomhach: suiteáiltear an meaisín gan aon sonraí pearsanta, agus roghnaíonn cibé duine a thosnaíonn ar dtús é a mhéarchlár agus cruthaíonn sé a úsáideoir. Sin é an mód le haghaidh rigí íomháithe, áit nár cheart don tiomántán dintiúir aon duine a iompar ar chor ar bith.

## Rochtain SSH

Nuair atá `authorized_keys` ann, socraíonn an tsuiteáil na heochracha mar `~/.ssh/authorized_keys` an úsáideora, cumasaíonn sí `sshd`, agus osclaíonn sí an balla dóiteáin dó. (Tagann openssh le gnáthshuiteáil Omarchy leis an tseirbhís díchumasaithe agus an port dúnta, mar sin bheadh meaisín gan duine i láthair dorochtana murach sin.) Ní chuireann an tsuiteáil ach do chuid eochracha leis — ní scaoileann sí aon cheann de shocruithe fíordheimhnithe eile dheamhan SSH.

Nuair atá `tailscale_authkey` ann, téann an meaisín isteach i do tailnet ar an gcéad tosú ina ionad sin: suiteáiltear Tailscale ó phacáistí cuachta an ISO, ceadaíonn an balla dóiteáin an comhéadan tailnet, agus ritheann jab cúlra an teacht isteach a luaithe a bhíonn líonra ag an meaisín i ndáiríre, ag athiarraidh go dtí go n-éiríonn leis. Bain úsáid as eochair in-athúsáidte, réamhúdaraithe ionas gur féidir le híomhá tiomántáin amháin freastal ar go leor meaisíní.

## An tiomántán cidata a thógáil

Oibríonn aon chóras comhad leis an lipéad ceart. Is ISO beag bídeach an bealach éasca:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Ansin ceangail leis an VM é in éineacht le ISO Omarchy. Seo sampla iomlán Proxmox:

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

Liostaíonn ord an tosaithe an diosca ar dtús d'aon ghnó: titeann an diosca folamh ar aghaidh chuig an ISO ar an gcéad tosú, agus tosnaíonn an córas suiteáilte ón diosca go deo ina dhiaidh sin.

## Dhá rabhadh

Níl suiteálacha criptithe gan duine i láthair go hiomlán gan duine i láthair — caithfidh duine éigin pasfhrása LUKS a chlóscríobh fós ag an gcéad tosú. Agus iompraíonn an bloc `disk_encryption` in `user_configuration.json` an pasfhrása sin i ngnáth-théacs, mar sin déileáil le tiomántán cidata a tógadh ó shuiteáil chriptithe mar an rún is ea é.
