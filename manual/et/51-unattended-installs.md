# Järelevalveta paigaldused

Omarchy ISO suudab end paigaldada ilma, et keegi klaviatuuri taga istuks. Kui paigaldaja leiab teise ketta sildiga `cidata`, mis kannab selle konfiguratsioonifaile, kopeerib see need sealt maha, jätab seadistusviisardi täielikult vahele ja taaskäivitab end omal käel valmis süsteemi. Ei mingit spetsiaalset ISO koosteversiooni, ei mingit lisakirjet alglaadimismenüüs — kui sellist ketast küljes pole, ei muutu midagi ja saad tavalise viisardi.

See teeb Omarchy suurepäraseks baaskujutiseks ühekordsetele arenduskeskkondadele: loo VM Proxmoxis või Packeriga, käivita see, kõnni minema, logi SSH kaudu sisse. `cidata` on cloud-init `NoCloud` silt, nii et kõik levinud virtualiseerimistööriistad teavad juba, kuidas sellist ketast külge ühendada.

## Konfiguratsioonifailid

Failid on täpselt need, mida paigaldaja enda viisard kirjutab, nii et lihtsaim viis algkomplekti saamiseks on teha üks interaktiivne paigaldus (näiteks VM-is) ja kopeerida see, mis see `/root` alla kirjutas:

| Fail | Kohustuslik | Otstarve |
|------|----------|---------|
| `user_configuration.json` | Jah | Ketas, hostinimi, ajavöönd, klaviatuur |
| `user_credentials.json` | Jah | Kasutajanimi ja parooliräsi ning LUKS parool krüptitud paigalduse jaoks |
| `user_encrypt_installation.txt` | Ei | `true`, kui konfiguratsioon sisaldab `disk_encryption` plokki |
| `authorized_keys` | Ei | SSH avalikud võtmed, üks rea kohta |
| `tailscale_authkey` | Ei | Tailscale autentimisvõti esimesel käivitamisel sinu tailnetiga liitumiseks |

Loo `user_credentials.json` jaoks parooliräsi käsuga `openssl passwd -6 "yourpassword"`.

Git commit'ide nimi ja e-posti aadress ei kuulu paigalduse juurde. Sea need paika, kui masin on üleval, näiteks SSH kaudu käsuga `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Võid `user_credentials.json` asemele panna ka tühja faili nimega `defer-provisioning`. See käivitab sama [teise omaniku jaoks ettevalmistava paigalduse](02-getting-started.md), mille saad käivitada ka interaktiivselt: masin paigaldatakse ilma isiklike andmeteta ning see, kes selle esimesena käivitab, valib oma klaviatuuri ja loob oma kasutaja. See on režiim kujutiste tegemise seadmete jaoks, kus ketas ei tohiks üldse kellegi sisselogimisandmeid kanda.

## SSH-juurdepääs

Kui `authorized_keys` on olemas, seab paigaldus võtmed kasutaja `~/.ssh/authorized_keys` failiks, lubab `sshd` ja avab sellele tulemüüri. (Tavaline Omarchy paigaldus tarnitakse openssh-ga, mille teenus on keelatud ja port suletud, nii et järelevalveta masin oleks muidu kättesaamatu.) Paigaldus lisab ainult sinu võtmed — see ei lõdvenda ühtegi muud SSH deemoni autentimissätet.

Kui `tailscale_authkey` on olemas, liitub masin esimesel käivitamisel hoopis sinu tailnetiga: Tailscale paigaldatakse ISO-ga kaasas olevatest pakettidest, tulemüür lubab tailneti liidest ja taustatöö käivitab liitumise niipea, kui masinal on tegelikult võrk olemas, proovides uuesti, kuni see õnnestub. Kasuta korduvkasutatavat, eelnevalt volitatud võtit, et üks kettakujutis saaks teenindada paljusid masinaid.

## cidata ketta ehitamine

Iga õige sildiga failisüsteem töötab. Pisike ISO on lihtne viis:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Seejärel ühenda see VM-i külge koos Omarchy ISO-ga. Siin on täielik Proxmox näide:

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

Alglaadimisjärjekorras on ketas meelega esimesena: tühi ketas langeb esimesel käivitamisel ISO juurde edasi ja paigaldatud süsteem käivitub edaspidi alati kettalt.

## Kaks mööndust

Krüptitud järelevalveta paigaldused pole täielikult järelevalveta — keegi peab esimesel käivitamisel ikkagi LUKS parooli sisestama. Ja see parool läheb `user_credentials.json` ülemisele tasemele võtmega `encryption_password` — archinstall loeb seda sealt, mitte `user_configuration.json` faili `disk_encryption` plokist — nii et kohtle krüptitud paigaldusest ehitatud cidata ketast saladusena, mis see on.
