# Güvenlik

Omarchy güvenliği son derece ciddiye alır. Bu, _Gerçek Dünya_'da _Gerçek İş_ yapmak için kullanabileceğiniz bir işletim sistemi olacak şekilde tasarlanmıştır. Dizüstü bilgisayarınızı kaybetmenin bir güvenlik acil durumuna dönüşemeyeceği bir işletim sistemi. İşte yaptıklarımız:

1. *Tam disk şifreleme varsayılan olarak açıktır*: Bu, verilerinizin fiziksel korunmasını sağlamak için en önemli adımdır. Bilgisayarınız kaybolur veya çalınırsa, veriler standart LUKS (Linux Unified Key Setup) kullanılarak tamamen şifrelenir. Kurulum programı, gözden çıkarılabilir makineler için bundan vazgeçmenize izin verir (bkz. [Başlarken](02-getting-started.md)); şifreleme olmadan yapılan bir kurulumda bu korumanın hiçbiri yoktur ve sürücü elinde olan herkes onu okuyabilir.
2. *Güvenlik duvarı varsayılan olarak etkindir*: Tüm gelen trafik varsayılan olarak engellenir, birkaç istisna dışında: [LocalSend](https://localsend.org/) için 53317 numaralı bağlantı noktası; Docker'ın kapsayıcılarına verdiği özel adres aralıklarından kabul edilen, Docker köprü adresindeki (172.17.0.1) bilgisayarın kendi çözümleyicisine yapılan DNS sorguları; ve yazıcıların ve ağınızdaki diğer cihazların birbirini bulmasını sağlayan ve ayrıca bilgisayarınızın adını orada duyuran çok noktaya yayın DNS'i (5353 numaralı bağlantı noktası). Bunların yanında, güvenlik duvarı UFW'nun ping, yönlendiricinizden adres alma (DHCP) ve UPnP keşfi için standart izinlerini korur. SSH anahtarınızı yetkilendiren, parola ile oturum açmayı kapatan ve ancak ondan sonra 22 numaralı bağlantı noktasını açan (kaba kuvvete karşı hız sınırlamalı) _Kurulum > Güvenlik > SSHD_ üzerinden açana kadar ssh bile kapalıdır. Kapsayıcılarınızın yanlışlıkla dünyaya açılmasını önlemek için [ufw-docker](https://github.com/chaifeng/ufw-docker) kurulumunu kullanarak Docker erişimini bile kilitliyoruz.
3. *Arch her zaman en son güncellemelere sahiptir*: Omarchy'nin üzerine inşa edildiği temel dağıtım olan Arch, sürekli güncellenen bir dağıtımdır. Bu, herhangi bir pakette keşfedilen ve yamalanan her güvenlik açığının `omarchy-update` kullanılarak hızla kurulabileceği anlamına gelir. Bu sayede her zaman her şeyin en yeni, en güvenli sürümlerini çalıştırırsınız.
4. *Omarchy kendi paketlerini ve yansısını korur*: Omarchy varsayılan olarak yalnızca Arch'nin kendi core/extra/multilib depolarındaki (ARM makinelerinde Arch Linux ARM'ın depoları, ayrıca Apple Silicon üzerinde Asahi ALARM) paketlere ve kendi Omarchy Package Repository'sine dayanır. Yazılımı doğrudan AUR'dan kurabilirsiniz, ancak temel kurulum bunu yapmaz — üçüncü taraf tarayıcılar gibi yalnızca birkaç isteğe bağlı kurulum AUR'dan çeker.
5. *Cloudflare bizi DDoS'tan korur*: Omarchy dağıtım altyapısı — ISO'lar, Omarchy paketleri, Arch yansısı — Cloudflare'ın güçlü DDoS kalkanının arkasında korunur ve onların CDN'i üzerinde barındırılır. Bu, mükemmel kullanılabilirlik sağlar.

## Parolalarınızı değiştirme

Şifreli bir kurulumda iki parolanız vardır: açılışta sürücünün kilidini açan ve oturum açmak ve `sudo` ile kullanmak için kullandığınız. Kurulum bunları aynı yapar. Omarchy menüsündeki _Güncelleme > Parola_ ikisini birden değiştirir, böylece aynı kalırlar: mevcut sürücü parolasını, ardından yenisini sorar, sürücününkini değiştirir ve sonra oturum açma parolanızı buna uyacak şekilde ayarlar. Sürücü şifrelemesi olmadan yalnızca oturum açma parolanızı değiştirir. Bir değişiklik yarıda kesilirse, _Güncelleme > Parola_'yı tekrar çalıştırın: sürücünün kilidini şu anda açan parolayı sorar, değişikliği tamamlar ve oturum açma parolanızı buna ayarlar. Başka bir şifreli sürücünün parolasını değiştirmek için bir terminalde `omarchy-drive-password` çalıştırın.

## Kullandığınız bir makineyi başkasına verme

Makinenizi başka birine veriyorsanız, yeniden kurmanız gerekmez. Omarchy menüsünde _Kaldır > Fabrika Ayarlarına Sıfırla_'yı çalıştırın, onaylamak için `reset` yazın, istenirse sürücü şifreleme parolanızı girin ve yeniden başlatın. Bu, her kullanıcı hesabını ve `/home` içindeki her şeyi siler, kurulumdan bu yana yaptığınız tüm paketleri ve sistem değişikliklerini atar ve makinenin kimliğini — ağ bağlantıları, ana bilgisayar anahtarları ve her şeyi — temizler. Açıldığında gelen şey, ilk açılıştaki kurulum sihirbazıdır; yeni sahibinin kendi adını, parolasını ve şifreleme parolasını girmesi için hazırdır.

Kurulum programının aldığı temel anlık görüntüyü geri yükleyerek çalışır, bu yüzden yalnızca Omarchy ISO'sundan kurulan makinelerde kullanılabilir. Ve şifrelemesiz bir sürücüde sıfırlama, güvenli silme yerine silme işlemidir, bu nedenle veriler hassassa bunun yerine sıfırdan kurulum yapın.

## Parolasız sudo

Bazen `sudo`'nun sormayı bırakmasını istersiniz, en sık da bir yapay zekâ aracı sizin için uzun bir sistem çalışması yürütürken. _Kurulum > Güvenlik > Parolasız Sudo_, erişime ne kadar süreyle izin verileceğini sorar: **15 dakika**, **1 Saat**, **1 Gün** veya **Kalıcı olarak**. Erişim etkin olduğu sürece diğer menü çubuğu göstergelerinin yanında kırmızı bir uyarı simgesi görünür. Kapatmak için üzerine tıklayın veya komutu tekrar çalıştırın. `omarchy-sudo-passwordless 30` ile kendi dakika sayınızı da (1 ile 1440 arasında) verebilir veya `omarchy-sudo-passwordless permanent` kullanabilirsiniz.

Süreli erişimin süresi, son tarihi aşan bir askıya alma durumundan devam ettikten hemen sonra da dahil olmak üzere, otomatik olarak dolar. Bilgisayarı yeniden başlatmak bunu erken sonlandırır. Kalıcı erişim yeniden başlatmalardan sonra da devam eder ve siz devre dışı bırakana kadar etkin kalır.

Omarchy'nin ayar paketini güncellemek veya kaldırmak, süre sonu desteği değişmeden önce tüm geçici yetkileri sonlandırır. Komut bir yetkilendirme veya temizleme hatası bildirirse, başka bir yetki etkinleştirmeye çalışmadan önce bunu giderin; bir hata, parolasız erişimin etkin olmadığı anlamına gelmez.

Bu konuda gözünüz açık olsun: açıkken, kullanıcınız olarak çalışan her şey, sorulmadan root olarak her şeyi yapabilir. Zaten bütün amaç bu, bütün risk de bu.

## İmzalama Anahtarları

Tüm ISO imzaları ve Omarchy repo paketi için genel anahtar `40DFB630FF42BCFFB047046CF0134EE680CAC571` anahtarıdır ([openpgp.org'da doğrulayın](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` paketi de bunu içerir ve olası güncellemelerin sorunsuz bir şekilde dağıtılması için kullanılacaktır.

Herhangi bir ISO sürümünün imzasını, URL'sine `.sig` ekleyerek bulabilirsiniz, örneğin `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
