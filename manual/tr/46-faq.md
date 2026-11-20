# SSS

### Klavye düzenleri arasında nasıl geçiş yaparım?

`Left Alt + Right Alt` ile düzenler arasında geçiş yapmak için `~/.config/hypr/input.lua` dosyanızı düzenleyin ve şunu ekleyin:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Birden fazla düzen yapılandırdıktan sonra bar, geçerli klavye düzeninizi otomatik olarak gösterir (ve geçiş yapmak için üzerine de tıklayabilirsiniz).

### Saatin biçimini 12 saatlik biçime nasıl değiştiririm?

12 saatlik biçimler de dahil olmak üzere yaygın biçimler arasında geçiş yapmak için bardaki saate sağ tıklayın. Biçimi doğrudan da ayarlayabilirsiniz:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Bu, Pazar 10:55 AM olarak görüntülenir.

### Saat dilimimi nasıl değiştiririm?

Omarchy menüsünde _Setup > Region > Timezone_ öğesini çalıştırın ve listeden seçin. Saat dilimi doğruysa ama saatin kendisi kaymışsa, _Update > Time_ saat senkronizasyonunu sizin için yeniden başlatır.

### DNS'imi nasıl değiştiririm, Wi-Fi'ımı nasıl paylaşırım veya bağlantı hızımı nasıl kontrol ederim?

Bunların hepsi [ağ bağlantıları](35-networking.md) bölümünde yer alır.

### Diskimin ne kadar hızlı olduğunu nasıl kontrol ederim?

_Trigger > Speed Test > Disk Speed Test_, sürücünüzde canlı okuma ve yazma hızını ölçer ya da terminalden `omarchy disk speedtest` çalıştırabilirsiniz.

### Nasıl yazıcı eklerim?

Yazdırma kutudan çıkar çıkmaz kurulu ve çalışır durumdadır ve her yazıcıyı uygulama başlatıcıdaki (`Super + Space`) _Print Settings_ üzerinden kendiniz eklersiniz.

_Add_ öğesini seçin ve araması için bir an verin: USB üzerinden takılı bir yazıcı ve çoğu ağ yazıcısı sizin için bulunur. Sizinki listede yoksa, _Network Printer > Internet Printing Protocol (ipp)_ öğesini seçin ve adresini girin — yazıcının kendi ekranı veya web sayfası bunun ne olduğunu söyler, genellikle kuyruğu `ipp/print` olan `192.168.1.50` gibi bir şeydir. _Forward_ ardından bir sürücü sunar; burada modern bir yazıcı en iyi sürücüsüz _IPP Everywhere_ profiliyle çalışır ve eski bir yazıcı modelin kendi sürücüsünü ister.

Bir yazıcıya sağ tıklayın ve uygulamalarınızın ilk önce hangisine ulaşacağını seçmek için _Set as Default_ öğesini, kağıt boyutunu, çift taraflı baskıyı ve kaliteyi ayarlamak için _Properties_ öğesini seçin.

Ağdaki yazıcıların eklenmeden göründüğü otomatik bulma, yeniden düzenlenirken geçici olarak kapatılmıştır; bu yüzden yukarıdaki ilk adım otomatik olmak yerine size kalmıştır. Herhangi bir yazıcı olmadan da bir PDF dosyasına yazdırabilirsiniz.

### Ekran görüntülerinin veya ekran kayıtlarının kaydedileceği yeri nasıl değiştiririm?

Kaydedilen ekran görüntüleri varsayılan olarak `~/Pictures/Screenshots` konumuna gider. Başka bir dizin kullanmak için, `~/.config/uwsm/env.d/` altında bir dosyaya (örneğin `~/.config/uwsm/env.d/capture`) şunu ekleyin:

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Aynı şeyi ekran kayıtları için `OMARCHY_SCREENRECORD_DIR` kullanarak yapabilirsiniz.

Omasnap, ekran görüntüsü dizinini otomatik olarak oluşturur. Ekran kaydı dizinini kendiniz oluşturun, ardından her iki ortam değişikliğinin de etkili olması için Omarchy'yi yeniden başlatın.

### Apple Studio Display'imde hoparlörleri + web kamerasını nasıl çalıştırırım?

USB C'yi takmanızın yetmesi gerektiğini düşünürsünüz ama ne yazık ki öyle değil. Güvenilir şekilde çalışmasını sağlamak için bulduğum çözüm, [WJESOG DisplayPort + USB-A => USB-C kablosunu](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) kullanmak. Sonra hoparlörler ve web kamerası tıkır tıkır çalışıyor.

Omarchy'de Apple Display'ler (hem Studio hem de XDR) için normal klavye parlaklık düğmelerini kullanarak yerleşik parlaklık kontrolünüz olduğunu unutmayın.

### Tüm ekstra yazılımlardan nasıl kurtulurum?

Obsidian veya LibreOffice gibi programları ya da önceden kurulu diğer şeylerden herhangi birini istemiyorsanız, bunları çok kolayca kaldırabilirsiniz.

Kurulu her paketi görmek için _Remove > Package_ öğesini çalıştırın. Ardından kaldırmak istediğiniz herhangi bir paketi tab ile seçebilir ve return ile seçtiğiniz her şeyi kaldırmaya başlayabilirsiniz.

Ve istemediğiniz önceden kurulu web uygulamalarından herhangi birini kaldırmak için Omarchy menüsünden _Remove > Web App_ öğesini kullanabilirsiniz.

Ya da önceden kurulu tüm ekstraları — web uygulamaları, TUI'ler ve isteğe bağlı uygulamalar — tek seferde süpürmek için _Remove > Preinstalls_ öğesini çalıştırın. Bunları başlatan kısayol tuşları da onlarla birlikte gider, böylece `~/.config/hypr/bindings.lua` içinde kendi kısayollarınızla dolduracağınız temiz bir bağlama listesi kalır.

---

Hatalar ve bozuk parçalar için [Sorun Giderme bölümüne](45-troubleshooting.md) bakın.
