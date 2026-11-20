# Çift Önyüklemeli Kurulum

Omarchy'yi Windows'un veya diğer kurulumların yanına tek bir bölüme kurabilirsiniz.

Bu kurulum yöntemi, bölüm için varsayılan olarak hâlâ LUKS şifrelemesiyle gelir, bu yüzden aslında tüm sürücü kurulumundan hiçbir farkı yoktur ve yalnızca diskte boş alan olmasını gerektirir.

## Windows'ta Yer Açma

Windows'un yanına kurmak için başlat menüsüne `disk management` yazın ve **Sabit disk bölümleri oluştur ve biçimlendir** seçeneğini seçin.

 ![dual-boot-1](images/dual-boot-1.webp)

Uygun bölümü bulun, sağ tıklayın ve **Birimi Küçült** seçeneğini seçin.

![dual-boot-2](images/dual-boot-2.webp)

 Birimi ne kadar küçültmek istediğinizi girin. Bunun, önyükleme bölümü dahil olmak üzere gelecekteki Omarchy kurulumunuzun boyutu olacağını unutmayın.

 ![dual-boot-3](images/dual-boot-3.webp)

İşiniz bittiğinde, buna benzer bir şey görmelisiniz; bu örnekte 50GB'lik bölüm, Omarchy'yi kuracağımız yerdir.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy'yi Kurma

Omarchy kurulum süreci aslında normal kurulumla aynıdır. Diskinizi seçtikten sonra size **Boş alan kurulumu** seçeneği sunulacaktır. Tüm diskin silinmesini önlemek için bu seçeneği seçin.

 ![dual-boot-5](images/dual-boot-5.webp)

Her şeyin düzgün göründüğünü onaylayın ve kurulumun normal şekilde bitmesini bekleyin. Burası aynı zamanda, tıpkı tüm sürücü kurulumunda olduğu gibi, şifresiz kurulum yapmayı seçebileceğiniz yerdir (önerilmez).
 ![dual-boot-6](images/dual-boot-6.webp)

## Diğer Kurulumları Önyükleyiciye Ekleme

Omarchy kurulumunuzu bitirdiğinizde, artık varsayılanın Limine önyükleyicisi olduğunu fark edeceksiniz. Bununla, Windows gibi diğer kurulumlarınız için Limine'ye seçenekler de ekleyebilirsiniz.

Diğer işletim sistemlerini eklemek için `limine-scan` komutunu çalıştırın ve istediğiniz girdileri Limine yapılandırmanıza eklemek için istemleri izleyin. Önyükleme menüsü varsayılan olarak gizli kalır ve bir saniye sonra Omarchy'yi başlatır. Windows'u veya başka bir girdiyi seçmek için Limine başlar başlamaz herhangi bir tuşa basın; menü göründüğünde, bir girdiyi seçmek için ok tuşlarını kullanın ve Enter tuşuna basın. Siz bir tuşa basmadan önce Omarchy başlarsa, yeniden başlatın ve tekrar deneyin.

## Bitlocker

Bu kurulum yönteminin, yalnızca bölümü değil tüm sürücüyü şifrelediği için Bitlocker ile uyumlu olmadığını unutmamak önemlidir. Bitlocker'ın etkin olduğunu belirten bir hatayla karşılaşırsanız, Windows'u başlatın, **Ayarlar -> Gizlilik ve Güvenlik -> Cihaz şifreleme** bölümüne gidin ve Bitlocker'ı kapatın. Sürücünün şifresinin çözülmesi biraz zaman alabilir.

 ![dual-boot-7](images/dual-boot-7.webp)
