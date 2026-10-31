# Çift Önyükleme Kurulumu

Omarchy'yi Windows veya diğer kurulumların yanında tek bir bölüme kurabilirsiniz.

Bu kurulum yöntemi varsayılan olarak bölüm için LUKS şifrelemesiyle birlikte gelir, bu yüzden tam sürücüden etkili bir şekilde farklı değildir ve yalnızca diskte boş alan bulunmasını gerektirir.

## Windows'da Alan Açma

Windows'un yanına kurmak için, başlangıç menüsüne `disk management` yazın ve **Create and format hard disk partitions** seçeneğini seçin.

 ![dual-boot-1](images/dual-boot-1.webp)

Uygun bölümü bulun, sağ tıklayın ve **Shrink Volume** seçeneğini seçin.

![dual-boot-2](images/dual-boot-2.webp)

 Birimi ne kadar küçültmek istediğinizi girin. Bunun, önyükleme bölümü dahil olmak üzere gelecekteki Omarchy kurulumunuzun boyutu olacağını unutmayın.

 ![dual-boot-3](images/dual-boot-3.webp)

İşiniz bittiğinde, 50GB'lık bölümün bu örnekte Omarchy'yi kuracağımız yer olduğu buna benzer bir şey görmelisiniz.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy'yi Kurma

Omarchy kurulum süreci etkili bir şekilde normalle aynıdır. Diskinizi seçtikten sonra, size **Free space install** seçeneği verilecektir. Tam diskin silinmesini önlemek için o seçeneği seçin.

 ![dual-boot-5](images/dual-boot-5.webp)

Her şeyin iyi göründüğünü doğrulayın ve kurulumun normal şekilde bitmesini bekleyin. Bu aynı zamanda tam sürücü kurulumunda olduğu gibi şifresiz kurulumu seçebileceğiniz (önerilmez) yerdir.
 ![dual-boot-6](images/dual-boot-6.webp)

## Diğer Kurulumları Önyükleyiciye Ekleme

Omarchy kurulumunuzu bitirdiğinizde, Limine önyükleyicisinin artık varsayılan olduğunu fark edeceksiniz. Bununla birlikte, Windows gibi diğer kurulumlarınız için de Limine'ye seçenekler ekleyebilirsiniz.

Bunu yapmak için, `limine-scan` çalıştırın ve limine yapılandırmanıza istediğiniz öğeleri eklemek için istemleri izleyin. Ardından önyükleme yaptığınızda, Omarchy için normal seçeneklerinizin yanı sıra Windows Boot Manager veya başkalarını göreceksiniz.

## Bitlocker

Bu kurulum yönteminin Bitlocker ile uyumlu olmadığını belirtmek önemlidir, çünkü Bitlocker yalnızca bölümü değil tüm sürücüyü şifreler. Bitlocker'ın etkin olduğunu belirten bir hatayla karşılaşırsanız, Windows'a önyükleme yapın, **Settings -> Privacy & Security -> Device encryption** yoluna gidin ve Bitlocker'ı kapatın. Sürücünün şifresini çözmek biraz zaman alabilir.

 ![dual-boot-7](images/dual-boot-7.webp)
