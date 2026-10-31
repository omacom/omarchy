# Metin Çıkarma ve Dikte

### Metin Çıkarma

Metin çıkarma için ekranda bir bölge seçmek üzere `Super + Ctrl + PrtScr` tuşlarına basın. tesseract açık kaynak OCR modeli daha sonra bu seçimi hızla metne dönüştürür ve panoya yerleştirir. Ardından yapıştırmak için `Super + V` tuşlarına basmanız yeterlidir.

Bu, görsel alt bilgilerinin içindeki adresleri ya da web sitesi başlıklarına gömülmüş telefon numaralarını kapmak için çok faydalıdır.

 ![text-extraction](images/text-extraction.webp)

### Dikte

Yeni kurulumlarda, [Superwhisper](https://superwhisper.com/) varsayılan dikte arka ucudur ve çevrimdışı model indirmeleri olmadan bulut işleme kullanır. Superwhisper ya da [Voxtype](https://voxtype.io/) arasında Omarchy menüsünde _Kurulum > Varsayılanlar > Dikte_ üzerinden seçim yapın. Bir arka uç seçildiğinde, gerekirse arka uç kurulur ve dikte için varsayılan hâline getirilir. Voxtype, 150MB yer kaplayan temel bir İngilizce model yükler; modeli `voxtype setup model` ile, diğer ayarları ise `~/.config/voxtype/config.toml` üzerinden değiştirin. Superwhisper, bulut ya da yerel işlemeyi seçmeniz için ayarlarını açar ve OPR uygulamayı güncel tutar.

`Right Alt` tuşunu basılı tutarak ya da `Alt + Space` ile geçiş yaparak dikte edersiniz ve dikte edilen metin, odaklanılan giriş alanında belirir. Bu kısayollar seçili arka ucu kullanır. Right Alt, bir değiştirici kombinasyonu içinde kullanıldığında da dikteyi başlatır; bu kombinasyonlar için Left Alt kullanın. Right Alt'ın AltGr olarak görev yaptığı klavye düzenlerinde, AltGr'yi yazmak için kullanılabilir tutmak amacıyla `Alt + Space` kullanın. Alt + Space'in varsayılan hâline gelmesinden önceki kurulumlar, bas-konuş için `F9` ve geçiş için `Super + Ctrl + X` kısayollarını `~/.config/hypr/bindings.lua` dosyasına eklenmiş hâlde korur; bu tuşları uygulamalara geri vermek için bunları oradan kaldırın.

Aynı kısayollar iki arka uçla da çalışır. Arka ucunuzu Kurulum > Varsayılanlar > Dikte üzerinden seçin. Arka uç kurucusu arka ucu yapılandırır ve seçimi kaydeder. Hangisinin seçili olduğunu görmek için `omarchy default dictation` komutunu çalıştırın. Seçim, `~/.config/omarchy/defaults/dictation` içinde kaydedilir. Yeni kurulumlar Superwhisper'ı otomatik olarak seçer.

Omarchy, seçili arka ucun masaüstü entegrasyonunu otomatik olarak yükler. `~/.config/hypr/` içinde Superwhisper yapılandırmasına gerek yoktur.

Özel bağlamalar ve betikler `omarchy dictation start`, `omarchy dictation stop` ve `omarchy dictation toggle` komutlarını kullanabilir. Kaydı ve yazıya dökmeyi seçili arka uç gerçekleştirir. Superwhisper seçildiğinde, kendi basılı tutma kısayolu devre dışı bırakılır ve kendi geçiş kısayolu `Ctrl + Alt + Space` olarak ayarlanır; böylece Omarchy'nin kayıt tuşlarından ayrı kalır. Superwhisper en az bir yerel kayıt kısayolu gerektirir ve iptal kısayolu kullanılabilir durumda kalır.

Ek arka uçlar, Omarchy'yi değiştirmeden entegre olabilir. PATH üzerinde, `start`, `stop` ve `toggle` komutlarını kabul eden, hemen dönen ve hata durumunda sıfırdan farklı bir durumla dönen, `omarchy-dictation-<backend>` adlı bir çalıştırılabilir dosya sağlayın. Kurucusu sağlayıcıyı yapılandırır ve başarılı kurulumun ardından `omarchy-dictation-use <backend>` komutunu çağırır. Bu, önceki arka ucu durdurur ve seçimi atomik olarak kaydeder; `stop`, sağlayıcı boştayken ya da kullanılamazken de başarılı olmalıdır. Arka uç adlarında küçük harfler, rakamlar ve tireler kullanılır. Kurulum için `omarchy-install-dictation-<backend>` sağlayın; `omarchy default dictation <backend>` bunu başlatır. Bu seçiciyi çağırmak için bir Omarchy menü uzantısı aracılığıyla Varsayılanlar menüsüne bir giriş ekleyin. İsteğe bağlı masaüstü entegrasyonu `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` içinde bulunabilir.
