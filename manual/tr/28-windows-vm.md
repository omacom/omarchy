# Windows VM

Omarchy, x86_64 makinelerde Docker VM ile Windows çalıştırmanın kolay bir yolunu sunuyor. Bunu Omarchy menüsünden (`Super + Space`) _Kur > Windows_ seçeneğiyle kurabilirsiniz.

Makineniz bunun için KVM sanallaştırmasına ihtiyaç duyuyor; çoğu makinede var — ama bazen BIOS'ta kapalıdır ve öyleyse kurulum programı size bunu söyler. Disk alanına da ihtiyacınız olacak: Windows'a verdiğiniz kadar, artı imajın kendisi için yaklaşık 10GB.

Kurulum programı ne kadar RAM, kaç CPU çekirdeği ve ne kadar disk tahsis edeceğinizi sorar (64GB veya daha fazlası makul alt sınırdır), ardından bir Windows kullanıcı adı ve parolası sorar. Bunları boş bırakırsanız `docker` / `admin` alırsınız. İndirme biraz zaman alır — 10-15 dakika normaldir — ve ilerlemeyi tarayıcıda `http://127.0.0.1:8006` adresinden takip edebilirsiniz. Tarayıcı, konsolu açmadan önce aynı kullanıcı adını ve parolayı ister.

 ![windows-vm](images/windows-vm.webp)

## Kullanımı

Kurulduktan sonra uygulama başlatıcıdan _Windows_'u başlatın. Bu, zaten çalışmıyorsa VM'yi başlatır ve size RDP üzerinden tam ekran bağlanır. Soğuk başlatmada ona 15-30 saniye verin.

RDP oturumu sesi, mikrofonunuzu ve paylaşılan bir panoyu taşır, bu yüzden Linux ile Windows arasında metin kopyalamak sorunsuz çalışır. Çözünürlük pencerenizi takip eder ve Omarchy ekran ölçeklendirmenizi geçirir, böylece HiDPI ekranda bulanık bir karmaşayla karşılaşmazsınız.

RDP penceresini kapattığınızda VM otomatik olarak kapanır. Çalışır durumda bırakmayı tercih ederseniz — diyelim içinde çalışmaya devam eden bir şeyiniz var — bunun yerine `omarchy windows vm launch --keep-alive` ile başlatın.

Kontrollerin geri kalanı aynı komuttadır:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Dosya paylaşımı

Ev dizininizdeki `~/Windows` dizini VM ile otomatik olarak paylaşılır. Windows'un erişebilmesini istediğiniz dosyaları oraya koyun. VM'nin dosya sisteminizin başka hiçbir bölümüne erişimi yoktur, bu yüzden Windows tarafındaki herhangi bir kötü amaçlı şeye karşı güvendesiniz. Kendi sanal diski `~/.windows` konumundadır.

Bu tanıdık ev dizini yolları kendi dosya sistemlerinde kalır. Ayrıca size ait dizinlere işaret eden symlink'ler de olabilirler; bu, sanal disk daha büyük bir sürücüde bulunduğunda kullanışlıdır. Kurulum programı boş alanı, ev dizininizi içeren dosya sisteminde değil, gerçekten `~/.windows` ögesini içeren dosya sisteminde ölçer.

Disk ve paylaşılan yolları ayrı, çakışmayan dizinler olarak tutun. Kaldırma işlemi disk dizinini kasıtlı olarak boşaltır ama paylaşılan dizini korur. Silme işleminden hemen önce Omarchy sınırlı bir kapsama denetimi gerçekleştirir ve bu denetim zaman aşımına uğrarsa veya iki ağacın ayrı olduğunu kanıtlayamazsa herhangi bir şeyi kaldırmayı reddeder.

VM başlamadan önce Omarchy bu iki dizini açıp sabitler, ardından birebir aynı dizin inode'larını `/var/lib/omarchy/windows/mounts` altındaki özel, kullanıcıya özgü dayanak noktalarına bind-mount ile bağlar. Docker yalnızca root tarafından korunan bu dayanak noktalarını görür. Bu, özel disk konumlarını korurken, siz olarak çalışan başka bir işlemin, ayrıcalıklı kapsayıcı kullanmadan önce denetlenmiş bir yolu değiştirmesini engeller. Mevcut disk ve paylaşılan dizinler, diğer yerel hesapların içeriklerine göz atamaması için geçiş sırasında `0700` moduna sıkılaştırılır.

VM'nin portları yalnızca localhost'a bağlıdır, bu yüzden ağınızdaki hiçbir şey Windows makinesine ulaşamaz. Web konsolu da yapılandırılmış Windows kullanıcı adını ve parolasını gerektirir; bu, başka bir yerel hesabın VM'yi 8006 portu üzerinden çalıştırmasını engeller.

## Sınırlar ve lisanslama

Bu kurulumda GPU passthrough yoktur, bu yüzden oyun veya video düzenleme için uygun değildir. Microsoft Office'i veya mutlaka sahip olmanız gereken başka her şeyi çalıştırmak için harika bir yoldur.

Kurulan sürüm Windows 11 Pro'dur ve etkinleştirilmemiştir. Kısıtlanmış özellikleri kullanmak için kendi lisans anahtarınıza ihtiyacınız olacak.

Bu bilgisayar Windows ile geldiyse, Omarchy kurulduktan sonra bile OEM anahtarı firmware içinde hâlâ duruyordur. `omarchy windows key` ile yazdırın. Bu anahtar bu makineye bağlıdır — bu donanımda yeniden kurulan Windows'u etkinleştirir, ama genellikle VM'yi etkinleştirmez.

Kaynak tahsisini daha sonra bir terminalde `omarchy windows vm install` çalıştırarak değiştirebilirsiniz; bu, VM'nin yapılandırmasını yanıtlarınıza göre yeniden yazar. Compose dosyasının kendisi artık `/var/lib/omarchy/windows/docker-compose.yml` konumunda bulunur ve root'a aittir — bu kasıtlıdır, böylece siz olarak çalışan bir işlem onu yeniden yazıp ayrıcalıklı başlatmanın tüm diskinizi kapsayıcıya bağlamasını sağlayamaz. Elle düzenlemeniz gerekirse (örneğin bir USB cihazı bağlamak için), `sudo` ile düzenleyin ve tüm seçenekler için [Dockur Windows projesine](https://github.com/dockur/windows) bakın.

Her şeyden kurtulmak için Omarchy menüsünden _Kaldır > Windows_ seçeneğini kullanın. Bu, VM'nin `~/.windows` içindeki diskini ve Windows içine kurulan her şeyi siler, bu yüzden önce ihtiyacınız olan her şeyi VM'den dışarı kopyalayın. Paylaşılan `~/Windows` klasörünüze dokunulmaz.
