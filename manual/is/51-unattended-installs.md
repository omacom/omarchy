# Uppsetningar án viðveru

Omarchy ISO-skráin getur sett sig upp án þess að nokkur sé við lyklaborðið. Ef uppsetningarforritið finnur annað drif merkt `cidata` með stillingarskrám sínum afritar það þær, sleppir uppsetningarhjálpinni alfarið og endurræsir sjálft inn í fullbúið kerfi. Engin sérstök ISO-bygging, enginn auka valmyndaratriði í ræsingu — ef ekkert slíkt drif er tengt breytist ekkert og þú færð venjulegu uppsetningarhjálpina.

Þetta gerir Omarchy að frábærum grunnmynd fyrir einnota þróunarumhverfi: búðu til VM í Proxmox eða með Packer, ræstu hana, farðu í burtu og tengstu inn með SSH. `cidata` er `NoCloud`-merkið frá cloud-init, svo öll algeng sýndarvæðingartól vita þegar hvernig á að tengja slíkt drif.

## Stillingarskrárnar

Skrárnar eru nákvæmlega það sem uppsetningarhjálp uppsetningarforritsins skrifar sjálf, svo auðveldasta leiðin til að fá byrjunarsett er að keyra eina gagnvirka uppsetningu (í VM, til dæmis) og afrita það sem hún skrifaði í `/root`:

| Skrá | Krafist | Tilgangur |
|------|----------|---------|
| `user_configuration.json` | Já | Diskur, vélarnafn, tímabelti, lyklaborð |
| `user_credentials.json` | Já | Notendanafn og kássa lykilorðs, og LUKS-aðgangsorðið fyrir dulritaða uppsetningu |
| `user_encrypt_installation.txt` | Nei | `true` þegar stillingin inniheldur `disk_encryption` reit |
| `authorized_keys` | Nei | SSH-dreifilyklar, einn í hverri línu |
| `tailscale_authkey` | Nei | Tailscale-auðkenningarlykill til að tengjast tailnet-inu þínu við fyrstu ræsingu |

Búðu til kássu lykilorðsins fyrir `user_credentials.json` með `openssl passwd -6 "yourpassword"`.

Nafn og netfang fyrir git-skráningar eru ekki hluti af uppsetningunni. Stilltu þau þegar vélin er komin í gang, yfir SSH til dæmis, með `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Þú getur líka sett inn tóma skrá sem heitir `defer-provisioning` í stað `user_credentials.json`. Það keyrir sömu [uppsetningu þar sem vélin er undirbúin fyrir annan eiganda](02-getting-started.md) og þú getur ræst gagnvirkt: vélin er sett upp án nokkurra persónulegra upplýsinga, og sá sem ræsir hana fyrst velur lyklaborð sitt og býr til notandann sinn. Það er hamurinn fyrir myndavélar, þar sem drifið á alls ekki að geyma skilríki nokkurs manns.

## SSH-aðgangur

Þegar `authorized_keys` er til staðar setur uppsetningin lyklana upp sem `~/.ssh/authorized_keys` notandans, virkjar `sshd` og opnar eldvegginn fyrir hann. (Venjuleg Omarchy-uppsetning fylgir með openssh með þjónustuna óvirka og gáttina lokaða, svo vél án viðveru væri annars óaðgengileg.) Uppsetningin bætir aðeins við lyklunum þínum — hún slakar ekki á neinum öðrum auðkenningarstillingum SSH-púkans.

Þegar `tailscale_authkey` er til staðar tengist vélin tailnet-inu þínu við fyrstu ræsingu þess í staðinn: Tailscale er sett upp af meðfylgjandi pökkum ISO-skrárinnar, eldveggurinn leyfir tailnet-viðmótið og bakgrunnsverk keyrir tenginguna um leið og vélin hefur í raun net, og reynir aftur þar til það tekst. Notaðu endurnotanlegan, fyrirfram heimilaðan lykil svo ein drifmynd geti þjónað mörgum vélum.

## Að búa til cidata-drifið

Hvaða skráarkerfi sem er með rétta merkið virkar. Lítil ISO-skrá er auðvelda leiðin:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Tengdu það síðan við VM samhliða Omarchy ISO-skránni. Hér er fullt Proxmox-dæmi:

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

Ræsingarröðin listar diskinn fyrst viljandi: tómi diskurinn fellur í gegn að ISO-skránni við fyrstu ræsingu, og uppsetta kerfið ræsist af diski upp frá því.

## Tveir fyrirvarar

Dulritaðar uppsetningar án viðveru eru ekki alveg án viðveru — einhver þarf samt að slá inn LUKS-aðgangsorðið við fyrstu ræsingu. Og það aðgangsorð fer á efsta stig `user_credentials.json` sem `encryption_password` — archinstall les það þaðan, ekki úr `disk_encryption` reitnum í `user_configuration.json` — svo farðu með cidata-drif sem er byggt úr dulritaðri uppsetningu eins og leyndarmálið sem það er.
