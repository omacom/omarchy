# Çift Önyükleme Kurulumu

Omarchy'yi Windows'un veya diğer kurulumların yanında tek bir bölüme kurabilirsiniz.

Bu kurulum yöntemi de varsayılan olarak bölüm için LUKS şifrelemesiyle gelir, bu yüzden aslında tam disk kurulumundan hiçbir farkı yoktur ve yalnızca diskte boş alan olmasını gerektirir.

## Windows'ta Yer Açma

Windows'un yanına kurmak için başlat menüsüne `disk management` yazın ve **Sabit disk bölümleri oluştur ve biçimlendir** seçeneğini belirleyin.

 ![dual-boot-1](images/dual-boot-1.webp)

Uygun bölümü bulun, sağ tıklayın ve **Birimi Küçült** seçeneğini belirleyin.

![dual-boot-2](images/dual-boot-2.webp)

 Birimi ne kadar küçültmek istediğinizi girin. Bunun, önyükleme bölümü de dahil olmak üzere gelecekteki Omarchy kurulumunuzun boyutu olacağını unutmayın.

 ![dual-boot-3](images/dual-boot-3.webp)

Bitirdiğinizde, bu örnekte Omarchy'yi kuracağımız 50GB'lık bölümün olduğu buna benzer bir şey görmelisiniz.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy'yi Kurma

Omarchy kurulum süreci aslında normal kurulumla aynıdır. Diskinizi seçtikten sonra size **Boş alana kurulum** seçeneği sunulacaktır. Tam diski silmeyi önlemek için o seçeneği belirleyin.

 ![dual-boot-5](images/dual-boot-5.webp)

Her şeyin doğru göründüğünü onaylayın ve kurulumun normal şekilde bitmesini bekleyin. Burası aynı zamanda, tam disk kurulumunda olduğu gibi, şifresiz kurulum yapmayı da seçebileceğiniz yerdir (önerilmez).
 ![dual-boot-6](images/dual-boot-6.webp)

## Diğer Kurulumları Önyükleyiciye Ekleme

Omarchy kurulumunuzu bitirdiğinizde, Limine önyükleyicisinin artık varsayılan olduğunu fark edeceksiniz. Bununla birlikte, Windows gibi diğer kurulumlarınız için Limine'ye seçenekler de ekleyebilirsiniz.

Diğer işletim sistemlerini eklemek için `limine-scan` komutunu çalıştırın ve istediğiniz girdileri Limine yapılandırmanıza eklemek için yönergeleri izleyin. Önyükleme menüsü varsayılan olarak gizli kalır ve bir saniye sonra Omarchy'yi başlatır. Windows'u veya başka bir girdiyi seçmek için, Limine başlar başlamaz herhangi bir tuşa basın; menü göründüğünde, bir girdiyi seçmek için ok tuşlarını kullanın ve Enter tuşuna basın. Siz bir tuşa basmadan Omarchy başlarsa, yeniden başlatın ve tekrar deneyin.

## Bitlocker

Bu kurulum yönteminin Bitlocker ile uyumlu olmadığını belirtmek önemlidir, çünkü Bitlocker yalnızca bölümü değil tüm diski şifreler. Bitlocker'ın etkin olduğunu belirten bir hatayla karşılaşırsanız, Windows'a önyükleme yapın, **Ayarlar -> Gizlilik ve güvenlik -> Cihaz şifreleme** bölümüne gidin ve Bitlocker'ı kapatın. Diskin şifresinin çözülmesi biraz zaman alabilir.

 ![dual-boot-7](images/dual-boot-7.webp)

## Windows'u Yeniden Kurma

Bu bilgisayar Windows ile birlikte geldiyse, ürün anahtarı aygıt yazılımında saklanır. Anahtarı yazdırmak için `omarchy windows key` komutunu çalıştırın, böylece Windows'u bu makineye yeniden kurarsanız tekrar etkinleştirebilirsiniz.
