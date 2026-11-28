# Markalama

Omarchy, şirket logonuzu veya kişisel görselinizi hem ekran koruyucu hem de hakkında ekranı için ayarlamanıza olanak tanır.

### Ekran koruyucu

Ekran koruyucu için kullanılan logoyu _Görünüm > Markalama > Ekran Koruyucu_ altından değiştirebilirsiniz. Bu bir ASCII logosu, dolayısıyla metni doğrudan düzenleyebilirsiniz, ancak ona bir png veya svg görseli de verebilirsiniz; biz de onu ASCII'ye dönüştürürüz. Oldukça havalı görünüyor.

 ![branding-screensaver](images/branding-screensaver.webp)

Bu menüde üç giriş var:

- **Metni Düzenle**, `~/.config/omarchy/branding/screensaver.txt` dosyasını düzenleyicinizde açar. İstediğinizi yazın veya yapıştırın — ASCII sanatı, adınız, kaba bir söz. Kaydedip çıkın; ekran koruyucu hemen devreye girer, böylece görebilirsiniz.
- **Görselden Ayarla**, bir png veya svg için dosya seçici açar, onu ASCII'ye dönüştürür ve sonucu size gösterir. Net silüeti olan logolar, fotoğraflardan çok daha iyi sonuç verir.
- **Varsayılanı Geri Yükle**, Omarchy logosunu geri getirir.

### Hakkında ekranı

Aynı üç seçenek, Omarchy menüsünden ulaştığınız _Hakkında_ ekranı için _Görünüm > Markalama > Hakkında_ altında da bulunur ve aynı şekilde çalışır — dosya `~/.config/omarchy/branding/about.txt` dosyasıdır ve Hakkında penceresi her değişikliğin ardından açılır. Hakkında görseli, ekran koruyucununkinden daha küçük bir boyuta dönüştürülür, çünkü ekranınızı doldurmak yerine bir pencereye sığması gerekir.

Pencere açıkken, parlak beyaz ışıktan bir şerit birkaç saniyede bir görselin üzerinden eğilerek geçer ve sonra onu yeniden hareketsiz bırakır. Kendi görseliniz de bunu alır, yeter ki içindeki her karakter bir sütun genişliğinde olsun — _Görselden Ayarla_ ile üretilen her şey öyledir. Emoji veya çift genişlikli karakterlerden oluşturulan görseller bunun yerine hareketsiz kalır; kendi fastfetch yapılandırmanızı korursanız ekran da öyle kalır: bu durumlarda hareketsiz bir logo, animasyonun başarısız olması değil, yoldan çekilmesidir, çünkü bir parıltıyı bunların üzerinden kaydırmak satırın geri kalanını yanlış yere getirir.

 ![branding-about](images/branding-about.webp)

### Görselleri kendiniz dönüştürme

Her iki _Görselden Ayarla_ seçeneği de aslında `omarchy transcode ascii` komutunu çağırır; dönüştürme üzerinde kontrol istiyorsanız bunu doğrudan çalıştırabilirsiniz:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Terminal sütunları ve satırları cinsinden `--width` ve `--height`, `braille` (varsayılan ve çok daha ince) veya `block` olabilen bir `--mode`, hangi piksellerin logonun parçası sayılacağına karar vermek için bir `--threshold` yüzdesi ve logonuz koyu arka plan üzerinde açık renkli olduğunda kullanmak üzere `--invert` alır. Bir dönüştürme leke gibi çıkarsa, genellikle çevirmeniz gereken ayar eşiktir.

### Logo yerine sözcükler

`omarchy ascii`, metni Omarchy kelime markasının kendisinin de çizildiği FIGlet fontu olan Delta Corps Priest 1 ile çizer, böylece bir ekran koruyucu resim göstermek yerine bir şey söyleyebilir:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Metni argüman olarak alır veya hiç verilmezse bir pipe'tan okur. Font yalnızca harfleri ve boşlukları taşır — rakamlar veya noktalama işaretleri olmadan çizilmiştir — dolayısıyla başka her şey sessizce yutulmak yerine atılır ve stderr üzerinde adı belirtilir.
