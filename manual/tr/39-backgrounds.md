# Arka planlar

Her tema kendi arka plan setiyle birlikte gelir ve `~/.config/omarchy/backgrounds/[theme]` içine kendinizden ekstralar ekleyebilirsiniz. Diyelim ki nord temasına ek bir arka plan görüntüsü eklemek istiyorsunuz; dosyayı `~/.config/omarchy/backgrounds/nord` içine koymanız yeterlidir.

Bunu en kolay şekilde Omarchy Menüsünde _Kur > Stil > Arka Plan_ yoluna giderek yapabilirsiniz. Bu, o temanın arka planlarının saklandığı klasörü açacaktır. Başka bir dosya yöneticisi başlatmak için `Super + Shift + F` tuşlarına basın, arka planınızı bulun, kopyalayın. Artık `Super + Ctrl + Space` kullanarak aralarından seçim yapabileceğiniz arka plan seçeneklerine dahil edilecektir.

Arka planlar durağan görüntüler olabileceği gibi videolar da olabilir. Aynı klasöre bir `mp4`, `m4v`, `mov`, `webm`, `mkv` veya `avi` dosyası bırakın; görüntülerin yanında görünecektir. Videolar OWE duvar kâğıdı motoru tarafından oynatılır. Videoyu tüm monitörler için bir kez çözer ve sesini varsayılan ses çıkışı üzerinden oynatır, hiçbir şey onu göremediğinde de oynatmayı durdurur. Kilit ekranı aynı çözmeyi sesi kapalı olarak OWE üzerinden çizer. Bir video duvar kâğıdı, durağan bir tanesinden çok daha fazla güce mal olur.

Temalar, durağan bir arka plan için kısa bir giriş içerebilir. `backgrounds/road.webp` için eşleşen video `backgrounds/intros/road.mp4` konumunda bulunur. Önyüklemede ve o arka planın seçili olduğu bir temaya geçerken otomatik olarak oynatılır, ardından durağan görüntüye döner. Giriş videoları arka plan seçicisinin dışında kalır ve asla döngüye girmez.

_Tetikle > Görünüm > Animasyonlar_ seçeneğini kapatmak arka plan girişlerini de kapatır. Omarchy bunu bir sanal makinede varsayılan olarak yapar. `omarchy theme bg intro toggle` komutu girişleri ayrıca açıp kapatabilir. Bir temayı yenilemek veya aynı tema içinde başka bir arka plan seçmek giriş oynatmaz.

Harika derlenmiş arka planlardan oluşan devasa bir koleksiyonu şurada bulabilirsiniz: https://github.com/dharmx/walls.

Video arka planları, oynatma duraklatıldığında veya kullanılamadığında kilit ekranında önbelleğe alınmış bir durağan görüntüyü tutar. Hareketli GIF'ler masaüstünde oynatılır ve kilit ekranında durağan bir kare gösterir.
