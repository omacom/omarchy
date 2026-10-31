# Sistem anlık görüntüleri

Her Omarchy güncellemesinde otomatik olarak anlık görüntüler oluşturuyoruz, ancak kendinizinkini oluşturmak isterseniz `omarchy-snapshot create` komutunu kullanabilirsiniz.

Bir anlık görüntüyü başlatmak ve geri yüklemek için onu Limine boot loader üzerinden seçersiniz. (Şu anda doğrudan Omarchy şifre çözme ekranına önyükleme yapıyorsanız, önce BIOS üzerinden Limine'yi bir önyükleme seçeneği olarak seçmeniz gerekir).

Bu ekrandan, tarih ve sürüme göre önyükleme yapmak istediğiniz anlık görüntüyü seçin. Anlık görüntü alındığı sırada Omarchy'nin sürümü sol alt köşede görülebilir.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

İçeri girdiğinizde, önyüklenebilir bir anlık görüntüde olduğunuzu bildiren bir bildirim açılır ve üzerine tıklarsanız geri yükleme işlemi başlar. Alternatif olarak `omarchy-snapshot restore` komutunu kullanabilirsiniz.

 ![snapshots-restore](images/snapshots-restore.webp)

Bu, kök dosya sisteminizi geri yükler, ancak `/home` dizininizi geri yüklemez. Yani bozuk bir sistem güncellemesini geri almak için işe yarar, ancak kaybolan kişisel dosyaları kurtarmak için işe yaramaz.

Bu aynı zamanda `~/.config` dizininizin olduğu gibi korunduğu anlamına gelir. Yani yapılandırma dosyalarını yeni bir formatta saklayan bir kütüphanenin veya uygulamanın daha eski bir sürümüne geri dönüyorsanız, bunu elle halletmeniz gerekir.

Aynı durum, hangi geçişlerin zaten çalıştırıldığına dair Omarchy'nin kendi kaydı için de geçerlidir: bu kayıt ev dizininizde yaşar, bu yüzden geri yüklemeden sağ çıkar. Anlık görüntü alındıktan sonra çalıştırılan geçişler, kök dosya sisteminde yaptıkları değişiklikler geri alınmış olsa bile tamamlandı olarak işaretli kalır ve bir sonraki `omarchy update` bunları tekrar çalıştırmaz. Bu yüzden bir geri yüklemeden sonra tekrar güncelleme yaparsanız ve daha önceki bir güncellemenin kurduğu bir şey hâlâ eksikse, muhtemel nedeni budur.

_Not: Bu özellik yalnızca Limine boot loader kullanan kurulumlarda kullanılabilir; bu, Omarchy 2.0'dan beri varsayılandır. GRUB veya systemd-boot kullanıyorsanız kullanılamaz._

### Önyükleme menüsünü atlama

Önyükleme menüsüne hiç dokunmuyorsanız ve makinenin doğrudan şifre çözme ekranına gitmesini istiyorsanız, Omarchy menüsünde _Setup > Direct Boot_ seçeneğini çalıştırın. Bu, doğrudan Omarchy'yi işaret eden bir EFI girdisi ekler, böylece firmware Limine'de durmadan onu önyükler.

Bunun karşılığında verilen ödün, en başta bahsedilen şeydir: direct boot açıkken bir anlık görüntüye ulaşmak, önce BIOS önyükleme menünüzden Limine'yi seçmek anlamına gelir. Girdiyi kaldırmak ve Limine üzerinden önyüklemeye geri dönmek için _Setup > Direct Boot_ seçeneğini tekrar çalıştırın. Bazı firmware'ler özel EFI girdilerinden pek hoşlanmaz, bu yüzden kurulum American Megatrends ve Apple firmware'lerinde çalışmayı reddeder.
