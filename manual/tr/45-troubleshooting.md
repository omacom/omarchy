# Sorun Giderme

### Bir güncellemeyle sistemimi bozdum!

Önce [sisteminizi geri almayı](47-system-snapshots.md) son güncellemenizden önceki sürüme deneyin. Bu işe yaramazsa, sorununuzu Discord'daki #omarchy-help kanalında paylaşmak için `omarchy-debug` kullanın. Ve bunların hepsi de başarısız olursa, varsayılan yapılandırmaları ve paketleri `omarchy-reinstall` kullanarak yeniden kurabilirsiniz.

### Bazı uygulamalar ekranımda neden bu kadar büyük görünüyor?

Omarchy, 2x yüksek çözünürlüklü bir ekranınız olduğunu varsayar, bu yüzden monitör panelinde bir ölçek seçene kadar `GDK_SCALE` değerini 2 olarak ayarlar. 1x bir ekrandaysanız ve GTK veya X11 uygulamaları aşırı büyük çıkıyorsa, monitör panelinde onun için 1x seçin ya da `~/.config/hypr/monitors.lua` dosyasına `hl.env("GDK_SCALE", "1")` ekleyin (ve ardından aşırı büyük olan uygulamaları yeniden başlatın). Bkz. [monitörler hakkındaki kılavuz](33-monitors.md).

Spotify için, arayüzü küçültmek üzere `Ctrl + Minus` kullanabilirsiniz (büyütmek için de `Ctrl + Plus`).

### Tüm Super tuşu kısayollarım neden çalışmayı bıraktı?

Bazı ASUS ROG ve TUF dizüstü bilgisayarlarda `Fn + Super`, firmware Windows tuşu kilidini açıp kapatan, gözden kaçması kolay bir kombinasyondur (oyun oynarken yanlışlıkla oyundan çıkmamanız için tasarlanmıştır). Ekranda bunun olduğunu gösteren hiçbir şey çıkmaz. Kilit açıkken Super hiçbir şey göndermez — bu yüzden Super kullanan her Omarchy kısayolu çalışmayı bırakır ve Hyprland bozulmuş gibi görünür.

`~/.config/hypr/` içinde bir şeyleri kurcalamaya başlamadan önce bir kez `Fn + Super` tuşlarına basın ve bu Super'i geri getirmezse kilidi açık bırakmamak için tekrar basın. Bu, Fn-lock değildir; Fn-lock yalnızca F tuşu sırasının ne yaptığını değiştirir.

### Wi-Fi, Bluetooth, ses veya trackpad'im çalışmayı bıraktı

Yeniden başlatmadan önce, sorun çıkaran alt sistemi tek başına yeniden başlatmayı deneyin. Omarchy menüsündeki _Update > Hardware_ altında Wi-Fi, Bluetooth, Audio ve Trackpad bulunur ve bunlardan birini yeniden yüklemek "beş dakika önce çalışıyordu" durumlarının büyük çoğunluğunu düzeltir — yeniden bağlanmayan bir Bluetooth kulaklık, askıya alma sonrası çalışmaz hale gelen bir trackpad, bir monitörün fişini çektiğinizde kaybolan ses.

### Harici hoparlörlerim neden ses çalmıyor?

Muhtemelen birincil çıkış olarak ayarlanmadıkları için. Çubuğun sağ tarafındaki hoparlör simgesine tıklayın; ses düzeyi açılır penceresi açılır, buradan çıkış cihazını seçebilirsiniz (ve uygulama başına ses düzeylerini de ayarlayabilirsiniz).

### Dizüstü bilgisayarımın hoparlörlerinden ses tuhaf geliyor

Bazı dizüstü bilgisayarlarda Omarchy, dahili hoparlörlerin frekans tepkisini düzelten bir hoparlör ayarını otomatik olarak uygular. `omarchy audio tuning status`, makinenizde bir ayarın etkin olup olmadığını gösterir ve hoparlörleri ham haliyle duymayı tercih ederseniz `omarchy audio tuning off` bunu kapatır.

### Parolamla neden giriş yapamıyorum veya sudo kullanamıyorum?

Muhtemelen parolayı çok fazla kez yanlış yazdınız ve kilitlendiniz. Bu kilit ekranında oluyorsa, yeni bir TTY başlatmak için `CTRL + ALT + F2` tuşlarına basabilir, orada root olarak giriş yapabilir, ardından `faillock --reset --user [your-username]` çalıştırabilirsiniz. Bu, kilitlenmeyi sıfırlar ve hazırsınız.

### 1Password SSH Agent / CLI için 1Password yetkilendirme istemlerim neden görünmüyor?

Bu, 2 nedenden dolayı olabilir:

Zengin onay isteminin görünmesi için Settings > Advanced > Use Hardware Acceleration açık olmalıdır. _Not: Bunun çalışmaya başlaması için yeniden başlatma gerekir._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ya da bilgisayarı açtıktan sonra 1Password'ü hiç başlatmadıysanız istem görünmez.
