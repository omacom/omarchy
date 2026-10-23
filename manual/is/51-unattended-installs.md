# Óaðgæddar uppsetningar

Omarchy ISO getur sett sig upp án þess að nokkur sé við lyklaborðið. Ef uppsetningarforritið finnur annað drif merkt `cidata` sem ber stillingarskrár sínar, afritar það þær af, sleppir uppsetningarhjálpinni alveg og endurræsir sjálft inn í fullbúna kerfið. Engin sérstök ISO bygging, engin aukaræsivalmyndarfærsla — með ekkert slíkt drif tengt breytist ekkert og þú færð venjulegu hjálpina.

Þetta gerir Omarchy frábært sem grunnmynd fyrir einnota þróunarumhverfi: búðu til VM í Proxmox eða með Packer, ræstu hana, farðu í burtu, SSH-aðu inn. `cidata` er cloud-init `NoCloud` merkið, svo öll algeng sýndartól vita nú þegar hvernig á að tengja slíkt drif.

## Stillingarskrárnar

Skrárnar eru nákvæmlega það sem eigin hjálp uppsetningarforritsins skrifar, svo auðveldasta leiðin til að fá upphafssett er að keyra eina gagnvirka uppsetningu (í VM, til dæmis) og afrita það sem hún skrifaði í `/root`:

| Skrá | Krafist | Tilgangur |
|------|----------|---------|
| `user_configuration.json` | Já | Diskur, hýsilsnafn, tímabelti, lyklaborð |
| `user_credentials.json` | Já | Notendanafn og lykilorðshass |
| `user_full_name.txt` | Nei | Fullt Git nafn |
| `user_email_address.txt` | Nei | Git netfang |
| `user_encrypt_installation.txt` | Nei | `true` þegar stillingin ber `disk_encryption` blokk |
| `authorized_keys` | Nei | Opinberir SSH lyklar, einn á línu |
| `tailscale_authkey` | Nei | Tailscale auðkenningarlykill til að ganga í tailnetið þitt við fyrstu ræsingu |

Gerðu lykilorðshassann fyrir `user_credentials.json` með `openssl passwd -6 "yourpassword"`.

Þú getur líka sett inn tóma skrá sem heitir `defer-provisioning` í stað `user_credentials.json`. Það keyrir sömu [undirbúa-fyrir-annan-eiganda uppsetningu](02-getting-started.md) og þú getur kveikt á gagnvirkt: vélin setst upp án persónulegra upplýsinga, og hver sem ræsir hana fyrstur velur lyklaborð sitt og býr til notanda sinn. Það er hamurinn fyrir myndgerðarbúnað, þar sem drifinn ætti alls ekki að bera skilríki nokkurs.

## SSH aðgangur

Þegar `authorized_keys` er til staðar setur uppsetningin lyklana upp sem `~/.ssh/authorized_keys` notandans, virkjar `sshd` og opnar eldvegginn fyrir því. (Venjuleg Omarchy uppsetning flytur openssh með þjónustuna óvirka og tengið lokað, svo óvarin vél væri annars óaðgengileg.) Uppsetningin bætir aðeins lyklunum þínum við — hún slakar ekki á neinum af öðrum auðkenningarstillingum SSH þjónustunnar.

Þegar `tailscale_authkey` er til staðar gengur vélin í tailnetið þitt við fyrstu ræsingu í staðinn: Tailscale er sett upp úr innbyggðum pökkum ISO, eldveggurinn leyfir tailnet viðmótið, og bakgrunnsverk keyrir inngönguna um leið og vélin hefur raunverulega net, og reynir aftur þar til það heppnast. Notaðu endurnotanlegan, fyrirframsamþykktan lykil svo ein drifmynd geti þjónað mörgum vélum.

## Að byggja cidata drifinn

Sérhvert skráarkerfi með rétta merkið virkar. Lítið ISO er auðvelda leiðin:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Tengdu það svo við VM við hlið Omarchy ISO. Hér er fullt Proxmox dæmi:

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

Ræsisröðin telur diskinn fyrstan viljandi: tómur diskurinn fellur í gegn á ISO við fyrstu ræsingu, og uppsetta kerfið ræsir af diski upp frá því.

## Tvær fyrirvarar

Dulritaðar óaðgæddar uppsetningar eru ekki fullkomlega óaðgæddar — einhver þarf enn að slá inn LUKS lykilorðið við fyrstu ræsingu. Og `disk_encryption` blokkin í `user_configuration.json` ber það lykilorð í texta, svo meðhöndlaðu cidata drif byggt úr dulritaðri uppsetningu sem leyndarmálið sem það er.
