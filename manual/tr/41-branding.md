# Markalaşma

Omarchy, şirket logonuzu veya kişisel görselinizi hem önyükleme kilidini açma ekranı, hem ekran koruyucu, hem de hakkında ekranı için ayarlamanıza olanak tanır.

### Önyükleme kilidini açma

Özel logonuzun ve renklerinizin nasıl görüneceğini görmek için `omarchy plymouth preview` komutunu kullanabilirsiniz. Bu komut bir arka plan rengi, bir metin rengi, bir logo png dosyası ve önizleme görseli için bir yol alır:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Ardından kurulumu `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` ile uygulayın; bu, SDDM giriş ekranına da aynı renkleri ve logoyu verecektir. Geri dönmek isterseniz `omarchy plymouth reset` komutunu kullanabilirsiniz.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ekran koruyucu

Ekran koruyucu için kullanılan logoyu _Appearance > Branding > Screensaver_ altında değiştirebilirsiniz. Bu bir ASCII logosu, yani metni doğrudan düzenleyebilirsiniz, ancak ona bir png veya svg görseli de verebilirsiniz; biz de onu ASCII'ye dönüştürürüz. Oldukça havalı görünüyor.

 ![branding-screensaver](images/branding-screensaver.webp)

O menüde üç giriş var:

- **Edit Text**, `~/.config/omarchy/branding/screensaver.txt` dosyasını düzenleyicinizde açar. Ne isterseniz yazın veya yapıştırın — ASCII sanatı, adınız, kaba bir kelime. Kaydedip çıkın; ekran koruyucu hemen devreye girer, böylece görebilirsiniz.
- **Set From Image**, bir png veya svg için bir dosya seçici açar, onu ASCII'ye dönüştürür ve sonucu size gösterir. Net bir siluete sahip logolar, fotoğraflardan çok daha iyi çalışır.
- **Restore Default**, Omarchy logosunu geri getirir.

### Hakkında ekranı

Aynı üç seçenek, Omarchy menüsünden ulaştığınız _About_ ekranı için _Appearance > Branding > About_ altında da bulunur ve tamamen aynı şekilde çalışır — dosya `~/.config/omarchy/branding/about.txt` dosyasıdır ve About penceresi her değişiklikten sonra açılır. About görseli, ekran koruyucununkinden daha küçük bir boyuta dönüştürülür, çünkü ekranınızı doldurmak yerine bir pencereye sığması gerekir.

Pencere açıkken, birkaç saniyede bir yeşil bir parıltı görselin üzerinden eğilerek geçer ve sonra onu yeniden hareketsiz bırakır. Her karakteri tek sütun genişliğinde olduğu sürece kendi görseliniz de bunu alır — _Set From Image_ ile üretilen her şey öyledir. Emoji veya çift genişlikli karakterlerden oluşturulan görseller bunun yerine hareketsiz kalır; kendi fastfetch yapılandırmanızı korursanız ekran da öyle kalır: bu durumlarda hareketsiz bir logo, animasyonun başarısız olmasından değil, yoldan çekilmesindendir, çünkü bir parıltıyı bunların üzerinden kaydırmak satırın geri kalanını yanlış yere düşürür.

 ![branding-about](images/branding-about.webp)

### Görselleri kendiniz dönüştürme

_Set From Image_ seçeneklerinin ikisi de yalnızca `omarchy transcode ascii` komutunu çağırır; dönüştürme üzerinde kontrol istiyorsanız bunu doğrudan çalıştırabilirsiniz:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Bu komut, terminal sütunları ve satırları cinsinden `--width` ve `--height`, `braille` (varsayılan ve çok daha ince) veya `block` değerlerinden biri olan bir `--mode`, hangi piksellerin logonun parçası sayılacağına karar vermek için bir `--threshold` yüzdesi ve logonuz koyu bir arka plan üzerinde açık renkli olduğunda kullanılacak `--invert` seçeneğini alır. Bir dönüştürme bir leke gibi çıkarsa, genellikle çevrilecek düğme eşik değeridir.

### Logo yerine kelimeler

`omarchy ascii`, metni Omarchy kelime işaretinin kendisinin de çizildiği FIGlet fontu olan Delta Corps Priest 1 ile çizer, böylece bir ekran koruyucu bir resim göstermek yerine bir şey söyleyebilir:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Metni argüman olarak alır veya hiç argüman verilmezse bir pipe üzerinden okur. Font yalnızca harfleri ve boşlukları taşır — rakamlar veya noktalama işaretleri olmadan çizilmiştir — bu yüzden başka her şey sessizce yutulmak yerine düşürülür ve stderr üzerinde adı belirtilir.
