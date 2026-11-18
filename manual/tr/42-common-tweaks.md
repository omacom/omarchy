# Yaygın ince ayarlar

Bu, Omarchy kurulumuna yapılan yaygın kişiselleştirmelerin bir koleksiyonudur. Şunu bilin ki sistem güncelleştirmelerinin zaman zaman belirli yapılandırmaları özgün durumlarına geri yüklemesi gerekebilir. Bu olursa, değişiklikleriniz kaybolmaz, aynı dizinde bir `.bak` dosyasına konur.

Bir şeyi bozarsanız, tek tek yapılandırmaları Omarchy menüsündeki _Güncelle > Yapılandırma_ aracılığıyla özgün kurulumlarına geri yükleyebilirsiniz. Her şeyi _gerçekten_ bozarsanız, tüm yapılandırmaları `omarchy-reinstall` aracılığıyla sıfırlayabilirsiniz.

### Tüm tepsi simgelerini her zaman göster

Varsayılan olarak, Dropbox, 1password veya Steam gibi tepsi simgeleri, üzerinize geldiğinizde onları ortaya çıkaran tepsi genişletici okunun arkasına gizlenir. Onları her zaman açıkta görmek isterseniz, genişletici oka sağ tıklayarak tepsi simgesi yöneticisini açın, ardından görünür tutmak istediğiniz simgeleri sabitleyin (asla görmek istemediklerinizi de gizleyebilirsiniz).

### Yuvarlak pencere köşeleri

Omarchy'nin varsayılan tasarımı kare köşelerden oluşur, ancak bunu biraz yumuşatmayı seviyorsanız, `~/.config/hypr/looknfeel.lua` dosyasını yuvarlatma artık yorum dışı olmayacak şekilde değiştirebilirsiniz:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Pencere boşluklarını kaldır

Dizüstü bilgisayar ekranlarında bazı kişiler hiçbir pikseli pencere boşluklarına (veya `Super + Shift + Space` ile kapatabileceğiniz bir üst çubuğa bile) harcamamayı tercih eder. Tüm boşlukları ve kenarlıkları `Super + Shift + Backspace` ile kapatabilir veya `~/.config/hypr/looknfeel.lua` dosyasının bu bölümündeki yorumları kaldırarak kalıcı olarak kaldırabilirsiniz:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
