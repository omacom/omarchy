# Gezinti

Omarchy'de her şey klavyeyle yapılır — _HER ŞEY!_ Sistem ilk başladığında, kelimenin tam anlamıyla yalnızca fareyle hiçbir şey yapamazsınız. Ama `Super + Space` tuşlarına basarak Omarchy Menu'yü görüntüleyebilirsiniz ve buradan hemen hemen her şeyi yapabilirsiniz.

Ancak Omarchy menüsünün çoğu zaman sistemi çalıştırmanın ana yolu olması bile amaçlanmamıştır. Bundan daha hızlı olabiliriz! En önemli uygulamaların tümü doğrudan ayrı kısayol tuşlarına bağlıdır. Terminali `Super + Return` ile, bir tarayıcıyı ise `Super + Shift + Return` ile başlatırsınız. Birini diğerinin ardından deneyin; Hyprland'in döşeme büyüsünü çalışırken göreceksiniz:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ardından, yan yana yerine üst üste dizmek için `Super + J` tuşlarına basabilirsiniz:

 ![navigation-stacked](images/navigation-stacked.webp)

Yan yana konumlarına döndürmek için tekrar `Super + J` tuşlarına basın. Ardından tarayıcıdayken pencereleri takas etmek için `Super + Shift + Arrow Right` tuşlarını deneyin.

Şimdi Activity monitörünü başlatmak için `Super + Shift + T` tuşlarını deneyin. Bu, yüzen bir pencere olarak görünecektir. `Super + T` kullanarak onu döşeyebilirsiniz (ve tekrar yüzen hâle getirmek için aynı tuşlara tekrar basabilirsiniz). Şimdi dosya yöneticisini açmak için `Super + Shift + F` tuşlarına basın. Düzgün bir dörtlü düzeniniz olacak:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Aktif olmasını istediğiniz pencereye `Super + Arrow` ile geçersiniz. Bu, odağı değiştirir ve imleci yeni uygulamanın merkezine taşır. Bir ekranın kenarında, o taraftaki monitörde devam eder.

`Super + Shift + 2` tuşlarına basarsanız, o anda odaklanılmış uygulamayı ikinci çalışma alanına taşırsınız. `Super + Shift + 1` onu geri taşır. (Ve `Super + Shift + Alt + 2`, o anda odaklanılmış uygulamayı ona geçmeden ikinci çalışma alanına taşır).

Birden fazla monitörde, her monitörün kendine ait 1'den 10'a kadar çalışma alanları vardır. `Super + 2`, üzerinde olduğunuz monitörün ikinci çalışma alanına gider ve her monitörün üst çubuğu kendi çalışma alanlarını ve gösterdiği çalışma alanını gösterir. `Super + Tab`, üzerinde olduğunuz monitördeki çalışma alanları arasında geçiş yapar. `Super + Shift + Ctrl + Arrows`, üzerinde olduğunuz pencereyi o yöndeki monitöre, onun gösterdiği çalışma alanına taşır ve `Super + Shift + Alt + Arrows`, üzerinde olduğunuz çalışma alanını o yöndeki monitöre taşır; orada boşsa aynı numarayı alır. Bir monitör, bağlantısını kestiğinizde çalışma alanlarını korur: bunlar başka bir ekranınkine katılır, onun zaten sahip olduklarından sonra numaralandırılır ve monitör geri geldiğinde eski numaralarının altına geri döner.

`Super` tuşunu basılı tutar ve fareyle bir pencereye tıklarsanız, pencerenin oturduğu yeri yeniden düzenleyebilirsiniz. `Super` tuşunu basılı tutar ve farenin sağ düğmesini kullanırsanız, pencereyi serbestçe yeniden boyutlandırabilirsiniz.

Bir pencereyi `Super + W` veya `Super + Q` ile kapatırsınız (ve tüm pencereleri `Ctrl + Alt + Delete` ile kapatırsınız).

Ayrıca `Super + F` ile tam ekran yapabilir, hatta `Super + Alt + F` ile yalnızca tam genişlik (üst çubuğu koruyarak) veya `Super + Ctrl + F` ile bir pencere içinde tam ekran yapabilirsiniz (YouTube için iyidir!).

### Dwindle ve kaydırmalı düzen

Omarchy'nin varsayılan düzenine dwindle denir. Açtığınız tüm pencereleri, onları küçültmek zorunda kalsa bile, tek bir çalışma alanında her zaman görünür tutar.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ancak bir çalışma alanını, pencerelerin ekranın görünür kenarının ötesinde yan yana sıralandığı kaydırmalı düzene dönüştürmeyi de seçebilirsiniz. Tek bir çalışma alanını `Super + L` ile bu düzene dönüştürürsünüz.

`Super + L` tuşlarına tekrar basmak çalışma alanını yüzen hâle getirir; burada pencereler serbestçe çakışır ve onları kendiniz yerleştirirsiniz ve üçüncü bir basış onu dwindle düzenine döndürür. `Super + Alt + L` bunların arasından diğer yöne doğru gider. Zaten yüzen bir pencere — `Super + T` ile dışarı çıkardığınız bir pencere veya her zaman yüzen olarak açılan bir uygulama — çalışma alanı döşemeye geri döndüğünde yüzen kalır. Üst çubuk, üzerinde olduğunuz çalışma alanını düzeniyle işaretler: dwindle için bir kare, kaydırmalı için bir daire ve yüzen için bir üçgen. Bu işarete tıklamak da düzeni değiştirir.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Seçim çalışma alanı başına yapılır ve kalıcıdır. Böylece çalışma alanı 1'i gezinmek için dwindle düzeninde, çalışma alanı 2'yi kod için kaydırmalı düzende tutabilirsiniz ve yeniden başlatmadan sonra bu şekilde geri gelirler.

Kaydırmalı düzeni varsayılan olarak kullanmak isterseniz, bunu `~/.config/hypr/looknfeel.lua` içinde ayarlayabilirsiniz:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Yüzen çalışma alanları

Yüzen bir çalışma alanı geleneksel bir masaüstü gibi çalışır: pencereler çakışır ve onları kendiniz taşıyıp boyutlandırırsınız. Her pencere, temanızın renklerinde, simge durumuna küçültme, ekranı kaplama ve kapatma düğmeleri olan bir başlık çubuğu alır. `Super + M` de odaklanılmış pencereyi simge durumuna küçültür. Simge durumuna küçültülmüş bir pencere dock'ta bekler; geri getirmek için uygulamasına tıklayın. Bir pencereyi öne getirmek için ona tıklayın. Onu herhangi bir kenardan veya köşeden yeniden boyutlandırın. Üst çubuğu görünürde tutarken pencereyi ekranı kaplayacak hâle getirmek için bir başlık çubuğuna çift tıklayın ve eski boyutunu geri almak için tekrar çift tıklayın. Chrome ve diğer Chromium tabanlı tarayıcılar, Disks ve Document Viewer başlık çubuğunu atlar ve bunun yerine kendi başlıklarını kullanır; `Super + Alt + F` onları ekranı kaplayacak hâle getirir ve `Super + M` onları simge durumuna küçültür.

Yüzen bir çalışma alanı ayrıca, sabitlenmiş uygulamalarınız, çalışan her şey ve uygulamalar düğmesinin arkasındaki her uygulamanın bir ızgarası ile bir dock gösterir; bunu `Super + Alt + Space` ve Omarchy menüsündeki _Apps_ de açar. Kaldırmak için ızgaradaki bir uygulamaya sağ tıklayın veya `Delete` tuşuna basın. Açmak veya penceresini öne getirmek için bir uygulamaya tıklayın; pencereleri arasında geçiş yapmak için tekrar tıklayın. Files yalnızca üzerinde olduğunuz çalışma alanından bir pencereyi geri getirir ve aksi hâlde yeni bir pencere açar ve Terminal ile Agent her zaman başka bir tane başlatır, ancak simge durumuna küçültülmüş bir pencere önce geri gelir. Orta tıklama yeni bir pencere açar. Onu taşımak için bir simgeyi dock boyunca sürükleyin; çalışan bir uygulamayı diğerlerinin arasına sürüklemek onu orada tutar. Bir uygulamayı dock'ta tutmak, çıkarmak veya ondan çıkmak için sağ tıklayın. Dock, tam ekran bir pencerenin önünden çekilir. Dock'u başka bir kenara taşımak veya işaretçi kenarına ulaşana kadar gizlenmesini sağlamak için uygulamalar düğmesine sağ tıklayın. Konum ayrıca _Appearance > Dock > Dock Position_ altındadır ve `omarchy dock position left` ile `omarchy dock autohide on` ikisini de bir terminalden ayarlar. Dock'ta tuttuğunuz uygulamalar, çalışmadıkları sırada soluktur.

Yeni çalışma alanları ve `Super + L` ile kendi düzenini vermedikleriniz, varsayılan düzeni kullanır. Varsayılanı değiştirmek, penceresi olmayan her çalışma alanını ona sıfırlar; üzerinde pencereler olan bir çalışma alanı ise sahip olduğu düzeni korur. Dock'a simge durumuna küçültülmüş bir pencere, ayrıldığı çalışma alanındaki bir pencere olarak sayılmaya devam eder. Onu _Appearance > Workspace Layout_ altında seçin: Tiling, Scrolling veya Floating. `omarchy-hyprland-workspace-layout-default scrolling` onu bir terminalden ayarlar.

### Pencereleri gruplama

Pencereler `Super + G` kullanılarak gruplandırılabilir. Bir grubun içine girdiğinizde, bu aktifken başlattığınız her pencere gruba ait olacaktır. Bu gruplandırılmış pencereler arasında `Super + Ctrl + Arrow Left/Right` kullanarak veya doğrudan sırayla gruplandırılmış pencerelere gitmek için `Super + Alt + 1/2/3/4` kullanarak geçiş yapabilirsiniz.

Bir pencereyi `Super + Alt + G` ile gruplandırmadan çıkarabilir veya tekrar `Super + G` tuşlarına basarak tüm grubu dağıtabilirsiniz. Son olarak, grup dışındaki pencereleri `Super + Alt + Arrows` ile grubun içine taşıyabilirsiniz.

### Pencereleri dışarı çıkarma

Bir pencereyi `Super + O` ile çalışma alanı tahsisinden dışarı çıkarabilirsiniz. Bu, onu gittiğiniz her çalışma alanında sizi takip eden yüzen bir pencere olarak sabitler. Video oynatıcılar ve benzerleri için harikadır.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad çalışma alanı

O anda üzerinde olduğunuz çalışma alanının üstüne binen özel, tam boyutlu bir scratchpad çalışma alanı vardır. Üzerindekilere `Super + S` kullanarak erişirsiniz ve pencereleri oraya `Super + Alt + S` kullanarak yerleştirirsiniz.

Mevcut çalışma alanından ayrılmadan hızlıca etkileşim kurmak istediğiniz kontroller veya bir terminal için iyi çalışır.

### Quake konsolu

Son olarak, o anda üzerinde olduğunuz çalışma alanının üzerinde aşağı açılan yarım yükseklikte bir Quake konsolu vardır. Onu `Super + Grave` ile açıp kapatın ve oraya `Super + Shift + Grave` kullanarak bir pencere yerleştirin.

Varsayılan agent'ınız hazır hâlde açılır. Konsol tek bir pencere tutarken, ekranı kaplamak yerine ortalanmış bir panel olarak aşağı açılır. Üzerine ikinci bir uygulama koyun; ikisinin yan yana oturması için yer olması amacıyla tam genişliğe geri döner.

Bir pencereyi scratchpad'den veya konsoldan çıkarmak için, onu `Super + Shift + 1` gibi bir şeyle doğrudan başka bir çalışma alanına gönderin.

### Alışmak biraz zaman alır!

Masaüstünüzde bu şekilde gezinmeye alışmak biraz zaman alır, ancak alıştığınızda geleneksel fareyle yönetilen bir masaüstü deneyimine geri dönmek zor olacaktır!
