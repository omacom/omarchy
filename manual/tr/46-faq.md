# SSS

### Klavye düzeni arasında nasıl geçiş yaparım?

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

Çubuk, birden fazla düzeni yapılandırdıktan sonra geçerli klavye düzeninizi otomatik olarak gösterecektir (ve geçiş yapmak için ona tıklayabilirsiniz de).

### Saat biçimini 12 saate nasıl değiştiririm?

12 saatlik olanlar da dahil olmak üzere yaygın biçimler arasında geçiş yapmak için çubuktaki saate sağ tıklayın. Biçimi doğrudan da ayarlayabilirsiniz:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Bu, Pazar 10:55 AM gösterecektir.

### Saat dilimimi nasıl değiştiririm?

Omarchy menüsünde _Güncelle > Saat Dilimi_ yolunu çalıştırın ve listeden seçin. Saat dilimi doğru ama saatin kendisi kaymışsa, _Güncelle > Saat_ zaman eşitlemesini sizin için yeniden başlatır.

### DNS'imi nasıl değiştiririm, Wi-Fi'imi nasıl paylaşırım veya bağlantı hızımı nasıl kontrol ederim?

Bunların hepsi [ağ](35-networking.md) bölümünde yer alır.

### Diskimin ne kadar hızlı olduğunu nasıl kontrol ederim?

_Tetikle > Hız Testi > Disk Hız Testi_ sürücünüzdeki canlı okuma ve yazma hızını ölçer veya terminalden `omarchy disk speedtest` komutunu kullanabilirsiniz.

### Chromium'da neden Google hesabıma giriş yapamıyorum?

Sade açık kaynaklı Chromium yapısı, Google'ın hesap girişi için istediği OAuth kimlik bilgileriyle birlikte gelmez. Bunları eklemek için Omarchy menüsünde _Kur > Servis > Chromium Hesabı_ yolunu çalıştırın, tarayıcıyı yeniden başlatın ve giriş tamamlanacaktır.

### Nasıl yazıcı eklerim?

Yazdırma kutudan çıktığı gibi kurulu ve çalışır durumdadır ve her yazıcıyı uygulama başlatıcıdaki (`Super + Space`) _Yazdırma Ayarları_ üzerinden kendiniz eklersiniz.

_Ekle_ seçeneğini seçin ve bakması için bir an verin: USB üzerinden takılı bir yazıcı ve çoğu ağ yazıcısı sizin için bulunur. Sizinkisi listede yoksa, _Ağ Yazıcısı > Internet Printing Protocol (ipp)_ seçeneğini seçin ve adresini girin — yazıcının kendi ekranı veya web sayfası bunun ne olduğunu söyler, genellikle `ipp/print` kuyruğuyla `192.168.1.50` gibi bir şeydir. _İleri_ ardından bir sürücü sunar; burada modern bir yazıcı sürücüsüz _IPP Everywhere_ profilinde en iyi sonucu verir ve daha eski biri modelin kendi sürücüsünü ister.

Bir yazıcıya sağ tıklayın ve uygulamalarınızın önce hangisine ulaşacağını seçmek için _Varsayılan Olarak Ayarla_ seçeneğini, kâğıt boyutunu, çift yönlü yazdırmayı ve kaliteyi ayarlamak için _Özellikler_ seçeneğini seçin.

Ağdaki yazıcıların eklenmeden göründüğü otomatik keşif, yeniden çalışılırken geçici olarak kapalıdır; bu yüzden yukarıdaki ilk adım otomatik yerine sizindir. Bir PDF dosyasına yazdırmak, hiç yazıcı olmadan çalışır.

### Ekran görüntülerinin veya ekran kayıtlarının nereye kaydedileceğini nasıl değiştiririm?

Kaydedilen ekran görüntüleri varsayılan olarak `~/Pictures/Screenshots` klasörüne gider. Başka bir dizin kullanmak için, bunu `~/.config/uwsm/env.d/` altında bir dosyaya (örneğin `~/.config/uwsm/env.d/capture` gibi) ekleyin:

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Aynısını ekran kayıtları için `OMARCHY_SCREENRECORD_DIR` kullanarak yapabilirsiniz.

Omasnap ekran görüntüsü dizinini otomatik olarak oluşturur. Ekran kaydı dizinini kendiniz oluşturun, ardından herhangi bir ortam değişikliğinin etkili olması için Omarchy'yi yeniden başlatın.

### Apple Studio Display'imde hoparlörleri + web kamerasını nasıl çalıştırabilirim?

Her şeyin yalnızca USB C takılarak çalışması gerektiğini düşünürsünüz, ancak ne yazık ki durum böyle değildir. Güvenilir şekilde çalışması için bulduğum çözüm [WJESOG DisplayPort + USB-A => USB-C kablosunu](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) kullanmaktır. Ardından hoparlörler ve web kamerası kusursuz çalışır.

Normal klavye parlaklık düğmelerini kullanarak Apple Ekranları (hem Studio hem de XDR) için Omarchy'de yerleşik parlaklık denetiminiz olduğunu unutmayın.

### Tüm ekstra yazılımlardan nasıl kurtulurum?

Obsidian veya LibreOffice gibi programları veya önceden kurulu başka şeylerden hiçbirini istemiyorsanız, onları çok kolay bir şekilde kaldırabilirsiniz.

Kurulu olan her paketi görmek için _Kaldır > Paket_ yolunu çalıştırın. Ardından kaldırmak istediğiniz herhangi bir paketi tab tuşuyla seçebilir ve return tuşuyla seçtiğiniz her şeyi kaldırmaya başlayabilirsiniz.

Ve istemediğiniz önceden kurulu web uygulamalarından herhangi birini kaldırmak için Omarchy menüsünden _Kaldır > Web Uygulaması_ yolunu kullanabilirsiniz.

Veya tüm önceden kurulu ekstraları — web uygulamaları, TUI'ler ve isteğe bağlı uygulamalar — tek seferde süpürmek için _Kaldır > Önceden Kurulanlar_ yolunu çalıştırın. Onları başlatan kısayollar onlarla birlikte gider, böylece `~/.config/hypr/bindings.lua` içinde kendinizinkilerle doldurmak üzere temiz bir bağlama sayfasıyla kalırsınız.

---

Hatalar ve bozuk parçalar için [Sorun Giderme bölümüne](45-troubleshooting.md) bakın.
