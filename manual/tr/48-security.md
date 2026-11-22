# Güvenlik

Omarchy güvenliği son derece ciddiye alır. Bu, _Gerçek Dünya_ içinde _Gerçek İş_ yapmak için kullanabileceğiniz bir işletim sistemi olarak tasarlanmıştır. Bir dizüstü bilgisayarın kaybolmasının bir güvenlik acil durumuna yol açamayacağı bir sistem. İşte yaptıklarımız:

1. *Tam disk şifrelemesi varsayılan olarak açıktır*: Bu, verilerinizin fiziksel korunmasını sağlamanın en önemli adımıdır. Bilgisayarınız kaybolursa veya çalınırsa, veriler standart LUKS (Linux Unified Key Setup) kullanılarak tamamen şifrelenmiş durumdadır. Kurulum programı, kullanılıp atılacak makineler için bunu devre dışı bırakmanıza izin verir (bkz. [Başlarken](02-getting-started.md)); şifrelemesiz bir kurulumda bu korumanın hiçbiri yoktur ve diski elinde bulunduran herkes onu okuyabilir.
2. *Güvenlik duvarı varsayılan olarak etkindir*: Gelen tüm trafik varsayılan olarak engellenir, birkaç istisna dışında: [LocalSend](https://localsend.org/) için 53317 numaralı bağlantı noktası; Docker köprü adresindeki (172.17.0.1) bilgisayarın kendi çözümleyicisine yönelik, Docker'ın kapsayıcılarına verdiği özel adres aralıklarından kabul edilen DNS sorguları; ve yazıcıların ve ağınızdaki diğer cihazların birbirini bulmasını sağlayan, aynı zamanda bilgisayarınızın adını da orada duyuran çok noktaya yayın DNS'i (5353 numaralı bağlantı noktası). Bunların yanında güvenlik duvarı, ping, yönlendiricinizden bir adres alma (DHCP) ve UPnP keşfi için UFW'nin standart izinlerini korur. ssh bile, onu _Setup > Security > SSHD_ üzerinden açana kadar kapalıdır; bu işlem SSH anahtarınızı yetkilendirir, parola ile oturum açmayı kapatır ve ancak ondan sonra 22 numaralı bağlantı noktasını açar (kaba kuvvet saldırılarına karşı hız sınırlamalıdır). Hatta kapsayıcılarınızın yanlışlıkla dünyaya açılmasını önlemek için [ufw-docker](https://github.com/chaifeng/ufw-docker) kurulumunu kullanarak Docker erişimini de kilitleriz.
3. *Arch her zaman en son güncellemelere sahiptir*: Omarchy'nin üzerine inşa edildiği alttaki dağıtım olan Arch, sürekli güncellenen bir dağıtımdır. Bu, herhangi bir pakette keşfedilen ve yamalanan herhangi bir güvenlik açığının, `omarchy-update` kullanılarak hızla kurulabilir hâle geldiği anlamına gelir. Bu şekilde her zaman her şeyin en son, en güvenli sürümlerini çalıştırırsınız.
4. *Omarchy kendi paketlerini ve yansısını kendisi sürdürür*: Omarchy varsayılan olarak yalnızca Arch'ın kendi core/extra/multilib depolarındaki (ARM makinelerde Arch Linux ARM'ın, ayrıca Apple Silicon üzerinde Asahi ALARM) paketlere ve kendi Omarchy Package Repository'sine dayanır. Doğrudan AUR'dan yazılım kurabilirsiniz, ancak temel kurulum bunu yapmaz — üçüncü taraf tarayıcılar gibi yalnızca birkaç isteğe bağlı kurulum AUR'dan çeker.
5. *Cloudflare bizi DDoS'a karşı korur*: Omarchy dağıtım altyapısı — ISO'lar, Omarchy paketleri, Arch yansısı — Cloudflare'ın güçlü DDoS kalkanının arkasında korunur ve onların CDN'i üzerinde barındırılır. Bu, mükemmel erişilebilirlik sağlar.

## Parolalarınızı değiştirme

Şifreli bir kurulumda iki parolanız vardır: açılışta diskin kilidini açan ve oturum açmak ve `sudo` ile kullanmak için kullandığınız. Setup, bunları aynı yapar. İkisi de Omarchy menüsünde _Update > Password_ altında değiştirilebilir — birincisi için _Drive Encryption_, ikincisi için _User_. Disk parolasını değiştirmek önce mevcut olanı sorar, bu yüzden onu elinizin altında bulundurun. Bir değişiklik yarıda kesilirse, _Drive Encryption_ işlemini tekrar çalıştırın: şu anda diskin kilidini açan parolayı sorar ve değişikliği tamamlar.

## Zaten kullandığınız bir makineyi devretme

Makinenizi bir başkasına veriyorsanız, onu yeniden kurmak zorunda değilsiniz. Omarchy menüsünde _Remove > Factory Reset_ işlemini çalıştırın, onaylamak için `reset` yazın, sorulursa disk şifreleme parolanızı girin ve yeniden başlatın. Bu, her kullanıcı hesabını ve `/home` içindeki her şeyi siler, kurulumdan beri yaptığınız tüm paketleri ve sistem değişikliklerini atar ve makinenin kimliğini temizler — ağ bağlantıları, ana bilgisayar anahtarları ve hepsi. Geri gelen, ilk açılıştaki kurulum sihirbazıdır; yeni sahibinin kendi adını, parolasını ve şifreleme parolasını girmesine hazırdır.

Bu, kurulum programının aldığı temel anlık görüntüyü geri yükleyerek çalışır, bu yüzden yalnızca Omarchy ISO'sundan kurulmuş makinelerde kullanılabilir. Ve şifrelemesiz bir diskte, sıfırlama güvenli bir silme değil, bir silme işlemidir; bu yüzden veriler hassassa, bunun yerine temiz bir kurulum yapın.

## Parolasız sudo

Bazen, en sık da bir AI agent sizin için uzun süreli bir sistem işini yürütürken, `sudo` komutunun sormayı bırakmasını istersiniz. _Setup > Security > Passwordless Sudo_, erişime ne kadar süre izin verileceğini sorar: **15 dakika**, **1 Saat**, **1 Gün** veya **Kalıcı olarak**. Erişim etkinken, diğer menü çubuğu göstergelerinin yanında kırmızı bir uyarı simgesi görünür. Erişimi kapatmak için ona tıklayın veya komutu tekrar çalıştırın. Ayrıca `omarchy-sudo-passwordless 30` ile kendi dakika sayınızı (1 ile 1440 arasında) verebilir veya `omarchy-sudo-passwordless permanent` kullanabilirsiniz.

Süreli erişim, son tarihi aşan bir askıya alma durumundan devam edildikten hemen sonra da dahil olmak üzere, otomatik olarak sona erer. Bilgisayarı yeniden başlatmak bunu erken sonlandırır. Kalıcı erişim yeniden başlatmalardan sonra da kalır ve siz devre dışı bırakana kadar etkin kalır.

Omarchy'nin ayar paketini güncellemek veya kaldırmak, süresi dolma desteği değişmeden önce herhangi bir geçici izni sona erdirir. Komut bir yetkilendirme veya temizleme hatası bildirirse, başka bir izin etkinleştirmeye çalışmadan önce bunu çözün; bir hata, parolasız erişimin etkin olmadığı anlamına gelmez.

Bu konuda gözünüz açık olsun: bu açıkken, kullanıcınız olarak çalışan her şey, sorulmadan root olarak her şeyi yapabilir. Bütün mesele budur ve bütün risk de budur.

## İmzalama Anahtarları

Tüm ISO imzaları ve Omarchy depo paketi için ortak anahtar `40DFB630FF42BCFFB047046CF0134EE680CAC571` anahtarıdır ([openpgp.org üzerinde doğrulayın](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` paketi de bunu içerir ve olası güncellemelerin sorunsuz bir şekilde dağıtılması için kullanılacaktır.

Herhangi bir ISO sürümünün imzasını, URL'sine `.sig` ekleyerek bulabilirsiniz; örneğin `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
