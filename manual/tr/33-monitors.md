# Monitörler

Omarchy, varsayılan olarak 2x özellikli, retina sınıfı bir ekran kullandığınızı varsayar. Güzel, keskin programcı yazı tiplerini elde etmek için ihtiyacınız olan şey budur. Neredeyse tüm yeni, yüksek çözünürlüklü ekranlara sahip premium dizüstü bilgisayarlar bunun için optimize edilmiştir. 27" 5K bir [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) veya 32" 6K bir [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) üzerinde çalıştırmak isteyeceğiniz şey budur.

Ancak PPI değeri 218 veya üzerinde olan bir ekran kullanmıyorsanız monitör ayarlarını değiştirmek isteyeceksiniz. Örneğin 27" veya 32" bir 4K ekranınız varsa, `~/.config/hypr/monitors.lua` dosyasını açarak (Omarchy menüsünde _Kurulum > Monitörler_ üzerinden) ve o kombinasyon için önerilene geçerek kesirli ölçeklendirme kullanabilirsiniz:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

1080p veya 1440p bir ekran kullanıyorsanız muhtemelen sadece 1x ölçeklendirme kullanmak isteyeceksiniz, bu yüzden şunu kullanabilirsiniz:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` değişiklikleri, değişiklikten sonra başlatılan uygulamalar için geçerli olur (ve GTK yalnızca tam sayıları dikkate alır, bu yüzden onu monitör ölçeğinize en yakın tam sayıda tutun). Bu yüzden değişiklikten sonra aşırı büyük kalan pencerelerinizi kapattığınızdan emin olun (veya tüm pencereleri `Ctrl + Alt + Del` ile kapatın!).

Ayrıca daha yükseğe çıkmak için `Super + /` ve daha düşüğe inmek için `Super + Alt + /` kullanarak başlıca monitör ölçeklendirme oranları (1x, 1.25x, 1.6x, 2x, 3x, 4x) arasında hızlıca geçiş yapabilir veya üst çubuktaki monitör panelinden birini seçebilirsiniz. Bunlar yalnızca odaklandığınız monitörü değiştirir, böylece bir dizüstü bilgisayar ekranı ile harici bir ekranın her birinin kendi ölçeği olabilir. Seçim, o monitör için bir `hl.monitor` kuralı olarak `~/.config/hypr/monitors.lua` dosyasına kaydedilir, böylece yeniden başlatmadan sonra da kalıcı olur ve kendi kuralı olmayan her monitör için ölçek olarak kalmaya devam eden `omarchy_monitor_scale` değerinden öncelikli olur.

### Metni büyütme veya küçültme

Monitör ölçeklendirmesi her şeyin boyutunu değiştirir. İstediğiniz tek şey daha büyük veya daha küçük _metin_ ise, bunun için tek bir ayar vardır:

```
omarchy display text size 14
```

Bu, 9 ile 20 arasında bir piksel boyutu alır ve Omarchy kabuğunu, GTK uygulamalarını ve terminalinizi birlikte hareket ettirir, böylece tüm masaüstü orantılı kalır. Nerede olduğunuzu görmek için argümansız çalıştırın, varsayılana dönmek için `omarchy display text size reset` çalıştırın. Foot tek istisnadır: yapılandırmasını yeniden yüklemenin bir yolu yoktur, bu yüzden çalışan terminaller yeni bir tane açana kadar eski boyutlarını korur.

### Dizüstü bilgisayar ekranlarını genişletme ve yansıtma

Dizüstü bilgisayarınıza harici bir ekran bağladığınızda ekran otomatik olarak genişletilir. Ancak Omarchy menüsünde _Tetikleyici > Donanım_ seçeneğini veya `Super + Ctrl + Alt + Delete` kısayolunu kullanarak bunu bunun yerine yansıtmaya değiştirebilirsiniz. Bu, özellikle o harici ekran bir projektörse ve siz çalışırken bir şey göstermek istiyorsanız faydalıdır.

Genişletirken dizüstü bilgisayarın kapağını kapatmak dahili ekranı otomatik olarak kapatır. Kapağı açmak onu tekrar açar. Bunu Omarchy menüsünde _Tetikleyici > Donanım_ seçeneğini veya `Super + Ctrl + Delete` kısayolunu kullanarak manuel olarak da kontrol edebilirsiniz.

### Birden çok ekranı düzenleme

Hyprland birden çok ekranla harika çalışır. Bunların nasıl yerleştirileceği hakkında daha fazlasını [Hyprland monitör belgelerinde](https://wiki.hypr.land/Configuring/Basics/Monitors/) okuyun. Omarchy'de bunlar, `hl.monitor` girdileri olarak `~/.config/hypr/monitors.lua` dosyasına girer — dosya, belirli bir monitörü bir çözünürlüğe, konuma ve döndürmeye sabitlemek için yorum satırı yapılmış örneklerle birlikte gelir.

Her monitörün kendine ait 1'den 10'a kadar çalışma alanları vardır, bu yüzden `Super + 1` her zaman üzerinde olduğunuz monitörün ilk çalışma alanı anlamına gelir. Arka planda Hyprland çalışma alanlarını yine de tüm monitörler arasında numaralandırır: dizüstü bilgisayar ekranınız (veya ilk monitörünüz) 1–10'u, bir sonraki monitör 11–20'yi alır ve bu böyle devam eder ve her monitör, onu her taktığınızda kendi bloğunu korur. Belirli bir monitör için [çalışma alanı kuralları](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) veya pencere kuralları yazarsanız bu numaraları kullanın, böylece 12 numaralı çalışma alanı ikinci monitörünüzün ikinci çalışma alanı olur. `~/.local/state/omarchy/monitor-workspaces` her monitörün hangi bloğa sahip olduğunu listeler.

Ok tuşları, düzeninizde bir kenarı paylaşan monitörler arasında çalışır. Yalnızca bir köşede birbirine değen veya aralarında boşluk olan ekranlar komşu değildir, bu yüzden aralarında geçiş yapmak için `Ctrl + Alt + Tab` kullanın.

| Kısayol Tuşu | Monitörler arasında |
| --- | --- |
| `Super + Arrow` | O yönde artık pencere kalmadığında odağı o taraftaki monitöre taşır |
| `Super + Shift + Arrow` | O taraftaki monitördeki bir pencereyle yer değiştirir |
| `Super + Alt + Arrow` | Pencereyi o taraftaki monitördeki bir gruba taşır |
| `Super + Shift + Ctrl + Arrow` | Pencereyi o taraftaki monitöre, onun gösterdiği çalışma alanının üzerine taşır |
| `Super + Shift + Alt + Arrow` | Çalışma alanını o taraftaki monitöre taşır, boşsa numarasını korur |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Düzen ne olursa olsun odağı bir sonraki veya bir önceki monitöre taşır |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Üzerinde olduğunuz monitörde kalır |

Birden çok ekranın konumlandırılmasında size yardımcı olacak bir TUI isterseniz [Hyprmon](https://github.com/erans/hyprmon/)'a da göz atabilirsiniz.

### Parlaklığı kontrol etme

Monitör parlaklığı, parlaklığı artırma/azaltma için ayrılmış işlev tuşlarıyla kontrol edilir. Bunlara basarken Shift tuşunu basılı tutarsanız maksimum veya minimum parlaklığa gidersiniz. Tuşlar odaklandığınız ekranı kontrol eder, bu yüzden DDC/CI konuşan harici monitörler dizüstü bilgisayar ekranıyla aynı şekilde ayarlanır.

### Apple Ekranları

Bir Apple ekranı kullanıyorsanız, Apple ekranına odaklandığınızda normal klavye parlaklık tuşları da otomatik olarak çalışır. Bu, `asdcontrol` komutu aracılığıyla yapılır.

Bir Apple 6K XDR ekranı kullanıyorsanız `hyprctl monitors` listenizde hayalet bir ekran görebileceğinizi unutmayın. Bunu _Kurulum > Monitörler_ üzerinden `hl.monitor({ output = "DP-2", disabled = true })` gibi bir şeyle kapatabilirsiniz.

Intel makinelerde Apple ekranlarına normal bir Thunderbolt kablosu kullanarak bağlanmalısınız. Thunderbolt olmayan diğer makinelerde, çalışmasını sağlamak için genellikle bir [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) kullanmanız gerekecektir.
