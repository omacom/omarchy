# Ómönnuð uppsetning

Omarchy ISO-ið getur sett sig upp án þess að nokkur sé við lyklaborðið. Ef uppsetningarforritið finnur annað drif merkt `cidata` með stillingarskrám þess afritar það þær þaðan, sleppir uppsetningarhjálpinni alfarið og endurræsir sjálft inn í fullbúið kerfið. Engin sérstök ISO-smíði, enginn auka valkostur í ræsivalmyndinni — án slíks drifs breytist ekkert og þú færð venjulegu uppsetningarhjálpina.

Þetta gerir Omarchy að frábærum grunnmyndum fyrir einnota þróunarumhverfi: búðu til VM í Proxmox eða með Packer, ræstu hana, farðu í burtu og tengstu inn með SSH. `cidata` er `NoCloud`-merkið frá cloud-init, svo öll algeng sýndarvæðingartól vita nú þegar hvernig á að tengja slíkt drif.

## Stillingarskrárnar

Skrárnar eru nákvæmlega það sem uppsetningarhjálp uppsetningarforritsins skrifar sjálf, svo auðveldasta leiðin til að fá byrjunarsafn er að keyra eina gagnvirka uppsetningu (til dæmis í VM) og afrita það sem hún skrifaði í `/root`:

| Skrá | Nauðsynleg | Tilgangur |
|------|----------|---------|
| `user_configuration.json` | Já | Diskur, vélarheiti, tímabelti, lyklaborð |
| `user_credentials.json` | Já | Notandanafn og tætigildi lykilorðs |
| `user_encrypt_installation.txt` | Nei | `true` þegar stillingarnar innihalda `disk_encryption` blokk |
| `authorized_keys` | Nei | Opinberir SSH-lyklar, einn í hverri línu |
| `tailscale_authkey` | Nei | Tailscale-auðkenningarlykill til að tengjast tailnet-inu þínu við fyrstu ræsingu |

Búðu til tætigildi lykilorðsins fyrir `user_credentials.json` með `openssl passwd -6 "yourpassword"`.

Nafnið og netfangið fyrir git-commit eru ekki hluti af uppsetningunni. Stilltu þau þegar vélin er komin í gang, til dæmis yfir SSH, með `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Þú getur líka sett inn tóma skrá sem heitir `defer-provisioning` í stað `user_credentials.json`. Það keyrir sömu [uppsetningu sem undirbýr vélina fyrir annan eiganda](02-getting-started.md) og þú getur ræst gagnvirkt: vélin setur upp án nokkurra persónuupplýsinga, og sá sem ræsir hana fyrst velur lyklaborðið sitt og býr til notandann sinn. Það er stillingin fyrir myndavélar, þar sem drifið á alls ekki að geyma innskráningarupplýsingar nokkurs manns.

## SSH-aðgangur

Þegar `authorized_keys` er til staðar setur uppsetningin lykla þína upp sem `~/.ssh/authorized_keys` notandans, virkjar `sshd` og opnar eldvegginn fyrir honum. (Venjuleg Omarchy-uppsetning fylgir með openssh með þjónustuna óvirka og gáttina lokaða, svo ómönnuð vél væri annars óaðgengileg.) Uppsetningin bætir aðeins lyklunum þínum við — hún losar ekki um neinar aðrar auðkenningarstillingar SSH-þjónsins.

Þegar `tailscale_authkey` er til staðar tengist vélin tailnet-inu þínu við fyrstu ræsingu í staðinn: Tailscale er sett upp úr pökkunum sem fylgja ISO-inu, eldveggurinn leyfir viðmót tailnet-sins og bakgrunnsverk keyrir tenginguna um leið og vélin er raunverulega komin með net, og reynir aftur þar til það tekst. Notaðu endurnotanlegan, fyrirfram heimilaðan lykil svo ein drifmynd geti þjónað mörgum vélum.

## Að búa til cidata-drifið

Hvaða skráarkerfi sem er með rétta merkið virkar. Lítið ISO er auðveld leið:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Tengdu það síðan við VM-ina ásamt Omarchy ISO-inu. Hér er fullt Proxmox-dæmi:

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

Ræsingarröðin setur diskinn fyrst viljandi: auði diskurinn fellur í gegn að ISO-inu við fyrstu ræsingu, og uppsetta kerfið ræsir af diski upp frá því.

## Tveir fyrirvarar

Dulrituð ómönnuð uppsetning er ekki alveg ómönnuð — einhver þarf samt að slá inn LUKS-lykilorðið við fyrstu ræsingu. Og `disk_encryption` blokkin í `user_configuration.json` geymir það lykilorð í hreinum texta, svo farðu með cidata-drif sem er búið til úr dulritaðri uppsetningu eins og leyndarmálið sem það er.
