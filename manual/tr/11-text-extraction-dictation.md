# Metin Çıkarma ve Dikte

### Metin Çıkarma

Metin çıkarmak üzere ekranda bir bölge seçmek için `Super + Ctrl + PrtScr` tuşlarına basın. Açık kaynaklı tesseract OCR modeli daha sonra bu seçimi hızla metne dönüştürür ve panoya yerleştirir. Ardından yapıştırmak için `Super + V` tuşlarına basmanız yeterlidir.

Bu, resim altbilgilerindeki adresleri veya web sitesi başlıklarına gömülü telefon numaralarını kapmak için çok faydalıdır.

 ![text-extraction](images/text-extraction.webp)

### Dikte

Taze kurulumlarda, [Superwhisper](https://superwhisper.com/) varsayılan dikte arka ucudur ve çevrimdışı model indirmeleri olmadan bulut işleme kullanır. Omarchy menüsünde _Setup > Defaults > Dictation_ üzerinden Superwhisper, [Voxtype](https://voxtype.io/) veya [Hex](https://anoma.ly/hex/) arasından seçim yapın. Bir arka uç seçmek, gerekirse onu kurar ve dikte için varsayılan hâle getirir. Voxtype, 150MB yer kaplayan temel bir İngilizce model yükler; modeli `voxtype setup model` ile, diğer ayarları da `~/.config/voxtype/config.toml` üzerinden değiştirin. Superwhisper, bulut veya yerel işleme arasında seçim yapmak için ayarlarını açar ve OPR uygulamayı güncel tutar. Hex, cihaz üzerindeki konuşma modelini kurulum sırasında indirir ve `hex.service` kullanıcı hizmeti olarak çalışır; modeli ve diğer ayarları değiştirmek için penceresini çubuktaki tepsi simgesinden veya `hex` komutunu çalıştırarak açın.

Dikte etmek için `Right Alt` tuşunu basılı tutun veya `Alt + Space` ile geçiş yapın; dikte edilen metin, odaklanılan giriş alanında görünür. Bu kısayollar seçili arka ucu kullanır. Right Alt, bir değiştirici bileşimi içinde kullanıldığında da dikteyi başlatır; bu bileşimler için Left Alt kullanın. Right Alt tuşunun AltGr olduğu klavye düzenlerinde, geçiş yaptığınız düzenlerden biri böyle bir düzen olsa bile, dikte etmek için tuşu kendi başına bir an basılı tutun; başka bir tuşla birlikte basılan AltGr yine de kendi karakterini yazar. Alt + Space varsayılan olmadan önceki kurulumlar, bas-konuş için `F9` tuşunu ve geçiş yapmak için `Super + Ctrl + X` tuşlarını korur; bunlar `~/.config/hypr/bindings.lua` dosyasına eklenmiştir ve burada `Super + Ctrl + X`, agents panelinin yerini alır; bu tuşları uygulamalara ve panele geri vermek için bunları oradan kaldırın.

Aynı kısayollar her arka uçla çalışır. Arka ucunuzu Setup > Defaults > Dictation üzerinden seçin. Arka uç kurucusu onu yapılandırır ve seçimi kaydeder. Hangisinin seçili olduğunu görmek için `omarchy default dictation` komutunu çalıştırın. Seçim, `~/.config/omarchy/defaults/dictation` içinde saklanır. Taze kurulumlar Superwhisper'ı otomatik olarak seçer.

Omarchy, seçili arka ucun masaüstü entegrasyonunu otomatik olarak yükler. `~/.config/hypr/` içinde hiçbir Superwhisper yapılandırması gerekmez.

Özel tuş atamaları ve betikler `omarchy dictation start`, `omarchy dictation stop` ve `omarchy dictation toggle` komutlarını kullanabilir. Kaydı ve yazıya dökmeyi seçili arka uç üstlenir. Superwhisper'ı seçmek, onun yerel basılı tutma kısayolunu devre dışı bırakır ve yerel geçiş kısayolunu `Ctrl + Alt + Space` olarak ayarlar; böylece Omarchy'nin kayıt tuşlarından ayrı tutulur. Superwhisper en az bir yerel kayıt kısayolu gerektirir ve iptal kısayolu kullanılabilir durumda kalır.

Ek arka uçlar, Omarchy'yi değiştirmeden entegre olabilir. PATH üzerinde, `start`, `stop` ve `toggle` kabul eden, hemen dönen ve başarısızlık durumunda sıfırdan farklı bir durumla çıkan, `omarchy-dictation-<backend>` adlı bir çalıştırılabilir dosya sağlayın. Kurucusu sağlayıcıyı yapılandırır ve başarılı kurulumun ardından `omarchy-dictation-use <backend>` komutunu çağırır. Bu, önceki arka ucu durdurur ve seçimi atomik olarak kaydeder; sağlayıcı boşta veya kullanılamaz durumdayken `stop` başarılı olmalıdır. Arka uç adları küçük harfler, rakamlar ve tireler kullanır. Kurulum için `omarchy-install-dictation-<backend>` sağlayın; `omarchy default dictation <backend>` onu başlatır. Bu seçiciyi çağırmak üzere bir Omarchy menü uzantısı aracılığıyla bir Defaults menü girdisi ekleyin. İsteğe bağlı masaüstü entegrasyonu `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` içinde yer alabilir.
