# SSS

### Klavye düzenleri arasında nasıl geçiş yaparım?

`~/.config/hypr/input.lua` dosyanızı düzenleyin ve `Left Alt + Right Alt` ile düzenler arasında geçiş yapmak için bunu ekleyin:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Birden fazla düzen yapılandırdığınızda çubuk geçerli klavye düzeninizi otomatik olarak gösterir (ve geçiş yapmak için üzerine de tıklayabilirsiniz).

### Saat biçimini 12 saatlik biçime nasıl değiştiririm?

12 saatlik biçimler de dahil olmak üzere yaygın biçimler arasında geçiş yapmak için çubuktaki saate sağ tıklayın. Biçimi doğrudan da ayarlayabilirsiniz:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Bu, Pazar 10:55 AM olarak görüntülenir.

### Saat dilimimi nasıl değiştiririm?

Omarchy menüsünde _Setup > Region > Timezone_ seçeneğini çalıştırın ve listeden seçiminizi yapın. Saat dilimi doğruysa ancak saatin kendisi kaymışsa, _Update > Time_ zaman senkronizasyonunu sizin için yeniden başlatır.

### DNS'imi nasıl değiştiririm, Wi-Fi'ımı nasıl paylaşırım veya bağlantı hızımı nasıl kontrol ederim?

Bunların hepsi [ağ](35-networking.md) bölümünde yer alır.

### Diskimin ne kadar hızlı olduğunu nasıl kontrol ederim?

_Trigger > Speed Test > Disk Speed Test_, sürücünüzdeki canlı okuma ve yazma hızını ölçer veya terminalden `omarchy disk speedtest` kullanabilirsiniz.

### Yazıcı nasıl eklerim?

Yazdırma, kutudan çıktığı gibi kurulu ve çalışır durumdadır ve her yazıcıyı uygulama başlatıcıdaki (`Super + Alt + Space`) _Print Settings_ üzerinden kendiniz eklersiniz.

_Add_ seçeneğini seçin ve araması için bir süre bekleyin: USB üzerinden bağlanan bir yazıcı ve çoğu ağ yazıcısı sizin için bulunur. Sizinki listede yoksa, _Network Printer > Internet Printing Protocol (ipp)_ seçeneğini seçin ve adresini girin — yazıcının kendi ekranı veya web sayfası bunun ne olduğunu size söyler, genellikle `ipp/print` kuyruğuyla birlikte `192.168.1.50` gibi bir şeydir. _Forward_ ardından bir sürücü sunar; burada modern bir yazıcı sürücüsüz _IPP Everywhere_ profiliyle en iyi şekilde çalışırken, daha eski bir yazıcı modelin kendi sürücüsünü ister.

Hangi yazıcıya uygulamalarınızın ilk olarak ulaşacağını seçmek için bir yazıcıya sağ tıklayıp _Set as Default_ seçeneğini, kağıt boyutunu, çift taraflı yazdırmayı ve kaliteyi ayarlamak için ise _Properties_ seçeneğini seçin.

Ağdaki yazıcıların eklenmeden göründüğü otomatik keşif, yeniden düzenlenirken geçici olarak kapatılmıştır; bu yüzden yukarıdaki ilk adım otomatik değil, sizin yapmanız gereken bir adımdır. Bir PDF dosyasına yazdırmak, hiç yazıcı olmadan da çalışır.

### Ekran görüntülerinin veya ekran kayıtlarının kaydedildiği yeri nasıl değiştiririm?

Kaydedilen ekran görüntüleri varsayılan olarak `~/Pictures/Screenshots` konumuna gider. Başka bir dizin kullanmak için bunu `~/.config/uwsm/env.d/` altındaki bir dosyaya (örneğin `~/.config/uwsm/env.d/capture`) ekleyin:

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Aynısını ekran kayıtları için `OMARCHY_SCREENRECORD_DIR` kullanarak da yapabilirsiniz.

Omasnap, ekran görüntüsü dizinini otomatik olarak oluşturur. Ekran kaydı dizinini kendiniz oluşturun, ardından ortam değişikliklerinden herhangi birinin geçerli olması için Omarchy'yi yeniden başlatın.

### Apple Studio Display'de hoparlörleri ve web kamerasını nasıl çalıştırırım?

USB C'yi takmanızın her şeyin çalışması için yeterli olacağını düşünürsünüz, ancak ne yazık ki durum böyle değil. Güvenilir şekilde çalışmasını sağlamak için bulduğum çözüm, [WJESOG DisplayPort + USB-A => USB-C kablosunu](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) kullanmak. Ardından hoparlörler ve web kamerası sorunsuz çalışıyor.

Omarchy'de Apple Display'ler (hem Studio hem de XDR) için normal klavye parlaklık düğmelerini kullanarak yerleşik parlaklık kontrolüne sahip olduğunuzu unutmayın.

### Tüm fazladan yazılımlardan nasıl kurtulurum?

Obsidian veya LibreOffice gibi programları ya da önceden yüklenmiş diğer şeylerden herhangi birini istemiyorsanız, bunları çok kolay bir şekilde kaldırabilirsiniz.

Yüklü olan her paketi görmek için _Remove > Package_ seçeneğini çalıştırın. Ardından tab ile kaldırmak istediğiniz herhangi bir paketi seçebilir ve return ile seçtiğiniz her şeyi kaldırmaya başlayabilirsiniz.

Ayrıca istemediğiniz önceden yüklenmiş web uygulamalarından herhangi birini kaldırmak için Omarchy menüsünden _Remove > Web App_ seçeneğini kullanabilirsiniz.

Veya önceden yüklenmiş tüm ekstraları — web uygulamaları, TUI'ler ve isteğe bağlı uygulamalar — tek seferde süpürmek için _Remove > Preinstalls_ seçeneğini çalıştırın. Bunları başlatan kısayol tuşları da onlarla birlikte gider, böylece `~/.config/hypr/bindings.lua` içinde kendi kısayollarınızla dolduracağınız temiz bir bağlama sayfasıyla baş başa kalırsınız.

---

Hatalar ve bozuk şeyler için [Sorun Giderme bölümüne](45-troubleshooting.md) bakın.
