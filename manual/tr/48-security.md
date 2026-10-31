# Güvenlik

Omarchy güvenliği son derece ciddiye alır. Bunun, _Gerçek Dünyada_ _Gerçek İşler_ yapmak için kullanabileceğiniz bir işletim sistemi olması amaçlanıyor. Bir dizüstü bilgisayarı kaybetmenin bir güvenlik acil durumuna yol açamayacağı bir sistem. İşte yaptıklarımız:

1. *Tam disk şifrelemesi zorunludur*: Bu, verilerinizin fiziksel korumasını sağlamanın en önemli adımıdır. Bilgisayarınız kaybolur veya çalınırsa, veriler standart LUKS (Linux Unified Key Setup) kullanılarak tamamen şifrelenmiş olur.
2. *Güvenlik duvarı varsayılan olarak etkindir*: [LocalSend](https://localsend.org/) için 53317 numaralı bağlantı noktası hariç, gelen tüm trafik varsayılan olarak engellenir. _Setup > Security > SSHD_ üzerinden açana kadar ssh bile kapalıdır; bu kurulumun bir parçası olarak 22 numaralı bağlantı noktasını açar (kaba kuvvet saldırılarına karşı hız sınırlaması uygulanır). Konteynerlerinizin yanlışlıkla dünyaya açılmasını önlemek için [ufw-docker](https://github.com/chaifeng/ufw-docker) kurulumunu kullanarak Docker erişimini bile kilitliyoruz.
3. *Arch her zaman en güncel sürümlere sahiptir*: Omarchy'nin üzerine inşa edildiği temel dağıtım olan Arch, yuvarlanan bir dağıtımdır. Bu, herhangi bir pakette keşfedilen ve yamalanan herhangi bir güvenlik açığının `omarchy-update` kullanılarak hızla kurulabileceği anlamına gelir. Bu sayede her zaman her şeyin en güncel, en güvenli sürümlerini çalıştırırsınız.
4. *Omarchy kendi paketlerini ve yansısını korur*: Omarchy varsayılan olarak yalnızca Arch'ın kendi core/extra/multilib depolarındaki paketlere ve kendi Omarchy Package Repository'sine dayanır. Yazılımları doğrudan AUR'dan kurabilirsiniz, ancak temel kurulum bunu yapmaz — üçüncü taraf tarayıcılar gibi yalnızca birkaç isteğe bağlı kurulum AUR'dan çeker.
5. *Cloudflare bizi DDoS'tan korur*: Omarchy dağıtım altyapısı — ISO'lar, Omarchy paketleri, Arch yansısı — Cloudflare'ın güçlü DDoS kalkanının arkasında korunur ve onların CDN'inde barındırılır. Bu, mükemmel kullanılabilirlik sağlar.

## Şifrelerinizi değiştirme

Şifreli bir kurulumda iki şifreniz vardır: açılışta sürücünün kilidini açan ve oturum açmak ile `sudo` için kullandığınız. Kurulum ikisini de aynı yapar. İkisi de Omarchy menüsünde _Update > Password_ altından değiştirilebilir — ilki için _Drive Encryption_, ikincisi için _User_. Sürücü şifresini değiştirmek önce mevcut şifreyi sorar, bu yüzden onu elinizin altında bulundurun. Bir değişiklik yarıda kesilirse, _Drive Encryption_ seçeneğini tekrar çalıştırın: sürücünün kilidini şu anda açan şifreyi sorar ve değişikliği tamamlar.

## Zaten kullandığınız bir makineyi devretme

Makinenizi başka birine devrediyorsanız, onu yeniden kurmanız gerekmez. Omarchy menüsünde _Setup > Reset Computer_ seçeneğini çalıştırın, onaylamak için `reset` yazın ve yeniden başlatın. Bu, her kullanıcı hesabını ve `/home` içindeki her şeyi siler, kurulumdan bu yana yaptığınız tüm paketleri ve sistem değişikliklerini atar ve makinenin kimliğini — ağ bağlantıları, ana bilgisayar anahtarları ve hepsini — temizler. Geri açılan şey, ilk açılıştaki kurulum sihirbazıdır; yeni sahibinin kendi adını, şifresini ve şifreleme şifresini girmesi için hazırdır.

Bu, yükleyicinin aldığı temel anlık görüntüyü geri yükleyerek çalışır, bu yüzden yalnızca Omarchy ISO'sundan kurulmuş makinelerde kullanılabilir. Şifrelemesiz bir sürücüde ise sıfırlama, güvenli bir silme yerine silme işlemidir; bu yüzden veriler hassassa bunun yerine sıfırdan kurulum yapın.

## Şifresiz sudo

Bazen `sudo`'nun sormayı bırakmasını istersiniz; en sık olarak da bir AI agent sizin için uzun süreli bir sistem işini yaparken. _Setup > Security > Passwordless Sudo_, erişime ne kadar süre izin verileceğini sorar: **15 dakika**, **1 Saat**, **1 Gün** veya **Kalıcı olarak**. Erişim aktifken diğer menü çubuğu göstergelerinin yanında kırmızı bir uyarı simgesi görünür. Erişimi kapatmak için ona tıklayın veya komutu tekrar çalıştırın. `omarchy-sudo-passwordless 30` ile kendi dakika sayınızı (1 ile 1440 arasında) da verebilirsiniz veya `omarchy-sudo-passwordless permanent` kullanabilirsiniz.

Süreli erişim, son tarihi aşan bir askıya alma işleminden devam edildikten hemen sonra da dahil olmak üzere, otomatik olarak sona erer. Bilgisayarı yeniden başlatmak bunu erken bitirir. Kalıcı erişim yeniden başlatmalardan sonra da devam eder ve siz devre dışı bırakana kadar etkin kalır.

Omarchy'nin ayarlar paketini güncellemek veya kaldırmak, süre sonu desteği değişmeden önce herhangi bir geçici yetkiyi bitirir. Komut bir yetkilendirme veya temizleme hatası bildirirse, başka bir yetkiyi etkinleştirmeye çalışmadan önce bunu çözün; bir hata, şifresiz erişimin etkin olmadığı anlamına gelmez.

Bu konuda gözünüz açık olsun: bu açıkken, kullanıcınız olarak çalışan her şey, sorulmadan root olarak her şeyi yapabilir. Bütün mesele bu, bütün risk de bu.

## İmzalama Anahtarları

Tüm ISO imzaları ve Omarchy repo paketi için genel anahtar `40DFB630FF42BCFFB047046CF0134EE680CAC571` şeklindedir ([openpgp.org'da doğrulayın](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` paketi de bunu içerir ve olası güncellemeleri sorunsuz bir şekilde dağıtmak için kullanılacaktır.

Herhangi bir ISO sürümünün imzasını, URL'sine `.sig` ekleyerek bulabilirsiniz; örneğin `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
