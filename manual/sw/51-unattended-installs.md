# Usakinishaji Usiosimamiwa

ISO ya Omarchy inaweza kujisakinisha bila mtu yeyote kwenye kibodi. Ikiwa kisakinishi kitakuta diski ya pili yenye lebo `cidata` inayobeba faili zake za usanidi, kinakili faili hizo, kinaruka mchawi wa usanidi kabisa, na kuwasha upya kwenye mfumo uliokamilika chenyewe. Hakuna ujenzi maalum wa ISO, hakuna kiingilio cha ziada kwenye menyu ya kuwasha — bila diski kama hiyo kuambatishwa, hakuna kinachobadilika na unapata mchawi wa kawaida.

Hii huifanya Omarchy kuwa bora kama picha ya msingi kwa mazingira ya uendelezaji yanayoweza kutupwa: unda VM katika Proxmox au kwa Packer, iwashe, ondoka, ingia kwa SSH. `cidata` ni lebo ya cloud-init `NoCloud`, kwa hivyo zana zote za kawaida za uboreshaji pepe tayari zinajua jinsi ya kuambatisha diski kama hiyo.

## Faili za usanidi

Faili hizo ni kile hasa ambacho mchawi wa kisakinishi chenyewe huandika, kwa hivyo njia rahisi zaidi ya kupata seti ya kuanzia ni kufanya usakinishaji mmoja wa kuingiliana (katika VM, kwa mfano) na kunakili kile ilichoandika ndani ya `/root`:

| Faili | Inahitajika | Kusudi |
|------|----------|---------|
| `user_configuration.json` | Ndiyo | Diski, jina la seva, saa za eneo, kibodi |
| `user_credentials.json` | Ndiyo | Jina la mtumiaji na heshi ya nenosiri |
| `user_encrypt_installation.txt` | Hapana | `true` wakati usanidi unabeba kizuizi cha `disk_encryption` |
| `authorized_keys` | Hapana | Funguo za umma za SSH, moja kwa kila mstari |
| `tailscale_authkey` | Hapana | Ufunguo wa uthibitishaji wa Tailscale kwa kujiunga na tailnet yako wakati wa kuwasha kwa kwanza |

Tengeneza heshi ya nenosiri kwa ajili ya `user_credentials.json` kwa `openssl passwd -6 "yourpassword"`.

Jina na barua pepe kwa ajili ya ahadi za git si sehemu ya usakinishaji. Viweke mara tu mashine inapokuwa imewashwa, kwa SSH kwa mfano, kwa `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Unaweza pia kuweka faili tupu yenye jina `defer-provisioning` badala ya `user_credentials.json`. Hiyo huendesha usakinishaji ule ule wa [kutayarisha kwa mmiliki mwingine](02-getting-started.md) ambao unaweza kuuanzisha kwa kuingiliana: mashine husakinisha bila maelezo yoyote ya kibinafsi, na yeyote anayeiwasha kwanza huchagua kibodi yake na kuunda mtumiaji wake. Hiyo ndiyo hali kwa ajili ya mitambo ya kuunda picha, ambapo diski haipaswi kubeba vitambulisho vya mtu yeyote kabisa.

## Ufikiaji wa SSH

Wakati `authorized_keys` ipo, usakinishaji huweka funguo hizo kama `~/.ssh/authorized_keys` ya mtumiaji, huwezesha `sshd`, na kuifungulia firewall. (Usakinishaji wa kawaida wa Omarchy huja na openssh huku huduma ikiwa imezimwa na mlango ukiwa umefungwa, kwa hivyo mashine isiyosimamiwa isingefikika vinginevyo.) Usakinishaji huongeza funguo zako tu — hailegezi mipangilio mingine yoyote ya uthibitishaji ya daemon ya SSH.

Wakati `tailscale_authkey` ipo, mashine hujiunga na tailnet yako wakati wa kuwasha kwa kwanza badala yake: Tailscale husakinishwa kutoka kwa vifurushi vilivyojumuishwa kwenye ISO, firewall huruhusu kiolesura cha tailnet, na kazi ya chinichini huendesha uunganishaji mara tu mashine inapokuwa na mtandao kweli, ikijaribu tena hadi ifanikiwe. Tumia ufunguo unaoweza kutumika tena, ulioidhinishwa mapema ili picha moja ya diski iweze kuhudumia mashine nyingi.

## Kuunda diski ya cidata

Mfumo wowote wa faili wenye lebo sahihi hufanya kazi. ISO ndogo ndiyo njia rahisi:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Kisha iambatishe kwenye VM pamoja na ISO ya Omarchy. Hapa kuna mfano kamili wa Proxmox:

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

Mpangilio wa kuwasha huorodhesha diski kwanza kwa makusudi: diski tupu huendelea hadi kwenye ISO wakati wa kuwasha kwa kwanza, na mfumo uliosakinishwa huwasha kutoka kwenye diski milele baada ya hapo.

## Tahadhari mbili

Usakinishaji usiosimamiwa uliosimbwa kwa njia fiche si usiosimamiwa kikamilifu — mtu bado anapaswa kuandika kauli ya siri ya LUKS wakati wa kuwasha kwa kwanza. Na kizuizi cha `disk_encryption` katika `user_configuration.json` hubeba kauli hiyo ya siri kwa maandishi wazi, kwa hivyo ichukulie diski ya cidata iliyoundwa kutoka kwa usakinishaji uliosimbwa kwa njia fiche kama siri ilivyo.
