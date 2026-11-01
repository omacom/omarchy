# Ağ

Omarchy'de ağ bağlantısı NetworkManager tarafından yönetilir ve bunu [üst çubuktaki](05-the-top-bar.md) ağ simgesinden ya da `Super + Ctrl + N` ile kontrol edersiniz.

Bu panel Wi-Fi ağlarını tarar, sinyal gücünü gösterir ve bağlantı kurar. Ethernet için hiçbir şey gerekmez — kabloyu takın ve çalışır. Terminalde kalmayı tercih ederseniz, `nmtui` size aynı kontrolleri sunar ve bir de `omarchy network` komut grubu vardır.

## Wi-Fi'nizi paylaşma

Uzun bir parolayı yüksek sesle okumak yerine, Wi-Fi'ye bağlıyken _Setup > Network > QR Code_ yolunu çalıştırın. Bu, herhangi bir telefon kamerasının tarayarak katılabileceği bir QR kodunu ekrana getirir. Varlığını öğrendikten sonra beklediğinizden daha sık kullanacağınız şeylerden biridir.

Parolanın kendisine gerçekten ihtiyacınız varsa, `omarchy network password <interface>` onu yazdırır.

## DNS

Omarchy, ağınızın DHCP üzerinden verdiği DNS'i kullanır. Bunu tüm makine için _Setup > Network > DNS_ altında geçersiz kılabilirsiniz; burada Cloudflare ve Google tek tık uzağınızdadır. Kendi sunucularınızı yazmak için _Custom_ seçeneğini seçin.

Terminalden, `omarchy dns` geçerli sağlayıcıyı yazdırır ve `omarchy dns Cloudflare` birini ayarlar.

## Wi-Fi bandını sabitleme

Yönlendiriciniz 2.4GHz, 5GHz ve 6GHz'i aynı ağ adı altında sunuyorsa, dizüstü bilgisayarınız bazen yavaş olana tutunur. `omarchy network band` hangi bantta olduğunuzu gösterir ve `omarchy network band 5` onu sabitler. Tekrar kendisinin seçmesine izin vermek için `auto` kullanın.

Bu, belirli bir erişim noktasını değil bandı sabitler, böylece AP'ler arasında normal şekilde dolaşmaya devam edersiniz.

## Ne kadar hızlı?

_Trigger > Speed Test > Network Speed Test_ gerçek indirme ve yükleme hızınızı bir çift göstergeyle ölçer. Terminalden, `omarchy network speedtest down` ya da `up` ile yapılır. Omarchy'nin kendi servisine karşı ölçüm yapar ve yalnızca kendi test aktarımlarını sayar. Diğer indirmeler bant genişliği için rekabet edebilir, ancak hız testi sonucuna eklenmezler. (Diğer darboğazı ölçüyorsanız, o menüde hemen yanında bir disk hız testi de bulunur.)

## Güvenlik duvarı

Güvenlik duvarı varsayılan olarak açıktır ve gelen tüm trafiği engeller; tek bir istisnayla: 53317 numaralı port, böylece [LocalSend](22-guis.md) kutudan çıktığı gibi çalışır.

SSH, _Setup > Security > SSHD_ ile açana kadar kapalıdır; bu, daemon'ı başlatır, 22 numaralı portu kaba kuvvet saldırılarına karşı hız sınırlı olarak açar ve bir anahtarı yetkilendirir. Docker da kilit altındadır, böylece konteynerler kendilerini yanlışlıkla dünyaya açamaz. Hikayenin tamamı için bkz. [güvenlik](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/), tüm bilgisayarlarınıza ve sunucularınıza internet üzerinden ulaşmayı basit ve güvenli hale getiren bir mesh VPN'dir. _Install > Service > Tailscale_ ile kurun.

Bu size çubukta bir Tailscale paneli verir; bu panel tailnet'e bağlanır ve bağlantıyı keser, hesap değiştirir ve bir çıkış düğümü seçer — kendi makineleriniz de Mullvad bölgeleri de listede görünür. Ayrıca makinelerinize göz atar ve Taildrop'un yaşadığı yer de burasıdır: bir makine seçin ve ona dosya göndermek için `s` tuşuna basın ya da IP'sini, adını veya tam DNS adını kopyalamak için `c`, `n` ve `d` tuşlarına basın. Terminaldeki karşılığı `omarchy tailscale send <machine> [file...]` komutudur ve size gönderilen dosyalar otomatik olarak `~/Downloads` klasörüne iner. Bir varışı duyuran bildirim, siz tıklayarak açana ya da kapatana kadar bekler, böylece makineden uzaktayken gelen bir dosya, geri döndüğünüzde hâlâ yanıtınızı bekler.

Kurulum, Tailscale yönetim konsolu için bir web uygulaması da ekler.

## Çalışmayı bıraktığında

Yeniden başlatmadan önce, sorunlu parçayı tek başına yeniden başlatmayı deneyin. _Update > Hardware_ altında Wi-Fi, Bluetooth, Audio ve Trackpad bulunur ve bunlardan birini yeniden yüklemek çoğu "beş dakika önce çalışıyordu" durumunu düzeltir. Bkz. [sorun giderme](45-troubleshooting.md).
