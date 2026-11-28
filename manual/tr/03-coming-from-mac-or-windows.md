# Mac veya Windows'tan Geliyorsanız

Yıllarınızı macOS veya Windows'ta geçirdiyseniz, parmaklarınız beyninizin öğrendiğini bile unuttuğu yüzlerce şeyi biliyor. Bu bölüm çeviri katmanı: bu içgüdülerin Omarchy'de nereye gittiği. Özelliklerin kendileri başka yerlerde derinlemesine anlatılıyor — bu yalnızca harita.

### Super her şeyin merkezinde

Cmd veya Windows tuşu etrafında edindiğiniz tüm kas hafızası tek bir tuşa aktarılıyor: Super. Bu, PC klavyesindeki Windows tuşu ve Omarchy'deki neredeyse her kısayolun dayanağı.

Spotlight, Raycast veya Başlat menüsü refleksiniz `Super + Space` oluyor. Bu, Omarchy menüsünü açar; uygulamaları başlatır, ayarları değiştirir, yazılım kurar, ekranı yakalar — hemen hemen her şeyi yapar. Filtrelemek için yazmaya başlayın. `Super + Alt + Space`, Launchpad'in yaptığı gibi her uygulamayı tek bir ızgarada gösterir. Bkz. [navigasyon](04-navigation.md).

### Masaüstü simgesi yok ve dock yalnızca yüzerken görünür

Masaüstünde düzenlenecek simgeler yok ve döşemeli bir çalışma alanında dock da yok — dock yalnızca yüzer bir çalışma alanında görünür (bkz. [navigasyon](04-navigation.md)). Uygulamalar bir kısayolla (terminal için `Super + Return`, tarayıcı için `Super + Shift + Return` ve eşlenmiş her şeyin listesi için `Super + K`) veya menüden başlar. Kalıcı tek UI parçası, menü çubuğunun, sistem tepsisinin ve Notification Center'ın eskiden sizin için yaptıklarını üstlenen [üst çubuk](05-the-top-bar.md) ve üzerindeki neredeyse her widget sol, sağ ve orta tıklamada bir şeyler yapar.

### Pencereler kendi kendine yerleşir

En büyük zihniyet değişimi: pencereleri sürükleyip ekran yarılarına yaslamıyorsunuz. Bir pencere açarsanız tüm ekranı kaplar. İkincisini açarsanız ekranı bölüşürler. Bir pencereyi asla bir başkasının altından çekip çıkarmak zorunda kalmazsınız, çünkü pencereler üst üste binmez.

Gerçekten yüzer bir pencereye ihtiyacınız olduğunda, `Super + T` etkin pencereyi döşemenin dışına çıkarır (ve geri getirir). Ama önce döşemeye gerçek bir şans verin — her şeyin kalbi o. [Navigasyon](04-navigation.md) size adım adım anlatır.

Çalışma alanları tanıdık gelecektir: macOS Spaces veya Windows sanal masaüstleri gibiler, tek farkı bunları gerçekten kullanacak olmanız; çünkü `Super + 1/2/3/4` doğrudan birine atlar ve `Super + Shift + 1/2/3/4` etkin pencereyi oraya gönderir. Animasyon gecikmesi yok, yalnızca anında atlamalar var. Bu, önceden buna alışkınsanız birden fazla monitöre bile ihtiyacınız olmayabileceği anlamına geliyor.

### Kopyala ve yapıştır sorunsuz çalışıyor

Mac'te her yerde Cmd + C vardı. Windows'ta her yerde Ctrl + C vardı — terminal hariç, orada programınızı öldürür. Omarchy size `Super + C`, `Super + X` ve `Super + V` verir ve bunlar terminal dahil her yerde çalışır. Kabuk için ayrı bir refleks öğrenmenize gerek yok.

Windows'tan gelenler: Win + V pano geçmişiniz `Super + Ctrl + V` üzerinde yaşıyor ve metnin yanı sıra görüntüleri de tutuyor. Bkz. [birleşik pano ve geçmiş](08-unified-clipboard-history.md).

### Çeviri tablosu

| Elinizin gittiği | Omarchy'de |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy menüsü |
| AirDrop | LocalSend, `Super + Ctrl + S` ile — bkz. [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` veya `Print Screen` — bkz. [ekran görüntüleri ve kayıt](12-screenshots-recording.md) |
| Notification Center | `Super + Shift + Alt + ,` ile bildirim geçmişi |
| Time Machine (sistem için) | Her güncellemede otomatik [sistem anlık görüntüleri](47-system-snapshots.md) |
| App Store / bir kurulum dosyası indirmek | Menüdeki _Install_ veya `omarchy pkg add` — bkz. [diğer paketler](29-other-packages.md) |
| System Settings / Control Panel | Düz yapılandırma dosyalarını düzenleyen, menüdeki _Setup_ — bkz. [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, `Super + Shift + F` ile — bkz. [GUIs](22-guis.md) |
| Safari / Edge | `Super + Shift + Return` ile Google Chrome; _Setup > Defaults > Browser_ altında başka birini seçin — bkz. [tarayıcılar](23-browsers.md) |
| Preview / Photos | Resimler, video ve müzik için Omaview, PDF'ler için Document Viewer — bkz. [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, `Super + Shift + N` ile; _Setup > Defaults > Editor_ altında başka birini seçin |

### Bazı şeyler gerçekten farklı

Birçok ayar, tıklayarak gezdiğiniz panellerde değil, düzenlediğiniz metin dosyalarında yaşıyor. Bu, her ince ayarın görülebildiğini, bir sonraki makinenize kopyalanabildiğini ve sürüm denetimine konulabildiğini fark edene kadar ilkel geliyor. _Setup_ menüsü sizi doğrudan doğru dosyaya bırakır ve işiniz bittiğinde yeniden başlatılması gereken ne varsa yeniden başlatır.

Güncellemeler tek bir komutla gelir — _Update > Omarchy_ — bu, önce bir anlık görüntü alarak Omarchy'nin kendisini ve sistemdeki her paketi günceller. Rastgele zamanlarda sizi dürten uygulama başına güncelleyiciler yok. Bkz. [güncellemeler](30-updates.md).

Yazılım, indirilen kurulum dosyalarından değil, bir paket yöneticisinden gelir.

Ve bir pencereyi kapattığınızda uygulama gerçekten kapanır. Programın penceresiz çalışmaya devam ettiği macOS arafı yok. `Super + W` — veya geldiğiniz parmak hafızası buysa `Super + Q` — gitti demek.

### Mac donanımında

Omarchy, Intel Mac'lerde ve Omarchy for Apple Silicon ile M1, M2 ve M3 Mac'lerde iyi çalışır. Bkz. [Mac desteği](44-mac-support.md). Ve klavye size nazik davranır: Omarchy hiçbir şeyi yeniden eşlemez ve Linux, Command tuşunu Super olarak kabul eder, yani Super tam Cmd'nin her zaman olduğu yerde durur. Başparmağınız taşınmayı fark etmez bile.

### İki hafta şans verin

İçgüdüler düşündüğünüzden daha hızlı aktarılır. [kısayol tuşları](07-hotkeys.md) bölümüne bir kez göz atın ve bir atamada takıldığınızda `Super + K` tuşuna basın — size hepsini gösterir. Aslında ezberlemeniz gereken tek kısayol bu.
