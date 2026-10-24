# Ağ

Omarchy'de ağ NetworkManager tarafından yönetilir ve bunu [menü çubuğundaki](05-the-top-bar.md) ağ simgesinden veya `Super + Ctrl + W` ile kullanırsınız.

Bu panel Wi-Fi ağlarını tarar, sinyal gücünü gösterir ve bağlanır. Ethernet'in hiçbir şeye ihtiyacı yoktur — takın ve çalışsın. Terminalde kalmayı tercih ederseniz, `nmtui` size aynı denetimleri verir ve bir de `omarchy network` komut grubu vardır.

## Wi-Fi'inizi paylaşma

Uzun bir parolayı sesli okumak yerine, Wi-Fi'a bağlıyken _Ayarlar > Ağ > QR Kodu_ yolunu çalıştırın. Bu, ekrana herhangi bir telefon kamerasının tarayarak katılabileceği bir QR kodu koyar. Orada olduğunu öğrendikten sonra sandığınızdan daha sık kullanacağınız şeylerden biridir.

Parolanın kendisine gerçekten ihtiyacınız varsa, `omarchy network password <interface>` komutu onu yazdırır.

## DNS

Omarchy, ağınızın DHCP üzerinden verdiği DNS'i kullanır. Bunu tüm makine için _Ayarlar > Ağ > DNS_ altında geçersiz kılabilirsiniz; burada Cloudflare ve Google tek tık uzağınızdadır. Kendi sunucularınızı yazmak için _Özel_ seçeneğini seçin.

Terminalden `omarchy dns` geçerli sağlayıcıyı yazdırır ve `omarchy dns Cloudflare` bir tanesini ayarlar.

## Wi-Fi bandını sabitleme

Yönlendiriciniz 2.4GHz, 5GHz ve 6GHz'i aynı ağ adına koyarsa, dizüstü bilgisayarınız bazen yavaş olana tutunur. `omarchy network band` hangi bantta olduğunuzu gösterir ve `omarchy network band 5` onu sabitler. Tekrar kendisinin seçmesine izin vermek için `auto` kullanın.

Bu, belirli bir erişim noktası yerine bandı sabitler, böylece erişim noktaları arasında normal şekilde dolaşmaya devam edersiniz.

## Ne kadar hızlı?

_Tetikle > Hız Testi > Ağ Hız Testi_ bir çift kadranla gerçek indirme ve yükleme hızınızı ölçer. Terminalden bu, `omarchy network speedtest down` veya `up` komutudur. (O menüde onun yanında bir disk hız testi de vardır, diğer darboğazı ölçüyorsanız bakabilirsiniz.)

## Güvenlik duvarı

Güvenlik duvarı varsayılan olarak açıktır ve gelen tüm trafiği engeller; tek istisna vardır: 53317 numaralı bağlantı noktası, böylece [LocalSend](22-guis.md) kutudan çıktığı gibi çalışır.

SSH, _Ayarlar > Güvenlik > SSHD_ ile açana kadar kapalıdır; bu, arka plan hizmetini başlatır, kaba kuvvet saldırılarına karşı hız sınırlı olarak 22 numaralı bağlantı noktasını açar ve bir anahtarı yetkilendirir. Docker da kilitlidir, böylece kapsayıcılar kendilerini yanlışlıkla dünyaya açamaz. Hikâyenin tamamı için [güvenlik](48-security.md) bölümüne bakın.

## Tailscale

[Tailscale](https://tailscale.com/), tüm bilgisayarlarınıza ve sunucularınıza internet üzerinden ulaşmayı basit ve güvenli hale getiren bir mesh VPN'dir. _Kur > Servis > Tailscale_ ile kurun.

Bu, size çubukta tailnet'e bağlanan ve bağlantıyı kesen, hesap değiştiren ve bir çıkış düğümü seçen bir Tailscale paneli verir — hem kendi makineleriniz hem de Mullvad bölgeleri listede görünür. Ayrıca makinelerinize göz atar ve Taildrop burada yaşar: bir makine seçin ve ona dosya göndermek için `s` tuşuna basın ya da IP'sini, adını veya tam DNS adını kopyalamak için `c`, `n` ve `d` tuşlarına basın. Terminal karşılığı `omarchy tailscale send <machine> [file...]` komutudur ve size gönderilen dosyalar otomatik olarak `~/Downloads` klasörüne düşer. Bir geliş haberini bildiren bildirim, siz tıklayıp açana veya kapatana kadar bekler; böylece siz makinenin başında değilken gelen bir dosya, geri döndüğünüzde yanıtlanmak üzere hâlâ orada olur.

Kurulum, Tailscale yönetim konsolu için bir web uygulaması da ekler.

## Çalışmayı durdurduğunda

Yeniden başlatmadan önce, sorun çıkaran parçayı kendi başına yeniden başlatmayı deneyin. _Güncelle > Donanım_ altında Wi-Fi, Bluetooth, Ses ve Dokunmatik Yüzey vardır ve bunlardan birini yeniden yüklemek, çoğu "beş dakika önce çalışıyordu" durumunu giderir. [Sorun giderme](45-troubleshooting.md) bölümüne bakın.
