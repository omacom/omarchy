# Gezinme

Omarchy'de her şey klavyeyle olur — _HER ŞEY!_ Sistem ilk kez başladığında, yalnızca fareyle kelimenin tam anlamıyla hiçbir şey yapamazsınız. Ama `Super + Space` tuşlarına basarak Omarchy Menüsünü açabilirsiniz ve buradan neredeyse her şeyi yapabilirsiniz.

Ancak Omarchy menüsü, çoğu zaman sistemi çalıştırmanın ana yolu olarak bile tasarlanmadı. Bundan daha hızlı olabiliriz! En önemli uygulamaların tümü doğrudan ayrı kısayol tuşlarına bağlıdır. Terminali `Super + Return` ile ve bir tarayıcıyı `Super + Shift + Return` ile başlatırsınız. İkisini art arda deneyin, Hyprland'ın döşemesinin büyüsünü iş başında göreceksiniz:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ardından `Super + J` tuşlarına basarak bunları yan yana yerine üst üste istifleyebilirsiniz:

 ![navigation-stacked](images/navigation-stacked.webp)

Yan yana konumlarına döndürmek için tekrar `Super + J` tuşlarına basın. Ardından pencerelerin yerini değiştirmek için tarayıcıdayken `Super + Shift + Arrow Right` tuşlarını deneyin.

Şimdi Activity monitörünü başlatmak için `Super + Shift + T` tuşlarını deneyin. Bu, sürükleyebileceğiniz bir başlık çubuğu ve simge durumuna küçültme, büyütme ve kapatma düğmeleri olan yüzen bir pencere olarak görünür. Nerede olursa olsun, her yüzen pencere bir tane alır. `Super + T` kullanarak döşeyebilirsiniz (ve tekrar basarak yeniden yüzen yapabilirsiniz). Şimdi dosya yöneticisini açmak için `Super + Shift + F` tuşlarına basın. Şık bir dörtlü kurulumunuz olacak:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Aktif olmasını istediğiniz pencere arasında `Super + Arrow` ile gezinirsiniz. Bu, odağı değiştirir ve imleci yeni uygulamanın merkezine taşır. Bir ekranın kenarında, o taraftaki monitöre devam eder.

`Super + Shift + 2` tuşlarına basarsanız, o anda odaklanılan uygulamayı ikinci çalışma alanına taşırsınız. `Super + Shift + 1` onu geri taşır. (Ve `Super + Shift + Alt + 2`, o anda odaklanılan uygulamayı ona geçmeden ikinci çalışma alanına taşır).

Birden fazla monitörle, her monitörün kendine ait 1'den 10'a kadar çalışma alanları vardır. `Super + 2`, üzerinde olduğunuz monitörün ikinci çalışma alanına gider ve her monitörün üst çubuğu kendi çalışma alanlarını ve gösterdiğini gösterir. `Super + Tab`, üzerinde olduğunuz monitördeki çalışma alanları arasında geçiş yapar. `Super + Shift + Ctrl + Arrows`, üzerinde olduğunuz pencereyi o yöndeki monitöre, gösterdiği çalışma alanına taşır ve `Super + Shift + Alt + Arrows`, üzerinde olduğunuz çalışma alanını o yöndeki monitöre taşır; orada boşsa aynı numarayı alır. Bir monitör, fişini çektiğinizde çalışma alanlarını korur: bunlar başka bir ekranınkine katılır, zaten sahip olduklarının ardından numaralandırılır ve monitör geri geldiğinde eski numaralarıyla geri dönerler.

`Super` tuşunu basılı tutar ve fareyle bir pencereye tıklarsanız, oturduğu yeri yeniden düzenleyebilirsiniz. `Super` tuşunu basılı tutar ve farenin sağ düğmesini kullanırsanız, pencereyi serbestçe yeniden boyutlandırabilirsiniz.

Bir pencereyi `Super + W` veya `Super + Q` ile kapatırsınız (ve tüm pencereleri `Ctrl + Alt + Delete` ile kapatırsınız).

Ayrıca `Super + F` ile tam ekrana veya `Super + Alt + F` ile yalnızca tam genişliğe (üst çubuğu koruyarak) veya `Super + Ctrl + F` ile bir pencere içinde tam ekrana geçebilirsiniz (YouTube için iyidir!).

### Dwindle ve kaydırmalı düzen karşılaştırması

Omarchy'nin varsayılan düzenine dwindle denir. Açtığınız tüm pencereleri, küçültmesi gerekse bile, tek bir çalışma alanında her zaman görünür tutar.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ancak bir çalışma alanını, pencerelerin ekranın görünür kenarının ötesinde yan yana sıralandığı kaydırmalı düzene dönüştürmeyi de seçebilirsiniz. Tek bir çalışma alanını `Super + L` ile bu düzene dönüştürürsünüz.

Tekrar `Super + L` tuşlarına basmak çalışma alanını yüzen hale getirir; burada pencereler serbestçe çakışır ve onları kendiniz yerleştirirsiniz ve üçüncü bir basış onu dwindle'a geri döndürür. `Super + Alt + L` bunlardan ters yönde geçer. Her durumda yüzen bir pencere — `Super + T` ile dışarı çıkardığınız veya her zaman yüzen olarak açılan bir uygulama — çalışma alanı döşemeye geri döndüğünde yüzen kalmaya devam eder. Üst çubuk, üzerinde olduğunuz çalışma alanını düzeniyle işaretler: dwindle için bir kare, kaydırmalı için bir daire ve yüzen için bir üçgen. Bu işarete tıklamak da düzeni değiştirir ve buna sahip dizüstü bilgisayarlardaki ekran tuşu da öyle.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Seçim çalışma alanı başınadır ve kalıcıdır. Yani 1. çalışma alanını gezinmek için dwindle'da ve 2. çalışma alanını kod için kaydırmalıda tutabilirsiniz ve yeniden başlatmadan sonra bu şekilde geri gelirler.

Kaydırmalı düzeni varsayılan olarak kullanmak isterseniz, bunu `~/.config/hypr/looknfeel.lua` içinde ayarlayabilirsiniz:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Yüzen çalışma alanları

Yüzen bir çalışma alanı geleneksel bir masaüstü gibi çalışır: pencereler çakışır ve onları kendiniz taşır ve boyutlandırırsınız. Her pencere temanızın renklerinde bir başlık çubuğu alır; simge durumuna küçültme, büyütme ve kapatma düğmeleriyle birlikte. `Super + M` odaklanılan pencereyi de simge durumuna küçültür. Simge durumuna küçültülmüş bir pencere dock'ta bekler; geri getirmek için uygulamasına tıklayın. Bir pencereyi öne getirmek için tıklayın. Herhangi bir kenardan veya köşeden yeniden boyutlandırın. Üst çubuğu görünürde tutarken pencereyi büyütmek için bir başlık çubuğuna çift tıklayın ve eski boyutunu geri almak için tekrar çift tıklayın. Chrome ve diğer Chromium tabanlı tarayıcılar, Disks ve Document Viewer başlık çubuğunu atlar ve bunun yerine kendi üst bilgilerini kullanır; `Super + Alt + F` onları büyütür ve `Super + M` onları simge durumuna küçültür.

Her çalışma alanının bir dock'u vardır; sabitlenmiş uygulamalarınız, çalışan her şey ve uygulamalar düğmesinin arkasındaki her uygulamanın ızgarası ile birlikte; bunu `Super + Alt + Space` ve Omarchy menüsündeki _Apps_ de açar. Bir uygulamayı kaldırmak için ızgarada ona sağ tıklayın veya `Delete` tuşuna basın. Açmak veya penceresini öne getirmek için bir uygulamaya tıklayın; pencereleri arasında geçiş yapmak için tekrar tıklayın. Files yalnızca üzerinde olduğunuz çalışma alanından bir pencereyi geri getirir ve aksi takdirde yeni bir tane açar ve Terminal ve Agent her zaman bir başkasını başlatır, ancak simge durumuna küçültülmüş bir pencere önce geri gelir. Orta tıklama yeni bir pencere açar. Taşımak için bir simgeyi dock boyunca sürükleyin; çalışan bir uygulamayı diğerlerinin arasına sürüklemek onu orada tutar. Bir uygulamayı dock'ta tutmak, çıkarmak veya ondan çıkmak için sağ tıklayın. Dock, bir çalışma alanı boşken dışarıda kalır ve çalışma alanında bir pencere olduğunda, işaretçi kenarına ulaşana kadar gizlenir. Tam ekran bir pencere onu tamamen gizler. Dock'u oraya taşımak için uygulamalar düğmesini ekranın başka bir kenarına doğru sürükleyin. Bir kenar seçmek için _Position_ ve varsayılan düzeni _Appearance > Workspace Layout_ öğesinin yaptığı gibi ayarlamak için _Layout_ için ona sağ tıklayın. Konum ayrıca _Appearance > Dock > Dock Position_ altındadır ve `omarchy dock position left` bunu bir terminalden ayarlar. Dock'ta tuttuğunuz uygulamalar çalışmadıklarında soluktur. Dock'u yüzen çalışma alanlarıyla sınırlamak için _Appearance > Dock > Dock Only on Floating_ öğesini veya `omarchy dock tiling off` komutunu kullanın.

Yeni çalışma alanları ve `Super + L` ile kendine ait bir düzen vermedikleriniz varsayılan düzeni kullanır. Varsayılanı değiştirmek, penceresi olmayan her çalışma alanını ona sıfırlar; penceresi olan ise sahip olduğu düzeni korur. Dock'a simge durumuna küçültülmüş bir pencere hâlâ ayrıldığı çalışma alanında bir pencere sayılır. Bunu _Appearance > Workspace Layout_ altında seçin: Tiling, Scrolling veya Floating. `omarchy hyprland workspace layout default scrolling` bunu bir terminalden ayarlar.

### Pencereleri gruplama

Pencereler `Super + G` kullanılarak gruplanabilir. Bir gruba girdikten sonra, o aktifken başlattığınız her pencere gruba ait olur. Bu gruplanmış pencereler arasında `Super + Ctrl + Arrow Left/Right` kullanarak veya doğrudan sıralı olarak gruplanmış pencerelere gitmek için `Super + Alt + 1/2/3/4` kullanarak hareket edebilirsiniz.

Bir pencereyi `Super + Alt + G` ile grubun dışına taşıyabilir veya tekrar `Super + G` tuşlarına basarak tüm grubu dağıtabilirsiniz. Son olarak, grup dışındaki pencereleri `Super + Alt + Arrows` ile içine taşıyabilirsiniz.

### Pencereleri dışarı çıkarma

Bir pencereyi `Super + O` ile çalışma alanı tahsisinden dışarı çıkarabilirsiniz. Bu, onu gittiğiniz her çalışma alanında sizi takip eden yüzen bir pencere olarak sabitler. Video oynatıcılar ve benzerleri için harikadır.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad çalışma alanı

Üzerinde olduğunuz çalışma alanının üstüne binen özel, tam boyutlu bir scratchpad çalışma alanı vardır. Üzerindekine `Super + S` kullanarak erişirsiniz ve pencereleri oraya `Super + Alt + S` kullanarak yerleştirirsiniz.

Mevcut çalışma alanından ayrılmadan hızlıca etkileşim kurmak istediğiniz kontroller veya bir terminal için iyi çalışır.

### Quake konsolu

Son olarak, üzerinde olduğunuz çalışma alanının üzerine açılan yarım yükseklikte bir Quake konsolu vardır. `Super + the key above Tab` (ABD düzenlerinde grave) ile açıp kapatın ve oraya `Super + Shift + the key above Tab` kullanarak bir pencere yerleştirin.

İlk açıldığında, varsayılan agent'ınızı başlatır veya henüz bir tane seçmediyseniz bir tane seçmenizi ister. Konsol tek bir pencere tutarken, ekranı kaplamak yerine ortalanmış bir panel olarak açılır. Üzerine ikinci bir uygulama koyun ve yan yana oturacak alanları olması için tam genişliğe geri döner.

Bir pencereyi scratchpad'den veya konsoldan taşımak için, `Super + Shift + 1` gibi bir şeyle doğrudan başka bir çalışma alanına gönderin.

### Buna alışmak biraz zaman alır!

Masaüstünüzde bu şekilde gezinmeye alışmak biraz zaman alır, ancak alıştığınızda geleneksel fareyle çalışan bir masaüstü deneyimine geri dönmek zor olacaktır!
