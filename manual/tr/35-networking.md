# Ağ

Omarchy'de ağ işleri NetworkManager tarafından yürütülür ve bunu [üst çubuk](05-the-top-bar.md) içindeki ağ simgesinden ya da `Super + Ctrl + N` ile yönetirsiniz.

Bu panel Wi-Fi ağlarını tarar, sinyal gücünü gösterir ve bağlanır. Ethernet'in hiçbir şeye ihtiyacı yoktur — takın ve çalışsın. Terminalde kalmayı tercih ederseniz, `nmtui` size aynı kontrolleri sunar ve bir de `omarchy network` komut grubu vardır.

## Wi-Fi'nizi paylaşma

Uzun bir parolayı sesli okumak yerine, Wi-Fi'a bağlıyken _Kurulum > Ağ > QR Code_ yolunu çalıştırın. Bu, herhangi bir telefon kamerasının tarayarak katılabileceği bir QR kodunu ekrana getirir. Varlığını öğrendikten sonra beklediğinizden daha sık kullanacağınız şeylerden biridir.

Parolanın kendisine gerçekten ihtiyacınız varsa, `omarchy network password <interface>` onu yazdırır.

## DNS

Omarchy, ağınızın DHCP üzerinden verdiği DNS'i kullanır. Bunu tüm makine için _Kurulum > Ağ > DNS_ altında geçersiz kılabilirsiniz; burada Cloudflare ve Google tek tık uzağınızdadır. Kendi sunucularınızı yazmak için _Özel_ seçeneğini seçin.

Terminalden, `omarchy dns` geçerli sağlayıcıyı yazdırır ve `omarchy dns Cloudflare` birini ayarlar.

## Wi-Fi bandını sabitleme

Yönlendiriciniz 2.4GHz, 5GHz ve 6GHz'i aynı ağ adında sunuyorsa, dizüstü bilgisayarınız bazen yavaş olana tutunur. `omarchy network band` hangi bantta olduğunuzu gösterir ve `omarchy network band 5` onu sabitler. Yeniden kendisinin seçmesine izin vermek için `auto` kullanın.

Bu, belirli bir erişim noktası yerine bandı sabitler, böylece AP'ler arasında normal şekilde dolaşmaya devam edersiniz.

## Ne kadar hızlı?

_Tetikleyici > Hız Testi > Ağ Hız Testi_ gerçek yükleme ve indirme hızınızı bir çift göstergeyle ölçer. Terminalden bu, `omarchy network speedtest down` veya `up` komutudur. (Diğer darboğazı ölçüyorsanız, o menüde hemen yanında bir disk hız testi de bulunur.)

## Güvenlik duvarı

Güvenlik duvarı varsayılan olarak açıktır ve tek bir istisna dışında tüm gelen trafiği engeller: 53317 numaralı bağlantı noktası, böylece [LocalSend](22-guis.md) kutudan çıktığı gibi çalışır.

SSH, _Kurulum > Güvenlik > SSHD_ ile açana kadar kapalıdır; bu, arka plan hizmetini başlatır, kaba kuvvete karşı hız sınırlamalı olarak 22 numaralı bağlantı noktasını açar ve bir anahtarı yetkilendirir. Docker da kilitlidir, böylece kapsayıcılar kendilerini yanlışlıkla dünyaya açamaz. Hikayenin tamamı için bkz. [güvenlik](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/), tüm bilgisayarlarınıza ve sunucularınıza internet üzerinden ulaşmayı basit ve güvenli hale getiren bir mesh VPN'dir. _Kur > Hizmet > Tailscale_ ile kurun.

Bu size çubukta bir Tailscale paneli verir; bu panel tailnet'e bağlanır ve bağlantısını keser, hesap değiştirir ve bir çıkış düğümü seçer — kendi makineleriniz ve Mullvad bölgelerinizin her ikisi de listede görünür. Ayrıca makinelerinize göz atar ve Taildrop da orada yaşar: bir makine seçin ve ona dosya göndermek için `s` tuşuna, ya da IP'sini, adını veya tam DNS adını kopyalamak için `c`, `n` ve `d` tuşlarına basın. Terminaldeki karşılığı `omarchy tailscale send <machine> [file...]` komutudur ve size gönderilen dosyalar otomatik olarak `~/Downloads` içine düşer. Bir gelişin haberini veren bildirim, siz tıklayıp açana veya kapatana kadar bekler, böylece siz makineden uzaktayken gelen bir dosya, geri döndüğünüzde yanıtlanmak üzere hâlâ oradadır.

Kurulumu ayrıca Tailscale yönetici konsolu için bir web uygulaması ekler.

## Çalışmayı bıraktığında

Yeniden başlatmadan önce, sorun çıkaran parçayı tek başına yeniden başlatmayı deneyin. _Güncelle > Donanım_ altında Wi-Fi, Bluetooth, Ses ve İzleme Dörtgeni bulunur ve bunlardan birini yeniden yüklemek çoğu "beş dakika önce çalışıyordu" durumunu çözer. Bkz. [sorun giderme](45-troubleshooting.md).
