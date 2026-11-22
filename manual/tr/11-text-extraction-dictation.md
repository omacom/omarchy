# Metin Çıkarma ve Dikte

### Metin Çıkarma

Metin çıkarma için ekranda bir bölge seçmek üzere `Super + Ctrl + PrtScr` tuşlarına basın. Açık kaynaklı tesseract OCR modeli daha sonra o seçimi hızla metne dönüştürür ve panoya yerleştirir. Ardından yapıştırmak için sadece `Super + V` tuşlarına basmanız yeterlidir.

Bu, görsel altbilgilerinden adresleri veya web sitesi başlıklarına gömülü telefon numaralarını kapmak için çok faydalıdır.

 ![text-extraction](images/text-extraction.webp)

### Dikte

Yeni kurulumlarda, [Superwhisper](https://superwhisper.com/) varsayılan dikte arka ucudur; çevrimdışı model indirmeleri olmadan bulut işlemeyi kullanır. Omarchy menüsünde _Setup > Defaults > Dictation_ üzerinden Superwhisper, [Voxtype](https://voxtype.io/) veya [Hex](https://anoma.ly/hex/) seçin. Bir arka uç seçmek, gerekirse onu kurar ve dikte için varsayılan yapar. Voxtype, 150MB yer kaplayan temel bir İngilizce model yükler; modeli `voxtype setup model` ile ve diğer ayarları `~/.config/voxtype/config.toml` üzerinden değiştirin. Superwhisper, bulut veya yerel işlemeden birini seçmek için ayarlarını açar ve OPR uygulamayı güncel tutar. Hex, kurulum sırasında cihazdaki konuşma modelini indirir ve `hex.service` kullanıcı hizmeti olarak çalışır; modeli ve diğer ayarları değiştirmek için penceresini çubuktaki tepsi simgesinden açın veya `hex` çalıştırın.

`Right Alt` tuşunu basılı tutarak veya `Alt + Space` ile geçiş yaparak dikte edersiniz ve dikte edilen metin odaklanılan giriş alanında görünür. Bu kısayollar seçili arka ucu kullanır. Right Alt, bir değiştirici akorunda kullanıldığında da dikteyi başlatır; bu akorlar için Left Alt kullanın. Right Alt'ın AltGr olduğu klavye düzenlerinde, AltGr'yi yazmak için kullanılabilir tutmak üzere `Alt + Space` kullanın. Alt + Space varsayılan olmadan önceki kurulumlar, bas-konuş için `F9` ve geçiş yapmak için `Super + Ctrl + X` tuşlarını korur; bunlar `~/.config/hypr/bindings.lua` dosyasına eklenmiştir ve burada `Super + Ctrl + X`, agents panelinin yerini alır; o tuşları uygulamalara ve panele geri vermek için bunları oradan kaldırın.

Aynı kısayollar her arka uçla çalışır. Arka ucunuzu Setup > Defaults > Dictation üzerinden seçin. Arka uç kurucusu onu yapılandırır ve seçimi kaydeder. Hangisinin seçili olduğunu görmek için `omarchy default dictation` çalıştırın. Seçim `~/.config/omarchy/defaults/dictation` içinde kaydedilir. Yeni kurulumlar Superwhisper'ı otomatik olarak seçer.

Omarchy, seçili arka ucun masaüstü entegrasyonunu otomatik olarak yükler. `~/.config/hypr/` içinde Superwhisper yapılandırmasına gerek yoktur.

Özel bağlamalar ve betikler `omarchy dictation start`, `omarchy dictation stop` ve `omarchy dictation toggle` kullanabilir. Seçili arka uç kaydı ve yazıya dökmeyi üstlenir. Superwhisper'ı seçmek, onun yerel basılı tutma kısayolunu devre dışı bırakır ve yerel geçişini `Ctrl + Alt + Space` olarak ayarlar; böylece Omarchy'nin kayıt tuşlarından ayrı kalır. Superwhisper en az bir yerel kayıt kısayolu gerektirir ve iptal kısayolu kullanılabilir durumda kalır.

Ek arka uçlar Omarchy'yi değiştirmeden entegre olabilir. PATH üzerinde, `start`, `stop` ve `toggle` kabul eden, hemen geri dönen ve başarısızlık durumunda sıfırdan farklı bir durumla dönen, `omarchy-dictation-<backend>` adlı çalıştırılabilir bir dosya sağlayın. Kurucusu sağlayıcıyı yapılandırır ve başarılı kurulumdan sonra `omarchy-dictation-use <backend>` çağırır. Bu, önceki arka ucu durdurur ve seçimi atomik olarak kaydeder; sağlayıcı boştayken veya kullanılamıyorken `stop` başarılı olmalıdır. Arka uç adları küçük harfler, rakamlar ve tireler kullanır. Kurulum için `omarchy-install-dictation-<backend>` sağlayın; `omarchy default dictation <backend>` onu başlatır. O seçiciyi çağırmak için bir Omarchy menü uzantısı aracılığıyla bir Defaults menü girdisi ekleyin. İsteğe bağlı masaüstü entegrasyonu `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` içinde bulunabilir.
