# Markalama

Omarchy, şirket logonuzu veya kişisel görselinizi hem önyükleme kilidi açma ekranı, hem ekran koruyucu hem de hakkında ekranı için ayarlamanıza olanak tanır.

### Önyükleme kilidi açma

Özel logonuzun ve renklerinizin nasıl görüneceğini görmek için `omarchy plymouth preview` komutunu kullanabilirsiniz. Bir arka plan rengi, bir metin rengi, bir logo png'si ve önizleme görseli için bir yol alır:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Ardından kurulumu `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` ile uygulayın; bu, SDDM giriş ekranına da aynı renkleri ve logoyu verir. Geri almak isterseniz `omarchy plymouth reset` komutunu kullanabilirsiniz.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ekran koruyucu

Ekran koruyucu için kullanılan logoyu _Görünüm > Markalama > Ekran Koruyucu_ altında değiştirebilirsiniz. Bu bir ASCII logosu, yani metni doğrudan düzenleyebilirsiniz, ama ona bir png veya svg görseli de verebilirsiniz, biz de onu ASCII'ye dönüştürürüz. Oldukça havalı görünüyor.

 ![branding-screensaver](images/branding-screensaver.webp)

Bu menüde üç giriş bulunur:

- **Metni Düzenle**, düzenleyicinizde `~/.config/omarchy/branding/screensaver.txt` dosyasını açar. İstediğinizi yazın veya yapıştırın — ASCII sanatı, adınız, kaba bir kelime. Kaydedip çıkın, ekran koruyucu da görebilmeniz için hemen devreye girer.
- **Görselden Ayarla**, bir png veya svg için bir dosya seçici açar, onu ASCII'ye dönüştürür ve sonucu size gösterir. Net bir siluete sahip logolar fotoğraflardan çok daha iyi sonuç verir.
- **Varsayılanı Geri Yükle**, Omarchy logosunu geri getirir.

### Hakkında ekranı

Aynı üç seçenek, Omarchy menüsünden ulaştığınız _Hakkında_ ekranı için _Görünüm > Markalama > Hakkında_ altında bulunur ve aynı şekilde çalışır — dosya `~/.config/omarchy/branding/about.txt`'dir ve Hakkında penceresi her değişiklikten sonra açılır. Hakkında görseli, ekranınızı doldurmak yerine bir pencereye sığması gerektiğinden, ekran koruyucununkinden daha küçük bir boyuta dönüştürülür.

Pencere açıkken parlak beyaz bir ışık bandı birkaç saniyede bir görselin üzerinden eğilerek geçer ve sonra onu tekrar hareketsiz bırakır. Her karakteri tek sütun genişliğinde olduğu sürece kendi görseliniz de bunu alır — _Görselden Ayarla_ ile üretilen her şey öyledir. Emoji veya çift genişlikli karakterlerden oluşturulmuş görseller bunun yerine hareketsiz kalır; kendi fastfetch yapılandırmanızı koruyorsanız ekran da öyle kalır: bu durumlarda hareketsiz bir logo, animasyonun başarısız olmasından değil, yolundan çekilmesindendir, çünkü bir parıltıyı onların üzerinden kaydırmak satırın geri kalanını yanlış yere getirir.

 ![branding-about](images/branding-about.webp)

### Görselleri kendiniz dönüştürme

İki _Görselden Ayarla_ seçeneği de aslında sadece `omarchy transcode ascii` komutunu çağırır; dönüştürme üzerinde kontrol istiyorsanız bunu doğrudan çalıştırabilirsiniz:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Bu komut, terminal sütunları ve satırları cinsinden `--width` ve `--height`, `braille` (varsayılan ve çok daha ince) veya `block` olabilen bir `--mode`, hangi piksellerin logonun parçası sayılacağına karar veren bir `--threshold` yüzdesi ve logonuz koyu bir arka plan üzerinde açık renkli olduğunda kullanılacak `--invert` seçeneğini alır. Bir dönüştürme bir leke gibi çıkarsa, genellikle ayarlamanız gereken düğme eşik değeridir.

### Logo yerine kelimeler

`omarchy ascii`, Omarchy kelime işaretinin kendisinin de çizildiği FIGlet yazı tipi olan Delta Corps Priest 1 ile metin çizer, böylece bir ekran koruyucu bir resim göstermek yerine bir şey söyleyebilir:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Metni argüman olarak alır veya hiç verilmezse bir pipe'tan okur. Yazı tipi yalnızca harf ve boşluk içerir — rakamlar veya noktalama işaretleri olmadan çizilmiştir — bu yüzden başka her şey sessizce yutulmak yerine atılır ve stderr üzerinde adı belirtilir.
