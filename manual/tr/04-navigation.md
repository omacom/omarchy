# Gezinme

Omarchy'de her şey klavyeyle olur — _HER ŞEY!_ Sistem ilk açıldığında, yalnızca fareyle kelimenin tam anlamıyla hiçbir şey yapamazsınız. Ama `Super + Space` tuşlarına basarak Omarchy Menu'yü ortaya çıkarabilirsiniz ve buradan hemen hemen her şeyi yapabilirsiniz.

Ama Omarchy menüsü, çoğu zaman sistemi kullanmanın ana yolu olarak bile tasarlanmadı. Bundan daha hızlı olabiliriz! En önemli uygulamaların tümü doğrudan tek tek kısayol tuşlarına bağlıdır. Terminali `Super + Return` ile, bir tarayıcıyı `Super + Shift + Return` ile başlatırsınız. Birini diğerinin ardından deneyin, Hyprland'in döşeme sihrini iş başında göreceksiniz:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ardından `Super + J` tuşlarına basarak bunları yan yana yerine üst üste yığabilirsiniz:

 ![navigation-stacked](images/navigation-stacked.webp)

Onları yan yana konumlarına döndürmek için `Super + J` tuşlarına tekrar basın. Ardından tarayıcıdayken pencereleri takas etmek için `Super + Shift + Arrow Right` tuşlarını deneyin.

Şimdi Activity izleyicisini başlatmak için `Super + Shift + T` tuşlarını deneyin. Bu, sürükleyebileceğiniz bir başlık çubuğu ve simge durumuna küçültme, ekranı kaplama ve kapatma düğmeleriyle yüzen bir pencere olarak görünür. Her yüzen pencere, nerede olursa olsun bir tane alır. `Super + T` kullanarak onu döşeyebilirsiniz (ve tekrar yüzen yapmak için o tuşa tekrar basın). Şimdi dosya yöneticisini açmak için `Super + Shift + F` tuşlarına basın. Düzenli bir dörtlü düzeniniz olacak:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Etkin olmasını istediğiniz pencere arasında `Super + Arrow` ile gezinirsiniz. Bu, odağı değiştirir ve imleci yeni uygulamanın merkezine taşır. Bir ekranın kenarında, o taraftaki monitörde devam eder.

`Super + Shift + 2` tuşlarına basarsanız, o anda odaklanılan uygulamayı ikinci çalışma alanına taşırsınız. `Super + Shift + 1` onu geri taşır. (`Super + Shift + Alt + 2` ise o anda odaklanılan uygulamayı, ona geçmeden ikinci çalışma alanına taşır).

Birden fazla monitörde, her monitörün kendine ait 1'den 10'a kadar çalışma alanları vardır. `Super + 2`, üzerinde olduğunuz monitörün ikinci çalışma alanına gider ve her monitörün üst çubuğu kendi çalışma alanlarını ve gösterdiğini gösterir. `Super + Tab`, üzerinde olduğunuz monitördeki çalışma alanları arasında döner. `Super + Shift + Ctrl + Arrows`, üzerinde olduğunuz pencereyi o yöndeki monitöre, onun gösterdiği çalışma alanına taşır ve `Super + Shift + Alt + Arrows`, üzerinde olduğunuz çalışma alanını o yöndeki monitöre taşır; orada boşsa aynı numarayı alır. Bir monitör, fişini çektiğinizde çalışma alanlarını korur: bunlar başka bir ekranınkine katılır, onun zaten sahip olduklarından sonra numaralandırılır ve monitör geri geldiğinde eski numaralarının altına geri döner.

`Super` tuşunu basılı tutup fareyle bir pencereye tıklarsanız, pencerenin nerede durduğunu yeniden düzenleyebilirsiniz. `Super` tuşunu basılı tutup farenin sağ düğmesini kullanırsanız, pencereyi serbestçe yeniden boyutlandırabilirsiniz.

Bir pencereyi `Super + W` veya `Super + Q` ile kapatırsınız (ve tüm pencereleri `Ctrl + Alt + Delete` ile kapatırsınız).

Ayrıca `Super + F` ile tam ekrana geçebilir, hatta `Super + Alt + F` ile yalnızca tam genişliğe (üst çubuğu koruyarak) geçebilir veya `Super + Ctrl + F` ile bir pencere içinde tam ekran yapabilirsiniz (YouTube için iyi!).

### Dwindle vs kaydırmalı düzen

Omarchy'nin varsayılan düzenine dwindle denir. Bir çalışma alanında açtığınız tüm pencereleri, küçültmesi gerekse bile her zaman görünür tutar.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ama bir çalışma alanını, pencerelerin yan yana, ekranın görünür kenarının ötesinde sıralandığı kaydırmalı düzene dönüştürmeyi de seçebilirsiniz. Tek bir çalışma alanını `Super + L` ile bu düzene dönüştürürsünüz.

`Super + L` tuşuna tekrar basmak çalışma alanını yüzen düzene çevirir; burada pencereler serbestçe çakışır ve onları kendiniz yerleştirirsiniz, üçüncü bir basış onu dwindle'a geri döndürür. `Super + Alt + L` bunlardan ters yönde geçer. Her durumda yüzen bir pencere — `Super + T` ile dışarı çıkardığınız veya her zaman yüzen açılan bir uygulama — çalışma alanı döşemeye geri döndüğünde yüzen kalmaya devam eder. Üst çubuk, üzerinde olduğunuz çalışma alanını düzeniyle işaretler: dwindle için bir kare, kaydırmalı için bir daire ve yüzen için bir üçgen. O işarete tıklamak da düzeni döngüye sokar, böyle bir tuşa sahip dizüstü bilgisayarlardaki ekran tuşu da öyle yapar.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Seçim çalışma alanı başına yapılır ve kalıcıdır. Yani 1. çalışma alanını gezinmek için dwindle'da, 2. çalışma alanını kod için kaydırmalıda tutabilirsiniz ve yeniden başlatmanın ardından bu şekilde geri gelirler.

Kaydırmalı düzeni varsayılan olarak kullanmak isterseniz, bunu `~/.config/hypr/looknfeel.lua` içinde ayarlayabilirsiniz:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Yüzen çalışma alanları

Yüzen bir çalışma alanı geleneksel bir masaüstü gibi çalışır: pencereler çakışır ve onları kendiniz taşıyıp boyutlandırırsınız. Her pencere, temanızın renklerinde, simge durumuna küçültme, ekranı kaplama ve kapatma düğmeleriyle bir başlık çubuğu alır. `Super + M` de odaklanılan pencereyi simge durumuna küçültür. Simge durumuna küçültülmüş bir pencere dock'ta bekler; geri getirmek için uygulamasına tıklayın. Bir pencereyi öne getirmek için tıklayın. Herhangi bir kenardan veya köşeden yeniden boyutlandırın. Üst çubuğu görünürde tutarken pencereyi ekranı kaplamak için bir başlık çubuğuna çift tıklayın, eski boyutunu geri almak için tekrar çift tıklayın. Chrome ve diğer Chromium tabanlı tarayıcılar, Disks ve Document Viewer başlık çubuğunu atlar ve bunun yerine kendi başlıklarını kullanır; `Super + Alt + F` onları ekranı kaplar ve `Super + M` onları simge durumuna küçültür.

Her çalışma alanının bir dock'u vardır; sabitlenmiş uygulamalarınız, çalışan her şey ve uygulamalar düğmesinin arkasında her uygulamanın bir ızgarası bulunur; `Super + Alt + Space` ve Omarchy menüsündeki _Apps_ da bunu açar. Kaldırmak için ızgaradaki bir uygulamaya sağ tıklayın veya `Delete` tuşuna basın. Açmak veya penceresini öne getirmek için bir uygulamaya tıklayın; pencereleri arasında geçiş yapmak için tekrar tıklayın. Files yalnızca üzerinde olduğunuz çalışma alanından bir pencereyi geri getirir, aksi halde yeni bir tane açar ve Terminal ve Agent her zaman bir tane daha başlatır, ancak simge durumuna küçültülmüş bir pencere önce geri gelir. Orta tıklama yeni bir pencere açar. Taşımak için bir simgeyi dock boyunca sürükleyin; çalışan bir uygulamayı diğerlerinin arasına sürüklemek onu orada tutar. Bir uygulamayı dock'ta tutmak, çıkarmak veya kapatmak için sağ tıklayın. Dock, bir çalışma alanı boşken dışarıda kalır ve çalışma alanında bir pencere olduğunda, işaretçi kenarına ulaşana kadar gizlenir. Tam ekran bir pencere onu tamamen gizler. Dock'u oraya taşımak için uygulamalar düğmesini ekranın başka bir kenarına doğru sürükleyin. Bir kenar seçmek için _Position_, varsayılan düzeni _Appearance > Workspace Layout_'ın yaptığı gibi ayarlamak için _Layout_ ve dock'u her zaman açık tutmak, ilk uygulamanın onu gizlemesini sağlamak veya her zaman gizli tutmak için _Visibility_ seçenekleri için ona sağ tıklayın. `omarchy dock visibility always` bunu bir terminalden ayarlar. Konum ayrıca _Appearance > Dock > Dock Position_ altındadır ve `omarchy dock position left` bunu bir terminalden ayarlar. Dock'ta tuttuğunuz uygulamalar çalışmadıklarında soluk görünür. Dock'u yüzen çalışma alanlarıyla sınırlı tutmak için _Appearance > Dock > Dock Only on Floating_ veya `omarchy dock tiling off` kullanın.

Yeni çalışma alanları ve `Super + L` ile kendine ait bir düzen vermedikleriniz, varsayılan düzeni kullanır. Varsayılanı değiştirmek, penceresi olmayan her çalışma alanını ona sıfırlar; üzerinde pencereler olan ise sahip olduğu düzeni korur. Dock'a simge durumuna küçültülmüş bir pencere hâlâ ayrıldığı çalışma alanında bir pencere sayılır. Bunu _Appearance > Workspace Layout_ altında seçin: Tiling, Scrolling veya Floating. `omarchy hyprland workspace layout default scrolling` bunu bir terminalden ayarlar.

### Pencereleri gruplama

Pencereler `Super + G` kullanılarak gruplandırılabilir. Bir grubun içindeyken, o etkinken başlattığınız her pencere gruba ait olur. Bu gruplandırılmış pencereler arasında `Super + Ctrl + Arrow Left/Right` kullanarak hareket edebilir veya sırayla gruplandırılmış pencerelere doğrudan gitmek için `Super + Alt + 1/2/3/4` kullanabilirsiniz.

Bir pencereyi `Super + Alt + G` ile grubun dışına taşıyabilir veya `Super + G` tuşuna tekrar basarak tüm grubu dağıtabilirsiniz. Son olarak, grup dışındaki pencereleri `Super + Alt + Arrows` ile içine taşıyabilirsiniz.

### Pencereleri dışarı çıkarma

Bir pencereyi `Super + O` ile çalışma alanı tahsisinden dışarı çıkarabilirsiniz. Bu, gittiğiniz her çalışma alanında sizi takip eden yüzen bir pencere olarak onu sabitler. Video oynatıcılar ve benzerleri için harika.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad çalışma alanı

Üzerinde olduğunuz çalışma alanının üzerine binen özel, tam boyutlu bir scratchpad çalışma alanı vardır. Üzerindekilere `Super + S` kullanarak erişirsiniz ve pencereleri oraya `Super + Alt + S` kullanarak yerleştirirsiniz.

Mevcut çalışma alanından ayrılmadan hızlıca etkileşim kurmak istediğiniz kontroller veya bir terminal için iyi çalışır.

### Quake konsolu

Son olarak, üzerinde olduğunuz çalışma alanının üzerine açılan yarı yükseklikte bir Quake konsolu vardır. Onu `Super + the key above Tab` (ABD düzenlerinde grave) ile açıp kapatın ve `Super + Shift + the key above Tab` kullanarak oraya bir pencere yerleştirin.

İlk açıldığında, varsayılan agent'ınızı başlatır veya henüz bir tane seçmediyseniz bir tane seçmenizi ister. Konsol tek bir pencere barındırırken, ekranı kaplamak yerine ortalanmış bir panel olarak açılır. Üzerine ikinci bir uygulama koyun, tam genişliğe geri döner, böylece ikisinin yan yana oturacak yeri olur.

Bir pencereyi scratchpad'den veya konsoldan taşımak için, onu `Super + Shift + 1` gibi bir şeyle doğrudan başka bir çalışma alanına gönderin.

### Alışmak biraz zaman alıyor!

Masaüstünüzde bu şekilde gezinmeye alışmak biraz zaman alır, ama alıştığınızda geleneksel fareyle sürülen bir masaüstü deneyimine geri dönmek zor olacak!
