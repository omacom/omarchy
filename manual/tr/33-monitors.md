# Monitörler

Omarchy varsayılan olarak 2x kapasiteli retina sınıfı bir ekran kullandığınızı varsayar. Bu güzel, net programcı yazı tiplerini elde etmek için ihtiyacınız olan şey budur. Hemen hemen tüm yeni premium dizüstü bilgisayarların yüksek çözünürlüklü ekranlarıyla optimize edildiği şey budur. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) veya 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) üzerinde çalıştırmak isteyeceğiniz şey budur.

Ancak PPI değeri 218 veya üzerinde olan bir ekran kullanmıyorsanız, monitör ayarlarını değiştirmek isteyeceksiniz. Örneğin, 27" veya 32" 4K ekranınız varsa, üst çubuktaki monitör panelinden bunun için kesirli bir ölçek seçebilir veya `~/.config/hypr/monitors.lua` dosyasını açıp o kombinasyon için önerilene geçerek her monitör için varsayılanı ayarlayabilirsiniz:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

1080p veya 1440p bir ekran kullanıyorsanız, muhtemelen sadece 1x ölçeklendirme kullanmak isteyeceksiniz; aynısı GTK ve X11 uygulamaları için de geçerli, böylece şunu kullanabilirsiniz:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` değişiklikleri, değişiklikten sonra başlatılan uygulamalar için geçerlidir (ve GTK yalnızca tam sayıları kabul eder, bu yüzden onu monitör ölçeğinize en yakın tam sayıda tutun). Bu yüzden değişiklikten sonra çok büyük olan pencerelerinizi kapattığınızdan emin olun (veya tüm pencereleri `Ctrl + Alt + Del` ile kapatın!).

Ayrıca daha yükseğe çıkmak için `Super + /` ve daha düşüğe inmek için `Super + Alt + /` kullanarak veya üst çubuktaki monitör panelinden birini seçerek başlıca monitör ölçeklendirme oranları (1x, 1.25x, 1.6x, 2x, 3x, 4x) arasında hızlıca geçiş yapabilirsiniz. Bunlar yalnızca odaklandığınız monitörü değiştirir, böylece bir dizüstü bilgisayar ekranı ve harici bir ekranın her birinin kendi ölçeği olabilir. Panel ayrıca her monitörün çözünürlüğünü de ayarlar. Seçimleriniz o fiziksel monitör için `~/.local/state/omarchy/monitors/settings` içinde kaydedilir, böylece yeniden başlatmadan sonra da kalıcı olur ve monitörü bir sonraki sefer hangi bağlantı noktasına veya dock'a takarsanız takın onu takip eder. Bunlar, Omarchy'nin asla düzenlemediği `~/.config/hypr/monitors.lua` içindeki aynı monitöre yönelik herhangi bir kuraldan önceliklidir. `GDK_SCALE` tüm ekranlar için tek bir değer olduğundan, seçilen bir ölçek onu en düşük ölçeğe sahip monitörden ayarlar; böylece X11 uygulamaları diğer ekranda çok büyük çıkmak yerine daha yoğun ekranda biraz küçük çıkar.

### Metni büyütme veya küçültme

Monitör ölçeklendirmesi her şeyin boyutunu değiştirir. Tek istediğiniz daha büyük veya daha küçük _metin_ ise, bunun için tek bir ayar vardır:

```
omarchy display text size 14
```

Bu, 9 ile 20 arasında bir piksel boyutu alır ve Omarchy kabuğunu, GTK uygulamalarını ve terminalinizi birlikte hareket ettirir, böylece tüm masaüstü orantılı kalır. Nerede olduğunuzu görmek için argümansız çalıştırın ve varsayılana dönmek için `omarchy display text size reset` kullanın. Foot tek geride kalan: yapılandırmasını yeniden yüklemenin bir yolu yok, bu yüzden çalışan terminaller yeni bir tane açana kadar eski boyutlarını korur.

### Dizüstü bilgisayar ekranlarını genişletme ve yansıtma

Dizüstü bilgisayarınıza harici bir ekran bağladığınızda, ekran otomatik olarak genişletilir. Ancak Omarchy menüsünde _Trigger > Hardware_ yolunu veya `Super + Ctrl + Alt + Delete` kısayolunu kullanarak bunu bunun yerine yansıtmaya değiştirebilirsiniz. Bu, özellikle o harici ekran bir projektörse ve çalışırken bir şey göstermek istiyorsanız faydalıdır.

Genişletirken, dizüstü bilgisayarın kapağını kapatmak dahili ekranı otomatik olarak kapatacaktır. Kapağı açmak onu tekrar açacaktır. Bunu Omarchy menüsünde _Trigger > Hardware_ yolunu veya `Super + Ctrl + Delete` kısayolunu kullanarak manuel olarak da kontrol edebilirsiniz.

### Birden çok ekranı düzenleme

Hyprland birden çok ekranla harika çalışır. Üst çubuktaki monitör paneli onları oturdukları yerde çizer: birini diğerinin kenarına sürükleyerek oraya taşıyın, düzenleme her monitörün diğer ayarlarıyla birlikte kaydedilir. Panelin kapsamadığı herhangi bir şey için, [Hyprland monitör belgelerinde](https://wiki.hypr.land/Configuring/Basics/Monitors/) bunları nasıl yerleştireceğiniz hakkında daha fazla bilgi edinin. Omarchy'de bunlar `~/.config/hypr/monitors.lua` içine `hl.monitor` girdileri olarak gider — dosya, belirli bir monitörü bir çözünürlüğe, konuma ve döndürmeye sabitlemek için yorum satırı yapılmış örneklerle birlikte gelir.

Her monitörün kendine ait 1'den 10'a kadar çalışma alanları vardır, böylece `Super + 1` her zaman üzerinde olduğunuz monitörün ilk çalışma alanı anlamına gelir. Perde arkasında, Hyprland çalışma alanlarını yine de tüm monitörler genelinde numaralandırır: dizüstü bilgisayar ekranınız (veya ilk monitörünüz) 1–10'u, sonraki monitör 11–20'yi alır ve bu böyle devam eder; her monitör, onu her taktığınızda kendi bloğunu korur. Belirli bir monitör için [çalışma alanı kuralları](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) veya pencere kuralları yazarsanız bu numaraları kullanın, böylece çalışma alanı 12, ikinci monitörünüzün ikinci çalışma alanı olur. `~/.local/state/omarchy/monitors/workspaces` hangi monitörün hangi bloğa sahip olduğunu listeler.

Ok tuşları, düzeninizde bir kenarı paylaşan monitörler arasında çalışır. Yalnızca bir köşede birbirine değen veya aralarında boşluk olan ekranlar komşu değildir, bu yüzden aralarında geçiş yapmak için `Ctrl + Alt + Tab` kullanın.

| Kısayol | Monitörler arasında |
| --- | --- |
| `Super + Arrow` | O yönde artık pencere kalmadığında o taraftaki monitöre odağı taşır |
| `Super + Shift + Arrow` | O taraftaki monitördeki bir pencereyle yer değiştirir |
| `Super + Alt + Arrow` | Pencereyi o taraftaki monitördeki bir gruba taşır |
| `Super + Shift + Ctrl + Arrow` | Pencereyi o taraftaki monitöre, onun gösterdiği çalışma alanına taşır |
| `Super + Shift + Alt + Arrow` | Çalışma alanını o taraftaki monitöre taşır, boşsa numarasını korur |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Düzen ne olursa olsun odağı sonraki veya önceki monitöre taşır |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Üzerinde olduğunuz monitörde kalır |

Birden çok ekranın konumlandırılmasında size yardımcı olacak bir TUI isterseniz [Hyprmon](https://github.com/erans/hyprmon/) projesine de göz atabilirsiniz.

### Parlaklığı kontrol etme

Monitör parlaklığı, parlaklığı artırma/azaltma için ayrılmış işlev tuşlarıyla kontrol edilir. Bunlara basarken shift tuşunu basılı tutarsanız, maksimum veya minimum parlaklığa gidersiniz. Tuşlar odaklandığınız ekranı kontrol eder, böylece DDC/CI konuşan harici monitörler de dizüstü bilgisayar ekranıyla aynı şekilde ayarlanır.

### Apple Ekranlar

Apple bir ekran kullanıyorsanız, Apple ekrana odaklanmışsanız normal klavye parlaklık tuşları da otomatik olarak çalışacaktır. Bu, `asdcontrol` komutu aracılığıyla yapılır.

Apple 6K XDR ekran kullanıyorsanız, `hyprctl monitors` listenizde hayalet bir ekran görebileceğinizi unutmayın. Bunu `~/.config/hypr/monitors.lua` içinde `hl.monitor({ output = "DP-2", disabled = true })` gibi bir şeyle kapatabilirsiniz.

Intel makinelerde, Apple ekranlara normal bir Thunderbolt kablosu kullanarak bağlanmalısınız. Thunderbolt olmayan diğer makinelerde, çalışmasını sağlamak için genellikle bir [DP + USB-A -> USB-C kablosu](https://www.amazon.com/dp/B0BNX7MS6N) kullanmanız gerekecektir.
