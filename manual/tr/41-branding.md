# Markalaşma

Omarchy, hem önyükleme kilidi açma hem ekran koruyucu hem de hakkında ekranı için şirket logonuzu veya kişisel görüntünüzü ayarlamanıza izin verir.

### Önyükleme kilidi açma

Özel logonuzun ve renklerinizin nasıl görüneceğini görmek için `omarchy plymouth preview` kullanabilirsiniz. Bu bir arka plan rengi, bir metin rengi, bir logo png'si ve önizleme görüntüsü için bir yol alır:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Ardından kurulumu `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` ile uygulayın; bu, SDDM giriş ekranına da aynı renkleri ve logoyu verecektir. Geri almak isterseniz, `omarchy plymouth reset` kullanabilirsiniz.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ekran koruyucu

Ekran koruyucu için kullanılan logoyu _Stil > Ekran Koruyucu_ altından değiştirebilirsiniz. Bu bir ASCII logosudur, böylece metni doğrudan düzenleyebilirsiniz, ancak ona bir png veya svg görüntüsü de verebilirsiniz ve biz onu ASCII'ye dönüştürürüz. Oldukça havalı görünüyor.

 ![branding-screensaver](images/branding-screensaver.webp)

O menüde üç giriş vardır:

- **Metni Düzenle** `~/.config/omarchy/branding/screensaver.txt` dosyasını düzenleyicinizde açar. İstediğinizi yazın veya yapıştırın — ASCII sanatı, adınız, kaba bir söz. Kaydedip çıkın, ekran koruyucu onu görebilmeniz için hemen başlar.
- **Görüntüden Ayarla** bir png veya svg için dosya seçici açar, onu ASCII'ye dönüştürür ve sonucu gösterir. Belirgin silüeti olan logolar fotoğraflardan çok daha iyi sonuç verir.
- **Varsayılanı Geri Yükle** Omarchy logosunu geri koyar.

### Hakkında ekranı

Aynı üç seçenek, Omarchy menüsünden aldığınız _Hakkında_ ekranı için _Stil > Hakkında_ altındadır ve aynı şekilde çalışır — dosya `~/.config/omarchy/branding/about.txt` dosyasıdır ve Hakkında penceresi her değişiklikten sonra açılır. Hakkında sanatı, ekran koruyucununkinden daha küçük bir boyuta dönüştürülür, çünkü ekranınızı doldurmak yerine bir pencereye sığması gerekir.

Pencere açıkken birkaç saniyede bir yeşil bir parıltı sanatın üzerinden geçer ve sonra onu tekrar hareketsiz bırakır. Kendi sanatınız da bunu alır, yeter ki içindeki her karakter bir sütun genişliğinde olsun — _Görüntüden Ayarla_ seçeneğinin ürettiklerinin hepsi öyledir. Emoji veya çift genişlikli karakterlerden oluşmuş sanat bunun yerine hareketsiz kalır, kendinize ait bir fastfetch yapılandırması tutarsanız ekran da öyle kalır: bu durumlarda hareketsiz bir logo, animasyonun başarısız olması değil, yoldan çekilmesidir, çünkü bir parıltıyı onların üzerinden kaydırmak satırın geri kalanını yanlış yere indirir.

 ![branding-about](images/branding-about.webp)

### Görüntüleri kendiniz dönüştürme

Her iki _Görüntüden Ayarla_ seçeneği de yalnızca `omarchy transcode ascii` komutunu çağırır; dönüştürme üzerinde denetim isterseniz bunu doğrudan çalıştırabilirsiniz:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Bu, terminal sütunları ve satırları cinsinden `--width` ve `--height`, `braille` (varsayılan ve çok daha ince) veya `block` seçeneklerinden biri olan `--mode`, hangi piksellerin logonun parçası sayılacağına karar vermek için yüzde cinsinden `--threshold` ve logonuz koyu bir arka plan üzerinde açık renkli olduğunda kullanılmak üzere `--invert` alır. Bir dönüştürme bir leke olarak çıkarsa, genellikle çevrilecek düğme eşik değeridir.

### Logo yerine sözcükler

`omarchy ascii` metni, Omarchy söz markasının kendisinin de çizildiği FIGlet yazı tipi Delta Corps Priest 1 ile çizer; böylece bir ekran koruyucu bir resim göstermek yerine bir şey söyleyebilir:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Metni bağımsız değişken olarak alır veya hiçbiri verilmezse bir borudan okur. Yazı tipi yalnızca harfleri ve boşlukları taşır — rakamlar veya noktalama işaretleri olmadan çizilmiştir — bu yüzden başka her şey bırakılır ve sessizce yutulmak yerine stderr'de adlandırılır.
