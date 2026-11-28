# Mac veya Windows'tan Geliyorsanız

macOS veya Windows'ta yıllar geçirdiyseniz, parmaklarınız beyninizin öğrendiğini bile çoktan unuttuğu yüzlerce şeyi biliyor. Bu bölüm çeviri katmanı: Omarchy'de o içgüdülerin nereye gittiği. Özelliklerin kendileri başka yerlerde derinlemesine ele alınıyor — bu sadece harita.

### Super her şeyin merkezinde

Cmd veya Windows tuşu etrafında edindiğiniz tüm kas hafızası tek bir tuşa aktarılıyor: Super. Bu, PC klavyesindeki Windows tuşu ve Omarchy'deki hemen her kısayolun dayanağı.

Spotlight veya Raycast veya Başlat menüsü refleksiniz `Super + Space` oluyor. Bu, Omarchy menüsünü açar; uygulamaları başlatır, ayarları değiştirir, yazılım kurar, ekranı yakalar — hemen her şeyi yapar. Filtrelemek için yazmaya başlayın. `Super + Alt + Space` tüm uygulamaları Launchpad'in yaptığı gibi tek bir ızgarada gösterir. Bkz. [gezinme](04-navigation.md).

### Masaüstü simgesi yok ve dock yolunuza çıkmıyor

Masaüstünde düzenlenecek simge yok ve bir çalışma alanında pencere olduğunda dock gizleniyor; imleci ekranın onun bulunduğu kenarına, siz taşımadıkça alt kenarına itene kadar da ortaya çıkmıyor (bkz. [gezinme](04-navigation.md)). Uygulamalar bir kısayolla (terminal için `Super + Return`, tarayıcı için `Super + Shift + Return` ve eşlenmiş her şeyin listesi için `Super + K`) veya menüden başlar. Tek kalıcı UI parçası [üst çubuk](05-the-top-bar.md); daha önce menü çubuğu, sistem tepsisi ve Notification Center'ın sizin için yaptıklarını o karşılıyor — ve üzerindeki hemen her widget sol, sağ ve orta tıklamada bir şey yapıyor.

### Pencereler kendiliğinden yerleşiyor

En büyük zihniyet değişimi: Pencereleri sürükleyip ekran yarılarına yaslamıyorsunuz. Bir pencere açın, tüm ekranı kaplasın. İkincisini açın, ekranı bölüşsünler. Pencereler üst üste binmediği için bir pencereyi bir diğerinin altından çekip çıkarmakla asla uğraşmıyorsunuz.

Gerçekten yüzen bir pencereye ihtiyacınız olduğunda, `Super + T` etkin pencereyi döşemeden çıkarır (ve geri alır). Ama önce döşemeye gerçek bir şans verin — her şeyin kalbi o. [Gezinme](04-navigation.md) size yol gösteriyor.

Çalışma alanları tanıdık gelecek: macOS Spaces veya Windows sanal masaüstleri gibiler, tek farkı bunları gerçekten kullanacak olmanız; çünkü `Super + 1/2/3/4` doğrudan birine atlıyor ve `Super + Shift + 1/2/3/4` etkin pencereyi oraya gönderiyor. Animasyon gecikmesi yok, anında atlamalar var. Bu, daha önce buna alışkınsanız birden çok monitöre bile ihtiyacınız olmayabileceği anlamına geliyor.

### Kopyala ve yapıştır sorunsuz çalışıyor

Mac'te her yerde Cmd + C vardı. Windows'ta her yerde Ctrl + C vardı — programınızı öldürdüğü terminal dışında. Omarchy size `Super + C`, `Super + X` ve `Super + V` veriyor ve bunlar terminal dahil her yerde çalışıyor. Kabuk için ayrı bir refleks öğrenmek yok.

Windows'tan gelenler: Win + V pano geçmişiniz `Super + Ctrl + V` üzerinde yaşıyor ve metnin yanı sıra görüntüleri de tutuyor. Bkz. [birleşik pano ve geçmiş](08-unified-clipboard-history.md).

### Çeviri tablosu

| Elinizin gittiği şey | Omarchy'de |
| ------------- | ---------- |
| Spotlight / Raycast / Başlat menüsü | `Super + Space` — Omarchy menüsü |
| AirDrop | LocalSend, `Super + Ctrl + S` üzerinden — bkz. [GUI'ler](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` veya `Print Screen` — bkz. [ekran görüntüleri ve kayıt](12-screenshots-recording.md) |
| Notification Center | `Super + Shift + Alt + ,` üzerinde bildirim geçmişi |
| Time Machine (sistem için) | Her güncellemede otomatik [sistem anlık görüntüleri](47-system-snapshots.md) |
| App Store / bir yükleyici indirmek | Menüde _Install_ veya `omarchy pkg add` — bkz. [diğer paketler](29-other-packages.md) |
| Sistem Ayarları / Denetim Masası | Menüde _Setup_, düz yapılandırma dosyalarını düzenler — bkz. [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, `Super + Shift + F` üzerinde — bkz. [GUI'ler](22-guis.md) |
| Safari / Edge | `Super + Shift + Return` üzerinde Google Chrome; _Setup > Defaults > Browser_ altında başka birini seçin — bkz. [tarayıcılar](23-browsers.md) |
| Preview / Photos | Resimler, video ve müzik için Omaview, PDF'ler için Document Viewer — bkz. [GUI'ler](22-guis.md) |
| TextEdit / Notepad | Plain, `Super + Shift + N` üzerinde; _Setup > Defaults > Editor_ altında başka birini seçin |

### Bazı şeyler gerçekten farklı

Pek çok ayar, tıklayarak gezdiğiniz panellerde değil, düzenlediğiniz metin dosyalarında yaşıyor. Her ince ayarın görülebilmesi, bir sonraki makinenize kopyalanabilmesi ve sürüm denetimine konabilmesi anlamına geldiğini fark edene kadar ilkel geliyor. _Setup_ menüsü sizi doğrudan doğru dosyaya bırakıyor ve işiniz bittiğinde yeniden başlatılması gereken ne varsa yeniden başlatıyor.

Güncellemeler tek bir komutla geliyor — _Update > Omarchy_; Omarchy'nin kendisini ve sistemdeki her paketi güncelliyor, önce de bir anlık görüntü alıyor. Rastgele zamanlarda sizi dürten uygulama başına güncelleyiciler yok. Bkz. [güncellemeler](30-updates.md).

Yazılım, indirilen yükleyicilerden değil bir paket yöneticisinden geliyor.

Ve bir pencereyi kapattığınızda uygulama gerçekten kapanıyor. Programın penceresiz çalışmaya devam ettiği bir macOS arafı yok. `Super + W` — ya da geldiğiniz parmak hafızası buysa `Super + Q` — gitti demek.

### Mac donanımında

Omarchy, Intel Mac'lerde ve Omarchy for Apple Silicon ile M1, M2 ve M3 Mac'lerde iyi çalışıyor. Bkz. [Mac desteği](44-mac-support.md). Klavye de size nazik davranıyor: Omarchy hiçbir şeyi yeniden eşlemiyor ve Linux, Command tuşunu Super olarak görüyor; yani Super tam Cmd'nin her zaman olduğu yerde oturuyor. Başparmağınız taşınmayı fark etmeyecek bile.

### Kendinize iki hafta verin

İçgüdüler düşündüğünüzden hızlı aktarılıyor. [kısayollar](07-hotkeys.md) bölümüne bir kez göz atın ve bir bağlamada takıldığınızda `Super + K` tuşuna basın — size hepsini gösteriyor. Gerçekten ezberlemeniz gereken tek kısayol bu.
