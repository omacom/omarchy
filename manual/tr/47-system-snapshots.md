# Sistem anlık görüntüleri

Her Omarchy güncellemesinde otomatik olarak anlık görüntüler oluşturuyoruz, ancak kendinizinkini oluşturmak isterseniz `omarchy-snapshot create` komutunu kullanabilirsiniz.

Bir anlık görüntüyü önyüklemek ve geri yüklemek için onu Limine boot loader'dan seçersiniz. Önyükleme menüsü varsayılan olarak gizli kalır, bu nedenle onu görüntülemek için Limine başlar başlamaz herhangi bir tuşa basın.

O ekrandan, tarih ve sürüme göre önyüklemek istediğiniz anlık görüntüyü seçin. Anlık görüntü alındığı sırada kullanılan Omarchy sürümü sol alt köşede görülebilir.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

İçeri girdiğinizde, önyüklenebilir bir anlık görüntüde olduğunuzu bildiren bir bildirim açılır ve üzerine tıklarsanız geri yükleme işlemini başlatır. Alternatif olarak `omarchy-snapshot restore` komutunu kullanabilirsiniz.

 ![snapshots-restore](images/snapshots-restore.webp)

Bu, kök dosya sisteminizi geri yükler, ancak `/home` dizininizi geri yüklemez. Yani bozuk bir sistem güncellemesini geri almak için işe yarar, ancak kaybolan kişisel dosyaları kurtarmak için işe yaramaz.

Bu aynı zamanda `~/.config` dizininizin olduğu gibi korunduğu anlamına gelir. Yani yapılandırma dosyalarını yeni bir biçimde saklayan bir kütüphanenin veya uygulamanın daha eski bir sürümüne geri dönüyorsanız, bunu manuel olarak halletmeniz gerekecektir.

Aynı şey, hangi geçişlerin zaten çalıştırıldığına dair Omarchy'nin kendi kaydı için de geçerlidir: bu kayıt ev dizininizde bulunur, bu nedenle geri yüklemeden sonra da korunur. Anlık görüntü alındıktan sonra çalıştırılan geçişler, kök dosya sisteminde yaptıkları değişiklikler geri alınmış olsa bile tamamlandı olarak işaretli kalır ve bir sonraki `omarchy update` bunları yeniden çalıştırmaz. Yani bir geri yüklemeden sonra tekrar güncelleme yaparsanız ve daha önceki bir güncellemenin kurduğu bir şey hâlâ eksikse, muhtemel nedeni budur.

_Not: Bu özellik yalnızca, Omarchy 2.0'dan beri varsayılan olan Limine boot loader'ı kullanan kurulumlarda kullanılabilir. GRUB veya systemd-boot kullanıyorsanız kullanılamaz._
