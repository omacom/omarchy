# Katılımsız Kurulumlar

Omarchy ISO'su, klavye başında kimse olmadan kendini kurabilir. Kurulum programı, yapılandırma dosyalarını taşıyan `cidata` etiketli ikinci bir sürücü bulursa dosyaları kopyalar, kurulum sihirbazını tamamen atlar ve kendi kendine bitmiş sisteme yeniden başlar. Özel bir ISO derlemesi yok, fazladan bir önyükleme menüsü girişi yok — böyle bir sürücü takılı değilse hiçbir şey değişmez ve normal sihirbazı alırsınız.

Bu, Omarchy'yi tek kullanımlık geliştirme ortamları için harika bir temel imaj yapar: Proxmox'ta veya Packer ile bir VM oluşturun, önyükleyin, uzaklaşın, SSH ile bağlanın. `cidata`, cloud-init `NoCloud` etiketidir, bu yüzden yaygın sanallaştırma araçlarının hepsi böyle bir sürücüyü nasıl takacağını zaten bilir.

## Yapılandırma dosyaları

Dosyalar tam olarak kurulum programının kendi sihirbazının yazdıklarıdır, bu yüzden bir başlangıç seti elde etmenin en kolay yolu etkileşimli bir kurulum çalıştırmak (diyelim bir VM'de) ve `/root` içine yazdıklarını kopyalamaktır:

| Dosya | Gerekli | Amaç |
|------|----------|---------|
| `user_configuration.json` | Evet | Disk, ana bilgisayar adı, saat dilimi, klavye |
| `user_credentials.json` | Evet | Kullanıcı adı ve parola karması |
| `user_encrypt_installation.txt` | Hayır | Yapılandırma bir `disk_encryption` bloğu taşıdığında `true` |
| `authorized_keys` | Hayır | SSH genel anahtarları, satır başına bir tane |
| `tailscale_authkey` | Hayır | İlk önyüklemede tailnet'inize katılmak için Tailscale kimlik doğrulama anahtarı |

`user_credentials.json` için parola karmasını `openssl passwd -6 "yourpassword"` ile oluşturun.

Git commit'leri için ad ve e-posta kurulumun parçası değildir. Bunları makine açıldıktan sonra, örneğin SSH üzerinden, `omarchy setup git --name "Jane Doe" --email jane@example.com` ile ayarlayın.

`user_credentials.json` yerine `defer-provisioning` adlı boş bir dosya da bırakabilirsiniz. Bu, etkileşimli olarak tetikleyebildiğiniz [başka bir sahip için hazırlama kurulumu](02-getting-started.md) ile aynı kurulumu çalıştırır: makine hiçbir kişisel ayrıntı olmadan kurulur ve onu ilk önyükleyen kişi klavyesini seçer ve kullanıcısını oluşturur. Bu, sürücünün hiç kimsenin kimlik bilgilerini taşımaması gereken imajlama düzenekleri için olan moddur.

## SSH erişimi

`authorized_keys` mevcut olduğunda, kurulum anahtarları kullanıcının `~/.ssh/authorized_keys` dosyası olarak ayarlar, `sshd`'yi etkinleştirir ve güvenlik duvarını ona açar. (Standart bir Omarchy kurulumu openssh ile birlikte gelir ancak hizmet devre dışıdır ve port kapalıdır, bu yüzden katılımsız bir makineye aksi halde ulaşılamazdı.) Kurulum yalnızca anahtarlarınızı ekler — SSH arka plan programının diğer kimlik doğrulama ayarlarının hiçbirini gevşetmez.

`tailscale_authkey` mevcut olduğunda, makine bunun yerine ilk önyüklemede tailnet'inize katılır: Tailscale, ISO'nun birlikte gelen paketlerinden kurulur, güvenlik duvarı tailnet arayüzüne izin verir ve bir arka plan işi, makine gerçekten ağa bağlanır bağlanmaz katılımı çalıştırır ve başarana kadar yeniden dener. Tek bir sürücü imajının birçok makineye hizmet verebilmesi için yeniden kullanılabilir, önceden yetkilendirilmiş bir anahtar kullanın.

## cidata sürücüsünü oluşturma

Doğru etikete sahip herhangi bir dosya sistemi çalışır. Küçük bir ISO kolay yoldur:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Ardından onu Omarchy ISO'sunun yanında VM'ye takın. İşte eksiksiz bir Proxmox örneği:

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

Önyükleme sırası diski bilerek ilk sıraya koyar: boş disk ilk önyüklemede ISO'ya düşer ve kurulan sistem ondan sonra hep diskten önyüklenir.

## İki uyarı

Şifreli katılımsız kurulumlar tam olarak katılımsız değildir — ilk önyüklemede birinin hâlâ LUKS parolasını yazması gerekir. Ve `user_configuration.json` içindeki `disk_encryption` bloğu o parolayı düz metin olarak taşır, bu yüzden şifreli bir kurulumdan oluşturulmuş bir cidata sürücüsüne, olduğu sır gibi davranın.
