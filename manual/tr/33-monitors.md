# Monitörler

Omarchy, varsayılan olarak 2x kapasiteli, retina sınıfı bir ekran kullandığınızı varsayar. O güzel, keskin programcı fontları için ihtiyacınız olan şey bu. Neredeyse tüm yeni, yüksek çözünürlüklü ekranlı premium dizüstü bilgisayarların optimize edildiği şey bu. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) veya 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) üzerinde çalıştırmak isteyeceğiniz şey bu.

Ancak 218 veya üzerinde PPI değerine sahip bir ekran kullanmıyorsanız, monitör ayarlarını değiştirmek isteyeceksiniz. Örneğin, 27" veya 32" 4K bir ekranınız varsa, üst çubuktaki monitör panelinden bunun için kesirli bir ölçek seçebilir ya da `~/.config/hypr/monitors.lua` dosyasını açıp o kombinasyon için önerilene geçerek her monitör için varsayılanı ayarlayabilirsiniz:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

1080p veya 1440p bir ekran kullanıyorsanız, muhtemelen yalnızca 1x ölçeklendirme kullanmak isteyeceksiniz ve aynısı GTK ve X11 uygulamaları için de geçerli, böylece şunu kullanabilirsiniz:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` değişiklikleri, değişiklikten sonra başlatılan uygulamalar için geçerlidir (ve GTK yalnızca tam sayıları dikkate alır, bu yüzden onu monitör ölçeğinize en yakın tam sayıda tutun). Bu yüzden değişiklikten sonra aşırı büyük kalan pencereleri kapattığınızdan emin olun (veya tüm pencereleri `Ctrl + Alt + Del` ile kapatın!).

Ayrıca `Super + /` ile daha yükseğe ve `Super + Alt + /` ile daha düşüğe giderek başlıca monitör ölçeklendirme oranları (1x, 1.25x, 1.6x, 2x, 3x, 4x) arasında hızlıca geçiş yapabilir ya da üst çubuktaki monitör panelinden birini seçebilirsiniz. Bunlar yalnızca odaklandığınız monitörü değiştirir, böylece bir dizüstü bilgisayar ekranı ve harici bir ekranın her biri kendi ölçeğine sahip olabilir. Panel ayrıca her monitörün çözünürlüğünü, yenileme hızını ve döndürmesini ayarlar. Seçimleriniz o fiziksel monitör için `~/.local/state/omarchy/monitors/settings` içinde kaydedilir, böylece yeniden başlatmadan sonra da kalıcı olur ve monitörü bir sonraki sefer hangi bağlantı noktasına veya dock'a takarsanız takın onu takip eder. Bunlar, `~/.config/hypr/monitors.lua` içinde aynı monitöre yönelik herhangi bir kuraldan öncelikli olur; Omarchy bu dosyayı asla düzenlemez. Monitörlerinizi tamamen o dosyada ayarlamayı tercih ederseniz, dosyaya `omarchy_monitor_panel_settings = false` ekleyin; panelin değişiklikleri yalnızca Hyprland yeniden yüklenene kadar geçerli olur. `GDK_SCALE` tüm ekranlar için tek bir değer olduğundan, seçilen bir ölçek onu en düşük ölçeğe sahip monitörden ayarlar, böylece X11 uygulamaları diğer ekranda aşırı büyük çıkmak yerine daha yoğun ekranda biraz küçük çıkar.

### Metni büyütme veya küçültme

Monitör ölçeklendirmesi her şeyin boyutunu değiştirir. Tek istediğiniz daha büyük veya daha küçük _metin_ ise, bunun için tek bir ayar var:

```
omarchy display text size 14
```

Bu, 9 ile 20 arasında bir piksel boyutu alır ve Omarchy kabuğunu, GTK uygulamalarını ve terminalinizi birlikte hareket ettirir, böylece tüm masaüstü orantılı kalır. Nerede olduğunuzu görmek için argümansız çalıştırın ve varsayılana dönmek için `omarchy display text size reset` kullanın. Foot tek geride kalan: yapılandırmasını yeniden yüklemenin bir yolu yok, bu yüzden çalışan terminaller yeni bir tane açana kadar eski boyutlarını korur.

### Dizüstü bilgisayar ekranlarını genişletme ve yansıtma

Dizüstü bilgisayarınıza harici bir ekran bağladığınızda, ekran otomatik olarak genişletilir. Ancak Omarchy menüsünde _Trigger > Hardware_ yolunu veya `Super + Ctrl + Alt + Delete` kısayolunu kullanarak bunu yerine yansıtma olarak değiştirebilirsiniz. Bu, özellikle o harici ekran bir projektörse ve çalışırken bir şey göstermek istiyorsanız faydalıdır.

Genişletme yaparken dizüstü bilgisayarın kapağını kapatmak dahili ekranı otomatik olarak kapatır. Kapağı açmak onu tekrar açar. Bunu Omarchy menüsünde _Trigger > Hardware_ yolunu veya `Super + Ctrl + Delete` kısayolunu kullanarak manuel olarak da kontrol edebilirsiniz.

### Birden çok ekranı düzenleme

Hyprland birden çok ekranla harika çalışır. Üst çubuktaki monitör paneli onları oturdukları yerde çizer: birini diğerinin kenarına sürükleyerek oraya taşıyın; düzenleme, her monitörün diğer ayarlarıyla birlikte kaydedilir. Panelin kapsamadığı herhangi bir şey için, [Hyprland monitör belgelerinde](https://wiki.hypr.land/Configuring/Basics/Monitors/) bunların nasıl düzenleneceği hakkında daha fazlasını okuyun. Omarchy'de bunlar `~/.config/hypr/monitors.lua` içine `hl.monitor` girdileri olarak girer — dosya, bir monitörü kapalı tutmak, panelin sunmadığı modlar, 10-bit renk ve değişken yenileme hızı için yorum satırı yapılmış örneklerle birlikte gelir.

Her monitörün kendi 1'den 10'a kadar çalışma alanları vardır, bu yüzden `Super + 1` her zaman bulunduğunuz monitörün ilk çalışma alanı anlamına gelir. Perde arkasında, Hyprland çalışma alanlarını yine de tüm monitörler arasında numaralandırır: dizüstü bilgisayar ekranınız (veya ilk monitörünüz) 1–10'u alır, sonraki monitör 11–20'yi alır ve bu böyle devam eder; her monitör, her taktığınızda kendi bloğunu korur. Belirli bir monitöre yönelik [çalışma alanı kuralları](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) veya pencere kuralları yazarsanız bu numaraları kullanın, böylece 12 numaralı çalışma alanı ikinci monitörünüzün ikinci çalışma alanı olur. `~/.local/state/omarchy/monitors/workspaces` hangi monitörün hangi bloğa sahip olduğunu listeler.

Ok tuşları, düzeninizde bir kenarı paylaşan monitörler arasında çalışır. Yalnızca bir köşede temas eden veya aralarında boşluk olan ekranlar komşu değildir, bu yüzden aralarında geçiş yapmak için `Ctrl + Alt + Tab` kullanın.

| Kısayol tuşu | Monitörler arasında |
| --- | --- |
| `Super + Arrow` | O yönde pencere kalmadığında o taraftaki monitöre odağı taşır |
| `Super + Shift + Arrow` | O taraftaki monitördeki bir pencereyle yer değiştirir |
| `Super + Alt + Arrow` | Pencereyi o taraftaki monitördeki bir gruba taşır |
| `Super + Shift + Ctrl + Arrow` | Pencereyi o taraftaki monitöre, onun gösterdiği çalışma alanına taşır |
| `Super + Shift + Alt + Arrow` | Çalışma alanını o taraftaki monitöre taşır, boşsa numarasını korur |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Düzen ne olursa olsun odağı sonraki veya önceki monitöre taşır |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Bulunduğunuz monitörde kalır |

Birden çok ekranın konumlandırılmasında size yardımcı olacak bir TUI isterseniz [Hyprmon](https://github.com/erans/hyprmon/) aracına da göz atabilirsiniz.

### Parlaklığı kontrol etme

Monitör parlaklığı, parlaklığı artırma/azaltma için ayrılmış fonksiyon tuşlarıyla kontrol edilir. Bu tuşlara basarken shift tuşunu basılı tutarsanız, maksimum veya minimum parlaklığa gidersiniz. Tuşlar odaklandığınız ekranı kontrol eder, böylece DDC/CI konuşan harici monitörler dizüstü bilgisayar ekranıyla aynı şekilde ayarlanır.

### Apple Ekranları

Bir Apple ekranı kullanıyorsanız, Apple ekranına odaklandığınızda normal klavye parlaklık tuşları da otomatik olarak çalışır. Bu, `asdcontrol` komutu aracılığıyla yapılır.

Bir Apple 6K XDR ekranı kullanıyorsanız, `hyprctl monitors` çıktınızda hayalet bir ekran görebileceğinizi unutmayın. Bunu `~/.config/hypr/monitors.lua` içine `hl.monitor({ output = "DP-2", disabled = true })` gibi bir şey ekleyerek kapatabilirsiniz.

Intel makinelerde, Apple ekranlarına normal bir Thunderbolt kablosuyla bağlanmalısınız. Thunderbolt olmayan diğer makinelerde, çalışması için genellikle bir [DP + USB-A -> USB-C kablosu](https://www.amazon.com/dp/B0BNX7MS6N) kullanmanız gerekir.
