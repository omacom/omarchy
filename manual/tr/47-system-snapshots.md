# Sistem anlık görüntüleri

Her Omarchy güncelleştirmesinde otomatik olarak anlık görüntüler oluşturuyoruz, ancak kendi anlık görüntünüzü oluşturmak isterseniz, `omarchy-snapshot create` kullanabilirsiniz.

Bir anlık görüntüyü önyüklemek ve geri yüklemek için onu Limine önyükleyicisinden seçersiniz. (Şu anda doğrudan Omarchy şifre çözme ekranına önyükleme yapıyorsanız, önce BIOS aracılığıyla bir önyükleme seçeneği olarak Limine'yi seçmeniz gerekir).

O ekrandan, tarihe ve sürüme göre önyüklemek istediğiniz anlık görüntüyü seçin. Anlık görüntü sırasındaki Omarchy sürümü sol alt köşede görülebilir.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

İçeri vardığınızda, önyüklenebilir bir anlık görüntüde olduğunuzu bildiren bir bildirim açılır ve ona tıklarsanız, geri yükleme işlemini başlatır. Alternatif olarak, `omarchy-snapshot restore` kullanabilirsiniz.

 ![snapshots-restore](images/snapshots-restore.webp)

Bu, kök dosya sisteminizi geri yükleyecektir, ancak `/home` dizininizi değil. Yani bozuk bir sistem güncelleştirmesini geri almak için çalışır, ancak kayıp kişisel dosyaları kurtarmak için çalışmaz.

Bu ayrıca `~/.config` dizininizin olduğu gibi tutulduğu anlamına gelir. Yani yapılandırma dosyalarını yeni bir biçimde saklayan bir kütüphanenin veya uygulamanın daha önceki bir sürümüne geri dönüyorsanız, bunu el ile halletmeniz gerekecektir.

_Not: Bu özellik yalnızca Omarchy 2.0'dan beri varsayılan olan Limine önyükleyicisini kullanan kurulumlarda kullanılabilir. GRUB veya systemd-boot kullanıyorsanız kullanılamaz._

### Önyükleme menüsünü atlama

Önyükleme menüsüne asla dokunmuyor ve yalnızca makinenin doğrudan şifre çözme ekranına gitmesini istiyorsanız, Omarchy menüsünde _Ayarlar > Doğrudan Önyükleme_ yolunu çalıştırın. Bu, doğrudan Omarchy'ye işaret eden bir EFI girişi ekler, böylece bellenim Limine'de durmadan onu önyükler.

Dezavantaj, en üstte söz edilenle aynıdır: doğrudan önyükleme açıkken, bir anlık görüntüye ulaşmak, önce BIOS önyükleme menünüzden Limine'yi seçmek anlamına gelir. Girişi kaldırmak ve Limine üzerinden önyüklemeye geri dönmek için _Ayarlar > Doğrudan Önyükleme_ yolunu tekrar çalıştırın. Bazı bellenimler özel EFI girişlerine iyi davranmaz, bu yüzden kurulum American Megatrends ve Apple belleniminde çalışmayı reddeder.
