# Usakinishaji Usiosimamiwa

ISO ya Omarchy inaweza kujisakinisha bila mtu yeyote kwenye kibodi. Kama kisakinishaji kinapata kiendeshaji cha pili kilichoandikwa `cidata` kikibeba faili zake za usanidi, hunakili, huruka mwongozaji wa usanidi kabisa, na huwasha upya kwenye mfumo uliomalizika wenyewe. Hakuna jengo maalum la ISO, hakuna ingizo la ziada la menyu ya kuwasha — bila kiendeshaji kama hicho kimeunganishwa, hakuna kinachobadilika na unapata mwongozaji wa kawaida.

Hii hufanya Omarchy kuwa nzuri kama picha ya msingi kwa mazingira ya maendeleo yanayotupwa: unda VM katika Proxmox au kwa Packer, iwashe, ondoka, ingia kwa SSH. `cidata` ni lebo ya cloud-init `NoCloud`, kwa hivyo zana zote za kawaida za uboreshaji pepe tayari zinajua jinsi ya kuunganisha kiendeshaji kama hicho.

## Faili za usanidi

Faili ni sawa kabisa na zile ambazo mwongozaji wa kisakinishaji huandika, kwa hivyo njia rahisi ya kupata seti ya kuanzia ni kuendesha usakinishaji mmoja shirikishi (katika VM, tuseme) na kunakili kile kilichoandika katika `/root`:

| Faili | Inahitajika | Kusudi |
|------|----------|---------|
| `user_configuration.json` | Ndiyo | Diski, jina la mwenyeji, eneo la saa, kibodi |
| `user_credentials.json` | Ndiyo | Jina la mtumiaji na hash ya nenosiri |
| `user_full_name.txt` | Hapana | Jina kamili la Git |
| `user_email_address.txt` | Hapana | Barua pepe ya Git |
| `user_encrypt_installation.txt` | Hapana | `true` wakati usanidi unabeba kizuizi cha `disk_encryption` |
| `authorized_keys` | Hapana | Funguo za umma za SSH, moja kwa kila mstari |
| `tailscale_authkey` | Hapana | Ufunguo wa uthibitishaji wa Tailscale kwa kujiunga na tailnet yako kwenye kuwasha wa kwanza |

Zalisha hash ya nenosiri kwa `user_credentials.json` kwa `openssl passwd -6 "yourpassword"`.

Unaweza pia kudondosha faili tupu iitwayo `defer-provisioning` badala ya `user_credentials.json`. Hiyo huendesha [usakinishaji wa kuandaa-kwa-mmiliki-mwingine](02-getting-started.md) unaoweza kuuchochea shirikishi: mashine husakinika bila maelezo binafsi, na yeyote anayeiwasha kwanza huchagua kibodi yake na kuunda mtumiaji wake. Hiyo ndiyo hali kwa rigi za kupiga picha, ambapo kiendeshaji hakipaswi kubeba vitambulisho vya mtu yeyote kabisa.

## Ufikiaji wa SSH

Wakati `authorized_keys` iko, usakinishaji huweka funguo kama `~/.ssh/authorized_keys` ya mtumiaji, huwezesha `sshd`, na hufungua ngome ya moto kwa ajili yake. (Usakinishaji wa kawaida wa Omarchy huja na openssh huduma ikiwa imezimwa na porti imefungwa, kwa hivyo mashine isiyosimamiwa vinginevyo haingefikiwa.) Usakinishaji huongeza tu funguo zako — haulegezi mipangilio mingine yoyote ya uthibitishaji ya daemon ya SSH.

Wakati `tailscale_authkey` iko, mashine hujiunga na tailnet yako kwenye kuwasha wa kwanza badala yake: Tailscale husakinishwa kutoka vifurushi vilivyowekwa kwenye ISO, ngome ya moto huruhusu kiolesura cha tailnet, na kazi ya nyuma huendesha uunganaji mara mashine inapokuwa na mtandao kweli, ikijaribu tena hadi ifanikiwe. Tumia ufunguo unaoweza kutumika tena, ulioidhinishwa awali ili picha moja ya kiendeshaji iweze kuhudumia mashine nyingi.

## Kujenga kiendeshaji cha cidata

Mfumo wowote wa faili wenye lebo sahihi hufanya kazi. ISO ndogo ndiyo njia rahisi:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Kisha iunganishe kwenye VM karibu na ISO ya Omarchy. Hapa kuna mfano kamili wa Proxmox:

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

Mpangilio wa kuwasha huorodhesha diski kwanza kwa makusudi: diski tupu huanguka kwenye ISO kwenye kuwasha wa kwanza, na mfumo uliosakinishwa huwasha kutoka diski milele baadaye.

## Tahadhari mbili

Usakinishaji usiosimamiwa uliosimbwa si usiosimamiwa kikamilifu — mtu bado lazima achapa neno/frasi ya LUKS kwenye kuwasha wa kwanza. Na kizuizi cha `disk_encryption` katika `user_configuration.json` hubeba neno/frasi hiyo katika maandishi wazi, kwa hivyo tibu kiendeshaji cha cidata kilichojengwa kutoka usakinishaji uliosimbwa kama siri ilivyo.
