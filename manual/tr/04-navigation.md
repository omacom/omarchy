# Gezinme

Omarchy'de her şey klavye ile olur — _HER ŞEY!_ Sistem ilk başladığında, yalnızca fareyle kelimenin tam anlamıyla hiçbir şey yapamazsınız. Ama `Super + Space` tuşuna basarak Omarchy Menüsünü açabilirsiniz ve buradan hemen hemen her şeyi yapabilirsiniz.

Ama Omarchy menüsünün çoğu zaman sistemi kullanmanın ana yolu olması bile amaçlanmamıştır. Bundan daha hızlı olabiliriz! En önemli uygulamaların tümü doğrudan tek tek kısayol tuşlarına bağlanmıştır. Terminali `Super + Return` ile ve bir tarayıcıyı `Super + Shift + Return` ile başlatırsınız. Birini diğerinin hemen ardından deneyin; Hyprland'in döşeme sihrini iş başında göreceksiniz:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Ardından, yan yana yerine üst üste dizmek için `Super + J` tuşuna basabilirsiniz:

 ![navigation-stacked](images/navigation-stacked.webp)

Onları yan yana konumlarına geri döndürmek için `Super + J` tuşuna tekrar basın. Sonra tarayıcıdayken pencereleri yer değiştirmek için `Super + Shift + Arrow Right` tuşunu deneyin.

Şimdi Activity monitörünü başlatmak için `Super + Shift + T` tuşunu deneyin. Bu, yüzen bir pencere olarak görünecektir. Onu `Super + T` kullanarak döşeyebilirsiniz (ve tekrar yüzen hâle getirmek için aynı tuşa tekrar basabilirsiniz). Şimdi dosya yöneticisini açmak için `Super + Shift + F` tuşuna basın. Düzenli bir dörtlü kurulumunuz olacak:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Aktif olmasını istediğiniz pencere arasında `Super + Arrow` ile gezinirsiniz. Bu, odağı değiştirir ve imleci yeni uygulamanın ortasına taşır. Bir ekranın kenarında, o taraftaki monitörde devam eder.

`Super + Shift + 2` tuşuna basarsanız, o anda odaklanılan uygulamayı ikinci çalışma alanına taşırsınız. `Super + Shift + 1` onu geri taşır. (Ve `Super + Shift + Alt + 2`, o anda odaklanılan uygulamayı ona geçiş yapmadan ikinci çalışma alanına taşır).

Birden fazla monitörle, her monitörün kendine ait 1'den 10'a kadar çalışma alanları vardır. `Super + 2`, üzerinde olduğunuz monitörün ikinci çalışma alanına gider ve her monitörün üst çubuğu kendi çalışma alanlarını ve gösterdiğini gösterir. `Super + Tab`, üzerinde olduğunuz monitördeki çalışma alanları arasında geçiş yapar. `Super + Shift + Ctrl + Arrows`, üzerinde olduğunuz pencereyi o yöndeki monitöre, onun gösterdiği çalışma alanına taşır ve `Super + Shift + Alt + Arrows`, üzerinde olduğunuz çalışma alanını o yöndeki monitöre taşır; orada, boşsa aynı numarayı alır. Bir monitör, fişini çektiğinizde çalışma alanlarını korur: bunlar başka bir ekranınkiler arasına, onun zaten sahip olduklarından sonra numaralandırılarak katılır ve monitör geri döndüğünde eski numaralarının altına geri gider.

`Super` tuşunu basılı tutup fareyle bir pencereye tıklarsanız, onun nerede durduğunu yeniden düzenleyebilirsiniz. `Super` tuşunu basılı tutup farenin sağ düğmesini kullanırsanız, pencereyi serbestçe yeniden boyutlandırabilirsiniz.

Bir pencereyi `Super + W` veya `Super + Q` ile kapatırsınız (ve tüm pencereleri `Ctrl + Alt + Delete` ile kapatırsınız).

Ayrıca `Super + F` ile tam ekrana geçebilir, hatta `Super + Alt + F` ile yalnızca tam genişliğe (üst çubuğu koruyarak) veya `Super + Ctrl + F` ile bir pencere içinde tam ekrana geçebilirsiniz (YouTube için harika!).

### Dwindle ve kaydırma düzeni

Omarchy'nin varsayılan düzenine dwindle denir. Açtığınız tüm pencereleri, onları küçültmek zorunda kalsa bile, tek bir çalışma alanında her zaman görünür tutar.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ama bir çalışma alanını, pencerelerin yan yana, ekranın görünür kenarının ötesine dizildiği kaydırma düzenine dönüştürmeyi de seçebilirsiniz. Tek bir çalışma alanını `Super + L` ile bu düzene dönüştürürsünüz.

`Super + L` tuşuna tekrar basmak çalışma alanını, pencerelerin serbestçe üst üste bindiği ve onları kendiniz yerleştirdiğiniz yüzen düzene çevirir ve üçüncü bir basış onu dwindle düzenine geri döndürür. `Super + Alt + L` bunlar arasında diğer yönde gider. Zaten yüzen bir pencere — `Super + T` ile dışarı çıkardığınız bir pencere veya her zaman yüzen olarak açılan bir uygulama — çalışma alanı döşemeye geri döndüğünde yüzen kalmaya devam eder. Üst çubuk, üzerinde olduğunuz çalışma alanını düzeniyle işaretler: dwindle için bir kare, kaydırma için bir daire ve yüzen için bir üçgen. O işarete tıklamak da düzen arasında geçiş yapar.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Seçim çalışma alanı başınadır ve kalıcıdır. Yani çalışma alanı 1'i gezinme için dwindle düzeninde ve çalışma alanı 2'yi kod için kaydırma düzeninde tutabilirsiniz ve bir yeniden başlatmadan sonra bu şekilde geri gelirler.

Kaydırma düzenini varsayılan olarak kullanmak isterseniz, bunu `~/.config/hypr/looknfeel.lua` içinde ayarlayabilirsiniz:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Yüzen çalışma alanları

Yüzen bir çalışma alanı geleneksel bir masaüstü gibi çalışır: pencereler üst üste biner ve onları kendiniz taşıyıp boyutlandırırsınız. Her pencere, temanızın renklerinde, simge durumuna küçültme, ekranı kaplama ve kapatma düğmeleri olan bir başlık çubuğu alır. `Super + M` de odaklanılan pencereyi simge durumuna küçültür. Simge durumuna küçültülmüş bir pencere dock'ta bekler; onu geri getirmek için uygulamasına tıklayın. Bir pencereyi öne getirmek için ona tıklayın. Onu herhangi bir kenardan veya köşeden yeniden boyutlandırın. Üst çubuğu görünürde tutarken pencereyi ekranı kaplayacak hâle getirmek için bir başlık çubuğuna çift tıklayın ve eski boyutunu geri almak için tekrar çift tıklayın.

Yüzen bir çalışma alanı ayrıca, sabitlenmiş uygulamalarınız, çalışan her şey ve uygulamalar düğmesinin arkasındaki her uygulamanın bir ızgarası ile bir dock gösterir; bu ızgarayı `Super + Alt + Space` ve Omarchy menüsündeki _Uygulamalar_ da açar. Kaldırmak için ızgaradaki bir uygulamaya sağ tıklayın veya `Delete` tuşuna basın. Bir uygulamayı açmak veya penceresini öne getirmek için ona tıklayın; pencereleri arasında geçiş yapmak için tekrar tıklayın. Orta tıklama yeni bir pencere açar. Taşımak için bir simgeyi dock boyunca sürükleyin; çalışan bir uygulamayı diğerlerinin arasına sürüklemek onu orada tutar. Bir uygulamayı dock'ta tutmak, oradan çıkarmak veya ondan çıkmak için sağ tıklayın. Dock, tam ekran bir pencerenin önünden çekilir. Dock'u başka bir kenara taşımak veya işaretçi onun kenarına ulaşana kadar gizlenmesini sağlamak için uygulamalar düğmesine sağ tıklayın. Konum ayrıca _Görünüm > Dock > Dock Konumu_ altındadır ve `omarchy dock position left` ile `omarchy dock autohide on` her ikisini de bir terminalden ayarlar. Dock'ta tuttuğunuz uygulamalar çalışmıyorken soluk görünür.

Yeni çalışma alanları ve `Super + L` ile kendine ait bir düzen vermedikleriniz varsayılan düzeni kullanır. Varsayılanı değiştirmek, penceresi olmayan her çalışma alanını ona sıfırlar; üzerinde pencereler olan biri ise sahip olduğu düzeni korur. Dock'a simge durumuna küçültülmüş bir pencere hâlâ ayrıldığı çalışma alanındaki bir pencere olarak sayılır. Onu _Görünüm > Çalışma Alanı Düzeni_ altından seçin: Döşeme, Kaydırma veya Yüzen. `omarchy-hyprland-workspace-layout-default scrolling` onu bir terminalden ayarlar.

### Pencereleri gruplama

Pencereler `Super + G` kullanılarak gruplanabilir. Bir gruba girdikten sonra, o aktifken başlattığınız her pencere gruba ait olacaktır. Bu gruplanmış pencereler arasında `Super + Ctrl + Arrow Left/Right` kullanarak veya doğrudan sırayla gruplanmış pencereye gitmek için `Super + Alt + 1/2/3/4` kullanarak hareket edebilirsiniz.

Bir pencereyi `Super + Alt + G` ile grubun dışına taşıyabilir veya `Super + G` tuşuna tekrar basarak tüm grubu dağıtabilirsiniz. Son olarak, grubun dışındaki pencereleri `Super + Alt + Arrows` ile onun içine taşıyabilirsiniz.

### Pencereleri dışarı çıkarma

Bir pencereyi `Super + O` ile çalışma alanı tahsisinin dışına çıkarabilirsiniz. Bu, onu gittiğiniz her çalışma alanında sizi takip eden yüzen bir pencere olarak sabitler. Video oynatıcılar ve benzerleri için harika.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad çalışma alanı

O anda üzerinde olduğunuz çalışma alanının üstünde kaplanan özel, tam boyutlu bir scratchpad çalışma alanı vardır. Üzerindekilere `Super + S` kullanarak erişirsiniz ve pencereleri oraya `Super + Alt + S` kullanarak yerleştirirsiniz.

Mevcut çalışma alanından ayrılmadan hızlıca etkileşim kurmak istediğiniz kontroller veya bir terminal için iyi çalışır.

### Quake konsolu

Son olarak, o anda üzerinde olduğunuz çalışma alanının üstüne aşağı açılan yarım yükseklikte bir Quake konsolu vardır. Onu `Super + Grave` ile açıp kapatırsınız ve oraya `Super + Shift + Grave` kullanarak bir pencere yerleştirirsiniz.

Varsayılan ajanınız hazır hâlde açılır. Konsol tek bir pencere barındırırken, ekranı kaplamak yerine ortalanmış bir panel olarak aşağı açılır. Üzerine ikinci bir uygulama koyun; ikisinin yan yana oturacak yeri olması için tam genişliğe geri döner.

Bir pencereyi scratchpad'den veya konsoldan çıkarmak için, onu `Super + Shift + 1` gibi bir tuşla doğrudan başka bir çalışma alanına gönderin.

### Alışmak biraz zaman alıyor!

Masaüstünüzde bu şekilde gezinmeye alışmak biraz zaman alır, ama alıştıktan sonra geleneksel fareyle yönetilen bir masaüstü deneyimine geri dönmek zor olacaktır!
