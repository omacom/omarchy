# Usakinishaji Bila Usimamizi

ISO ya Omarchy inaweza kujisakinisha yenyewe bila mtu yeyote kwenye kibodi. Ikiwa kisakinishi kitapata diski ya pili yenye lebo `cidata` inayobeba faili zake za usanidi, huzinakili, huruka kabisa wizard ya usanidi, na huwashwa upya ndani ya mfumo uliokamilika yenyewe. Hakuna uundaji maalum wa ISO, hakuna kipengee cha ziada cha menyu ya kuwasha — bila diski kama hiyo kuambatishwa, hakuna kinachobadilika na unapata wizard ya kawaida.

Hii hufanya Omarchy kuwa bora kama taswira ya msingi kwa mazingira ya uendelezaji yanayoweza kutupwa: unda VM katika Proxmox au kwa Packer, iwashe, ondoka, ingia kwa SSH. `cidata` ni lebo ya cloud-init `NoCloud`, hivyo zana zote za kawaida za uvirtualishaji tayari zinajua jinsi ya kuambatisha diski kama hiyo.

## Faili za usanidi

Faili hizi ni sawa kabisa na zile ambazo wizard ya kisakinishi yenyewe huandika, hivyo njia rahisi zaidi ya kupata seti ya kuanzia ni kufanya usakinishaji mmoja wa maingiliano (katika VM, kwa mfano) na kunakili ilichoandika ndani ya `/root`:

| Faili | Inahitajika | Kusudi |
|------|----------|---------|
| `user_configuration.json` | Ndiyo | Diski, jina la mwenyeji, ukanda wa saa, kibodi |
| `user_credentials.json` | Ndiyo | Jina la mtumiaji na heshi ya nenosiri, na nenosiri la LUKS kwa usakinishaji uliosimbwa kwa njia fiche |
| `user_encrypt_installation.txt` | Hapana | `true` wakati usanidi unabeba kizuizi cha `disk_encryption` |
| `authorized_keys` | Hapana | Funguo za umma za SSH, moja kwa kila mstari |
| `tailscale_authkey` | Hapana | Ufunguo wa uthibitishaji wa Tailscale kwa kujiunga na tailnet yako kwenye kuwasha kwa mara ya kwanza |

Tengeneza heshi ya nenosiri kwa ajili ya `user_credentials.json` kwa kutumia `openssl passwd -6 "yourpassword"`.

Jina na barua pepe kwa ajili ya commit za git si sehemu ya usakinishaji. Viweke mara tu mashine inapokuwa imewashwa, kupitia SSH kwa mfano, kwa kutumia `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Unaweza pia kuweka faili tupu lenye jina `defer-provisioning` badala ya `user_credentials.json`. Hiyo huendesha [usakinishaji ule ule wa kuandaa kwa mmiliki mwingine](02-getting-started.md) ambao unaweza kuuanzisha kwa maingiliano: mashine husakinisha bila maelezo yoyote ya kibinafsi, na yeyote anayeiwasha kwa mara ya kwanza huchagua kibodi yake na kuunda mtumiaji wake. Hiyo ndiyo hali kwa ajili ya rig za kuunda taswira, ambapo diski haipaswi kubeba sifa za mtu yeyote hata kidogo.

## Ufikiaji wa SSH

Wakati `authorized_keys` ipo, usakinishaji huweka funguo hizo kama `~/.ssh/authorized_keys` ya mtumiaji, huwasha `sshd`, na hufungua ngome kwa ajili yake. (Usakinishaji wa kawaida wa Omarchy huja na openssh huku huduma ikiwa imezimwa na mlango ukiwa umefungwa, hivyo mashine isiyo na usimamizi isingefikika vinginevyo.) Usakinishaji huongeza funguo zako tu — hailegezi mipangilio mingine yoyote ya uthibitishaji ya daemon ya SSH.

Wakati `tailscale_authkey` ipo, mashine hujiunga na tailnet yako kwenye kuwasha kwa mara ya kwanza badala yake: Tailscale husakinishwa kutoka kwenye vifurushi vilivyojumuishwa kwenye ISO, ngome huruhusu kiolesura cha tailnet, na kazi ya chinichini huendesha uungaji mara tu mashine inapokuwa na mtandao kweli, ikijaribu tena hadi ifanikiwe. Tumia ufunguo unaoweza kutumika tena, ulioidhinishwa mapema ili taswira moja ya diski iweze kuhudumia mashine nyingi.

## Kuunda diski ya cidata

Mfumo wowote wa faili wenye lebo sahihi hufanya kazi. ISO ndogo ndiyo njia rahisi:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Kisha iambatishe kwenye VM pamoja na ISO ya Omarchy. Huu hapa ni mfano kamili wa Proxmox:

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

Mpangilio wa kuwasha huorodhesha diski kwanza kwa makusudi: diski tupu hushuka hadi kwenye ISO kwenye kuwasha kwa mara ya kwanza, na mfumo uliosakinishwa huwasha kutoka kwenye diski milele baada ya hapo.

## Tahadhari mbili

Usakinishaji uliosimbwa kwa njia fiche usio na usimamizi si bila usimamizi kabisa — mtu bado anapaswa kuandika nenosiri la LUKS kwenye kuwasha kwa mara ya kwanza. Na nenosiri hilo huenda kwenye kiwango cha juu cha `user_credentials.json` kama `encryption_password` — archinstall hulisoma hapo, si kutoka kwenye kizuizi cha `disk_encryption` katika `user_configuration.json` — hivyo ichukulie diski ya cidata iliyoundwa kutoka kwenye usakinishaji uliosimbwa kwa njia fiche kama siri ilivyo.
