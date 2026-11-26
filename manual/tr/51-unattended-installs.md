# Gözetimsiz Kurulumlar

Omarchy ISO'su, klavye başında kimse olmadan kendini kurabilir. Kurulum programı `cidata` etiketli, yapılandırma dosyalarını taşıyan ikinci bir sürücü bulursa dosyaları kopyalar, kurulum sihirbazını tamamen atlar ve bitmiş sisteme kendi kendine yeniden başlar. Özel bir ISO derlemesi yok, fazladan bir önyükleme menüsü girdisi yok — böyle bir sürücü bağlı değilse hiçbir şey değişmez ve normal sihirbazı kullanırsınız.

Bu, Omarchy'yi atılabilir geliştirme ortamları için harika bir temel imaj haline getirir: Proxmox'ta ya da Packer ile bir VM oluşturun, başlatın, uzaklaşın, SSH ile bağlanın. `cidata`, cloud-init `NoCloud` etiketidir, yani yaygın sanallaştırma araçlarının tümü böyle bir sürücüyü nasıl bağlayacağını zaten bilir.

## Yapılandırma dosyaları

Dosyalar, kurulum programının kendi sihirbazının yazdıklarının tam aynısıdır; bu yüzden başlangıç setini edinmenin en kolay yolu etkileşimli bir kurulum çalıştırmak (örneğin bir VM'de) ve `/root` içine yazdıklarını kopyalamaktır:

| Dosya | Gerekli | Amaç |
|------|----------|---------|
| `user_configuration.json` | Evet | Disk, ana bilgisayar adı, saat dilimi, klavye |
| `user_credentials.json` | Evet | Kullanıcı adı ve parola hash'i ve şifreli bir kurulum için LUKS parolası |
| `user_encrypt_installation.txt` | Hayır | Yapılandırma bir `disk_encryption` bloğu taşıdığında `true` |
| `authorized_keys` | Hayır | SSH genel anahtarları, satır başına bir tane |
| `tailscale_authkey` | Hayır | İlk açılışta tailnet'inize katılmak için Tailscale kimlik doğrulama anahtarı |

`user_credentials.json` için parola hash'ini `openssl passwd -6 "yourpassword"` ile oluşturun.

Git commit'leri için ad ve e-posta, kurulumun bir parçası değildir. Makine açıldıktan sonra, örneğin SSH üzerinden, `omarchy setup git --name "Jane Doe" --email jane@example.com` ile bunları ayarlayın.

`user_credentials.json` yerine `defer-provisioning` adlı boş bir dosya da bırakabilirsiniz. Bu, etkileşimli olarak da tetikleyebileceğiniz [başka bir sahip için hazırlık kurulumunun](02-getting-started.md) aynısını çalıştırır: makine kişisel hiçbir ayrıntı olmadan kurulur ve onu ilk başlatan kişi klavyesini seçip kullanıcısını oluşturur. Sürücünün kimsenin kimlik bilgilerini taşımaması gereken imajlama düzenekleri için mod budur.

## SSH erişimi

`authorized_keys` mevcut olduğunda kurulum, anahtarları kullanıcının `~/.ssh/authorized_keys` dosyası olarak ayarlar, `sshd` hizmetini etkinleştirir ve güvenlik duvarını ona açar. (Standart bir Omarchy kurulumu, hizmet devre dışı ve port kapalı olarak openssh ile gelir; bu yüzden gözetimsiz bir makineye başka türlü ulaşılamazdı.) Kurulum yalnızca anahtarlarınızı ekler — SSH arka plan programının diğer kimlik doğrulama ayarlarının hiçbirini gevşetmez.

`tailscale_authkey` mevcut olduğunda makine bunun yerine ilk açılışta tailnet'inize katılır: Tailscale, ISO'nun birlikte gelen paketlerinden kurulur, güvenlik duvarı tailnet arabirimine izin verir ve bir arka plan işi, makine gerçekten ağa kavuşur kavuşmaz katılımı çalıştırır ve başarılı olana kadar yeniden dener. Tek bir sürücü imajının birçok makineye hizmet verebilmesi için yeniden kullanılabilir, önceden yetkilendirilmiş bir anahtar kullanın.

## cidata sürücüsünü oluşturma

Doğru etikete sahip herhangi bir dosya sistemi çalışır. Küçük bir ISO, kolay yoldur:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Ardından bunu VM'ye Omarchy ISO'sunun yanına bağlayın. İşte eksiksiz bir Proxmox örneği:

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

Önyükleme sırası diski bilerek ilk sıraya koyar: boş disk ilk açılışta ISO'ya düşer ve kurulan sistem bundan sonra hep diskten önyüklenir.

## İki uyarı

Şifreli gözetimsiz kurulumlar tamamen gözetimsiz değildir — ilk açılışta birinin hâlâ LUKS parolasını yazması gerekir. Ve o parola, `user_credentials.json` dosyasının en üst düzeyine `encryption_password` olarak gider — archinstall onu orada okur, `user_configuration.json` içindeki `disk_encryption` bloğundan okumaz — bu yüzden şifreli bir kurulumdan oluşturulmuş bir cidata sürücüsüne, olduğu gibi bir sır muamelesi yapın.
