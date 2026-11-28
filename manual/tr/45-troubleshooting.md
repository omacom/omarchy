# Sorun Giderme

### Güncellemeyle sistemimi bozdum!

Önce [sisteminizi son güncellemenizden önceki sürüme geri almayı](47-system-snapshots.md) deneyin. Bu işe yaramazsa, sorununuzu Discord'daki #omarchy-help kanalında paylaşmak için `omarchy-debug` kullanın. Bunların hiçbiri işe yaramazsa, `omarchy-reinstall` kullanarak varsayılan yapılandırmaları ve paketleri yeniden kurabilirsiniz.

### Bazı uygulamalar ekranımda neden bu kadar büyük görünüyor?

Omarchy, 2x yüksek çözünürlüklü bir ekranınız olduğunu varsayar; bu yüzden siz monitör panelinden bir ölçek seçene kadar `GDK_SCALE` değerini 2 olarak ayarlar. 1x bir ekrandaysanız ve GTK veya X11 uygulamaları aşırı büyük çıkıyorsa, monitör panelinden o ekran için 1x seçin ya da `~/.config/hypr/monitors.lua` dosyasına `hl.env("GDK_SCALE", "1")` ekleyin (ardından aşırı büyük olan uygulamaları yeniden başlatın). Bkz. [monitörler hakkındaki kılavuz](33-monitors.md).

Spotify için arayüzü küçültmek üzere `Ctrl + Minus` (büyütmek için `Ctrl + Plus`) kullanabilirsiniz.

### Tüm Super tuş bağlarım neden çalışmayı bıraktı?

Bazı ASUS ROG ve TUF dizüstü bilgisayarlarda `Fn + Super`, aygıt yazılımındaki Windows tuşu kilidini açıp kapatan, gözden kaçması kolay bir kısayoldur (oyundayken yanlışlıkla oyundan çıkmamanız için tasarlanmıştır). Ekranda bunun olduğunu gösteren hiçbir şey çıkmaz. Kilit açıkken Super hiçbir şey göndermez — bu yüzden Super kullanan her Omarchy bağı birden çalışmaz ve Hyprland bozulmuş gibi görünür.

`~/.config/hypr/` içinde kurcalamaya başlamadan önce bir kez `Fn + Super` tuşlarına basın; Super geri gelmezse, kilidi açık bırakmamak için bir kez daha basın. Bu, yalnızca F tuşu satırının davranışını değiştiren Fn-lock değildir.

### Wi-Fi, Bluetooth, sesim veya trackpad'im birden çalışmayı bıraktı

Yeniden başlatmadan önce, sorun çıkaran alt sistemi tek başına yeniden başlatmayı deneyin. Omarchy menüsündeki _Update > Hardware_ altında Wi-Fi, Bluetooth, Audio ve Trackpad seçenekleri vardır ve bunlardan birini yeniden yüklemek, "beş dakika önce çalışıyordu" durumlarının büyük çoğunluğunu düzeltir — yeniden bağlanmayan bir Bluetooth kulaklık, askıya alma sonrası ölen bir trackpad, bir monitörün fişini çektiğinizde kaybolan ses.

### Harici hoparlörlerim neden ses vermiyor?

Muhtemelen birincil çıkış olarak ayarlı değillerdir. Çubuğun sağ tarafındaki hoparlör simgesine tıklayın; ses açılır penceresi açılır ve oradan çıkış aygıtını seçebilirsiniz (uygulama başına ses düzeylerini de karıştırabilirsiniz).

### Dizüstü bilgisayarımın hoparlörlerinden garip ses geliyor

Bazı dizüstü bilgisayarlarda Omarchy, dahili hoparlörlerin frekans yanıtını düzelten bir hoparlör ayarı otomatik olarak uygular. `omarchy audio tuning status`, makinenizde bir ayarın etkin olup olmadığını söyler; hoparlörleri ham haliyle duymayı tercih ederseniz `omarchy audio tuning off` onu kapatır.

### Parolamla neden giriş yapamıyorum veya sudo kullanamıyorum?

Muhtemelen parolayı on kez yanlış yazdınız ve kilitlendiniz. Kilit iki dakika sonra kendiliğinden kalkar. Bekleyemiyorsanız ve bu kilit ekranında oluyorsa, yeni bir TTY başlatmak için `CTRL + ALT + F2` tuşlarına basıp root olarak giriş yapabilir, ardından `faillock --reset --user [your-username]` çalıştırabilirsiniz. Bu, kilidi sıfırlar ve devam edebilirsiniz.

### Parolam kabul ediliyor ama giriş ekranına geri dönüyorum

Bozuk bir oturum ortam dosyası, parolanız doğru olsa bile masaüstünün başlamasını engelleyebilir. Bunu özellikle `~/.config/uwsm/env.d/` dizinini düzenledikten sonra kontrol etmekte fayda var.

`Ctrl + Alt + F2` tuşlarına basın, normal kullanıcı adınız ve parolanızla giriş yapın ve geçerli önyüklemenin kullanıcı günlüğünü inceleyin:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Ortam dosyalarınızdan birini adlandıran, örneğin `bad substitution` gibi, env çıktı işaretinin bulunamadığını söyleyen bir iletiden hemen önce gelen bir hata arayın. Tekrar giriş yapmayı denemeden önce o dosyayı `env.d` dışına taşıyın. Örneğin, hata `99-custom` dosyasını adlandırıyorsa:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM, söz dizimi hatası olan bir dosyayı atlar, ancak yalnızca dosya çalışırken ortaya çıkan `bad substitution` gibi ölümcül bir hata yine de masaüstünün başlamasını engelleyebilir. Sistem anlık görüntüsüyle geri alma bu dosyaları onarmaz, çünkü `/home` geri alınmaz.

Giriş yapabildiğinizde, kaydedilmiş kopyayı geri taşımadan önce düzeltin. `sh -n`, dosyayı çalıştırmadan söz dizimi hatalarını yakalar, ancak dosya kaynak olarak okunurken ortaya çıkan her hatayı yakalayamaz. Değişiklikleri test ederken çalışan bir terminali açık tutun.

### 1Password SSH Agent / CLI için 1Password yetkilendirme istemlerim neden görünmüyor?

Bu, 2 nedenden dolayı olabilir:

Zengin onay isteminin görünmesi için Settings > Advanced > Use Hardware Acceleration açık olmalıdır. _Not: Bunun çalışmaya başlaması için yeniden başlatma gerekir._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ya da bilgisayarı açtıktan sonra 1Password'u başlatmadıysanız istem görünmez.
