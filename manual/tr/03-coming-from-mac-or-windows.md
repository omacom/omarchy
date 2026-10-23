# Mac veya Windows'tan Geliyorsanız

macOS veya Windows'ta yıllar geçirdiyseniz, parmaklarınız beyninizin hiç öğrendiğini unuttuğu yüzlerce şeyi bilir. Bu bölüm çeviri katmanıdır: o içgüdülerin Omarchy'de nereye gittiği. Özelliklerin kendileri başka yerlerde derinlemesine ele alınıyor — bu sadece harita.

### Super her şeyin merkezinde

Cmd veya Windows tuşu etrafında geliştirdiğiniz tüm kas hafızası tek bir tuşa aktarılır: Super. Bu, bir PC klavyesindeki Windows tuşudur ve Omarchy'deki neredeyse her kısayolun dayanağıdır.

Spotlight, Raycast veya Başlat menüsü refleksiniz `Super + Space` olur. Bu, uygulamaları başlatan, ayarları değiştiren, yazılım kuran, ekranı yakalayan — hemen hemen her şeyi yapan Omarchy menüsünü açar. Filtrelemek için yazmaya başlayın. `Super + Alt + Space`, Launchpad'in yaptığı gibi tüm uygulamaları tek bir ızgarada gösterir. Bkz. [gezinme](04-navigation.md).

### Dock ve masaüstü simgeleri yok

Bir şeyleri başlatmak için tıklanacak bir şey yok, masaüstünde düzenlenecek simgeler de yok. Uygulamalar bir kısayoldan (terminal için `Super + Return`, tarayıcı için `Super + Shift + Return` ve eşlenen her şeyin listesi için `Super + K`) veya menüden başlar. Kalıcı tek arayüz parçası, menü çubuğu, sistem tepsisi ve Bildirim Merkezi'nin daha önce sizin için yaptığını karşılayan [üst çubuk](05-the-top-bar.md)tur — ve üzerindeki hemen hemen her widget sol, sağ ve orta tıklamada bir şey yapar.

### Pencereler kendi kendine yerleşir

En büyük zihniyet değişimi: pencereleri sürüklemiyor veya ekranın yarılarına oturtmuyorsunuz. Bir pencere açın, tüm ekranı kaplar. İkinci bir pencere açın, ekranı bölüşürler. Bir pencereyi asla bir başkasının altından çıkarmak zorunda kalmazsınız, çünkü pencereler çakışmaz.

Gerçekten yüzen bir pencereye ihtiyacınız olduğunda, `Super + T` aktif pencereyi döşemenin dışına çıkarır (ve geri alır). Ama önce döşemeye gerçek bir şans verin — her şeyin kalbi odur. [Gezinme](04-navigation.md) sizi adım adım götürür.

Çalışma alanları tanıdık gelecektir: macOS Spaces veya Windows sanal masaüstleri gibidirler, ancak bu sefer gerçekten kullanacaksınız, çünkü `Super + 1/2/3/4` doğrudan birine atlar ve `Super + Shift + 1/2/3/4` aktif pencereyi oraya gönderir. Animasyon gecikmesi yok, sadece anında atlamalar. Bu, daha önce alışkınsanız çoklu monitöre bile ihtiyacınız olmayabileceği anlamına gelir.

### Kopyala yapıştır öylece çalışır

Mac'te her yerde Cmd + C vardı. Windows'ta her yerde Ctrl + C vardı — terminal hariç, orada programınızı öldürür. Omarchy size `Super + C`, `Super + X` ve `Super + V` verir ve bunlar terminal dahil her yerde çalışır. Kabuk için öğrenilecek ayrı bir refleks yok.

Windows kullanıcıları: Win + V pano geçmişiniz `Super + Ctrl + V` üzerinde yaşar ve metnin yanı sıra görselleri de tutar. Bkz. [birleşik pano ve geçmiş](08-unified-clipboard-history.md).

### Çeviri tablosu

| Ulaştığınız şey | Omarchy'de |
| ------------- | ---------- |
| Spotlight / Raycast / Başlat menüsü | `Super + Space` — Omarchy menüsü |
| AirDrop | LocalSend, `Super + Ctrl + S` ile — bkz. [GUI'ler](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — bkz. [ekran görüntüleri ve kayıt](12-screenshots-recording.md) |
| Bildirim Merkezi | `Super + Shift + Alt + ,` üzerindeki bildirim geçmişi |
| Time Machine (sistem için) | Her güncellemede otomatik [sistem anlık görüntüleri](47-system-snapshots.md) |
| App Store / kurulumcu indirme | Menüde _Kur_, veya `omarchy pkg add` — bkz. [diğer paketler](29-other-packages.md) |
| Sistem Ayarları / Denetim Masası | Menüde _Ayarlar_, düz yapılandırma dosyalarını düzenler — bkz. [dotfiles](31-dotfiles.md) |

### Bazı şeyler gerçekten farklı

Birçok ayar, panellerde tıklayarak değil, düzenlediğiniz metin dosyalarında yaşar. Bu, her ince ayarın görülebilmesi, bir sonraki makinenize kopyalanabilmesi ve sürüm denetimine konulabilmesi anlamına geldiğini fark edene kadar ilkel geliyor. _Ayarlar_ menüsü sizi doğrudan doğru dosyaya bırakır ve işiniz bittiğinde yeniden başlatılması gereken her şeyi yeniden başlatır.

Güncellemeler tek bir komuttan gelir — _Güncelle > Omarchy_ — bu komut, önce bir anlık görüntü alarak Omarchy'nin kendisini ve sistemdeki her paketi günceller. Rastgele zamanlarda sizi rahatsız eden uygulama başına güncelleyiciler yok. Bkz. [güncellemeler](30-updates.md).

Yazılım, indirilen kurulumculardan değil, bir paket yöneticisinden gelir.

Ve bir pencereyi kapattığınızda, uygulama gerçekten kapanır. Programın penceresiz çalışmaya devam ettiği bir macOS arafı yoktur. `Super + W` — veya geldiğiniz parmak hafızası buysa `Super + Q` — gitti anlamına gelir.

### Mac donanımında

Omarchy Intel Mac'lerde iyi çalışır — bkz. [Mac desteği](44-mac-support.md). Ve klavye size naziktir: Omarchy hiçbir şeyi yeniden eşlemez ve Linux Command tuşunu Super olarak ele alır, böylece Super tam Cmd'nin her zaman olduğu yerde oturur. Başparmağınız geçişi fark etmez bile.

### İki hafta verin

İçgüdüler düşündüğünüzden daha hızlı aktarılır. [Kısayollar](07-hotkeys.md) bölümünü bir kez gözden geçirin ve bir bağlamayı hatırlayamadığınızda `Super + K` tuşuna basın — size hepsini gösterir. Gerçekten ezberlemeniz gereken tek kısayol budur.
