# Gözetimsiz Kurulumlar

Omarchy ISO'su, klavyenin başında kimse yokken kendisini kurabilir. Kurulum programı, yapılandırma dosyalarını taşıyan `cidata` etiketli ikinci bir sürücü bulursa, onları kopyalar, kurulum sihirbazını tamamen atlar ve bitmiş sisteme kendi başına yeniden başlatır. Özel bir ISO yapısı yok, ekstra bir önyükleme menüsü girişi yok — böyle bir sürücü takılı olmadığında hiçbir şey değişmez ve normal sihirbazı alırsınız.

Bu, Omarchy'yi tek kullanımlık geliştirme ortamları için harika bir temel görüntü yapar: Proxmox'ta veya Packer ile bir VM oluşturun, önyükleme yapın, uzaklaşın, SSH ile bağlanın. `cidata` cloud-init `NoCloud` etiketidir, bu yüzden yaygın sanallaştırma araçlarının tamamı böyle bir sürücüyü nasıl takacağını zaten bilir.

## Yapılandırma dosyaları

Dosyalar tam olarak kurulum programının kendi sihirbazının yazdığı şeylerdir; bu yüzden bir başlangıç seti elde etmenin en kolay yolu, bir etkileşimli kurulum (örneğin bir VM'de) çalıştırmak ve `/root` içine yazdıklarını kopyalamaktır:

| Dosya | Gerekli | Amaç |
|------|----------|---------|
| `user_configuration.json` | Evet | Disk, ana bilgisayar adı, saat dilimi, klavye |
| `user_credentials.json` | Evet | Kullanıcı adı ve parola özeti |
| `user_full_name.txt` | Hayır | Git tam adı |
| `user_email_address.txt` | Hayır | Git e-postası |
| `user_encrypt_installation.txt` | Hayır | Yapılandırma bir `disk_encryption` bloğu taşıdığında `true` |
| `authorized_keys` | Hayır | SSH genel anahtarları, satır başına bir tane |
| `tailscale_authkey` | Hayır | İlk önyüklemede tailnet'inize katılmak için Tailscale yetkilendirme anahtarı |

`user_credentials.json` için parola özetini `openssl passwd -6 "yourpassword"` ile oluşturun.

`user_credentials.json` yerine `defer-provisioning` adlı boş bir dosya da bırakabilirsiniz. Bu, etkileşimli olarak tetikleyebileceğiniz [başka bir sahip için hazırla kurulumunun](02-getting-started.md) aynısını çalıştırır: makine kişisel ayrıntılar olmadan kurulur ve onu ilk önyükleyen kişi klavyesini seçer ve kullanıcısını oluşturur. Bu, sürücünün hiç kimsenin kimlik bilgilerini taşımaması gereken imajlama düzenekleri için bir moddur.

## SSH erişimi

`authorized_keys` mevcut olduğunda, kurulum anahtarları kullanıcının `~/.ssh/authorized_keys` dosyası olarak ayarlar, `sshd` hizmetini etkinleştirir ve güvenlik duvarını onun için açar. (Stok bir Omarchy kurulumu, hizmet devre dışı ve bağlantı noktası kapalı olarak openssh ile birlikte gelir, bu yüzden gözetimsiz bir makineye başka türlü ulaşılamaz.) Kurulum yalnızca anahtarlarınızı ekler — SSH arka plan hizmetinin diğer kimlik doğrulama ayarlarından hiçbirini gevşetmez.

`tailscale_authkey` mevcut olduğunda, makine bunun yerine ilk önyüklemede tailnet'inize katılır: Tailscale ISO'nun paketlenmiş paketlerinden kurulur, güvenlik duvarı tailnet arayüzüne izin verir ve bir arka plan işi, makine gerçekten ağa kavuşur kavuşmaz katılımı çalıştırır ve başarana kadar yeniden dener. Bir sürücü görüntüsünün birçok makineye hizmet edebilmesi için yeniden kullanılabilir, önceden yetkilendirilmiş bir anahtar kullanın.

## cidata sürücüsünü oluşturma

Doğru etikete sahip herhangi bir dosya sistemi çalışır. Küçük bir ISO kolay yoldur:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Ardından onu Omarchy ISO'sunun yanı sıra VM'ye takın. İşte eksiksiz bir Proxmox örneği:

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

Önyükleme sırası diski bilerek önce listeler: boş disk ilk önyüklemede ISO'ya düşer ve kurulu sistem bundan sonra hep diskten önyükleme yapar.

## İki uyarı

Şifreli gözetimsiz kurulumlar tam olarak gözetimsiz değildir — ilk önyüklemede birinin hâlâ LUKS parolasını yazması gerekir. Ve `user_configuration.json` içindeki `disk_encryption` bloğu o parolayı düz metin olarak taşır, bu yüzden şifreli bir kurulumdan oluşturulmuş bir cidata sürücüsüne, olduğu şey olan bir sır gibi davranın.
