# Duyurular

Bildirimler, odaklanılan ekranın sağ üst köşesinde belirir. Kısayol bildirimlerini kullanarak tarih ve saate, pil durumuna ve güncel hava durumuna da hızlıca erişebilirsiniz.

## Bildirimler

Aynı uygulama veya siteden gelen bildirimler bir deste hâlinde üst üste yığılır, böylece geveze bir Slack kanalı derleme hatanızı ekranın dışına itmez. Bir destenin üzerine gelerek onu yelpaze gibi açın; siz okurken imlecinizin altına yeni bir şey kaymaz. Geldiği yere atlamak için bir karta tıklayın, kapatmak için sağ tıklayın, orta tıklayın veya ✕ işaretine basın.

Kartlar, taşıdıkları şeyi sunar: doğrulama kodları için _Kodu kopyala_ ([pano geçmişinin](08-unified-clipboard-history.md) dışında tutulur ve bir dakika sonra temizlenir), ayrıca uygulamanın sağladığı tüm düğmeler. Bir bildirimin metnindeki bağlantılar tıklandığında açılır.

`Super + ,` en yeni bildirimi kapatır veya sunduğunda işaret ettiği şeyi açar, `Super + Alt + ,` yalnızca sonuncuyu kapatır, `Super + Shift + ,` hepsini kapatır ve `Super + Shift + Alt + ,` geçmişi açar. Bunları fare olmadan kullanmak için `Super + Ctrl + ,` tuşlarına basın. En yeni bildirim seçilir ve düğmeleri numaralandırılır: birini kullanmak için bir sayıya basın, bildirime tıklamak için `Enter` tuşuna basın, bildirimler arasında gezinmek için `↑` ve `↓` tuşlarını kullanın, birini kapatmak için `Delete` tuşuna basın ve klavyeyi geri vermek için `Esc` tuşuna basın. Birkaç saniye boşta kaldıktan sonra kendi kendine de bırakır.

Bildirimleri sessize almak onları geride tutar; ancak Omarchy'nin kendi onayları, acil durum uyarıları ve az önce istediğiniz doğrulama kodları bunun dışındadır. Tutulmuş olsun ya da olmasın, son birkaçını `Super + Shift + Alt + ,` ile tekrar ekrana getirin. Geçmiş bir gün boyunca saklanır.

## Kısayol bildirimleri

### Tarih ve Saat

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Hava Durumu

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Konum, IP adresinizden tespit edilir; bu genellikle yeterince yakındır, ancak her zaman değil. `omarchy weather location --set Malibu` ile sabitleyebilir veya koordinatları ekleyerek tam olarak belirtebilirsiniz: `omarchy weather location --set Malibu 34.0259,-118.7798`. Nerede olduğunuzu düşündüğünü görmek için `omarchy weather location` komutunu tek başına çalıştırın ve otomatik tespite geri dönmek için `--clear` kullanın.

### Pil

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
