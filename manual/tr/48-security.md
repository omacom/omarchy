# Güvenlik

Omarchy güvenliği son derece ciddiye alır. Bunun, _Gerçek Dünyada_ _Gerçek İşler_ yapmak için kullanabileceğiniz bir işletim sistemi olması amaçlanıyor. Dizüstü bilgisayarınızı kaybetmenin bir güvenlik acil durumuna yol açamayacağı bir yer. İşte yaptıklarımız:

1. *Tam disk şifrelemesi varsayılan olarak açıktır*: Bu, verilerinizin fiziksel korunmasını sağlamanın en önemli adımıdır. Bilgisayarınız kaybolur veya çalınırsa, veriler standart LUKS (Linux Unified Key Setup) kullanılarak tamamen şifrelenmiş olur. Kurulum programı, kullanılıp atılabilir makineler için bunu devre dışı bırakmanıza izin verir (bkz. [Başlangıç](02-getting-started.md)); şifreleme olmadan yapılan bir kurulumda bu korumanın hiçbiri yoktur ve sürücüyü elinde bulunduran herkes onu okuyabilir.
2. *Güvenlik duvarı varsayılan olarak etkindir*: Gelen tüm trafik varsayılan olarak engellenir, birkaç istisna dışında: [LocalSend](https://localsend.org/) için 53317 numaralı bağlantı noktası; Docker'ın kapsayıcılarına verdiği özel adres aralıklarından kabul edilen, bilgisayarın Docker köprü adresindeki (172.17.0.1) kendi çözümleyicisine yönelik DNS sorguları; ve yazıcıların ve ağınızdaki diğer cihazların birbirini bulmasını sağlayan, ayrıca bilgisayarınızın adını da orada duyuran çok noktaya yayın DNS (5353 numaralı bağlantı noktası). Bunların üzerine, güvenlik duvarı UFW'nin ping, yönlendiricinizden adres alma (DHCP) ve UPnP keşfi için standart izinlerini korur. ssh bile, kurulumun bir parçası olarak 22 numaralı bağlantı noktasını (kaba kuvvete karşı hız sınırlamalı) açan _Setup > Security > SSHD_ aracılığıyla açana kadar kapalıdır. Kapsayıcılarınızın yanlışlıkla dünyaya açılmasını önlemek için [ufw-docker](https://github.com/chaifeng/ufw-docker) kurulumunu kullanarak Docker erişimini bile kilitliyoruz.
3. *Arch her zaman en son güncellemelere sahiptir*: Omarchy'nin üzerine inşa edildiği alttaki dağıtım olan Arch, yuvarlanan bir dağıtımdır. Bu, herhangi bir pakette keşfedilen ve yamalanan herhangi bir güvenlik açığının `omarchy-update` kullanılarak kurulum için hızla kullanılabilir olduğu anlamına gelir. Bu şekilde her zaman her şeyin en son, en güvenli sürümlerini çalıştırırsınız.
4. *Omarchy kendi paketlerini ve yansısını korur*: Omarchy varsayılan olarak yalnızca Arch'ın kendi core/extra/multilib depolarındaki paketlere ve kendi Omarchy Package Repository'sine güvenir. Yazılımı doğrudan AUR'dan kurabilirsiniz, ancak temel kurulum bunu yapmaz — yalnızca üçüncü taraf tarayıcılar gibi birkaç isteğe bağlı kurulum AUR'dan çeker.
5. *Cloudflare bizi DDoS'tan korur*: Omarchy dağıtım altyapısı — ISO'lar, Omarchy paketleri, Arch yansısı — Cloudflare'in zorlu DDoS kalkanının arkasında korunur ve onların CDN'sinde barındırılır. Bu, mükemmel kullanılabilirlik sağlar.

## Parolalarınızı değiştirme

Şifreli bir kurulumda iki parolanız vardır: biri önyüklemede sürücünün kilidini açan, diğeri oturum açmak ve `sudo` ile kullanmak için kullandığınız. Setup ikisini de aynı yapar. İkisi de Omarchy menüsünde _Update > Password_ altında değiştirilebilir — ilki için _Drive Encryption_, ikincisi için _User_. Sürücü parolasını değiştirmek önce mevcut olanı sorar, bu yüzden onu elinizin altında bulundurun. Bir değişiklik yarıda kesilirse _Drive Encryption_'ı tekrar çalıştırın: sürücünün kilidini şu anda açan parolayı sorar ve değişikliği tamamlar.

## Zaten kullandığınız bir makineyi başkasına verme

Makinenizi başkasına veriyorsanız, onu yeniden kurmanız gerekmez. Omarchy menüsünde _Setup > Reset Computer_'ı çalıştırın, onaylamak için `reset` yazın ve yeniden başlatın. Bu, her kullanıcı hesabını ve `/home` içindeki her şeyi siler, kurulumdan beri yaptığınız tüm paketleri ve sistem değişikliklerini atar ve makinenin kimliğini temizler — ağ bağlantıları, ana bilgisayar anahtarları ve her şey. Tekrar açıldığında, ilk önyüklemedeki kurulum sihirbazı gelir, yeni sahibinin kendi adını, parolasını ve şifreleme parolasını girmesi için hazırdır.

Bu, kurulum programının aldığı temel anlık görüntüyü geri yükleyerek çalışır, bu yüzden yalnızca Omarchy ISO'sundan kurulan makinelerde kullanılabilir. Ve şifrelemesiz bir sürücüde, sıfırlama güvenli bir silme değil silme işlemidir, bu yüzden veriler hassassa bunun yerine temiz kurulum yapın.

## Parolasız sudo

Bazen `sudo`'nun sormayı bırakmasını istersiniz, en sık da bir AI agent sizin için uzun bir sistem işini yaparken. _Setup > Security > Passwordless Sudo_ erişime ne kadar süre izin verileceğini sorar: **15 dakika**, **1 Saat**, **1 Gün** veya **Kalıcı olarak**. Erişim etkinken diğer menü çubuğu göstergelerinin yanında kırmızı bir uyarı simgesi görünür. Kapatmak için ona tıklayın veya komutu tekrar çalıştırın. Ayrıca `omarchy-sudo-passwordless 30` ile kendi dakika sayınızı (1 ile 1440 arasında) verebilir veya `omarchy-sudo-passwordless permanent` kullanabilirsiniz.

Süreli erişimin süresi otomatik olarak dolar, son tarihi aşan bir askıya alma durumundan devam ettikten hemen sonra da dahil. Bilgisayarı yeniden başlatmak bunu erken sonlandırır. Kalıcı erişim yeniden başlatmalardan sonra da devam eder ve siz devre dışı bırakana kadar etkin kalır.

Omarchy'nin ayarlar paketini güncellemek veya kaldırmak, süre dolma desteği değişmeden önce herhangi bir geçici izni sonlandırır. Komut bir yetkilendirme veya temizleme hatası bildirirse, başka bir izin etkinleştirmeye çalışmadan önce bunu çözün; bir hata parolasız erişimin etkin olmadığı anlamına gelmez.

Bu konuda net olun: bu açıkken, kullanıcınız olarak çalışan her şey, sorulmadan root olarak her şeyi yapabilir. Bütün mesele bu, ve bütün risk de bu.

## İmzalama Anahtarları

Tüm ISO imzaları ve Omarchy repo paketi için genel anahtar `40DFB630FF42BCFFB047046CF0134EE680CAC571`'dir ([openpgp.org'da doğrulayın](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` paketi de bunu içerir ve olası güncellemelerin sorunsuz bir şekilde sunulması için kullanılacaktır.

Herhangi bir ISO sürümünün imzasını, URL'sine `.sig` ekleyerek bulabilirsiniz, örneğin `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
