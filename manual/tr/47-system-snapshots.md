# Sistem anlık görüntüleri

Her Omarchy güncellemesinde otomatik olarak anlık görüntüler oluşturuyoruz, ancak kendi anlık görüntünüzü oluşturmak isterseniz `omarchy-snapshot create` komutunu kullanabilirsiniz.

Bir anlık görüntüyü nasıl başlatacağınız ve geri yükleyeceğiniz, makinenizin hangi önyükleyiciyle başladığına bağlıdır. Yeni UEFI kurulumları systemd-boot kullanır; eski kurulumlar ve BIOS makineleri Limine kullanır. `omarchy-boot-backend` komutu sizde hangisinin olduğunu söyler.

## systemd-boot ile

Omarchy menüsünde _Sistem > Anlık Görüntüler_ seçeneğini seçin ve başlatmak istediğiniz anlık görüntüyü seçin. Makine bir kez o anlık görüntüyle yeniden başlar. Ya da makine başlarken Space tuşunu basılı tutarak önyükleme menüsünü görün; burada her anlık görüntü, Omarchy sürümü ve tarihiyle birlikte en yeniden en eskiye doğru listelenir.

Bir anlık görüntü üstte geçici bir katmanla başlar, bu yüzden onu normal şekilde kullanabilirsiniz, ancak yaptığınız her şey bir sonraki yeniden başlatmada kaybolur. Onu kalıcı yapmak için sisteminiz haline getirin: oturum açtığınızda görünen bildirime tıklayın, _Sistem > Anlık Görüntüler > Bu Anlık Görüntüyü Geri Yükle_ seçeneğini seçin ya da `omarchy-snapshot restore` komutunu çalıştırın. Geri yükleme, makine yeniden başlarken gerçekleşir. Sistemin önceki hali önyükleme menüsünde _Geri yükleme öncesi_ olarak kalır ve `omarchy-snapshot restore backup` komutu onu geri getirir.

Terminalden:

- `omarchy-snapshot list` başlatabileceğiniz anlık görüntüleri listeler;
- `omarchy-snapshot boot 12` bir kez 12 numaralı anlık görüntüyle yeniden başlatır;
- `omarchy-snapshot restore 12` bir sonraki yeniden başlatmada 12 numaralı anlık görüntüyü sistem yapar ve `omarchy-snapshot restore --cancel` o yeniden başlatmadan önce fikrinizi değiştirmenizi sağlar.

## Limine ile

Bir anlık görüntüyü başlatmak ve geri yüklemek için onu Limine önyükleyicisinden seçersiniz. Önyükleme menüsü varsayılan olarak gizli kalır, bu yüzden Limine başlar başlamaz herhangi bir tuşa basarak onu açın.

O ekrandan, tarihe ve sürüme göre başlatmak istediğiniz anlık görüntüyü seçin. Anlık görüntü alındığı sırada kullanılan Omarchy sürümü sol alt köşede görülebilir.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

İçeri girdiğinizde, başlatılabilir bir anlık görüntüde olduğunuzu bildiren bir bildirim açılır ve ona tıklarsanız geri yükleme işlemi başlar. Alternatif olarak `omarchy-snapshot restore` komutunu kullanabilirsiniz.

 ![snapshots-restore](images/snapshots-restore.webp)

## Geri yükleme neleri kapsar

Geri yükleme, kök dosya sisteminizi geri getirir, ancak `/home` dizininizi getirmez. Bu yüzden bozuk bir sistem güncellemesini geri almak için işe yarar, ancak kayıp kişisel dosyaları kurtarmak için yaramaz.

Bu aynı zamanda `~/.config` dizininizin olduğu gibi korunduğu anlamına gelir. Yani yapılandırma dosyalarını yeni bir biçimde saklayan bir kütüphanenin ya da uygulamanın daha eski bir sürümüne geri dönüyorsanız, bunu elle halletmeniz gerekir.

Aynı durum, hangi geçişlerin zaten çalıştırıldığına dair Omarchy'nin kendi kaydı için de geçerlidir: bu kayıt ev dizininizde yaşar, bu yüzden geri yüklemeden sağ çıkar. Anlık görüntü alındıktan sonra çalıştırılan geçişler, kök dosya sisteminde yaptıkları değişiklikler geri alınmış olsa bile yapılmış olarak işaretli kalır ve bir sonraki `omarchy update` onları tekrar çalıştırmaz. Yani bir geri yüklemeden sonra tekrar güncelleme yaparsanız ve daha önceki bir güncellemenin kurduğu bir şey hâlâ eksikse, muhtemel sebep budur.
