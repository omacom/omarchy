# Järelevalveta paigaldused

Omarchy ISO saab end paigaldada nii, et keegi pole klaviatuuri taga. Kui paigaldaja leiab teise ketta sildiga `cidata`, mis kannab selle seadistusfaile, kopeerib see need maha, jätab seadistusviisardi täielikult vahele ja taaskäivitub ise valmis süsteemi. Ei mingit spetsiaalset ISO järku ega lisakirjet alglaadimismenüüs — kui sellist ketast pole ühendatud, ei muutu midagi ja saad tavalise viisardi.

See muudab Omarchy suurepäraseks baaskujundiks ühekordsetele arenduskeskkondadele: loo VM Proxmoxis või Packeriga, alglaadi see, kõnni minema, logi SSH kaudu sisse. `cidata` on cloud-initi `NoCloud` silt, nii et kõik levinud virtualiseerimistööriistad teavad juba, kuidas sellist ketast ühendada.

## Seadistusfailid

Failid on täpselt need, mida paigaldaja oma viisard kirjutab, nii et lihtsaim viis lähtekomplekti saamiseks on käivitada üks interaktiivne paigaldus (näiteks VM-is) ja kopeerida see, mida see kausta `/root` kirjutas:

| Fail | Kohustuslik | Eesmärk |
|------|----------|---------|
| `user_configuration.json` | Jah | Ketas, hostinimi, ajavöönd, klaviatuur |
| `user_credentials.json` | Jah | Kasutajanimi ja parooli räsi |
| `user_full_name.txt` | Ei | Giti täisnimi |
| `user_email_address.txt` | Ei | Giti e-post |
| `user_encrypt_installation.txt` | Ei | `true`, kui seadistus kannab `disk_encryption` plokki |
| `authorized_keys` | Ei | SSH avalikud võtmed, üks rea kohta |
| `tailscale_authkey` | Ei | Tailscale'i autentimisvõti sinu tailnetiga liitumiseks esimesel alglaadimisel |

Genereeri parooli räsi failile `user_credentials.json` käsuga `openssl passwd -6 "yourpassword"`.

Sa saad faili `user_credentials.json` asemele panna ka tühja faili nimega `defer-provisioning`. See käivitab sama [teisele omanikule ettevalmistamise paigalduse](02-getting-started.md), mille saad interaktiivselt käivitada: masin paigaldatakse ilma isikuandmeteta ja kes selle esimesena alglaadib, valib oma klaviatuuri ja loob oma kasutaja. See on režiim kujundusjaamade jaoks, kus ketas ei peaks kandma kellegi mandaate.

## SSH juurdepääs

Kui `authorized_keys` on olemas, seadistab paigaldus võtmed kasutaja failiks `~/.ssh/authorized_keys`, lubab `sshd` ja avab sellele tulemüüri. (Tavapärase Omarchy paigaldusega tuleb openssh keelatud teenuse ja suletud pordiga, nii et järelevalveta masin oleks muidu kättesaamatu.) Paigaldus lisab ainult sinu võtmed — see ei lõdvenda ühtki teist SSH deemoni autentimisseadet.

Kui `tailscale_authkey` on olemas, liitub masin selle asemel esimesel alglaadimisel sinu tailnetiga: Tailscale paigaldatakse ISO kaasasolevatest pakettidest, tulemüür lubab tailneti liidest ja taustatöö käivitab liitumise kohe, kui masinal tegelikult võrk on, proovides uuesti kuni õnnestumiseni. Kasuta taaskasutatavat eelautoriseeritud võtit, et üks kettakujund saaks teenida paljusid masinaid.

## cidata ketta ehitamine

Iga õige sildiga failisüsteem töötab. Väike ISO on lihtsaim viis:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Seejärel ühenda see VM-i külge koos Omarchy ISO-ga. Siin on täielik Proxmoxi näide:

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

Alglaadimisjärjekord loetleb ketta meelega esimesena: tühi ketas kukub esimesel alglaadimisel ISO-le ja paigaldatud süsteem alglaadib edaspidi alati kettalt.

## Kaks hoiatust

Krüpteeritud järelevalveta paigaldused pole täielikult järelevalveta — keegi peab esimesel alglaadimisel ikka LUKS-i paroolifraasi kirjutama. Ja plokk `disk_encryption` failis `user_configuration.json` kannab seda paroolifraasi lihttekstina, nii et kohtle krüpteeritud paigaldusest ehitatud cidata ketast saladusena, mis see on.
