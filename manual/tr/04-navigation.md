# Gezinme

Omarchy'de her şey klavye ile olur — _HER ŞEY!_ Sistem ilk başladığında, fareyle tek başına kelimenin tam anlamıyla hiçbir şey yapamazsınız. Ama `Super + Space` tuşlarına basarak Omarchy Menu'yü açabilirsiniz ve buradan hemen hemen her şeyi yapabilirsiniz.

Ama Omarchy menüsü çoğu zaman sistemi kullanmanın ana yolu olmak için bile tasarlanmadı. Bundan daha hızlı olabiliriz! En önemli uygulamaların tümü doğrudan ayrı kısayol tuşlarına bağlanmıştır. Terminali `Super + Return` ile ve bir tarayıcıyı `Super + Shift + Return` ile başlatırsınız. Birbiri ardına deneyin, Hyprland'in döşeme sihrini iş başında göreceksiniz:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ardından yan yana yerine üst üste dizmek için `Super + J` tuşuna basabilirsiniz:

 ![navigation-stacked](images/navigation-stacked.webp)

Onları yan yana konumlarına döndürmek için tekrar `Super + J` tuşuna basın. Ardından pencereleri takas etmek için tarayıcıdayken `Super + Shift + Arrow Right` tuşlarını deneyin.

Şimdi Activity izleyicisini başlatmak için `Super + Shift + T` tuşlarını deneyin. Yüzen bir pencere olarak belirecektir. `Super + T` kullanarak onu döşeyebilirsiniz (ve tekrar yüzen yapmak için tekrar basın). Şimdi dosya yöneticisini açmak için `Super + Shift + F` tuşuna basın. Düzgün bir dörtlü düzeniniz olacak:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Etkin olmasını istediğiniz pencere arasında `Super + Arrow` ile gezinirsiniz. Bu, odağı değiştirir ve imleci yeni uygulamanın merkezine taşır. Bir ekranın kenarında, o taraftaki monitöre devam eder.

`Super + Shift + 2` tuşuna basarsanız, o anda odaklanmış uygulamayı ikinci çalışma alanına taşırsınız. `Super + Shift + 1` onu geri taşır. (Ve `Super + Shift + Alt + 2`, o anda odaklanmış uygulamayı ona geçiş yapmadan ikinci çalışma alanına taşır).

Birden fazla monitör varken, her monitörün kendine ait 1'den 10'a kadar çalışma alanları vardır. `Super + 2` bulunduğunuz monitörün ikinci çalışma alanına gider ve her monitörün üst çubuğu kendi çalışma alanlarını ve gösterdiği çalışma alanını gösterir. `Super + Tab` bulunduğunuz monitördeki çalışma alanları arasında geçiş yapar. `Super + Shift + Ctrl + Arrows` üzerinde olduğunuz pencereyi o yöndeki monitöre, onun gösterdiği çalışma alanına taşır ve `Super + Shift + Alt + Arrows` üzerinde olduğunuz çalışma alanını o yöndeki monitöre taşır, orada boşsa aynı numarayı alır. Bir monitör, fişini çektiğinizde çalışma alanlarını korur: başka bir ekranınkilerin arasına, onun zaten sahip olduklarından sonra numaralandırılarak katılırlar ve monitör geri geldiğinde eski numaralarına geri dönerler.

`Super` tuşunu basılı tutup fareyle bir pencereye tıklarsanız, onun oturduğu yeri yeniden düzenleyebilirsiniz. `Super` tuşunu basılı tutup farenin sağ düğmesini kullanırsanız, pencereyi serbestçe yeniden boyutlandırabilirsiniz.

Bir pencereyi `Super + W` veya `Super + Q` ile kapatırsınız (ve tüm pencereleri `Ctrl + Alt + Delete` ile kapatırsınız).

`Super + F` ile tam ekrana da geçebilir, hatta `Super + Alt + F` ile yalnızca tam genişliğe (üst çubuğu koruyarak) veya `Super + Ctrl + F` ile bir pencere içinde tam ekrana geçebilirsiniz (YouTube için iyi!).

### Dwindle ile kaydırma düzeni

Omarchy'nin varsayılan düzenine dwindle denir. Tek bir çalışma alanında açtığınız tüm pencereleri, onları küçültmek zorunda kalsa bile her zaman görünür tutar.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ama bir çalışma alanını, pencerelerin ekranın görünür kenarının ötesinde yan yana dizildiği kaydırma düzenine dönüştürmeyi de seçebilirsiniz. Tek bir çalışma alanını `Super + L` ile bu düzene dönüştürürsünüz.

`Super + L` tuşuna tekrar basmak çalışma alanını yüzen düzene dönüştürür; burada pencereler serbestçe üst üste biner ve onları kendiniz yerleştirirsiniz, üçüncü bir basış ise onu dwindle düzenine geri döndürür. `Super + Alt + L` bunlardan diğer yönde geçer. Zaten yüzen bir pencere — `Super + T` ile dışarı çıkardığınız veya her zaman yüzen olarak açılan bir uygulama — çalışma alanı döşemeye geri döndüğünde yüzen kalmaya devam eder. Üst çubuk üzerinde olduğunuz çalışma alanını düzeniyle işaretler: dwindle için bir kare, kaydırma için bir daire ve yüzen için bir üçgen. O işarete tıklamak da düzenler arasında geçiş yapar.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Seçim çalışma alanı başınadır ve kalıcıdır. Yani çalışma alanı 1'i gezinmek için dwindle düzeninde ve çalışma alanı 2'yi kod için kaydırma düzeninde tutabilirsiniz ve yeniden başlatmadan sonra da öyle geri gelirler.

Kaydırma düzenini varsayılan olarak kullanmak isterseniz, bunu `~/.config/hypr/looknfeel.lua` içinde ayarlayabilirsiniz:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Yüzen çalışma alanları

Yüzen bir çalışma alanı geleneksel bir masaüstü gibi çalışır: pencereler üst üste biner ve onları kendiniz taşıyıp boyutlandırırsınız. Her pencere temanızın renklerinde, simge durumuna küçültme, ekranı kaplama ve kapatma düğmeleri olan bir başlık çubuğu alır. `Super + M` de odaklanmış pencereyi simge durumuna küçültür. Simge durumuna küçültülmüş bir pencere dock'ta bekler; geri getirmek için uygulamasına tıklayın. Bir pencereyi öne getirmek için ona tıklayın. Onu herhangi bir kenardan veya köşeden yeniden boyutlandırın. Üst çubuğu görünürde tutarken pencereyi kaplayacak şekilde büyütmek için bir başlık çubuğuna çift tıklayın ve eski boyutunu geri almak için tekrar çift tıklayın. Chrome ve diğer Chromium tabanlı tarayıcılar, Disks ve Document Viewer başlık çubuğunu atlar ve bunun yerine kendi başlıklarını kullanır; `Super + Alt + F` onları kaplayacak şekilde büyütür ve `Super + M` onları simge durumuna küçültür.

Yüzen bir çalışma alanı ayrıca sabitlenmiş uygulamalarınız, çalışan her şey ve uygulamalar düğmesinin arkasındaki her uygulamanın ızgarası ile bir dock gösterir; bunu `Super + Alt + Space` ve Omarchy menüsündeki _Apps_ de açar. Bir uygulamayı kaldırmak için ızgaradaki bir uygulamaya sağ tıklayın veya `Delete` tuşuna basın. Bir uygulamayı açmak veya penceresini öne getirmek için ona tıklayın; pencereleri arasında geçiş yapmak için tekrar tıklayın. Orta tıklama yeni bir pencere açar. Taşımak için bir simgeyi dock boyunca sürükleyin; çalışan bir uygulamayı diğerlerinin arasına sürüklemek onu orada tutar. Bir uygulamayı dock'ta tutmak, çıkarmak veya ondan çıkmak için sağ tıklayın. Dock, tam ekran bir pencerenin yolundan çekilir. Dock'u başka bir kenara taşımak veya işaretçi kenarına ulaşana kadar gizlenmesini sağlamak için uygulamalar düğmesine sağ tıklayın. Konum ayrıca _Appearance > Dock > Dock Position_ altındadır ve `omarchy dock position left` ile `omarchy dock autohide on` her ikisini de bir terminalden ayarlar. Dock'ta tuttuğunuz uygulamalar çalışmıyorken soluk görünür.

Yeni çalışma alanları ve `Super + L` ile kendine ait bir düzen vermediğiniz tüm çalışma alanları varsayılan düzeni kullanır. Varsayılanı değiştirmek, penceresi olmayan her çalışma alanını ona sıfırlar; üzerinde pencereler olan ise sahip olduğu düzeni korur. Dock'a simge durumuna küçültülmüş bir pencere hâlâ ayrıldığı çalışma alanındaki bir pencere sayılır. Onu _Appearance > Workspace Layout_ altında seçin: Tiling, Scrolling veya Floating. `omarchy-hyprland-workspace-layout-default scrolling` bunu bir terminalden ayarlar.

### Pencereleri gruplama

Pencereler `Super + G` kullanılarak gruplandırılabilir. Bir gruba girdikten sonra, o etkin iken başlattığınız her pencere gruba ait olacaktır. Bu gruplandırılmış pencereler arasında `Super + Ctrl + Arrow Left/Right` kullanarak veya sıralı olarak gruplandırılmış pencerelere doğrudan gitmek için `Super + Alt + 1/2/3/4` kullanarak hareket edebilirsiniz.

Bir pencereyi `Super + Alt + G` ile gruplandırmanın dışına taşıyabilir veya tekrar `Super + G` tuşuna basarak tüm grubu dağıtabilirsiniz. Son olarak, grup dışındaki pencereleri `Super + Alt + Arrows` ile içine taşıyabilirsiniz.

### Pencereleri dışarı çıkarma

Bir pencereyi `Super + O` ile çalışma alanı tahsisinden dışarı çıkarabilirsiniz. Bu onu, gittiğiniz her çalışma alanında sizi takip eden yüzen bir pencere olarak sabitler. Video oynatıcılar ve benzerleri için harika.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Karalama defteri çalışma alanı

Şu anda üzerinde olduğunuz çalışma alanının üstüne binen özel, tam boyutlu bir karalama defteri çalışma alanı vardır. Üzerindekilere `Super + S` kullanarak erişirsiniz ve pencereleri oraya `Super + Alt + S` kullanarak yerleştirirsiniz.

Mevcut çalışma alanından ayrılmadan hızla etkileşim kurmak istediğiniz kontroller veya bir terminal için iyi çalışır.

### Quake konsolu

Son olarak, şu anda üzerinde olduğunuz çalışma alanının üzerine aşağı açılan, yarı yükseklikte bir Quake konsolu vardır. Onu `Super + Grave` ile açıp kapatın ve oraya `Super + Shift + Grave` kullanarak bir pencere yerleştirin.

Varsayılan agent'ınız kullanıma hazır olarak açılır. Konsol tek bir pencere tutarken, ekranı kaplamak yerine ortalanmış bir panel olarak aşağı açılır. Üzerine ikinci bir uygulama koyun, tam genişliğe geri döner, böylece ikisinin yan yana oturacak yeri olur.

Bir pencereyi karalama defterinden veya konsoldan taşımak için, onu `Super + Shift + 1` gibi bir şeyle doğrudan başka bir çalışma alanına gönderin.

### Alışmak biraz zaman alır!

Masaüstünüzde böyle gezinmeye alışmak biraz zaman alır, ama alıştıktan sonra geleneksel fareyle sürülen bir masaüstü deneyimine geri dönmek zor olacaktır!
