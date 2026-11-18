# Çift Önyükleme Kurulumu

Omarchy'yi Windows'un veya diğer kurulumların yanına tek bir bölüme kurabilirsiniz.

Bu kurulum yöntemi de bölüm için varsayılan olarak LUKS şifrelemesiyle gelir, bu yüzden aslında tam disk kurulumundan hiçbir farkı yoktur ve yalnızca diskte boş alan bulunmasını gerektirir.

## Windows'ta Yer Açma

Windows'un yanına kurmak için başlat menüsüne `disk management` yazın ve **Sabit disk bölümleri oluştur ve biçimlendir** seçeneğini seçin.

 ![dual-boot-1](images/dual-boot-1.webp)

Uygun bölümü bulun, sağ tıklayın ve **Birimi Küçült** seçeneğini seçin.

![dual-boot-2](images/dual-boot-2.webp)

 Birimi ne kadar küçültmek istediğinizi girin. Bunun, önyükleme bölümü dahil olmak üzere gelecekteki Omarchy kurulumunuzun boyutu olacağını unutmayın.

 ![dual-boot-3](images/dual-boot-3.webp)

İşiniz bittiğinde buna benzer bir şey görmelisiniz; bu örnekte 50GB'lik bölüm, Omarchy'yi kuracağımız yerdir.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy'yi Kurma

Omarchy kurulum süreci aslında normal kurulumla aynıdır. Diskinizi seçtikten sonra size **Boş alana kurulum** seçeneği sunulacaktır. Tüm diski silmeyi önlemek için bu seçeneği seçin.

 ![dual-boot-5](images/dual-boot-5.webp)

Her şeyin doğru göründüğünü onaylayın ve kurulumun normal şekilde bitmesini bekleyin. Tam disk kurulumunda olduğu gibi, şifresiz kurulum yapmayı (önerilmez) da buradan seçebilirsiniz.
 ![dual-boot-6](images/dual-boot-6.webp)

## Diğer Kurulumları Önyükleyiciye Ekleme

Omarchy kurulumunuzu bitirdiğinizde, artık varsayılanın Limine önyükleyicisi olduğunu fark edeceksiniz. Bununla, Windows gibi diğer kurulumlarınız için de Limine'ye seçenekler ekleyebilirsiniz.

Diğer işletim sistemlerini eklemek için `limine-scan` çalıştırın ve istediğiniz girdileri Limine yapılandırmanıza eklemek için yönergeleri izleyin. Önyükleme menüsü varsayılan olarak gizli kalır ve bir saniye sonra Omarchy'yi başlatır. Windows'u veya başka bir girdiyi seçmek için Limine başlar başlamaz herhangi bir tuşa basın; menü göründüğünde, bir girdi seçmek için ok tuşlarını kullanın ve Enter tuşuna basın. Siz bir tuşa basmadan Omarchy başlarsa, yeniden başlatın ve tekrar deneyin. _Setup > Direct Boot_ seçeneğini açtıysanız, donanım yazılımı Limine'yi tamamen atlar, bu yüzden BIOS önyükleme menünüzden Limine'yi seçin veya girdiyi kaldırmak için _Setup > Direct Boot_ seçeneğini tekrar çalıştırın.

## Bitlocker

Bu kurulum yönteminin Bitlocker ile uyumlu olmadığını unutmayın; çünkü Bitlocker yalnızca bölümü değil, tüm sürücüyü şifreler. Bitlocker'ın etkin olduğunu belirten bir hatayla karşılaşırsanız, Windows'u başlatın, **Ayarlar -> Gizlilik ve güvenlik -> Cihaz şifrelemesi** bölümüne gidin ve Bitlocker'ı kapatın. Sürücünün şifresini çözmek biraz zaman alabilir.

 ![dual-boot-7](images/dual-boot-7.webp)
