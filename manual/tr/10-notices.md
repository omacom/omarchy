# Uyarılar

Bildirimler, odaklanılan ekranın sağ üst köşesine düşer. Kısayol uyarılarını kullanarak tarih ve saate, pil durumuna ve güncel hava durumuna da hızlıca erişebilirsin.

## Bildirimler

Aynı uygulamadan veya siteden gelen bildirimler bir deste hâlinde üst üste yığılır, böylece geveze bir Slack kanalı derleme hatanı ekranın dışına itmez. Desteyi yelpaze gibi açmak için üzerine gel; sen okurken imlecinin altında yeni bir şey kayarak girmez. Geldiği yere atlamak için bir karta tıkla; kapatmak için sağ tıkla, orta tıkla veya ✕ işaretine bas.

Kartlar taşıdıklarını sunar: doğrulama kodları için _Kodu kopyala_ ([pano geçmişi](08-unified-clipboard-history.md) dışında tutulur ve bir dakika sonra temizlenir), ayrıca uygulamanın sağladığı tüm düğmeler. Bir bildirimin metnindeki bağlantılar tıklandığında açılır.

Bunları fare olmadan kullanmak için `Super + Ctrl + ,` tuşlarına bas. En yeni bildirim seçilir ve düğmeleri numaralandırılır: birini kullanmak için bir sayıya bas, bildirime tıklamak için `Enter`, bildirimler arasında gezinmek için `↑` ve `↓`, birini kapatmak için `Delete` ve klavyeyi geri vermek için `Esc` tuşuna bas. Birkaç saniye boşta kaldıktan sonra kendiliğinden de bırakır.

Bildirimleri sessize almak, az önce senin istediğin Omarchy'nin kendi onayları, acil durum uyarıları ve doğrulama kodları dışında onları geri tutar. Son birkaçını, geri tutulmuş olsun ya da olmasın, `Super + Shift + Alt + ,` ile tekrar ekrana getir. Geçmiş bir gün boyunca saklanır.

## Kısayol uyarıları

### Tarih ve Saat

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Hava Durumu

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Konum, IP adresinden tespit edilir; bu genellikle yeterince yakındır ama her zaman değil. `omarchy weather location --set Malibu` ile sabitleyebilir veya koordinat ekleyerek tam olarak belirtebilirsin: `omarchy weather location --set Malibu 34.0259,-118.7798`. Nerede olduğunu düşündüğünü görmek için `omarchy weather location` komutunu tek başına çalıştır, otomatik tespite geri dönmek için `--clear` kullan.

### Pil

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
