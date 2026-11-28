# Yaygın ince ayarlar

Bu, Omarchy kurulumuna yönelik yaygın özelleştirmelerin bir derlemesidir. Bilin ki sistem güncellemelerinin zaman zaman bazı yapılandırmaları özgün hallerine geri getirmesi gerekebilir. Bu olursa, değişiklikleriniz kaybolmaz, ancak orijinalin yanındaki bir `.bak.<timestamp>` dosyasına konur.

Bir şeyleri berbat ederseniz, Omarchy menüsündeki _Update > Config_ aracılığıyla tek tek yapılandırmaları özgün kurulumlarına geri getirebilirsiniz. Eğer her şeyi _gerçekten_ berbat ederseniz, `omarchy reinstall configs` ile tüm yapılandırmaları sıfırlayabilir veya `omarchy reinstall` ile her varsayılan paketi ve yapılandırmayı yeniden kurabilirsiniz.

### Tüm tepsi simgelerini her zaman göster

Varsayılan olarak, Dropbox, 1password veya Steam gibi tepsi simgeleri, üzerine geldiğinizde onları gösteren tepsi genişletme okunun arkasında gizlenir. Onları her zaman açıkta tutmak isterseniz, tepsi simgesi yöneticisini açmak için genişletme okuna sağ tıklayın, ardından görünür tutmak istediğiniz simgeleri sabitleyin (hiç görmek istemediklerinizi de gizleyebilirsiniz).

### Yuvarlatılmış pencere köşeleri

Omarchy'nin varsayılan tasarımı kare köşelerdir, ancak bunu biraz yumuşatmak isterseniz, Omarchy menüsünde _Appearance > Windows > Window Corners > Rounded Corners_ seçeneğini seçin veya `omarchy hyprland corners rounded` komutunu çalıştırın. _Theme Corners_, temanın kullandığı şeye geri döner. Kendi yarıçapınızı seçmek için _Theme Corners_ (`omarchy hyprland corners theme`) üzerinde kalın, çünkü Rounded ve Sharp yapılandırmanızdan sonra yüklenir ve onu geçersiz kılar, ve `~/.config/hypr/looknfeel.lua` içinde rounding satırındaki yorum işaretlerini kaldırın:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Pencere boşluklarını kaldır

Dizüstü bilgisayar ekranlarında, bazı kişiler pencere boşluklarına (veya `Super + Shift + Space` ile kapatıp açabileceğiniz bir üst çubuğa bile) hiç piksel harcamamayı tercih eder. `Super + Shift + Backspace` ile tüm boşlukları ve kenarlıkları kapatıp açabilir veya `~/.config/hypr/looknfeel.lua` dosyasının bu bölümündeki yorumları kaldırarak onları kalıcı olarak kaldırabilirsiniz:

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
