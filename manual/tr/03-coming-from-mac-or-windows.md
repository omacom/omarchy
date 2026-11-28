# Mac veya Windows'tan Geliyorsanız

Yıllarınızı macOS veya Windows'ta geçirdiyseniz, parmaklarınız beyninizin öğrendiğini unuttuğu yüzlerce şeyi biliyor. Bu bölüm o çeviri katmanı: Omarchy'de o içgüdülerin nereye gittiği. Özelliklerin kendileri başka yerlerde derinlemesine anlatılıyor — bu sadece harita.

### Super her şeyin merkezi

Cmd veya Windows tuşu etrafında edindiğiniz tüm kas hafızası tek bir tuşa aktarılıyor: Super. Bu, PC klavyesindeki Windows tuşu ve Omarchy'deki neredeyse her kısayolun dayanağı.

Spotlight veya Raycast veya Başlat menüsü refleksiniz `Super + Space` oluyor. Bu, Omarchy menüsünü açar; uygulamaları başlatır, ayarları değiştirir, yazılım kurar, ekranı yakalar — hemen her şeyi yapar. Filtrelemek için yazmaya başlayın. `Super + Alt + Space`, Launchpad'in yaptığı gibi her uygulamayı tek bir ızgarada gösterir. Bkz. [gezinme](04-navigation.md).

### Masaüstü simgesi yok ve dock yolunuza çıkmıyor

Masaüstünde düzenlenecek simge yok ve bir çalışma alanında pencere olduğunda dock gizlenir; siz taşımadıkça sağdaki olmak üzere, işaretçiyi ekranın kenarına itene kadar (bkz. [gezinme](04-navigation.md)). Uygulamalar bir kısayolla (`Super + Return` terminal için, `Super + Shift + Return` tarayıcı için ve `Super + K` eşlenmiş her şeyin listesi için) veya menüden başlar. Kalıcı tek UI parçası, daha önce menü çubuğu, sistem tepsisi ve Notification Center'ın sizin için yaptıklarını karşılayan [üst çubuk](05-the-top-bar.md) — ve üzerindeki neredeyse her widget sol, sağ ve orta tıklamada bir şey yapar.

### Pencereler kendiliğinden yerleşir

En büyük zihniyet değişimi: pencereleri sürükleyip ekran yarılarına yaslamıyorsunuz. Bir pencere açın, tüm ekranı kaplar. İkincisini açın, ekranı bölüşürler. Bir pencereyi asla başka birinin altından çekip çıkarmıyorsunuz, çünkü pencereler üst üste binmiyor.

Gerçekten yüzen bir pencereye ihtiyacınız olduğunda, `Super + T` etkin olanı döşemenin dışına (ve geri içine) alır. Ama önce döşemeye gerçek bir şans verin — tüm işin kalbi o. [Gezinme](04-navigation.md) size adım adım anlatıyor.

Çalışma alanları tanıdık gelecektir: macOS Spaces veya Windows sanal masaüstleri gibiler, tek farkı gerçekten kullanacak olmanız; çünkü `Super + 1/2/3/4` doğrudan birine atlar ve `Super + Shift + 1/2/3/4` etkin pencereyi oraya gönderir. Animasyon gecikmesi yok, sadece anında atlamalar. Bu, daha önce alışmış olsanız bile birden fazla monitöre ihtiyacınız bile olmayabileceği anlamına geliyor.

### Kopyala ve yapıştır sorunsuz çalışıyor

Mac'te her yerde Cmd + C vardı. Windows'ta her yerde Ctrl + C vardı — programınızı öldürdüğü terminal hariç. Omarchy size `Super + C`, `Super + X` ve `Super + V` veriyor ve bunlar terminal dahil her yerde çalışıyor. Kabuk için ayrı bir refleks öğrenmek yok.

Windows'tan gelenler: Win + V pano geçmişiniz `Super + Ctrl + V` üzerinde yaşıyor ve metnin yanı sıra görselleri de tutuyor. Bkz. [birleşik pano ve geçmiş](08-unified-clipboard-history.md).

### Çeviri tablosu

| Elinizin gittiği şey | Omarchy'de |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy menüsü |
| AirDrop | LocalSend, `Super + Ctrl + S` ile — bkz. [GUI'ler](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` veya `Print Screen` — bkz. [ekran görüntüleri ve kayıt](12-screenshots-recording.md) |
| Notification Center | `Super + Shift + Alt + ,` üzerinde bildirim geçmişi |
| Time Machine (sistem için) | Her güncellemede otomatik [sistem anlık görüntüleri](47-system-snapshots.md) |
| App Store / bir yükleyici indirmek | Menüde _Install_, veya `omarchy pkg add` — bkz. [diğer paketler](29-other-packages.md) |
| System Settings / Control Panel | Düz yapılandırma dosyalarını düzenleyen, menüdeki _Setup_ — bkz. [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, `Super + Shift + F` üzerinde — bkz. [GUI'ler](22-guis.md) |
| Safari / Edge | `Super + Shift + Return` üzerinde Google Chrome; başka birini _Setup > Defaults > Browser_ altından seçin — bkz. [tarayıcılar](23-browsers.md) |
| Preview / Photos | Resimler, video ve müzik için Omaview, PDF'ler için Document Viewer — bkz. [GUI'ler](22-guis.md) |
| TextEdit / Notepad | Plain, `Super + Shift + N` üzerinde; başka birini _Setup > Defaults > Editor_ altından seçin |

### Bazı şeyler gerçekten farklı

Birçok ayar, tıklayarak gezdiğiniz panellerde değil, düzenlediğiniz metin dosyalarında yaşıyor. Bu, her ince ayarın görülebildiğini, bir sonraki makinenize kopyalanabildiğini ve sürüm kontrolüne konabildiğini fark edene kadar ilkel geliyor. _Setup_ menüsü sizi doğrudan doğru dosyaya bırakıyor ve işiniz bittiğinde yeniden başlatılması gereken ne varsa yeniden başlatıyor.

Güncellemeler tek bir komutla geliyor — _Update > Omarchy_ — Omarchy'nin kendisini ve sistemdeki her paketi güncelliyor, önce bir anlık görüntü alıyor. Rastgele zamanlarda sizi dürten uygulama başına güncelleyiciler yok. Bkz. [güncellemeler](30-updates.md).

Yazılım, indirilen yükleyicilerden değil bir paket yöneticisinden geliyor.

Ve bir pencereyi kapattığınızda, uygulama gerçekten kapanıyor. Programın penceresiz çalışmaya devam ettiği bir macOS arafı yok. `Super + W` — veya geldiğiniz parmak hafızası buysa `Super + Q` — gitti demek.

### Mac donanımında

Omarchy, Intel Mac'lerde ve Omarchy for Apple Silicon ile M1, M2 ve M3 Mac'lerde iyi çalışıyor. Bkz. [Mac desteği](44-mac-support.md). Ve klavye size nazik davranıyor: Omarchy hiçbir şeyi yeniden eşlemiyor ve Linux, Command tuşunu Super olarak kabul ediyor, yani Super tam Cmd'nin hep olduğu yerde oturuyor. Başparmağınız taşınmayı fark etmeyecek bile.

### İki hafta verin

İçgüdüler düşündüğünüzden hızlı aktarılıyor. [kısayollar](07-hotkeys.md) bölümüne bir kez göz atın ve ne zaman bir bağlamada takılırsanız `Super + K` tuşuna basın — hepsini gösterir. Gerçekten ezberlemeniz gereken tek kısayol bu.
