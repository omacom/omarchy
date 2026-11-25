# Gezinme

Omarchy'de her şey klavyeyle gerçekleşir — _HER ŞEY!_ Sistem ilk başladığında, yalnızca fareyle kelimenin tam anlamıyla hiçbir şey yapamazsınız. Ama `Super + Space` tuşlarına basarak Omarchy Menüsünü açabilirsiniz ve buradan hemen hemen her şeyi yapabilirsiniz.

Ancak Omarchy menüsünün, çoğu zaman sistemi çalıştırmanın ana yolu olması bile amaçlanmamıştır. Bundan daha hızlı olabiliriz! En önemli uygulamaların tümü doğrudan ayrı kısayol tuşlarına bağlıdır. Terminali `Super + Return` ile, bir tarayıcıyı `Super + Shift + Return` ile başlatırsınız. Birbiri ardına deneyin, Hyprland'in döşeme sihrini iş başında göreceksiniz:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ardından `Super + J` tuşuna basarak bunları yan yana yerine üst üste istifleyebilirsiniz:

 ![navigation-stacked](images/navigation-stacked.webp)

`Super + J` tuşuna tekrar basarak yan yana konumlarına döndürün. Ardından, pencereleri değiştirmek için tarayıcıdayken `Super + Shift + Arrow Right` tuşlarına basmayı deneyin.

Şimdi Activity izleyicisini başlatmak için `Super + Shift + T` tuşlarını deneyin. Bu, yüzen bir pencere olarak görünecektir. `Super + T` kullanarak döşeyebilirsiniz (ve tekrar yüzen hale getirmek için aynı tuşa tekrar basın). Şimdi dosya yöneticisini açmak için `Super + Shift + F` tuşlarına basın. Düzenli bir dörtlü kurulumunuz olacak:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Etkin olmasını istediğiniz pencere arasında `Super + Arrow` ile gezinebilirsiniz. Bu, odağı değiştirir ve imleci yeni uygulamanın merkezine taşır. Bir ekranın kenarında, o taraftaki monitörde devam eder.

`Super + Shift + 2` tuşuna basarsanız, o anda odaklanılan uygulamayı ikinci çalışma alanına taşırsınız. `Super + Shift + 1` onu geri taşır. (Ve `Super + Shift + Alt + 2`, o anda odaklanılan uygulamayı ona geçmeden ikinci çalışma alanına taşır).

Birden fazla monitörde, her monitörün kendine ait 1'den 10'a kadar çalışma alanları vardır. `Super + 2`, üzerinde bulunduğunuz monitörün ikinci çalışma alanına gider ve her monitörün üst çubuğu kendi çalışma alanlarını ve gösterdiği çalışma alanını gösterir. `Super + Tab`, üzerinde bulunduğunuz monitördeki çalışma alanları arasında geçiş yapar. `Super + Shift + Ctrl + Arrows`, üzerinde bulunduğunuz pencereyi o yöndeki monitöre, onun gösterdiği çalışma alanına taşır ve `Super + Shift + Alt + Arrows`, üzerinde bulunduğunuz çalışma alanını o yöndeki monitöre taşır; orada boşsa aynı numarayı alır. Bir monitör, bağlantısını kestiğinizde çalışma alanlarını korur: bunlar başka bir ekranın çalışma alanlarına katılır, onun zaten sahip olduklarından sonra numaralandırılır ve monitör geri döndüğünde eski numaralarının altına geri döner.

`Super` tuşunu basılı tutar ve fareyle bir pencereye tıklarsanız, pencerenin oturduğu yeri yeniden düzenleyebilirsiniz. `Super` tuşunu basılı tutar ve farenin sağ düğmesini kullanırsanız, pencereyi serbestçe yeniden boyutlandırabilirsiniz.

Bir pencereyi `Super + W` veya `Super + Q` ile kapatırsınız (ve tüm pencereleri `Ctrl + Alt + Delete` ile kapatırsınız).

Ayrıca `Super + F` ile tam ekran yapabilir, hatta `Super + Alt + F` ile yalnızca tam genişlik (üst çubuğu koruyarak) veya `Super + Ctrl + F` ile pencere içinde tam ekran yapabilirsiniz (YouTube için harika!).

### Dwindle ve scrolling düzeni

Omarchy'nin varsayılan düzenine dwindle denir. Tek bir çalışma alanında açtığınız tüm pencereleri, onları küçültmek zorunda kalsa bile her zaman görünür tutar.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ama bir çalışma alanını, pencerelerin yan yana dizildiği ve ekranın görünür kenarının ötesine uzandığı scrolling düzenine dönüştürmeyi de seçebilirsiniz. Tek bir çalışma alanını `Super + L` ile bu düzene dönüştürürsünüz.

`Super + L` tuşuna tekrar basmak çalışma alanını, pencerelerin serbestçe üst üste bindiği ve onları kendiniz yerleştirdiğiniz yüzen düzene dönüştürür, üçüncü bir basış ise dwindle'a geri döndürür. `Super + Alt + L` bunlardan ters yönde geçer. Zaten yüzen bir pencere — `Super + T` ile dışarı çıkardığınız bir pencere veya her zaman yüzen açılan bir uygulama — çalışma alanı döşemeye geri döndüğünde yüzen kalır. Üst çubuk, üzerinde bulunduğunuz çalışma alanını düzeniyle işaretler: dwindle için bir kare, scrolling için bir daire ve yüzen için bir üçgen. O işarete tıklamak da düzeni değiştirir, buna sahip dizüstü bilgisayarlardaki ekran tuşu da öyle yapar.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Seçim çalışma alanı başına yapılır ve kalıcıdır. Yani 1. çalışma alanını gezinmek için dwindle'da, 2. çalışma alanını kod için scrolling'de tutabilirsiniz ve yeniden başlatmanın ardından bu şekilde geri gelirler.

Scrolling düzenini varsayılan olarak kullanmak isterseniz, bunu `~/.config/hypr/looknfeel.lua` içinde ayarlayabilirsiniz:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Yüzen çalışma alanları

Yüzen bir çalışma alanı geleneksel bir masaüstü gibi çalışır: pencereler üst üste biner ve onları kendiniz taşır ve boyutlandırırsınız. Her pencere, temanızın renklerinde, simge durumuna küçültmek, ekranı kaplamak ve kapatmak için düğmeleri olan bir başlık çubuğu alır. `Super + M` de odaklanılan pencereyi simge durumuna küçültür. Simge durumuna küçültülmüş bir pencere dock'ta bekler; geri getirmek için uygulamasına tıklayın. Bir pencereyi öne getirmek için üzerine tıklayın. Onu herhangi bir kenardan veya köşeden yeniden boyutlandırın. Üst çubuğu görünürde tutarken pencereyi büyütmek için bir başlık çubuğuna çift tıklayın, eski boyutunu geri almak için tekrar çift tıklayın. Chrome ve diğer Chromium tabanlı tarayıcılar, Disks ve Document Viewer başlık çubuğunu atlar ve bunun yerine kendi üstbilgilerini kullanır; `Super + Alt + F` onları büyütür ve `Super + M` onları simge durumuna küçültür.

Yüzen bir çalışma alanı ayrıca, sabitlediğiniz uygulamalar, çalışan her şey ve uygulamalar düğmesinin arkasındaki her uygulamanın ızgarası ile birlikte bir dock gösterir; bunu `Super + Alt + Space` ve Omarchy menüsündeki _Apps_ de açar. Kaldırmak için ızgaradaki bir uygulamaya sağ tıklayın veya `Delete` tuşuna basın. Bir uygulamayı açmak veya penceresini öne getirmek için tıklayın; pencereleri arasında geçiş yapmak için tekrar tıklayın. Files yalnızca üzerinde bulunduğunuz çalışma alanından bir pencereyi geri getirir ve aksi halde yeni bir tane açar, Terminal ve Agent ise her zaman başka bir tane başlatır, ancak simge durumuna küçültülmüş bir pencere önce geri gelir. Orta tıklama yeni bir pencere açar. Taşımak için bir simgeyi dock boyunca sürükleyin; çalışan bir uygulamayı diğerlerinin arasına sürüklemek onu orada tutar. Bir uygulamayı dock'ta tutmak, çıkarmak veya uygulamadan çıkmak için sağ tıklayın. Dock, tam ekran bir pencerenin yolundan çekilir. Dock'u başka bir kenara taşımak veya işaretçi kenarına ulaşana kadar gizlenmesini sağlamak için uygulamalar düğmesine sağ tıklayın. Konum ayrıca _Appearance > Dock > Dock Position_ altında da bulunur ve `omarchy dock position left` ile `omarchy dock autohide on` her ikisini de bir terminalden ayarlar. Dock'ta tuttuğunuz uygulamalar çalışmadıkları sırada soluk görünür.

Yeni çalışma alanları ve `Super + L` ile kendine ait bir düzen vermedikleriniz varsayılan düzeni kullanır. Varsayılanı değiştirmek, penceresi olmayan her çalışma alanını ona sıfırlar; penceresi olan bir çalışma alanı ise sahip olduğu düzeni korur. Dock'a simge durumuna küçültülmüş bir pencere de ayrıldığı çalışma alanında hâlâ bir pencere olarak sayılır. Bunu _Appearance > Workspace Layout_ altında seçin: Tiling, Scrolling veya Floating. `omarchy hyprland workspace layout default scrolling` bunu bir terminalden ayarlar.

### Pencereleri gruplama

Pencereler `Super + G` kullanılarak gruplanabilir. Bir gruba girdikten sonra, o etkin iken başlattığınız her pencere gruba ait olacaktır. Bu gruplanmış pencereler arasında `Super + Ctrl + Arrow Left/Right` kullanarak veya doğrudan sıralı olarak gruplanmış pencerelere gitmek için `Super + Alt + 1/2/3/4` kullanarak geçiş yapabilirsiniz.

Bir pencereyi `Super + Alt + G` ile grubun dışına taşıyabilir veya `Super + G` tuşuna tekrar basarak tüm grubu dağıtabilirsiniz. Son olarak, grup dışındaki pencereleri `Super + Alt + Arrows` ile grubun içine taşıyabilirsiniz.

### Pencereleri dışarı çıkarma

Bir pencereyi `Super + O` ile çalışma alanı tahsisinin dışına çıkarabilirsiniz. Bu, onu gittiğiniz her çalışma alanında sizi takip eden yüzen bir pencere olarak sabitler. Video oynatıcılar ve benzerleri için harika.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad çalışma alanı

Üzerinde bulunduğunuz çalışma alanının üstüne binen özel, tam boyutlu bir scratchpad çalışma alanı vardır. Üzerindekilere `Super + S` kullanarak erişirsiniz ve pencereleri oraya `Super + Alt + S` kullanarak yerleştirirsiniz.

Geçerli çalışma alanından ayrılmadan hızlıca etkileşim kurmak istediğiniz kontroller veya bir terminal için iyi çalışır.

### Quake konsolu

Son olarak, üzerinde bulunduğunuz çalışma alanının üzerine aşağı kayan yarı yükseklikte bir Quake konsolu vardır. Bunu `Super + the key above Tab` (ABD düzenlerinde grave) ile açıp kapatırsınız ve oraya `Super + Shift + the key above Tab` kullanarak bir pencere yerleştirirsiniz.

İlk açıldığında, varsayılan agent'ınızı başlatır veya henüz bir tane seçmediyseniz bir tane seçmenizi ister. Konsol tek bir pencere barındırırken, ekranı kaplamak yerine ortalanmış bir panel olarak aşağı kayar. Üzerine ikinci bir uygulama koyun, tam genişliğe geri döner, böylece ikisinin yan yana oturacak yeri olur.

Bir pencereyi scratchpad'den veya konsoldan taşımak için, onu `Super + Shift + 1` gibi bir şeyle doğrudan başka bir çalışma alanına gönderin.

### Alışmak biraz zaman alıyor!

Masaüstünüzde bu şekilde gezinmeye alışmak biraz zaman alır, ama alıştığınızda geleneksel fare odaklı bir masaüstü deneyimine geri dönmek zor olacaktır!
