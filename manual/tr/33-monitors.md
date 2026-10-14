# Monitörler

Omarchy, varsayılan olarak 2x kapasiteli retina sınıfı bir ekran üzerinde çalıştığınızı varsayar. O güzel, keskin programcı yazı tiplerini elde etmek için buna ihtiyacınız vardır. Yüksek çözünürlüklü ekranlara sahip neredeyse tüm yeni premium dizüstü bilgisayarların optimize edildiği şey budur. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) veya 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) üzerinde çalıştırmak isteyeceğiniz şey budur.

Ancak PPI değeri 218 veya üzerinde olan bir ekran çalıştırmıyorsanız, monitör ayarlarını değiştirmek isteyeceksiniz. Örneğin 27" veya 32" 4K bir ekranınız varsa, `~/.config/hypr/monitors.lua` dosyasını açarak (Omarchy menüsündeki _Ayarlar > Monitors_ aracılığıyla) ve o kombinasyon için öneriye geçerek kesirli ölçekleme kullanabilirsiniz:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

1080p veya 1440p bir ekran kullanıyorsanız, muhtemelen sadece 1x ölçekleme kullanmak isteyeceksiniz, bu yüzden şunları kullanabilirsiniz:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` değişiklikleri, değişiklikten sonra başlatılan uygulamalar için geçerlidir (ve GTK yalnızca tam sayılara uyar, bu yüzden bunu monitör ölçeğinizin en yakın tam sayısında tutun). Bu yüzden değişiklikten sonra sahip olduğunuz büyük boyutlu pencerelerden çıktığınızdan emin olun (veya tüm pencereleri `Ctrl + Alt + Del` ile kapatın!).

Ayrıca, daha yükseğe çıkmak için `Super + /` ve daha alçağa inmek için `Super + Alt + /` kullanarak başlıca monitör ölçekleme oranları (1x, 1.25x, 1.6x, 2x, 3x, 4x) arasında hızlıca adım atabilirsiniz. Varsayılan yapılandırmaya sahipseniz, bu değişiklikler yeniden başlatmanın ötesinde de kalıcı olacaktır.

### Metni daha büyük veya daha küçük yapmak

Monitör ölçekleme her şeyin boyutunu değiştirir. Tüm istediğiniz daha büyük veya daha küçük _metin_ ise, bunun için tek bir düğme vardır:

```
omarchy display text size 14
```

Bu, 9 ile 20 arasında bir piksel boyutu alır ve Omarchy kabuğunu, GTK uygulamalarını ve terminalinizi birlikte hareket ettirir, böylece tüm masaüstü orantılı kalır. Nerede olduğunuzu görmek için argümansız çalıştırın ve varsayılana dönmek için `omarchy display text size reset` komutunu kullanın. Foot tek tutarsız olandır: yapılandırmasını yeniden yüklemenin bir yolu yoktur, bu yüzden çalışan terminaller yeni bir tane açana kadar eski boyutlarını korur.

### Dizüstü ekranlarını genişletmek ve yansıtmak

Dizüstü bilgisayarınıza harici bir ekran bağladığınızda, ekran otomatik olarak genişletilir. Ancak bunu, Omarchy menüsündeki _Tetikle > Hardware_ veya `Super + Ctrl + Alt + Delete` kullanarak bunun yerine yansıtma olarak değiştirebilirsiniz. Bu, özellikle o harici ekran bir projektörse ve çalışırken bir şey göstermek isterseniz yararlıdır.

Genişletirken, dizüstü bilgisayardaki kapağı kapatmak dahili ekranı otomatik olarak kapatacaktır. Kapağı açmak onu yeniden açacaktır. Bunu Omarchy menüsündeki _Tetikle > Hardware_ veya `Super + Ctrl + Delete` kullanarak elle de kontrol edebilirsiniz.

### Birden çok ekranı düzenlemek

Hyprland birden çok ekranla harika çalışır. Bunları nasıl düzenleyeceğiniz hakkında daha fazlasını [Hyprland monitör belgelerinde](https://wiki.hypr.land/Configuring/Basics/Monitors/) okuyun. [Belirli çalışma alanlarını belirli monitörlere de bağlayabilirsiniz](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). Omarchy'de bu kurallar `~/.config/hypr/monitors.lua` içinde `hl.monitor` girişleri olarak yer alır — dosya, belirli bir monitörü bir çözünürlüğe, konuma ve döndürmeye sabitlemek için yorumlanmış örneklerle birlikte gelir.

Birden çok ekranın konumlandırılmasında size yardımcı olacak bir TUI isterseniz [Hyprmon](https://github.com/erans/hyprmon/) aracına da bakabilirsiniz.

### Parlaklığı kontrol etmek

Monitör parlaklığı, parlaklığı artırma/azaltma için ayrılmış işlev tuşlarıyla kontrol edilir. Bunlara basarken shift tuşunu basılı tutarsanız, maksimum veya minimum parlaklığa gidersiniz. Tuşlar, odaklandığınız ekranı kontrol eder; bu yüzden DDC/CI konuşan harici monitörler, dizüstü ekranıyla aynı şekilde ayarlanır.

### Apple Ekranları

Bir Apple ekranı kullanıyorsanız, Apple ekranına odaklanmışsanız normal klavye parlaklık tuşları da otomatik olarak çalışacaktır. Bu, `asdcontrol` komutu aracılığıyla yapılır.

Bir Apple 6K XDR ekranı kullanıyorsanız, `hyprctl monitors` listenizde bir hayalet ekran görebileceğinizi unutmayın. Bunu _Ayarlar > Monitors_ aracılığıyla `hl.monitor({ output = "DP-2", disabled = true })` gibi bir şeyle kapatabilirsiniz.

Intel makinelerde, Apple ekranlarına normal bir Thunderbolt kablosu kullanarak bağlanmalısınız. Thunderbolt olmayan diğer makinelerde, çalışmasını sağlamak için genellikle bir [DP + USB-A -> USB-C kablosu](https://www.amazon.com/dp/B0BNX7MS6N) kullanmanız gerekecektir.
