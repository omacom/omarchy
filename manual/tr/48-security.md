# Güvenlik

Omarchy güvenliği son derece ciddiye alır. Bu, _Gerçek Dünya_'da _Gerçek İşler_ yapmak için kullanabileceğiniz bir işletim sistemi olacak şekilde tasarlandı. Dizüstü bilgisayarınızı kaybetmenin bir güvenlik acil durumuna dönüşemeyeceği bir sistem. İşte yaptıklarımız:

1. *Tam disk şifrelemesi varsayılan olarak açıktır*: Bu, verilerinizin fiziksel korunmasını sağlamanın en önemli adımıdır. Bilgisayarınız kaybolur veya çalınırsa, veriler standart LUKS (Linux Unified Key Setup) kullanılarak tamamen şifrelenmiş olur. Kurulum programı, gözden çıkarılabilir makineler için bundan vazgeçmenize izin verir (bkz. [Başlangıç](02-getting-started.md)); şifrelemesiz bir kurulumda bu korumanın hiçbiri yoktur ve sürücü elinde olan herkes onu okuyabilir.
2. *Güvenlik duvarı varsayılan olarak etkindir*: Gelen tüm trafik varsayılan olarak engellenir, birkaç istisna dışında: [LocalSend](https://localsend.org/) için 53317 numaralı port; Docker köprüsü adresindeki (172.17.0.1) bilgisayarın kendi çözümleyicisine yapılan DNS sorguları, Docker'ın konteynerlerine verdiği özel adres aralıklarından kabul edilir; ve multicast DNS (port 5353), yazıcıların ve ağınızdaki diğer cihazların birbirini bulmasını sağlar ve ayrıca bilgisayarınızın adını orada duyurur. Bunların üzerine, güvenlik duvarı UFW'nin ping, yönlendiricinizden bir adres alma (DHCP) ve UPnP keşfi için standart izinlerini korur. ssh bile, _Kurulum > Güvenlik > SSHD_ üzerinden açana kadar kapalıdır; bu, kurulumun bir parçası olarak 22 numaralı portu açar (kaba kuvvet saldırılarına karşı hız sınırlamalıdır). Hatta konteynerlerinizin yanlışlıkla dünyaya açılmasını önlemek için [ufw-docker](https://github.com/chaifeng/ufw-docker) kurulumunu kullanarak Docker erişimini de kilitleriz.
3. *Arch her zaman en son güncellemelere sahiptir*: Omarchy'nin üzerine inşa edildiği temel dağıtım olan Arch, sürekli güncellenen bir dağıtımdır. Bu, herhangi bir pakette keşfedilen ve yamalanan herhangi bir güvenlik açığının `omarchy-update` kullanılarak hızla kurulabilir hale geldiği anlamına gelir. Bu sayede her şeyin her zaman en son, en güvenli sürümlerini çalıştırırsınız.
4. *Omarchy kendi paketlerini ve mirror'ını sürdürür*: Omarchy varsayılan olarak yalnızca Arch'ın kendi core/extra/multilib depolarındaki paketlere ve kendi Omarchy Package Repository'sine güvenir. Yazılımı doğrudan AUR'dan kurabilirsiniz, ancak temel kurulum bunu yapmaz — yalnızca üçüncü taraf tarayıcılar gibi birkaç isteğe bağlı kurulum AUR'dan çeker.
5. *Cloudflare bizi DDoS'tan korur*: Omarchy dağıtım altyapısı — ISO'lar, Omarchy paketleri, Arch mirror'ı — Cloudflare'ın müthiş DDoS kalkanının arkasında korunur ve onların CDN'inde barındırılır. Bu, olağanüstü bir erişilebilirlik sağlar.

## Parolalarınızı değiştirme

Şifreli bir kurulumda iki parolanız vardır: biri önyüklemede sürücünün kilidini açan, diğeri oturum açmak ve `sudo` ile kullandığınız. Kurulum bunları aynı yapar. İkisi de Omarchy menüsünde _Güncelle > Parola_ altında değiştirilebilir — ilki için _Sürücü Şifrelemesi_, ikincisi için _Kullanıcı_. Sürücü parolasını değiştirmek önce mevcut parolayı sorar, bu yüzden onu elinizin altında bulundurun. Bir değişiklik yarıda kesilirse, _Sürücü Şifrelemesi_'ni tekrar çalıştırın: sürücünün kilidini şu anda açan parolayı sorar ve değişikliği tamamlar.

## Zaten kullandığınız bir makineyi başkasına verme

Makinenizi bir başkasına devrediyorsanız, yeniden kurmanıza gerek yok. Omarchy menüsünde _Kaldır > Fabrika Sıfırlaması_'nı çalıştırın, onaylamak için `reset` yazın ve yeniden başlatın. Bu, her kullanıcı hesabını ve `/home` içindeki her şeyi siler, kurulumdan beri yaptığınız tüm paketleri ve sistem değişikliklerini atar ve makinenin kimliğini temizler — ağ bağlantıları, host anahtarları ve hepsi. Geri açılan şey, ilk önyüklemedeki kurulum sihirbazıdır; yeni sahibinin kendi adını, parolasını ve şifreleme parolasını girmesine hazırdır.

Kurulum programının aldığı temel anlık görüntüyü geri yükleyerek çalışır, bu yüzden yalnızca Omarchy ISO'sundan kurulan makinelerde kullanılabilir. Ve şifrelemesi olmayan bir sürücüde, sıfırlama güvenli bir silme değil, yalnızca silmedir; bu yüzden veriler hassassa, bunun yerine sıfırdan kurulum yapın.

## Parolasız sudo

Bazen `sudo`'nun sormayı bırakmasını istersiniz, en sık da bir AI agent'ı sizin için uzun bir sistem çalışması yaparken. _Kurulum > Güvenlik > Parolasız Sudo_, erişime ne kadar süre izin verileceğini sorar: **15 dakika**, **1 Saat**, **1 Gün** veya **Kalıcı Olarak**. Erişim etkinken, diğer menü çubuğu göstergelerinin yanında kırmızı bir uyarı simgesi görünür. Erişimi kapatmak için ona tıklayın veya komutu tekrar çalıştırın. Ayrıca `omarchy-sudo-passwordless 30` ile kendi dakika sayınızı (1 ile 1440 arasında) verebilir veya `omarchy-sudo-passwordless permanent` kullanabilirsiniz.

Süreli erişim, son tarihi aşan bir askıya alma durumundan devam edildikten hemen sonra da dahil olmak üzere, otomatik olarak sona erer. Bilgisayarı yeniden başlatmak bunu erken bitirir. Kalıcı erişim yeniden başlatmalardan sonra da devam eder ve siz devre dışı bırakana kadar etkin kalır.

Omarchy'nin ayarlar paketini güncellemek veya kaldırmak, sona erme desteği değişmeden önce her türlü geçici izni sona erdirir. Komut bir yetkilendirme veya temizleme hatası bildirirse, başka bir izin etkinleştirmeye çalışmadan önce bunu çözün; bir hata, parolasız erişimin etkin olmadığı anlamına gelmez.

Bu konuda gözünüz açık olsun: bu açıkken, kullanıcınız olarak çalışan her şey, kendisine sorulmadan root olarak her şeyi yapabilir. Bütün mesele budur ve bütün risk de budur.

## İmzalama Anahtarları

Tüm ISO imzaları ve Omarchy repo paketi için genel anahtar `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([openpgp.org'da doğrulayın](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` paketi de bunu içerir ve olası güncellemelerin sorunsuz bir şekilde sunulması için kullanılacaktır.

Herhangi bir ISO sürümünün imzasını, URL'sine `.sig` ekleyerek bulabilirsiniz, örneğin `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
