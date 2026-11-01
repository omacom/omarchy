# Gezinme

Omarchy'de her şey klavye ile olur — _HER ŞEY!_ Sistem ilk başladığında, yalnızca fareyle kelimenin tam anlamıyla hiçbir şey yapamazsınız. Ama `Super + Space` tuşuna basarak Omarchy Menu'yü ortaya çıkarabilirsiniz ve buradan neredeyse her şeyi yapabilirsiniz.

Ama Omarchy menüsü, çoğu zaman sistemi çalıştırmanın ana yolu olarak bile tasarlanmamıştır. Bundan daha hızlı olabiliriz! En önemli uygulamaların tümü doğrudan ayrı kısayol tuşlarına bağlanmıştır. Terminali `Super + Return` ile ve bir tarayıcıyı `Super + Shift + Return` ile başlatırsınız. Birbiri ardına deneyin, Hyprland'in döşeme sihrini çalışırken göreceksiniz:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ardından bunları yan yana yerine üst üste dizmek için `Super + J` tuşuna basabilirsiniz:

 ![navigation-stacked](images/navigation-stacked.webp)

Onları yan yana konumlarına döndürmek için tekrar `Super + J` tuşuna basın. Ardından tarayıcıdayken pencereleri takas etmek için `Super + Shift + Arrow Right` tuşunu deneyin.

Şimdi Activity monitor'ü başlatmak için `Super + Shift + T` tuşunu deneyin. Bu, yüzen bir pencere olarak görünecektir. Onu `Super + T` kullanarak döşeyebilirsiniz (ve tekrar yüzen yapmak için buna tekrar basın). Şimdi dosya yöneticisini açmak için `Super + Shift + F` tuşuna basın. Düzgün bir dörtlü kurulumunuz olacaktır:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Etkin olmasını istediğiniz pencere arasında `Super + Arrow` ile gezinirsiniz. Bu, odağı değiştirir ve imleci yeni uygulamanın merkezine taşır. Bir ekranın kenarında, o taraftaki monitöre devam eder.

`Super + Shift + 2` tuşuna basarsanız, o anda odaklanan uygulamayı ikinci çalışma alanına taşırsınız. `Super + Shift + 1` onu geri taşır. (Ve `Super + Shift + Alt + 2`, o anda odaklanan uygulamayı ona geçiş yapmadan ikinci çalışma alanına taşır).

Birden fazla monitörle, her monitörün kendine ait 1'den 10'a kadar çalışma alanları vardır. `Super + 2`, bulunduğunuz monitörün ikinci çalışma alanına gider ve her monitörün üst çubuğu kendi çalışma alanlarını ve gösterdiği çalışma alanını gösterir. `Super + Tab`, bulunduğunuz monitördeki çalışma alanları arasında geçiş yapar. `Super + Shift + Ctrl + Arrows`, üzerinde olduğunuz pencereyi o yöndeki monitöre, onun gösterdiği çalışma alanına taşır ve `Super + Shift + Alt + Arrows`, üzerinde olduğunuz çalışma alanını o yöndeki monitöre taşır; orada boşsa aynı numarayı alır. Bir monitör, fişini çektiğinizde çalışma alanlarını korur: bunlar başka bir ekranınkine katılır, onun zaten sahip olduklarının ardından numaralandırılır ve monitör geri döndüğünde eski numaralarına geri dönerler.

`Super` tuşunu basılı tutar ve fareyle bir pencereye tıklarsanız, onun oturduğu yeri yeniden düzenleyebilirsiniz. `Super` tuşunu basılı tutar ve farede sağ düğmeyi kullanırsanız, pencereyi serbestçe yeniden boyutlandırabilirsiniz.

Bir pencereyi `Super + W` veya `Super + Q` ile kapatırsınız (ve tüm pencereleri `Ctrl + Alt + Delete` ile kapatırsınız).

Ayrıca `Super + F` ile tam ekrana geçebilir veya hatta `Super + Alt + F` ile yalnızca tam genişliğe (üst çubuğu koruyarak) ya da `Super + Ctrl + F` ile bir pencere içinde tam ekrana geçebilirsiniz (YouTube için iyidir!).

### Dwindle ile kaydırmalı düzen karşılaştırması

Omarchy'nin varsayılan düzenine dwindle denir. Açtığınız tüm pencereleri tek bir çalışma alanında her zaman görünür tutar, bunun için onları küçültmesi gerekse bile.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ama bir çalışma alanını, pencerelerin ekranın görünür kenarının ötesinde yan yana sıralandığı kaydırmalı düzene dönüştürmeyi de seçebilirsiniz. Tek bir çalışma alanını `Super + L` ile bu düzene dönüştürürsünüz.

`Super + L` tuşuna tekrar basmak çalışma alanını, pencerelerin serbestçe üst üste bindiği ve onları kendiniz yerleştirdiğiniz yüzen düzene dönüştürür ve üçüncü bir basış onu dwindle'a döndürür. `Super + Alt + L` bunlardan ters yönde geçer. Zaten yüzen bir pencere — `Super + T` ile çıkardığınız bir pencere veya her zaman yüzen olarak açılan bir uygulama — çalışma alanı döşemeye geri döndüğünde yüzen kalır. Üst çubuk, üzerinde olduğunuz çalışma alanını düzeniyle işaretler: dwindle için bir kare, kaydırmalı için bir daire ve yüzen için bir üçgen. O işarete tıklamak da düzeni döngüsel olarak değiştirir.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Seçim çalışma alanı başınadır ve kalıcıdır. Böylece 1. çalışma alanını gezinmek için dwindle'da ve 2. çalışma alanını kod için kaydırmalıda tutabilirsiniz ve yeniden başlatmanın ardından bu şekilde geri gelirler.

Kaydırmalı düzeni varsayılan olarak kullanmak isterseniz, bunu `~/.config/hypr/looknfeel.lua` içinde ayarlayabilirsiniz:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Yüzen çalışma alanları

Yüzen bir çalışma alanı geleneksel bir masaüstü gibi çalışır: pencereler üst üste biner ve onları kendiniz taşıyıp boyutlandırırsınız. Her pencere, temanızın renklerinde, simge durumuna küçültme, ekranı kaplama ve kapatma düğmeleri olan bir başlık çubuğu alır. `Super + M` de odaklanan pencereyi simge durumuna küçültür. Simge durumuna küçültülmüş bir pencere dock'ta bekler; geri getirmek için uygulamasına tıklayın. Bir pencereyi öne getirmek için tıklayın. Onu herhangi bir kenardan veya köşeden yeniden boyutlandırın. Üst çubuğu görünür tutarken pencereyi ekranı kaplatmak için bir başlık çubuğuna çift tıklayın ve eski boyutunu geri almak için tekrar çift tıklayın.

Yüzen bir çalışma alanı ayrıca, sabitlenmiş uygulamalarınız, çalışan her şey ve uygulamalar düğmesinin arkasındaki her uygulamanın bir ızgarası ile bir dock gösterir; bunu `Super + Alt + Space` ve Omarchy menüsündeki _Apps_ de açar. Onu kaldırmak için ızgaradaki bir uygulamaya sağ tıklayın veya `Delete` tuşuna basın. Açmak veya penceresini öne getirmek için bir uygulamaya tıklayın; pencereleri arasında geçiş yapmak için tekrar tıklayın. Orta tıklama yeni bir pencere açar. Taşımak için bir simgeyi dock boyunca sürükleyin; çalışan bir uygulamayı diğerlerinin arasına sürüklemek onu orada tutar. Bir uygulamayı dock'ta tutmak, onu çıkarmak veya ondan çıkmak için sağ tıklayın. Dock, tam ekran bir pencerenin yolundan çekilir. Dock'u başka bir kenara taşımak veya işaretçi onun kenarına ulaşana kadar gizlenmesini sağlamak için uygulamalar düğmesine sağ tıklayın. Konum ayrıca _Appearance > Dock > Dock Position_ altındadır ve `omarchy dock position left` ile `omarchy dock autohide on` her ikisini de bir terminalden ayarlar. Dock'ta tuttuğunuz uygulamalar çalışmadıkları sırada soluk görünür.

Yeni çalışma alanları ve `Super + L` ile kendine ait bir düzen vermedikleriniz varsayılan düzeni kullanır. Varsayılanı değiştirmek, penceresi olmayan her çalışma alanını ona sıfırlar; penceresi olan ise sahip olduğu düzeni korur. Dock'a simge durumuna küçültülmüş bir pencere, ayrıldığı çalışma alanında hâlâ bir pencere olarak sayılır. Bunu _Appearance > Workspace Layout_ altında seçin: Tiling, Scrolling veya Floating. `omarchy-hyprland-workspace-layout-default scrolling` bunu bir terminalden ayarlar.

### Pencereleri gruplama

Pencereler `Super + G` kullanılarak gruplandırılabilir. Bir gruba girdikten sonra, o etkin iken başlattığınız her pencere gruba ait olacaktır. Bu gruplandırılmış pencereler arasında `Super + Ctrl + Arrow Left/Right` kullanarak veya sırayla gruplandırılmış pencerelere doğrudan gitmek için `Super + Alt + 1/2/3/4` kullanarak hareket edebilirsiniz.

Bir pencereyi `Super + Alt + G` ile gruplandırmanın dışına taşıyabilir veya `Super + G` tuşuna tekrar basarak tüm grubun tamamını dağıtabilirsiniz. Son olarak, grubun dışındaki pencereleri `Super + Alt + Arrows` ile içine taşıyabilirsiniz.

### Pencereleri çıkarma

Bir pencereyi `Super + O` ile çalışma alanı tahsisinin dışına çıkarabilirsiniz. Bu, onu gittiğiniz her çalışma alanında sizi takip eden yüzen bir pencere olarak sabitler. Video oynatıcılar ve benzerleri için harikadır.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad çalışma alanı

Şu anda üzerinde olduğunuz çalışma alanının üzerinde katman olarak görünen özel, tam boyutlu bir scratchpad çalışma alanı vardır. Üzerindekilere `Super + S` kullanarak erişirsiniz ve oraya `Super + Alt + S` kullanarak pencereler yerleştirirsiniz.

Geçerli çalışma alanından ayrılmadan hızlıca etkileşim kurmak istediğiniz kontroller veya bir terminal için iyi çalışır.

### Quake konsolu

Son olarak, şu anda üzerinde olduğunuz çalışma alanının üzerine açılan yarım yükseklikte bir Quake konsolu vardır. Onu `Super + Grave` ile açıp kapatın ve `Super + Shift + Grave` kullanarak oraya bir pencere yerleştirin.

Varsayılan agent'ınız hazır olarak açılır. Konsol tek bir pencere tutarken, ekranı kaplamak yerine ortalanmış bir panel olarak açılır. Üzerine ikinci bir uygulama koyun, tam genişliğe geri döner, böylece ikisinin yan yana oturacak yeri olur.

Bir pencereyi scratchpad'den veya konsoldan taşımak için, onu `Super + Shift + 1` gibi bir şeyle doğrudan başka bir çalışma alanına gönderin.

### Alışmak biraz zaman alıyor!

Masaüstünüzde bu şekilde gezinmeye alışmak biraz zaman alır, ama alıştıktan sonra geleneksel, fareyle sürülen bir masaüstü deneyimine geri dönmek zor olacaktır!
