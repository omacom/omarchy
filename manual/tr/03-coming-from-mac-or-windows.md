# Mac veya Windows'tan Geliyorsanız

Yıllarınızı macOS veya Windows'ta geçirdiyseniz, parmaklarınız beyninizin bir zamanlar öğrendiğini bile unuttuğu yüzlerce şeyi biliyor. Bu bölüm çeviri katmanıdır: o içgüdülerin Omarchy'de nereye gittiği. Özelliklerin kendileri başka yerlerde derinlemesine ele alınıyor — bu yalnızca harita.

### Super her şeyin merkezinde

Cmd veya Windows tuşu etrafında edindiğiniz tüm kas hafızası tek bir tuşa aktarılıyor: Super. Bu, PC klavyesindeki Windows tuşudur ve Omarchy'deki neredeyse her kısayol tuşunun çıpasıdır.

Spotlight veya Raycast veya Başlat menüsü refleksiniz `Super + Space` olur. Bu, Omarchy menüsünü açar; bu menü uygulamaları başlatır, ayarları değiştirir, yazılım kurar, ekranı yakalar — hemen hemen her şeyi yapar. Filtrelemek için yazmaya başlayın. `Super + Alt + Space`, Launchpad'in yaptığı gibi her uygulamayı tek bir ızgarada gösterir. Bkz. [gezinti](04-navigation.md).

### Dock yok ve masaüstü simgeleri yok

Tıklayıp bir şeyler başlatacak hiçbir şey yok, masaüstünde düzenlenecek simgeler yok. Uygulamalar bir kısayol tuşuyla (`Super + Return` terminal için, `Super + Shift + Return` tarayıcı için ve `Super + K` eşlenmiş her şeyin listesi için) veya menüden başlar. Tek kalıcı arayüz parçası [üst çubuktur](05-the-top-bar.md); bu çubuk menü çubuğunun, sistem tepsisinin ve Notification Center'ın daha önce sizin için yaptıklarını kapsar — ve üzerindeki neredeyse her widget sol, sağ ve orta tıklamada bir şey yapar.

### Pencereler kendiliğinden yerleşir

En büyük zihniyet değişimi: pencereleri oraya buraya sürüklemez veya ekran yarılarına yaslamazsınız. Bir pencere açarsınız ve tüm ekranı kaplar. İkincisini açarsınız ve ekranı bölüşürler. Bir pencereyi asla bir başkasının altından çıkarmaya çalışmazsınız, çünkü pencereler üst üste binmez.

Gerçekten yüzen bir pencereye ihtiyacınız olduğunda, `Super + T` etkin olanı döşemeden çıkarır (ve geri sokar). Ama önce döşemeye gerçek bir şans verin — her şeyin kalbi odur. [Gezinti](04-navigation.md) size yol gösterir.

Çalışma alanları tanıdık gelecektir: macOS Spaces veya Windows sanal masaüstleri gibidirler, tek farkı onları gerçekten kullanacak olmanızdır, çünkü `Super + 1/2/3/4` doğrudan birine atlar ve `Super + Shift + 1/2/3/4` etkin pencereyi oraya gönderir. Animasyon gecikmesi yok, sadece anında geçişler. Bu, daha önce alışmış olsanız bile birden fazla monitöre bile ihtiyacınız olmayabileceği anlamına geliyor.

### Kopyala ve yapıştır sorunsuz çalışır

Mac'te her yerde Cmd + C vardı. Windows'ta her yerde Ctrl + C vardı — terminal hariç; orada programınızı öldürür. Omarchy size `Super + C`, `Super + X` ve `Super + V` verir ve bunlar terminal dahil her yerde çalışır. Kabuk için ayrı bir refleks öğrenmenize gerek yok.

Windows'çular: Win + V pano geçmişiniz `Super + Ctrl + V` üzerinde yaşar ve metnin yanı sıra görüntüleri de tutar. Bkz. [birleşik pano ve geçmiş](08-unified-clipboard-history.md).

### Çeviri tablosu

| Elinizin gittiği şey | Omarchy'de |
| ------------- | ---------- |
| Spotlight / Raycast / Başlat menüsü | `Super + Space` — Omarchy menüsü |
| AirDrop | LocalSend, `Super + Ctrl + S` üzerinden — bkz. [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` veya `Print Screen` — bkz. [ekran görüntüleri ve kayıt](12-screenshots-recording.md) |
| Notification Center | `Super + Shift + Alt + ,` üzerinde bildirim geçmişi |
| Time Machine (sistem için) | Her güncellemede otomatik [sistem anlık görüntüleri](47-system-snapshots.md) |
| App Store / bir kurulum dosyası indirmek | Menüdeki _Yükle_ veya `omarchy pkg add` — bkz. [diğer paketler](29-other-packages.md) |
| System Settings / Control Panel | Düz yapılandırma dosyalarını düzenleyen menüdeki _Kurulum_ — bkz. [dotfiles](31-dotfiles.md) |

### Bazı şeyler gerçekten farklı

Birçok ayar, tıklayarak gezdiğiniz panellerde değil, düzenlediğiniz metin dosyalarında yaşar. Bu, her ince ayarın görülebildiğini, bir sonraki makinenize kopyalanabildiğini ve sürüm kontrolüne konabildiğini fark edene kadar ilkel geliyor. _Kurulum_ menüsü sizi doğrudan doğru dosyaya bırakır ve işiniz bittiğinde yeniden başlatılması gereken her şeyi yeniden başlatır.

Güncellemeler tek bir komutla gelir — _Güncelle > Omarchy_ — bu, önce bir anlık görüntü alarak Omarchy'nin kendisini ve sistemdeki her paketi günceller. Rastgele zamanlarda sizi rahatsız eden uygulama başına güncelleyiciler yok. Bkz. [güncellemeler](30-updates.md).

Yazılım, indirilen kurulum dosyalarından değil, bir paket yöneticisinden gelir.

Ve bir pencereyi kapattığınızda, uygulama gerçekten çıkar. Programın penceresiz çalışmaya devam ettiği bir macOS arafı yok. `Super + W` — veya geldiğiniz parmak hafızası buysa `Super + Q` — gitti demektir.

### Mac donanımında

Omarchy Intel Mac'lerde iyi çalışır — bkz. [Mac desteği](44-mac-support.md). Ve klavye size nazik davranır: Omarchy hiçbir şeyi yeniden eşlemez ve Linux, Command tuşunu Super olarak kabul eder, bu yüzden Super tam Cmd'nin her zaman olduğu yerde oturur. Başparmağınız taşınmayı fark etmez bile.

### İki hafta verin

İçgüdüler düşündüğünüzden daha hızlı aktarılır. [kısayol tuşları](07-hotkeys.md) bölümüne bir kez göz gezdirin ve bir tuş atamasında takıldığınızda `Super + K` tuşuna basın — size hepsini gösterir. Gerçekten ezberlemeniz gereken tek kısayol tuşu budur.
