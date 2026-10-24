# Metin Çıkarma ve Dikte

### Metin Çıkarma

Metin çıkarmak için ekranda bir bölge seçmek üzere `Super + Ctrl + PrtScr` tuşuna basın. Açık kaynak tesseract OCR modeli daha sonra bu seçimi hızla metne dönüştürür ve panoya yerleştirir. Ardından yapıştırmak için `Super + V` tuşuna basmanız yeterlidir.

Bu, görsel alt bilgilerinden adresleri veya web sitesi başlıklarına gömülü telefon numaralarını almak için çok yararlıdır.

 ![text-extraction](images/text-extraction.webp)

### Dikte

Yeni kurulumlarda, [Superwhisper](https://superwhisper.com/) varsayılan dikte arka ucudur ve çevrimdışı model indirmeleri olmadan bulut işlemeyi kullanır. Omarchy menüsündeki _Ayarlar > Varsayılanlar > Dikte_ yoluyla Superwhisper veya [Voxtype](https://voxtype.io/) arasında seçim yapın. Bir arka uç seçmek, gerekirse onu kurar ve dikte için varsayılan yapar. Voxtype, 150MB yer kaplayan temel bir İngilizce model yükler; modeli `voxtype setup model` ile ve diğer ayarları `~/.config/voxtype/config.toml` yoluyla değiştirin. Superwhisper, bulut veya yerel işlemeyi seçmek için ayarlarını açar ve OPR uygulamayı güncel tutar.

`Right Alt` veya `F9` tuşuna basılı tutarak ya da `Super + Ctrl + X` ile açıp kapatarak dikte edersiniz ve dikte edilen metin odaklanmış girdi alanında görünür. Bu kısayollar seçili arka ucu kullanır. Right Alt, bir değiştirici akorunda kullanıldığında da dikteyi başlatır; bu akorlar için Left Alt'ı kullanın. Right Alt'ın AltGr olduğu klavye düzenlerinde, AltGr'ı yazmak için kullanılabilir tutmak üzere `F9` tuşunu kullanın.

Aynı kısayollar her iki arka uçla da çalışır. Arka ucunuzu Ayarlar > Varsayılanlar > Dikte yoluyla seçin. Arka uç kurulumcusu onu yapılandırır ve seçimi kaydeder. Hangisinin seçili olduğunu görmek için `omarchy default dictation` çalıştırın. Seçim `~/.config/omarchy/defaults/dictation` içinde saklanır. Yeni kurulumlar Superwhisper'ı otomatik olarak seçer.

Omarchy, seçili arka ucun masaüstü entegrasyonunu otomatik olarak yükler. `~/.config/hypr/` içinde Superwhisper yapılandırmasına gerek yoktur.

Özel bağlamalar ve betikler `omarchy dictation start`, `omarchy dictation stop` ve `omarchy dictation toggle` kullanabilir. Seçili arka uç kaydı ve transkripsiyonu gerçekleştirir. Superwhisper'ı seçmek, onun yerel basılı tutma kısayolunu devre dışı bırakır ve yerel aç/kapat kısayolunu `Alt + Space` olarak ayarlayarak onu Omarchy'nin kayıt tuşlarından ayrı tutar. Superwhisper en az bir yerel kayıt kısayolu gerektirir ve iptal kısayolu kullanılabilir kalır.

Ek arka uçlar Omarchy'yi değiştirmeden entegre olabilir. PATH üzerinde, `start`, `stop` ve `toggle` kabul eden, derhal dönen ve başarısızlıkta sıfırdan farklı bir durum veren `omarchy-dictation-<backend>` adlı bir çalıştırılabilir sağlayın. Kurulumcusu sağlayıcıyı yapılandırır ve başarılı kurulumun ardından `omarchy-dictation-use <backend>` çağırır. Bu, önceki arka ucu durdurur ve seçimi atomik olarak kaydeder; sağlayıcı boşta veya kullanılamadığında `stop` başarılı olmalıdır. Arka uç adları küçük harf, rakam ve kısa çizgi kullanır. Kurulum için `omarchy-install-dictation-<backend>` sağlayın; `omarchy default dictation <backend>` onu başlatır. Bu seçiciyi çağırmak için bir Omarchy menü uzantısı yoluyla bir Varsayılanlar menü girdisi ekleyin. İsteğe bağlı masaüstü entegrasyonu `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` içinde yaşayabilir.
