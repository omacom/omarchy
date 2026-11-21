# Gezinme

Omarchy'de her şey klavye ile olur — _HER ŞEY!_ Sistem ilk başladığında, yalnızca fareyle kelimenin tam anlamıyla hiçbir şey yapamazsınız. Ama `Super + Space` tuşlarına basarak Omarchy Menu'yü açabilirsiniz ve buradan hemen hemen her şeyi yapabilirsiniz.

Ama Omarchy menüsü, çoğu zaman sistemi işletmenin ana yolu olarak bile düşünülmemiştir. Bundan daha hızlı olabiliriz! En önemli uygulamaların tümü doğrudan tek tek kısayol tuşlarına bağlanmıştır. Terminali `Super + Return` ile, bir tarayıcıyı da `Super + Shift + Return` ile başlatırsınız. Birini diğerinin ardından deneyin; Hyprland'in döşeme büyüsünü iş başında göreceksiniz:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ardından, yan yana yerine üst üste yığmak için `Super + J` tuşlarına basabilirsiniz:

 ![navigation-stacked](images/navigation-stacked.webp)

Yan yana konumlarına geri döndürmek için tekrar `Super + J` tuşlarına basın. Ardından tarayıcıdayken pencereleri takas etmek için `Super + Shift + Arrow Right` tuşlarını deneyin.

Şimdi Activity izleyicisini başlatmak için `Super + Shift + T` tuşlarını deneyin. Bu, yüzen bir pencere olarak belirecektir. `Super + T` kullanarak onu döşeyebilirsiniz (ve tekrar yüzer hâle getirmek için aynı tuşlara tekrar basabilirsiniz). Şimdi dosya yöneticisini açmak için `Super + Shift + F` tuşlarına basın. Elinizde düzgün bir dörtlü kurulum olacak:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Etkin olmasını istediğiniz pencereye `Super + Arrow` ile gidersiniz. Bu, odağı değiştirir ve imleci yeni uygulamanın merkezine taşır. Bir ekranın kenarında, o taraftaki monitörde devam eder.

`Super + Shift + 2` tuşlarına basarsanız, o anda odaklanılmış uygulamayı ikinci çalışma alanına taşırsınız. `Super + Shift + 1` onu geri taşır. (`Super + Shift + Alt + 2` ise o anda odaklanılmış uygulamayı, ona geçmeden ikinci çalışma alanına taşır).

Birden fazla monitörle, her monitörün kendine ait 1'den 10'a kadar çalışma alanları vardır. `Super + 2`, üzerinde olduğunuz monitörün ikinci çalışma alanına gider ve her monitörün üst çubuğu kendi çalışma alanlarını ve gösterdiği çalışma alanını gösterir. `Super + Tab`, üzerinde olduğunuz monitördeki çalışma alanları arasında dolaşır. `Super + Shift + Ctrl + Arrows`, üzerinde olduğunuz pencereyi o yöndeki monitöre, onun gösterdiği çalışma alanına taşır ve `Super + Shift + Alt + Arrows`, üzerinde olduğunuz çalışma alanını o yöndeki monitörün üzerine taşır; orada, boşsa aynı numarayı alır. Bir monitör, fişini çektiğinizde çalışma alanlarını korur: bunlar başka bir ekranınkine katılır, onun zaten sahip olduklarının ardından numaralandırılır ve monitör geri geldiğinde eski numaralarının altına geri döner.

`Super` tuşunu basılı tutar ve fareyle bir pencereye tıklarsanız, onun oturduğu yeri yeniden düzenleyebilirsiniz. `Super` tuşunu basılı tutar ve farenin sağ düğmesini kullanırsanız, pencereyi serbestçe yeniden boyutlandırabilirsiniz.

Bir pencereyi `Super + W` veya `Super + Q` ile kapatırsınız (ve tüm pencereleri `Ctrl + Alt + Delete` ile kapatırsınız).

`Super + F` ile tam ekrana da geçebilirsiniz; hatta `Super + Alt + F` ile yalnızca tam genişliğe (üst çubuğu koruyarak) veya `Super + Ctrl + F` ile bir pencere içinde tam ekrana geçebilirsiniz (YouTube için iyidir!).

### Dwindle ve scrolling düzeni karşılaştırması

Omarchy'nin varsayılan düzenine dwindle denir. Tek bir çalışma alanında açtığınız tüm pencereleri, onları küçültmek zorunda kalsa bile her zaman görünür tutar.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ama bir çalışma alanını, pencerelerin yan yana, ekranın görünür kenarının ötesine sıralandığı scrolling düzenine dönüştürmeyi de seçebilirsiniz. Tek bir çalışma alanını `Super + L` ile bu düzene dönüştürürsünüz.

Tekrar `Super + L` tuşlarına basmak çalışma alanını yüzen hâle getirir; burada pencereler serbestçe çakışır ve onları kendiniz yerleştirirsiniz; üçüncü bir basış onu dwindle düzenine geri döndürür. `Super + Alt + L` bunların arasından diğer yönde gider. Zaten yüzen bir pencere — `Super + T` ile kopardığınız bir pencere veya her zaman yüzen olarak açılan bir uygulama — çalışma alanı döşemeye geri döndüğünde yüzer durumda kalır. Üst çubuk, üzerinde olduğunuz çalışma alanını düzeniyle işaretler: dwindle için bir kare, scrolling için bir daire ve yüzen için bir üçgen. O işarete tıklamak da düzeni dolaştırır; buna sahip dizüstü bilgisayarlardaki ekran tuşu da öyle yapar.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Bu seçim çalışma alanı başınadır ve kalıcıdır. Yani 1. çalışma alanını gezinmek için dwindle düzeninde, 2. çalışma alanını kod için scrolling düzeninde tutabilirsiniz; yeniden başlatmanın ardından da o şekilde geri gelirler.

Scrolling düzenini varsayılan olarak kullanmak isterseniz, bunu `~/.config/hypr/looknfeel.lua` içinde ayarlayabilirsiniz:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Yüzen çalışma alanları

Yüzen bir çalışma alanı geleneksel bir masaüstü gibi çalışır: pencereler çakışır ve onları kendiniz taşıyıp boyutlandırırsınız. Her pencere, temanızın renklerinde, simge durumuna küçültme, ekranı kaplama ve kapatma düğmeleri olan bir başlık çubuğu alır. `Super + M` de odaklanılmış pencereyi simge durumuna küçültür. Simge durumuna küçültülmüş bir pencere dock'ta bekler; geri getirmek için uygulamasına tıklayın. Bir pencereyi öne getirmek için ona tıklayın. Onu herhangi bir kenardan veya köşeden yeniden boyutlandırın. Üst çubuğu görünürde tutarken pencereyi ekranı kaplatmak için bir başlık çubuğuna çift tıklayın; eski boyutunu geri almak için tekrar çift tıklayın. Chrome ve diğer Chromium tabanlı tarayıcılar, Disks ve Document Viewer başlık çubuğunu atlar ve bunun yerine kendi üstbilgilerini kullanır; `Super + Alt + F` onları ekranı kaplatır ve `Super + M` onları simge durumuna küçültür.

Yüzen bir çalışma alanı ayrıca, sabitlenmiş uygulamalarınız, çalışan her şey ve uygulamalar düğmesinin arkasındaki her uygulamanın bir ızgarası ile bir dock gösterir; `Super + Alt + Space` ve Omarchy menüsündeki _Apps_ da bunu açar. Bir uygulamayı kaldırmak için ızgarada ona sağ tıklayın veya `Delete` tuşuna basın. Bir uygulamayı açmak veya penceresini öne getirmek için ona tıklayın; pencereleri arasında dolaşmak için tekrar tıklayın. Files yalnızca üzerinde olduğunuz çalışma alanından bir pencereyi geri getirir ve aksi hâlde yeni bir tane açar; Terminal ve Agent her zaman bir başkasını başlatır, ancak simge durumuna küçültülmüş bir pencere önce geri gelir. Orta tıklama yeni bir pencere açar. Bir simgeyi taşımak için dock boyunca sürükleyin; çalışan bir uygulamayı diğerlerinin arasına sürüklemek onu orada tutar. Bir uygulamayı dock'ta tutmak, çıkarmak veya ondan çıkmak için sağ tıklayın. Dock, tam ekran bir pencerenin yolundan çekilir. Dock'u başka bir kenara taşımak veya işaretçi kenarına ulaşana kadar gizlenmesini sağlamak için uygulamalar düğmesine sağ tıklayın. Konum ayrıca _Appearance > Dock > Dock Position_ altındadır ve `omarchy dock position left` ile `omarchy dock autohide on` her ikisini de bir terminalden ayarlar. Dock'ta tuttuğunuz uygulamalar, çalışmadıkları sırada soluk görünür.

Yeni çalışma alanları ve `Super + L` ile kendine ait bir düzen vermedikleriniz, varsayılan düzeni kullanır. Varsayılanı değiştirmek, penceresi olmayan her çalışma alanını ona sıfırlar; üzerinde pencereler olan bir çalışma alanı ise sahip olduğu düzeni korur. Dock'a simge durumuna küçültülmüş bir pencere, ayrıldığı çalışma alanında hâlâ bir pencere olarak sayılır. Bunu _Appearance > Workspace Layout_ altında seçin: Tiling, Scrolling veya Floating. `omarchy hyprland workspace layout default scrolling` bunu bir terminalden ayarlar.

### Pencereleri gruplama

Pencereler `Super + G` kullanılarak gruplandırılabilir. Bir grubun içindeyken, o etkin olduğu sırada başlattığınız her pencere gruba ait olacaktır. Bu gruplandırılmış pencereler arasında `Super + Ctrl + Arrow Left/Right` kullanarak veya doğrudan sırayla gruplandırılmış pencerelere gitmek için `Super + Alt + 1/2/3/4` kullanarak hareket edebilirsiniz.

Bir pencereyi `Super + Alt + G` ile gruplandırmanın dışına taşıyabilir veya tekrar `Super + G` tuşlarına basarak tüm grubu dağıtabilirsiniz. Son olarak, grup dışındaki pencereleri `Super + Alt + Arrows` ile grubun içine taşıyabilirsiniz.

### Pencereleri koparma

Bir pencereyi `Super + O` ile çalışma alanı tahsisinden koparabilirsiniz. Bu, onu hangi çalışma alanına giderseniz gidin sizi izleyen yüzen bir pencere olarak sabitler. Video oynatıcılar ve benzerleri için harikadır.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad çalışma alanı

O anda üzerinde olduğunuz çalışma alanının üstüne binen, özel, tam boyutlu bir scratchpad çalışma alanı vardır. Üzerindekilere `Super + S` kullanarak erişirsiniz ve pencereleri oraya `Super + Alt + S` kullanarak yerleştirirsiniz.

Mevcut çalışma alanından ayrılmadan hızlıca etkileşim kurmak istediğiniz denetimler veya bir terminal için iyi çalışır.

### Quake konsolu

Son olarak, o anda üzerinde olduğunuz çalışma alanının üzerine açılan, yarı yükseklikte bir Quake konsolu vardır. Onu `Super + Grave` ile açıp kapatırsınız ve oraya `Super + Shift + Grave` kullanarak bir pencere yerleştirirsiniz.

İlk açıldığında, varsayılan agent'ınızı başlatır veya henüz bir tane seçmediyseniz bir tane seçmenizi ister. Konsol tek bir pencere tutarken, ekranı kaplamak yerine ortalanmış bir panel olarak açılır. Üzerine ikinci bir uygulama koyarsanız tam genişliğe geri döner, böylece ikisinin yan yana oturacak yeri olur.

Bir pencereyi scratchpad'den veya konsoldan taşımak için, onu `Super + Shift + 1` gibi bir şeyle doğrudan başka bir çalışma alanına gönderin.

### Alışmak biraz zaman alır!

Masaüstünüzde bu şekilde gezinmeye alışmak biraz zaman alır, ama alıştığınızda geleneksel, fareyle yürütülen bir masaüstü deneyimine geri dönmek zor olacaktır!
