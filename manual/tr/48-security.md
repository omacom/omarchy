# Güvenlik

Omarchy güvenliği son derece ciddiye alır. Bu, _Gerçek Dünyada_ _Gerçek İş_ yapmak için kullanabileceğiniz bir işletim sistemi olarak tasarlandı. Bir dizüstü bilgisayarı kaybetmenin bir güvenlik acil durumuna yol açamayacağı bir sistem. İşte yaptıklarımız:

1. *Tam disk şifrelemesi zorunludur*: Bu, verilerinizin fiziksel korunmasını sağlamanın en önemli adımıdır. Bilgisayarınız kaybolur veya çalınırsa, veriler standart LUKS (Linux Unified Key Setup) kullanılarak tamamen şifrelenmiş olur.
2. *Güvenlik duvarı varsayılan olarak etkindir*: Gelen tüm trafik varsayılan olarak engellenir; tek istisna, [LocalSend](https://localsend.org/) için 53317 numaralı bağlantı noktasıdır. Hatta ssh bile, kurulumun bir parçası olarak 22 numaralı bağlantı noktasını açan (kaba kuvvet saldırılarına karşı hız sınırlamalı) _Setup > Security > SSHD_ üzerinden açana kadar kapalıdır. Konteynerlerinizin yanlışlıkla dünyaya açılmasını önlemek için [ufw-docker](https://github.com/chaifeng/ufw-docker) kurulumunu kullanarak Docker erişimini bile kilitleriz.
3. *Arch her zaman en son güncellemelere sahiptir*: Omarchy'nin üzerine inşa edildiği temel dağıtım olan Arch, yuvarlanan bir dağıtımdır. Bu, herhangi bir pakette keşfedilen ve yamalanan herhangi bir güvenlik açığının `omarchy-update` kullanılarak hızla kurulabilir hale geldiği anlamına gelir. Bu şekilde her zaman her şeyin en yeni, en güvenli sürümlerini çalıştırırsınız.
4. *Omarchy kendi paketlerini ve yansısını korur*: Omarchy varsayılan olarak yalnızca Arch'ın kendi core/extra/multilib depolarındaki paketlere ve kendi Omarchy Package Repository'sine güvenir. Yazılımı doğrudan AUR'dan kurabilirsiniz, ancak temel kurulum bunu yapmaz — yalnızca üçüncü taraf tarayıcılar gibi birkaç isteğe bağlı kurulum AUR'dan çeker.
5. *Cloudflare bizi DDoS'tan korur*: Omarchy dağıtım altyapısı — ISO'lar, Omarchy paketleri, Arch yansısı — Cloudflare'ın güçlü DDoS kalkanının arkasında korunur ve onların CDN'inde barındırılır. Bu, mükemmel bir kullanılabilirlik sağlar.

## Şifrelerinizi değiştirme

Şifreli bir kurulumda iki şifreniz vardır: biri açılışta sürücünün kilidini açan, diğeri oturum açmak ve `sudo` için kullandığınız. Kurulum bunları aynı yapar. İkisi de Omarchy menüsünde _Update > Password_ altında değiştirilebilir — ilki için _Drive Encryption_, ikincisi için _User_. Sürücü şifresini değiştirmek önce mevcut şifreyi sorar, bu yüzden onu hazır bulundurun. Bir değişiklik yarıda kesilirse, _Drive Encryption_'ı tekrar çalıştırın: sürücünün kilidini şu anda açan şifreyi sorar ve değişikliği tamamlar.

## Zaten kullandığınız bir makineyi devretme

Makinenizi başkasına devrediyorsanız, yeniden kurmanıza gerek yok. Omarchy menüsünde _Setup > Reset Computer_'ı çalıştırın, onaylamak için `reset` yazın ve yeniden başlatın. Bu, her kullanıcı hesabını ve `/home` içindeki her şeyi siler, kurulumdan beri yaptığınız tüm paketleri ve sistem değişikliklerini atar ve makinenin kimliğini temizler — ağ bağlantıları, ana bilgisayar anahtarları ve hepsi. Geri gelen şey, ilk açılıştaki kurulum sihirbazıdır; yeni sahibinin kendi adını, şifresini ve şifreleme şifresini girmesi için hazırdır.

Bu, yükleyicinin aldığı temel anlık görüntüyü geri yükleyerek çalışır, bu yüzden yalnızca Omarchy ISO'sundan kurulan makinelerde kullanılabilir. Şifrelemesiz bir sürücüde sıfırlama, güvenli silme yerine silme işlemidir, bu yüzden veriler hassassa bunun yerine yeni bir kurulum yapın.

## Şifresiz sudo

Bazen `sudo`'nun sormayı bırakmasını istersiniz; en sık olarak bir AI agent sizin için uzun bir sistem işini yaparken. _Setup > Security > Passwordless Sudo_, erişime ne kadar süre izin verileceğini sorar: **15 dakika**, **1 Saat**, **1 Gün** veya **Kalıcı Olarak**. Erişim etkinken diğer menü çubuğu göstergelerinin yanında kırmızı bir uyarı simgesi görünür. Erişimi kapatmak için ona tıklayın veya komutu tekrar çalıştırın. Ayrıca `omarchy-sudo-passwordless 30` ile kendi dakika sayınızı (1 ile 1440 arasında) verebilir veya `omarchy-sudo-passwordless permanent` kullanabilirsiniz.

Zamanlı erişim, son tarihi geçen bir askıya alma işleminden devam edildikten hemen sonra da dahil olmak üzere, otomatik olarak sona erer. Bilgisayarı yeniden başlatmak bunu erken sonlandırır. Kalıcı erişim yeniden başlatmalardan sonra da devam eder ve siz devre dışı bırakana kadar etkin kalır.

Omarchy'nin ayarlar paketini güncellemek veya kaldırmak, sona erme desteği değişmeden önce verilen geçici yetkileri sonlandırır. Komut bir yetkilendirme veya temizleme hatası bildirirse, başka bir yetki etkinleştirmeye çalışmadan önce bunu çözün; bir hata, şifresiz erişimin etkin olmadığı anlamına gelmez.

Bu konuda gözünüz açık olun: açıkken, kullanıcınız olarak çalışan her şey, sorulmadan root olarak her şeyi yapabilir. Bütün mesele bu, ve bütün risk de bu.

## İmzalama Anahtarları

Tüm ISO imzaları ve Omarchy deposu paketleri için genel anahtar `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([openpgp.org'da doğrulayın](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` paketi de bunu içerir ve olası güncellemelerin sorunsuz bir şekilde sunulması için kullanılacaktır.

Herhangi bir ISO sürümünün imzasını URL'ye .sig ekleyerek bulabilirsiniz. Örneğin https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
