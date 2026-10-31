# Järelevalveta paigaldused

Omarchy ISO suudab end ise paigaldada ilma, et keegi klaviatuuri taga oleks. Kui paigaldaja leiab teise draivi sildiga `cidata`, millel on selle konfiguratsioonifailid, kopeerib ta need sealt ära, jätab seadistusviisardi täielikult vahele ja taaskäivitub omal käel valmis süsteemi. Ei mingit spetsiaalset ISO koosteversiooni, ei mingit lisakirjet alglaadimismenüüs — kui sellist draivi küljes pole, ei muutu midagi ja saad tavalise viisardi.

See teeb Omarchyst suurepärase baastõmmise ühekordsete arenduskeskkondade jaoks: loo VM Proxmoxis või Packeriga, käivita see, kõnni minema, logi SSH kaudu sisse. `cidata` on cloud-initi `NoCloud` silt, nii et kõik levinud virtualiseerimistööriistad oskavad sellise draivi juba külge ühendada.

## Konfiguratsioonifailid

Failid on täpselt need, mille paigaldaja enda viisard kirjutab, nii et kõige lihtsam viis algkomplekti saamiseks on teha üks interaktiivne paigaldus (näiteks VM-is) ja kopeerida see, mis see `/root` alla kirjutas:

| Fail | Kohustuslik | Otstarve |
|------|----------|---------|
| `user_configuration.json` | Jah | Ketas, hostinimi, ajavöönd, klaviatuur |
| `user_credentials.json` | Jah | Kasutajanimi ja parooliräsi |
| `user_encrypt_installation.txt` | Ei | `true`, kui konfiguratsioon sisaldab `disk_encryption` plokki |
| `authorized_keys` | Ei | SSH avalikud võtmed, üks rea kohta |
| `tailscale_authkey` | Ei | Tailscale'i autentimisvõti esimesel käivitamisel sinu tailnetiga liitumiseks |

Loo `user_credentials.json` jaoks parooliräsi käsuga `openssl passwd -6 "yourpassword"`.

Giti commit'ide nimi ja e-posti aadress ei ole paigalduse osa. Määra need, kui masin on üleval, näiteks SSH kaudu käsuga `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Võid `user_credentials.json` asemel sisse panna ka tühja faili nimega `defer-provisioning`. See käivitab sama [teise omaniku jaoks ettevalmistava paigalduse](02-getting-started.md), mille saad interaktiivselt käivitada: masin paigaldatakse ilma isikuandmeteta ning see, kes selle esimesena käivitab, valib oma klaviatuuri ja loob oma kasutaja. See on režiim tõmmiste tegemise seadmete jaoks, kus draivil ei tohiks üldse kellegi volitusi olla.

## SSH juurdepääs

Kui `authorized_keys` on olemas, seab paigaldus võtmed kasutaja `~/.ssh/authorized_keys` failiks, lubab `sshd` ja avab selle jaoks tulemüüri. (Omarchy tavapaigalduses tarnitakse openssh keelatud teenuse ja suletud pordiga, nii et järelevalveta masin oleks muidu kättesaamatu.) Paigaldus lisab ainult sinu võtmed — see ei lõdvenda ühtegi muud SSH deemoni autentimisseadet.

Kui `tailscale_authkey` on olemas, liitub masin selle asemel esimesel käivitamisel sinu tailnetiga: Tailscale paigaldatakse ISO-ga kaasas olevatest pakettidest, tulemüür lubab tailneti liidest ja taustatöö käivitab liitumise niipea, kui masinal on päriselt võrk olemas, proovides uuesti, kuni see õnnestub. Kasuta korduvkasutatavat, eelnevalt autoriseeritud võtit, nii saab üks draivitõmmis teenindada paljusid masinaid.

## cidata draivi loomine

Kõik õige sildiga failisüsteemid sobivad. Väike ISO on lihtne viis:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Seejärel ühenda see Omarchy ISO kõrval VM-i külge. Siin on täielik Proxmoxi näide:

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

Alglaadimisjärjekorras on ketas meelega esimesena: esimesel käivitamisel kukub tühi ketas läbi ISO juurde ja paigaldatud süsteem käivitub pärast seda alati kettalt.

## Kaks hoiatust

Krüptitud järelevalveta paigaldused ei ole täielikult järelevalveta — keegi peab esimesel käivitamisel ikkagi LUKS parooli sisestama. Ja `user_configuration.json` faili `disk_encryption` plokk sisaldab seda parooli lahtise tekstina, nii et käsitle krüptitud paigaldusest loodud cidata draivi sellise saladusena, nagu see on.
