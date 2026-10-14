# Sorun giderme

### Sistemimi bir güncellemeyle bozdum!

Önce, son güncellemenizden önceki sürüme [sisteminizi geri almayı](47-system-snapshots.md) deneyin. Bu işe yaramazsa, sorununuzu Discord'daki #omarchy-help kanalında paylaşmak için `omarchy-debug` kullanın. Ve bunların hepsi başarısız olursa, `omarchy-reinstall` kullanarak varsayılan yapılandırmaları ve paketleri yeniden kurabilirsiniz.

### Bazı uygulamalar ekranımda neden bu kadar büyük?

Omarchy 2x yüksek çözünürlüklü bir ekran varsayar; bu, `~/.config/hypr/monitors.lua` içinde `GDK_SCALE` değerinin 2 olarak ayarlanmasını gerektirir. Ancak 1x bir ekrandaysanız, `local omarchy_gdk_scale = 2` değerini 1 olarak değiştirebilirsiniz (ve ardından çok büyük olan uygulamaları yeniden başlatın). [Monitörler hakkındaki kılavuza](33-monitors.md) bakın.

Spotify için, kullanıcı arayüzünü küçültmek için `Ctrl + Minus` (büyütmek için `Ctrl + Plus`) kullanabilirsiniz.

### Wi-Fi'im, Bluetooth'um, sesim veya dokunmatik yüzeyim az önce çalışmayı durdurdu

Yeniden başlatmadan önce, sorun çıkaran alt sistemi kendi başına yeniden başlatmayı deneyin. Omarchy menüsündeki _Güncelle > Donanım_ altında Wi-Fi, Bluetooth, Ses ve Dokunmatik Yüzey vardır ve bunlardan birini yeniden yüklemek, "beş dakika önce çalışıyordu" durumlarının çoğunu giderir — yeniden bağlanmayan bir Bluetooth kulaklık, askıya almadan sonra ölen bir dokunmatik yüzey, bir monitörü çıkardığınızda kaybolan ses.

### Harici hoparlörlerim neden çalmıyor?

Muhtemelen birincil çıkış olarak ayarlanmamışlardır. Çubuğun sağ tarafındaki hoparlör simgesine tıklayın; çıkış cihazını seçebileceğiniz (ve uygulama başına ses düzeylerini de karıştırabileceğiniz) ses düzeyi açılır penceresi açılacaktır.

### Dizüstü bilgisayarımın hoparlörlerinin sesi garip geliyor

Bazı dizüstü bilgisayarlarda Omarchy, yerleşik hoparlörlerin frekans yanıtını düzelten bir hoparlör ayarı otomatik olarak uygular. `omarchy audio tuning status` makinenizde birinin etkin olup olmadığını söyler ve hoparlörleri ham haliyle duymayı tercih ederseniz `omarchy audio tuning off` onu kapatır.

### Neden parolamla giriş yapamıyor veya sudo kullanamıyorum?

Muhtemelen çok fazla kez yanlış yazdınız ve kilitlendiniz. Bu kilit ekranında oluyorsa, root olarak giriş yapabileceğiniz yeni bir TTY başlatmak için `CTRL + ALT + F2` tuşlarına basabilir, ardından `faillock --reset --user [your-username]` çalıştırabilirsiniz. Bu kilidi sıfırlayacaktır ve hazırsınız.

### 1Password SSH Agent / CLI için 1Password yetkilendirme istemlerim neden görünmüyor?

Bu, 2 nedenden dolayı olabilir:

Zengin onay isteminin görünmesi için Ayarlar > Gelişmiş > Donanım Hızlandırmayı Kullan seçeneğinin açık olması gerekir. _Not: Bunun çalışmaya başlaması için yeniden başlatma gerekir._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Veya önyüklemeden beri 1Password'ü başlatmadıysanız, istem görünmez.
