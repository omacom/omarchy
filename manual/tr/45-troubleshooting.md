# Sorun Giderme

### Bir güncellemeyle sistemimi bozdum!

Önce [sisteminizi](47-system-snapshots.md) son güncellemenizden önceki sürüme geri almayı deneyin. Bu işe yaramazsa, Discord'daki #omarchy-help kanalında sorununuzu paylaşmak için `omarchy-debug` kullanın. Bunların hiçbiri işe yaramazsa, `omarchy-reinstall` kullanarak varsayılan yapılandırmaları ve paketleri yeniden kurabilirsiniz.

### Bazı uygulamalar neden ekranımda bu kadar büyük görünüyor?

Omarchy 2x yüksek çözünürlüklü bir ekranınız olduğunu varsayar, bu yüzden monitör panelinde bir ölçek seçene kadar `GDK_SCALE` değerini 2 olarak ayarlar. 1x bir ekrandaysanız ve GTK veya X11 uygulamaları aşırı büyük çıkıyorsa, monitör panelinde onun için 1x seçin veya `~/.config/hypr/monitors.lua` dosyasına `hl.env("GDK_SCALE", "1")` ekleyin (sonra aşırı büyük olan uygulamaları yeniden başlatın). Bkz. [monitörler hakkındaki kılavuz](33-monitors.md).

Spotify için, arayüzü küçültmek için `Ctrl + Minus` kullanabilirsiniz (büyütmek için de `Ctrl + Plus`).

### Tüm Super tuşu kısayollarım neden çalışmayı bıraktı?

Bazı ASUS ROG ve TUF dizüstü bilgisayarlarda, `Fn + Super` fark edilmesi zor bir kombinasyondur ve donanım yazılımı düzeyinde bir Windows tuşu kilidini açıp kapatır (oyun oynarken yanlışlıkla oyundan çıkmamanız için tasarlanmıştır). Ekranda bunun olduğunu gösteren hiçbir şey çıkmaz. Kilit açıkken, Super hiçbir şey göndermez — bu yüzden Super kullanan her Omarchy kısayolu çalışmayı bırakır ve Hyprland bozulmuş gibi görünür.

`~/.config/hypr/` içinde kurcalamaya başlamadan önce bir kez `Fn + Super` tuşlarına basın, bu Super'i geri getirmezse kilidi açık bırakmamak için bir kez daha basın. Bu Fn-lock değildir; Fn-lock yalnızca F tuşu sırasının ne yaptığını değiştirir.

### Wi-Fi, Bluetooth, ses veya trackpad'im az önce çalışmayı bıraktı

Yeniden başlatmadan önce, sorun çıkaran alt sistemi kendi başına yeniden başlatmayı deneyin. Omarchy menüsündeki _Update > Hardware_ altında Wi-Fi, Bluetooth, Audio ve Trackpad bulunur ve bunlardan birini yeniden yüklemek "beş dakika önce çalışıyordu" durumlarının büyük çoğunluğunu düzeltir — yeniden bağlanmayan bir Bluetooth kulaklık, askıya alma sonrası ölen bir trackpad, bir monitörün fişini çektiğinizde kaybolan ses.

### Harici hoparlörlerim neden ses vermiyor?

Muhtemelen birincil çıkış olarak ayarlanmadıkları için. Çubuğun sağ tarafındaki hoparlör simgesine tıklayın; çıkış aygıtını seçebileceğiniz (ve uygulama başına ses seviyelerini de ayarlayabileceğiniz) ses açılır penceresi açılacaktır.

### Dizüstü bilgisayar hoparlörlerimin sesi garip geliyor

Bazı dizüstü bilgisayarlarda, Omarchy yerleşik hoparlörlerin frekans tepkisini düzelten bir hoparlör ayarını otomatik olarak uygular. `omarchy audio tuning status` makinenizde bir ayarın etkin olup olmadığını söyler ve hoparlörleri ham haliyle duymayı tercih ederseniz `omarchy audio tuning off` bunu kapatır.

### Neden parolamla giriş yapamıyorum veya sudo kullanamıyorum?

Muhtemelen parolayı çok fazla kez yanlış yazdınız ve kilitlendiniz. Bu kilit ekranında oluyorsa, yeni bir TTY başlatmak için `CTRL + ALT + F2` tuşlarına basabilirsiniz; orada root olarak giriş yapıp ardından `faillock --reset --user [your-username]` çalıştırabilirsiniz. Bu, kilidi sıfırlar ve devam edebilirsiniz.

### Parolam kabul ediliyor ama giriş ekranına geri dönüyorum

Bozuk bir oturum ortam dosyası, parolanız doğru olsa bile masaüstünün başlamasını engelleyebilir. Bunu özellikle `~/.config/uwsm/env.d/` dizinini düzenledikten sonra kontrol etmeye değer.

`Ctrl + Alt + F2` tuşlarına basın, normal kullanıcı adınız ve parolanızla giriş yapın ve geçerli önyüklemenin kullanıcı günlüğünü inceleyin:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Ortam dosyalarınızdan birini adlandıran, örneğin `bad substitution` gibi, env output mark was not found belirten bir iletiden hemen önce gelen bir hata arayın. Tekrar giriş yapmayı denemeden önce o dosyayı `env.d` dışına taşıyın. Örneğin, hata `99-custom` dosyasını adlandırıyorsa:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM söz dizimi hatası olan bir dosyayı atlar, ancak yalnızca dosya çalışırken ortaya çıkan, `bad substitution` gibi ölümcül bir hata yine de masaüstünün başlamasını engelleyebilir. Bir sistem anlık görüntüsüne geri dönmek bu dosyaları onarmaz, çünkü `/home` geri alınmaz.

Giriş yapabildiğinizde, kaydedilmiş kopyayı geri taşımadan önce düzeltin. `sh -n` dosyayı çalıştırmadan söz dizimi hatalarını yakalar, ancak dosya kaynak olarak kullanıldığında ortaya çıkan her hatayı yakalayamaz. Değişiklikleri test ederken çalışan bir terminali açık tutun.

### 1Password SSH Agent / CLI için 1Password yetkilendirme istemlerim neden görünmüyor?

Bu 2 nedenden dolayı olabilir:

Zengin onay isteminin görünmesi için Settings > Advanced > Use Hardware Acceleration açık olmalıdır. _Not: Bunun çalışmaya başlaması için yeniden başlatma gerekir._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Veya bilgisayarı açtıktan sonra 1Password'u başlatmadıysanız, istem görünmez.
