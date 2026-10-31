# Sorun Giderme

### Bir güncellemeyle sistemimi bozdum!

Önce son güncellemenizden önceki sürüme [sisteminizi geri almayı](47-system-snapshots.md) deneyin. Bu işe yaramazsa, sorununuzu Discord'daki #omarchy-help kanalında paylaşmak için `omarchy-debug` kullanın. Ve bunların hepsi başarısız olursa, `omarchy-reinstall` kullanarak varsayılan yapılandırmaları ve paketleri yeniden kurabilirsiniz.

### Bazı uygulamalar ekranımda neden bu kadar büyük?

Omarchy, `~/.config/hypr/monitors.lua` içinde `GDK_SCALE` değerinin 2 olarak ayarlanmasını gerektiren 2x yüksek çözünürlüklü bir ekran varsayar. Ancak 1x bir ekrandaysanız, `local omarchy_gdk_scale = 2` değerini 1 olarak değiştirebilirsiniz (ve ardından aşırı büyük görünen tüm uygulamaları yeniden başlatabilirsiniz). Bkz. [monitörler hakkındaki kılavuz](33-monitors.md).

Spotify için, arayüzü küçültmek için `Ctrl + Minus` (ve büyütmek için `Ctrl + Plus`) kullanabilirsiniz.

### Tüm Super tuşu atamalarım neden çalışmayı bıraktı?

Bazı ASUS ROG ve TUF dizüstü bilgisayarlarda, `Fn + Super`, ürün yazılımındaki Windows tuşu kilidini (yanlışlıkla oyundan çıkmamanız için oyun oynamaya yönelik) açıp kapatan, kolayca gözden kaçan bir kombinasyondur. Ekranda bunun olduğunu gösteren hiçbir şey olmaz. Kilit açıkken, Super hiçbir şey göndermez — bu yüzden Super kullanan her Omarchy ataması çalışmayı bırakır ve Hyprland bozulmuş gibi görünür.

`~/.config/hypr/` içinde incelemeye başlamadan önce bir kez `Fn + Super` tuşlarına basın ve bu Super'i geri getirmezse, kilidi açık bırakmamak için tekrar basın. Bu, yalnızca F tuşu satırının ne yaptığını değiştiren Fn-lock değildir.

### Wi-Fi, Bluetooth, ses veya trackpad'im birden çalışmayı bıraktı

Yeniden başlatmadan önce, sorunlu alt sistemi kendi başına yeniden başlatmayı deneyin. Omarchy menüsündeki _Update > Hardware_ içinde Wi-Fi, Bluetooth, Audio ve Trackpad bulunur ve bunlardan birini yeniden yüklemek, "beş dakika önce çalışıyordu" durumlarının çoğunu düzeltir — yeniden bağlanmayan bir Bluetooth kulaklık, askıya alma sonrasında çalışmayan bir trackpad, bir monitörün fişini çektiğinizde kaybolan ses.

### Harici hoparlörlerim neden çalmıyor?

Muhtemelen birincil çıkış olarak ayarlanmadıkları için. Çubuğun sağ tarafındaki hoparlör simgesine tıklayın; ses düzeyi açılır penceresi açılacak ve buradan çıkış cihazını seçebilirsiniz (ayrıca uygulama bazında ses düzeylerini de ayarlayabilirsiniz).

### Dizüstü bilgisayarımın hoparlörlerinden garip ses geliyor

Bazı dizüstü bilgisayarlarda Omarchy, yerleşik hoparlörlerin frekans yanıtını düzelten bir hoparlör ayarını otomatik olarak uygular. `omarchy audio tuning status` komutu, makinenizde bir ayarın etkin olup olmadığını söyler ve hoparlörleri ham haliyle duymayı tercih ederseniz `omarchy audio tuning off` komutu onu kapatır.

### Parolamla neden giriş yapamıyorum veya sudo kullanamıyorum?

Muhtemelen parolayı çok fazla kez yanlış girdiniz ve kilitlendiniz. Bu kilit ekranında oluyorsa, yeni bir TTY başlatmak için `CTRL + ALT + F2` tuşlarına basabilirsiniz; burada root olarak giriş yapıp ardından `faillock --reset --user [your-username]` çalıştırabilirsiniz. Bu, kilitlenmeyi sıfırlayacak ve devam edebileceksiniz.

### 1Password SSH Agent / CLI için 1Password yetkilendirme istemlerim neden görünmüyor?

Bu 2 nedenden dolayı olabilir:

Zengin onay isteminin görünmesi için Settings > Advanced > Use Hardware Acceleration açık olmalıdır. _Not: Bunun çalışmaya başlaması için yeniden başlatma gerekir._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Veya bilgisayarı başlattığınızdan beri 1Password'ü başlatmadıysanız, istem görünmeyecektir.
