# Monitörler

Omarchy, varsayılan olarak 2x kapasiteli retina sınıfı bir ekran kullandığınızı varsayıyor. O güzel, keskin programcı fontlarını elde etmek için ihtiyacınız olan şey bu. Yüksek çözünürlüklü ekranlara sahip neredeyse tüm yeni premium dizüstü bilgisayarların optimize edildiği şey bu. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) veya 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) üzerinde çalıştırmak isteyeceğiniz şey bu.

Ancak 218 veya üzerinde PPI değerine sahip bir ekran kullanmıyorsanız, monitör ayarlarını değiştirmek isteyeceksiniz. Örneğin, 27" veya 32" 4K'nız varsa, `~/.config/hypr/monitors.lua` dosyasını açarak (Omarchy menüsünde _Setup > Monitors_ yoluyla) kesirli ölçeklendirme kullanabilir ve o kombinasyon için önerilene geçebilirsiniz:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

1080p veya 1440p bir ekran kullanıyorsanız, muhtemelen sadece 1x ölçeklendirme kullanmak isteyeceksiniz, yani şunu kullanabilirsiniz:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` değişiklikleri, değişiklikten sonra başlatılan uygulamalar için geçerlidir (ve GTK yalnızca tam sayıları dikkate alır, bu yüzden onu monitör ölçeğinizin en yakın tam sayısında tutun). Bu yüzden değişiklikten sonra boyutu fazla büyük olan pencerelerden çıktığınızdan emin olun (veya tüm pencereleri `Ctrl + Alt + Del` ile kapatın!).

Ayrıca başlıca monitör ölçeklendirme oranları (1x, 1.25x, 1.6x, 2x, 3x, 4x) arasında `Super + /` kullanarak daha yükseğe ve `Super + Alt + /` kullanarak daha düşüğe hızlıca geçiş yapabilirsiniz. Varsayılan yapılandırmaya sahipseniz, bu değişiklikler yeniden başlatmadan sonra da kalıcı olur.

### Metni büyütme veya küçültme

Monitör ölçeklendirmesi her şeyin boyutunu değiştirir. İstediğiniz tek şey daha büyük veya daha küçük _metin_ ise, bunun için tek bir ayar var:

```
omarchy display text size 14
```

Bu, 9 ile 20 arasında bir piksel boyutu alır ve Omarchy kabuğunu, GTK uygulamalarını ve terminalinizi birlikte hareket ettirir, böylece tüm masaüstü orantılı kalır. Nerede olduğunuzu görmek için bağımsız değişken olmadan çalıştırın ve varsayılana dönmek için `omarchy display text size reset` çalıştırın. Foot tek geri kalandır: yapılandırmasını yeniden yüklemenin bir yolu yoktur, bu yüzden çalışan terminaller yeni bir tane açana kadar eski boyutlarını korur.

### Dizüstü bilgisayar ekranlarını genişletme ve yansıtma

Dizüstü bilgisayarınıza harici bir ekran bağladığınızda, ekran otomatik olarak genişletilir. Ancak Omarchy menüsünde _Trigger > Hardware_ kullanarak veya `Super + Ctrl + Alt + Delete` ile bunu bunun yerine yansıtma olarak değiştirebilirsiniz. Bu, özellikle o harici ekran bir projektörse ve çalışırken bir şey göstermek istiyorsanız faydalıdır.

Genişletirken, dizüstü bilgisayarın kapağını kapatmak dahili ekranı otomatik olarak kapatır. Kapağı açmak onu tekrar açar. Bunu Omarchy menüsünde _Trigger > Hardware_ kullanarak veya `Super + Ctrl + Delete` ile manuel olarak da kontrol edebilirsiniz.

### Birden çok ekranı düzenleme

Hyprland birden çok ekranla harika çalışır. Bunların nasıl yerleştirileceği hakkında daha fazla bilgiyi [Hyprland monitör belgelerinde](https://wiki.hypr.land/Configuring/Basics/Monitors/) okuyun. Omarchy'de bunlar `~/.config/hypr/monitors.lua` içinde `hl.monitor` girdileri olarak yer alır — dosya, belirli bir monitörü bir çözünürlüğe, konuma ve döndürmeye sabitlemek için yorum satırı yapılmış örneklerle birlikte gelir.

Her monitörün kendine ait 1'den 10'a kadar çalışma alanları vardır, bu yüzden `Super + 1` her zaman üzerinde olduğunuz monitörün ilk çalışma alanı anlamına gelir. Perde arkasında, Hyprland çalışma alanlarını hâlâ tüm monitörler arasında numaralandırır: dizüstü bilgisayar ekranınız (veya ilk monitörünüz) 1–10, sonraki monitör 11–20, vb. alır ve her monitör onu her taktığınızda kendi bloğunu korur. Belirli bir monitör için [çalışma alanı kuralları](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) veya pencere kuralları yazarsanız bu numaraları kullanın, böylece 12 numaralı çalışma alanı ikinci monitörünüzün ikinci çalışma alanıdır. `~/.local/state/omarchy/monitor-workspaces`, her monitörün hangi bloğa sahip olduğunu listeler.

Ok tuşları, düzeninizde bir kenarı paylaşan monitörler arasında çalışır. Yalnızca bir köşede temas eden veya aralarında boşluk olan ekranlar komşu değildir, bu yüzden aralarında geçiş yapmak için `Ctrl + Alt + Tab` kullanın.

| Kısayol | Monitörler arasında |
| --- | --- |
| `Super + Arrow` | O yönde pencere kalmadığında o taraftaki monitöre odağı taşır |
| `Super + Shift + Arrow` | O taraftaki monitördeki bir pencereyle yer değiştirir |
| `Super + Alt + Arrow` | Pencereyi o taraftaki monitördeki bir gruba taşır |
| `Super + Shift + Ctrl + Arrow` | Pencereyi o taraftaki monitöre, gösterdiği çalışma alanına taşır |
| `Super + Shift + Alt + Arrow` | Çalışma alanını o taraftaki monitöre taşır, boşsa numarasını korur |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Düzen ne olursa olsun odağı sonraki veya önceki monitöre taşır |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Üzerinde olduğunuz monitörde kalır |

Birden çok ekranın konumlandırılmasında size yardımcı olacak bir TUI istiyorsanız, [Hyprmon](https://github.com/erans/hyprmon/)'a da göz atabilirsiniz.

### Parlaklığı kontrol etme

Monitör parlaklığı, parlaklığı artırma/azaltma için ayrılmış fonksiyon tuşlarıyla kontrol edilir. Bunlara basarken shift tuşunu basılı tutarsanız, maksimum veya minimum parlaklığa gidersiniz. Tuşlar odaklandığınız ekranı kontrol eder, bu yüzden DDC/CI konuşan harici monitörler dizüstü bilgisayar ekranıyla aynı şekilde ayarlanır.

### Apple Ekranları

Bir Apple ekran kullanıyorsanız, Apple ekrana odaklanmışsanız normal klavye parlaklık tuşları da otomatik olarak çalışır. Bu, `asdcontrol` komutu aracılığıyla yapılır.

Bir Apple 6K XDR ekran kullanıyorsanız, `hyprctl monitors` listenizde hayalet bir ekran görebileceğinizi unutmayın. Bunu _Setup > Monitors_ yoluyla `hl.monitor({ output = "DP-2", disabled = true })` gibi bir şeyle kapatabilirsiniz.

Intel makinelerde, Apple ekranlara normal bir Thunderbolt kablosu kullanarak bağlanmalısınız. Thunderbolt'u olmayan diğer makinelerde, çalışmasını sağlamak için genellikle bir [DP + USB-A -> USB-C kablosu](https://www.amazon.com/dp/B0BNX7MS6N) kullanmanız gerekir.
