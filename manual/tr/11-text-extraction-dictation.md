# Metin Çıkarma ve Dikte

### Metin Çıkarma

Metin çıkarmak için ekranda bir bölge seçmek üzere `Super + Ctrl + PrtScr` tuşlarına basın. Tesseract açık kaynak OCR modeli daha sonra bu seçimi hızla metne dönüştürür ve panoya yerleştirir. Ardından yapıştırmak için `Super + V` tuşlarına basmanız yeterlidir.

Bu, görüntü altbilgilerindeki adresleri veya web sitesi başlıklarına gömülü telefon numaralarını almak için çok kullanışlıdır.

 ![text-extraction](images/text-extraction.webp)

### Dikte

Yeni kurulumlarda, [Superwhisper](https://superwhisper.com/) varsayılan dikte arka ucudur ve çevrimdışı model indirmeleri olmadan bulut işlemeyi kullanır. Omarchy menüsünde _Setup > Defaults > Dictation_ üzerinden Superwhisper, [Voxtype](https://voxtype.io/) veya [Hex](https://anoma.ly/hex/) seçin. Bir arka uç seçmek, gerekirse onu kurar ve dikte için varsayılan yapar. Voxtype, 150MB yer kaplayan temel bir İngilizce model yükler; modeli `voxtype setup model` ile ve diğer ayarları `~/.config/voxtype/config.toml` üzerinden değiştirin. Superwhisper, bulut veya yerel işleme arasında seçim yapmak için ayarlarını açar ve OPR uygulamayı güncel tutar. Hex, cihaz üzerindeki konuşma modelini kurulum sırasında indirir ve `hex.service` kullanıcı hizmeti olarak çalışır; modeli ve diğer ayarları değiştirmek için penceresini çubuktaki tepsi simgesinden veya `hex` çalıştırarak açın.

`Right Alt` tuşunu basılı tutarak veya `Alt + Space` ile açıp kapatarak dikte edersiniz ve dikte edilen metin odaklanılan giriş alanında görünür. Bu kısayollar seçili arka ucu kullanır. Right Alt, bir değiştirici akorunda kullanıldığında da dikteyi başlatır; bu akorlar için Left Alt kullanın. Right Alt'ın AltGr olduğu klavye düzenlerinde, AltGr'yi yazmak için kullanılabilir tutmak üzere `Alt + Space` kullanın. Alt + Space varsayılan olmadan önceki kurulumlar, bas-konuş için `F9` ve açıp kapatmak için `Super + Ctrl + X` tuşlarını korur; bunlar `~/.config/hypr/bindings.lua` dosyasına eklenmiştir; bu tuşları uygulamalara geri vermek için onları oradan kaldırın.

Aynı kısayollar her arka uçla çalışır. Arka ucunuzu Setup > Defaults > Dictation üzerinden seçin. Arka uç yükleyicisi onu yapılandırır ve seçimi kaydeder. Hangisinin seçili olduğunu görmek için `omarchy default dictation` çalıştırın. Seçim `~/.config/omarchy/defaults/dictation` içinde saklanır. Yeni kurulumlar Superwhisper'ı otomatik olarak seçer.

Omarchy, seçili arka ucun masaüstü entegrasyonunu otomatik olarak yükler. `~/.config/hypr/` içinde Superwhisper yapılandırması gerekmez.

Özel bağlamalar ve betikler `omarchy dictation start`, `omarchy dictation stop` ve `omarchy dictation toggle` kullanabilir. Seçili arka uç kaydı ve transkripsiyonu gerçekleştirir. Superwhisper'ı seçmek, yerel basılı tutma kısayolunu devre dışı bırakır ve yerel açıp kapatma kısayolunu `Ctrl + Alt + Space` olarak ayarlar; böylece Omarchy'nin kayıt tuşlarından ayrı tutulur. Superwhisper en az bir yerel kayıt kısayolu gerektirir ve iptal kısayolu kullanılabilir durumda kalır.

Ek arka uçlar Omarchy'yi değiştirmeden entegre olabilir. PATH üzerinde, `start`, `stop` ve `toggle` kabul eden, hemen dönen ve hata durumunda sıfırdan farklı bir durumla dönen, `omarchy-dictation-<backend>` adlı bir çalıştırılabilir dosya sağlayın. Yükleyicisi sağlayıcıyı yapılandırır ve başarılı kurulumdan sonra `omarchy-dictation-use <backend>` çağırır. Bu, önceki arka ucu durdurur ve seçimi atomik olarak kaydeder; `stop`, sağlayıcı boşta veya kullanılamaz durumdayken başarılı olmalıdır. Arka uç adları küçük harfler, rakamlar ve kısa çizgiler kullanır. Kurulum için `omarchy-install-dictation-<backend>` sağlayın; `omarchy default dictation <backend>` onu başlatır. Bu seçiciyi çağırmak için bir Omarchy menü uzantısı aracılığıyla bir Defaults menü girdisi ekleyin. İsteğe bağlı masaüstü entegrasyonu `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` içinde yer alabilir.
