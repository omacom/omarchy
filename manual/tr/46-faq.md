# SSS

### Klavye düzenleri arasında nasıl geçiş yaparım?

`~/.config/hypr/input.lua` dosyanızı düzenleyin ve düzenler arasında `Left Alt + Right Alt` ile geçiş yapmak için şunu ekleyin:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Birden fazla düzen yapılandırdıktan sonra çubuk mevcut klavye düzeninizi otomatik olarak gösterir (ve geçiş yapmak için ona tıklayabilirsiniz de).

### Saat formatını 12 saatlik formata nasıl değiştiririm?

Yaygın formatlar arasında, 12 saatlik olanlar da dahil olmak üzere geçiş yapmak için çubuktaki saate sağ tıklayın. Formatı doğrudan da ayarlayabilirsiniz:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Bu, Pazar 10:55 AM olarak görüntüleyecektir.

### Saat dilimimi nasıl değiştiririm?

Omarchy menüsünde _Güncelle > Saat Dilimi_ çalıştırın ve listeden seçin. Saat dilimi doğruysa ancak saatin kendisi kaymışsa, _Güncelle > Saat_ sizin için saat senkronizasyonunu yeniden başlatır.

### DNS'imi nasıl değiştiririm, Wi-Fi'ımı nasıl paylaşırım veya bağlantı hızımı nasıl kontrol ederim?

Bunların hepsi [ağ ayarları](35-networking.md) bölümünde bulunur.

### Diskimin ne kadar hızlı olduğunu nasıl kontrol ederim?

_Tetikle > Hız Testi > Disk Hız Testi_, sürücünüzdeki canlı okuma ve yazma hızını ölçer veya terminalden `omarchy disk speedtest` çalıştırın.

### Nasıl yazıcı eklerim?

Yazdırma, kutudan çıkar çıkmaz kurulu ve çalışır durumdadır ve her yazıcıyı uygulama başlatıcıdaki (`Super + Space`) _Yazdırma Ayarları_'ndan kendiniz eklersiniz.

_Ekle_'yi seçin ve bakması için ona biraz zaman tanıyın: USB üzerinden bağlanmış bir yazıcı ve çoğu ağ yazıcısı sizin için bulunur. Sizinki listede değilse, _Ağ Yazıcısı > Internet Printing Protocol (ipp)_ seçeneğini seçin ve adresini girin — yazıcının kendi ekranı veya web sayfası bunun ne olduğunu size söyler; genellikle `192.168.1.50` gibi, kuyruğu `ipp/print` olan bir şeydir. _İleri_ daha sonra bir sürücü sunar; burada modern bir yazıcı en iyi, sürücüsüz _IPP Everywhere_ profiliyle çalışırken daha eski bir yazıcı modelin kendi sürücüsünü ister.

Bir yazıcıya sağ tıklayın ve uygulamalarınızın ilk olarak hangisine ulaşacağını seçmek için _Varsayılan Olarak Ayarla_'yı, kağıt boyutunu, çift taraflı yazdırmayı ve kaliteyi ayarlamak için de _Özellikler_'i seçin.

Ağdaki yazıcıların eklenmeden göründüğü otomatik keşif, üzerinde yeniden çalışılırken geçici olarak kapatılmıştır; bu yüzden yukarıdaki ilk adım otomatik değil, sizindir. Hiç yazıcı olmadan da bir PDF dosyasına yazdırabilirsiniz.

### Ekran görüntülerinin veya ekran kayıtlarının nereye kaydedileceğini nasıl değiştiririm?

Kaydedilen ekran görüntüleri varsayılan olarak `~/Pictures/Screenshots` konumuna gider. Başka bir dizin kullanmak için, `~/.config/uwsm/env.d/` altında bir dosyaya (`~/.config/uwsm/env.d/capture` gibi) şunu ekleyin:

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Aynı şeyi ekran kayıtları için `OMARCHY_SCREENRECORD_DIR` kullanarak da yapabilirsiniz.

Omasnap, ekran görüntüsü dizinini otomatik olarak oluşturur. Ekran kaydı dizinini kendiniz oluşturun, ardından herhangi bir ortam değişikliğinin geçerli olması için Omarchy'yi yeniden başlatın.

### Apple Studio Display'imde hoparlörleri + webcam'i nasıl çalıştırırım?

USB C'yi takınca her şeyin çalışması gerektiğini düşünürsünüz, ama maalesef durum böyle değil. Güvenilir şekilde çalışmasını sağlamak için bulduğum çözüm, [WJESOG DisplayPort + USB-A => USB-C kablosunu](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) kullanmaktır. O zaman hoparlörler ve webcam bir harika çalışıyor.

Omarchy'de Apple ekranlar (hem Studio hem de XDR) için normal klavye parlaklık tuşlarını kullanarak yerleşik parlaklık kontrolüne sahip olduğunuzu unutmayın.

### Tüm fazladan yazılımlardan nasıl kurtulurum?

Obsidian veya LibreOffice gibi programları veya önceden kurulmuş diğer şeylerden hiçbirini istemiyorsanız, bunları çok kolay bir şekilde kaldırabilirsiniz.

Kurulu olan her paketi görmek için _Kaldır > Paket_ çalıştırın. Ardından tab ile kaldırmak istediğiniz herhangi bir paketi seçebilir ve return ile seçtiğiniz her şeyi kaldırmaya başlayabilirsiniz.

Ve istemediğiniz önceden kurulmuş web uygulamalarından herhangi birini kaldırmak için Omarchy menüsünden _Kaldır > Web Uygulaması_'nı kullanabilirsiniz.

Veya önceden kurulmuş tüm ekstraları — web uygulamaları, TUI'lar ve isteğe bağlı uygulamalar — tek seferde süpürüp atmak için _Kaldır > Önceden Kurulanlar_ çalıştırın. Onları başlatan kısayol tuşları da onlarla birlikte gider, böylece `~/.config/hypr/bindings.lua` içinde kendinizinkilerle dolduracağınız temiz bir bağlama sayfasıyla kalırsınız.

---

Hatalar ve bozuk parçalar için bkz. [Sorun Giderme bölümü](45-troubleshooting.md).
