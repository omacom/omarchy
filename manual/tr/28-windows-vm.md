# Windows VM

Omarchy, Windows'u bir Docker VM aracılığıyla çalıştırmanın kolay bir yolunu sunar. Onu Omarchy menüsünden (`Super + Space`) _Kur > Windows_ seçeneğini kullanarak kurabilirsiniz.

Makinenizin bunun için KVM sanallaştırmasına ihtiyacı vardır; çoğu makinede vardır — ancak bazen BIOS'ta kapatılmıştır ve kurulum programı durumun böyle olup olmadığını size söyler. Ayrıca disk alanına da ihtiyacınız olacaktır: Windows'a vereceğiniz kadar, artı görüntünün kendisi için yaklaşık 10GB.

Kurulum programı ne kadar RAM, kaç CPU çekirdeği ve ne kadar disk verileceğini sorar (64GB veya daha fazlası mantıklı tabandır), ardından bir Windows kullanıcı adı ve parolası sorar. Bunları boş bırakırsanız `docker` / `admin` alırsınız. İndirme biraz zaman alır — 10-15 dakika normaldir — ve ilerlemeyi tarayıcıda şu adreste izleyebilirsiniz: `http://127.0.0.1:8006`. Tarayıcı, konsolu açmadan önce aynı kullanıcı adı ve parolayı sorar.

 ![windows-vm](images/windows-vm.webp)

## Kullanımı

Kurulduktan sonra, uygulama başlatıcıdan _Windows_ uygulamasını başlatın. Bu, VM zaten çalışmıyorsa onu başlatır ve sizi RDP üzerinden tam ekran bağlar. Soğuk başlatmada 15-30 saniye bekleyin.

RDP oturumu sesi, mikrofonunuzu ve paylaşılan bir panoyu taşır, böylece Linux ile Windows arasında metin kopyalamak sorunsuz çalışır. Çözünürlük pencerenizi izler ve Omarchy ekran ölçeklemenizi aktarır, bu yüzden HiDPI ekranda bulanık bir karmaşa değildir.

RDP penceresini kapattığınızda VM otomatik olarak kapanır. Çalışır durumda bırakmayı tercih ederseniz — diyelim ki orada çalışan bir şeyiniz var — onu bunun yerine `omarchy windows vm launch --keep-alive` ile başlatın.

Kontrollerin geri kalanı aynı komut üzerindedir:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Dosyaları paylaşmak

Ana dizininizdeki `~/Windows` dizini, VM ile otomatik olarak paylaşılır. Windows tarafından erişilebilir olmalarını isterseniz dosyaları oraya koyun. VM'nin dosya sisteminizin başka hiçbir kısmına erişimi yoktur, bu yüzden Windows tarafındaki herhangi bir kötü şeyden güvendesiniz. Kendi sanal diski `~/.windows` adresinde kullanılabilir.

Bu tanıdık ana dizin yolları kendi dosya sistemlerinde kalır. Bunlar ayrıca, sanal disk daha büyük bir sürücüde yaşadığında kullanışlı olan, size ait dizinlere sembolik bağlantılar da olabilir. Kurulum programı, boş alanı ana dizininizi içeren dosya sisteminde değil, gerçekten `~/.windows` içeren dosya sisteminde ölçer.

Disk ve paylaşılan yolları ayrı, çakışmayan dizinler olarak tutun. Kaldırma, disk dizinini kasıtlı olarak boşaltır ancak paylaşılan dizini korur. Silmeden hemen önce Omarchy, sınırlı bir kapsama kontrolü gerçekleştirir ve bu kontrol zaman aşımına uğrarsa veya iki ağacın ayrı olduğunu kanıtlayamazsa herhangi bir şeyi kaldırmayı reddeder.

VM başlamadan önce Omarchy bu iki dizini açar ve sabitler, ardından tam dizin inode'larını `/var/lib/omarchy/windows/mounts` altındaki özel kullanıcı başına çapalar üzerine bağlayarak bağlar. Docker yalnızca bu root korumalı çapaları görür. Bu, özel disk konumlarını korurken, sizin adınıza çalışan başka bir işlemin, ayrıcalıklı kapsayıcı tüketmeden önce denetlenen bir yolu değiştirmesini önler. Mevcut disk ve paylaşılan dizinler, taşıma sırasında diğer yerel hesapların içeriklerine göz atamaması için `0700` moduna sıkılaştırılır.

VM'nin bağlantı noktaları yalnızca localhost'a bağlıdır, bu yüzden ağınızdaki hiçbir şey Windows makinesine ulaşamaz. Web konsolu ayrıca yapılandırılmış Windows kullanıcı adı ve parolasını gerektirir; bu, başka bir yerel hesabın 8006 numaralı bağlantı noktası üzerinden VM'yi yönlendirmesini önler.

## Sınırlar ve lisanslama

Bu kurulumla GPU geçişi yoktur, bu yüzden oyun veya video düzenleme için uygun değildir. Microsoft Office veya kesinlikle sahip olmanız gereken başka şeyleri çalıştırmanın harika bir yoludur.

Kurulan sürüm Windows 11 Pro'dur, etkinleştirilmemiştir. Kısıtlanmış özellikleri kullanmak için kendi lisans anahtarınıza ihtiyacınız olacaktır.

Bu bilgisayar Windows ile birlikte geldiyse, Omarchy kurulduktan sonra bile OEM anahtarı hâlâ bellenimdedir. Onu `omarchy windows key` ile yazdırın. Bu anahtar bu makineye bağlıdır — bu donanıma yeniden kurulan Windows'u etkinleştirir, ancak genellikle VM'yi etkinleştirmez.

Kaynak tahsisini daha sonra, yanıtlarınızdan VM'nin yapılandırmasını yeniden yazan `omarchy-windows-vm install` komutunu yeniden çalıştırarak değiştirebilirsiniz. Compose dosyasının kendisi artık `/var/lib/omarchy/windows/docker-compose.yml` adresinde yaşar ve root'a aittir — bu kasıtlıdır, böylece sizin adınıza çalışan bir işlem onu yeniden yazamaz ve ayrıcalıklı başlatmanın tüm diskinizi kapsayıcıya bağlamasını sağlayamaz. Onu elle düzenlemeniz gerekiyorsa (örneğin bir USB cihazı bağlamak için), `sudo` ile düzenleyin ve tüm seçenekleri [Dockur Windows projesinde](https://github.com/dockur/windows) görün.

Her şeyden kurtulmak için Omarchy menüsünden _Kaldır > Windows_ seçeneğini kullanın. Bu, VM'nin diskini ve tüm verilerini siler, bu yüzden önemsediğiniz her şeyin önce `~/Windows` dışına çıkarıldığından emin olun.
