# Mac veya Windows'tan Geliyorsanız

macOS veya Windows'ta yıllar geçirdiyseniz, parmaklarınız beyninizin öğrendiğini bile unuttuğu yüzlerce şeyi biliyor. Bu bölüm çeviri katmanı: Omarchy'de o içgüdülerin nereye gittiği. Özelliklerin kendileri başka yerlerde derinlemesine anlatılıyor — bu sadece harita.

### Super her şeyin merkezi

Cmd veya Windows tuşu etrafında edindiğiniz tüm kas hafızası tek bir tuşa aktarılıyor: Super. Bu, PC klavyesindeki Windows tuşu ve Omarchy'deki neredeyse her kısayolun dayanağı.

Spotlight veya Raycast veya Başlat menüsü refleksiniz `Super + Space` oluyor. Bu, uygulamaları başlatan, ayarları değiştiren, yazılım kuran, ekranı yakalayan Omarchy menüsünü açar — hemen hemen her şeyi. Filtrelemek için yazmaya başlayın. `Super + Alt + Space` tüm uygulamaları Launchpad'in yaptığı gibi tek bir ızgarada gösterir. Bkz. [gezinti](04-navigation.md).

### Masaüstü simgeleri yok ve dock yalnızca yüzdüğünüzde ortaya çıkar

Masaüstünde düzenlenecek simgeler yok ve döşemeli bir çalışma alanında dock yok — dock yalnızca yüzen bir çalışma alanında görünür (bkz. [gezinti](04-navigation.md)). Uygulamalar bir kısayol tuşuyla (terminal için `Super + Return`, tarayıcı için `Super + Shift + Return` ve eşlenmiş her şeyin listesi için `Super + K`) veya menüden başlar. Tek kalıcı arayüz öğesi, daha önce menü çubuğu, sistem tepsisi ve Notification Center'ın sizin için yaptıklarını karşılayan [üst çubuktur](05-the-top-bar.md) — ve üzerindeki hemen hemen her widget sol, sağ ve orta tıklamada bir şey yapar.

### Pencereler kendiliğinden yerleşir

En büyük zihniyet değişimi: pencereleri sürükleyip ekran yarılarına yaslamıyorsunuz. Bir pencere açın ve tüm ekranı kaplasın. İkincisini açın ve ekranı bölsünler. Bir pencereyi asla başka birinin altından çıkarmak zorunda kalmıyorsunuz, çünkü pencereler üst üste binmiyor.

Gerçekten yüzen bir pencereye ihtiyacınız olduğunda, `Super + T` etkin olanı döşemeden çıkarır (ve geri alır). Ama önce döşemeye gerçek bir şans verin — tüm işin kalbi bu. [Gezinti](04-navigation.md) size bunu adım adım gösterir.

Çalışma alanları tanıdık gelecektir: bunlar macOS Spaces veya Windows sanal masaüstleri, yalnız bunları gerçekten kullanacaksınız, çünkü `Super + 1/2/3/4` doğrudan birine atlar ve `Super + Shift + 1/2/3/4` etkin pencereyi oraya gönderir. Animasyon gecikmesi yok, sadece anında atlamalar. Bu, daha önce buna alışkınsanız birden fazla monitöre bile ihtiyacınız olmayabileceği anlamına geliyor.

### Kopyala ve yapıştır sorunsuz çalışıyor

Mac'te her yerde Cmd + C'niz vardı. Windows'ta her yerde Ctrl + C'niz vardı — programınızı öldürdüğü terminal hariç. Omarchy size `Super + C`, `Super + X` ve `Super + V` veriyor ve bunlar terminal de dahil her yerde çalışıyor. Kabuk için öğrenilecek ayrı bir refleks yok.

Windows'çular: Win + V pano geçmişiniz `Super + Ctrl + V` üzerinde yaşıyor ve metnin yanı sıra görüntüleri de tutuyor. Bkz. [birleşik pano ve geçmiş](08-unified-clipboard-history.md).

### Çeviri tablosu

| Elinizin gittiği | Omarchy'de |
| ------------- | ---------- |
| Spotlight / Raycast / Başlat menüsü | `Super + Space` — Omarchy menüsü |
| AirDrop | LocalSend, `Super + Ctrl + S` ile — bkz. [GUI'ler](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` veya `Print Screen` — bkz. [ekran görüntüleri ve kayıt](12-screenshots-recording.md) |
| Notification Center | `Super + Shift + Alt + ,` ile bildirim geçmişi |
| Time Machine (sistem için) | Her güncellemede otomatik [sistem anlık görüntüleri](47-system-snapshots.md) |
| App Store / bir yükleyici indirmek | Menüde _Install_ veya `omarchy pkg add` — bkz. [diğer paketler](29-other-packages.md) |
| Sistem Ayarları / Denetim Masası | Düz yapılandırma dosyalarını düzenleyen menüdeki _Setup_ — bkz. [dotfiles](31-dotfiles.md) |
| Finder / Dosya Gezgini | `Super + Shift + F` ile Files — bkz. [GUI'ler](22-guis.md) |
| Safari / Edge | `Super + Shift + Return` ile Google Chrome; _Setup > Defaults > Browser_ altında başka bir tane seçin — bkz. [tarayıcılar](23-browsers.md) |
| Preview / Photos | Resimler, video ve müzik için Omaview, PDF'ler için Document Viewer — bkz. [GUI'ler](22-guis.md) |
| TextEdit / Notepad | `Super + Shift + N` ile Plain; _Setup > Defaults > Editor_ altında başka bir tane seçin |

### Bazı şeyler gerçekten farklı

Birçok ayar, tıklayarak gezdiğiniz panellerde değil, düzenlediğiniz metin dosyalarında yaşıyor. Her ince ayarın görülebilmesi, bir sonraki makinenize kopyalanabilmesi ve sürüm denetimine konabilmesi anlamına geldiğini fark edene kadar bu ilkel geliyor. _Setup_ menüsü sizi doğrudan doğru dosyaya bırakır ve işiniz bittiğinde yeniden başlatılması gereken her şeyi yeniden başlatır.

Güncellemeler tek bir komutla gelir — _Update > Omarchy_ — bu, önce bir anlık görüntü alarak Omarchy'nin kendisini ve sistemdeki her paketi günceller. Rastgele zamanlarda sizi rahatsız eden uygulama başına güncelleyiciler yok. Bkz. [güncellemeler](30-updates.md).

Yazılım, indirilen yükleyicilerden değil, bir paket yöneticisinden gelir.

Ve bir pencereyi kapattığınızda, uygulama gerçekten kapanır. Programın penceresiz çalışmaya devam ettiği bir macOS arafı yok. `Super + W` — veya geldiğiniz parmak hafızası buysa `Super + Q` — gitti demektir.

### Mac donanımında

Omarchy Intel Mac'lerde iyi çalışır — bkz. [Mac desteği](44-mac-support.md). Ve klavye size nazik davranır: Omarchy hiçbir şeyi yeniden eşlemez ve Linux, Command tuşunu Super olarak görür, bu yüzden Super tam Cmd'nin her zaman olduğu yerde durur. Başparmağınız taşınmayı fark etmeyecek.

### İki hafta verin

İçgüdüler düşündüğünüzden daha hızlı aktarılıyor. [kısayol tuşları](07-hotkeys.md) bölümüne bir kez göz atın ve bir bağlamada boşluğa düştüğünüzde `Super + K`'ye basın — size hepsini gösterir. Aslında ezberlemeniz gereken tek kısayol tuşu bu.
