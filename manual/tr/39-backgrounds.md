# Arka Planlar

Her tema kendi arka plan setiyle birlikte gelir ve `~/.config/omarchy/backgrounds/[theme]` içine kendinize ait ekstralar ekleyebilirsiniz. Örneğin nord temasına ekstra bir arka plan görseli eklemek isterseniz, dosyayı `~/.config/omarchy/backgrounds/nord` içine koymanız yeterli.

Bunu en kolay Omarchy Menu içinde _Kurulum > Stil > Arka Plan_ yolunu izleyerek yapabilirsiniz. Bu, o temanın arka planlarının saklandığı klasörü açar. Başka bir dosya yöneticisi başlatmak için `Super + Shift + F` tuşlarına basın, arka planınızı bulun ve karşıya kopyalayın. Artık `Super + Ctrl + W` ile aralarında seçim yapabileceğiniz arka plan seçeneklerine dahil edilecek.

Arka planlar hareketsiz görsellerin yanı sıra videolar da olabilir. Aynı klasöre bir `mp4`, `m4v`, `mov`, `webm`, `mkv` veya `avi` dosyası bırakın; görsellerin yanında görünür. Videolar OWE wallpaper engine tarafından oynatılır. Videoyu tüm monitörler için bir kez çözer ve sesini varsayılan ses çıkışından oynatır, ayrıca hiçbir şey onu göremediğinde oynatmayı durdurur. Video arka planı yine de hareketsiz bir arka plandan çok daha fazla güç tüketir.

Temalar, hareketsiz bir arka plan için kısa bir intro içerebilir. `backgrounds/road.webp` için eşleşen video `backgrounds/intros/road.mp4` konumunda bulunur. Önyüklemede ve o arka planın seçili olduğu bir temaya geçildiğinde otomatik olarak oynatılır, ardından hareketsiz görsele döner. Intro videoları arka plan seçicinin dışında kalır ve asla döngüye girmez.

_Görünüm > Animasyonlar_ seçeneğini kapatmak arka plan introlarını da kapatır. Omarchy bunu bir sanal makinede varsayılan olarak yapar. `omarchy theme bg intro toggle` komutu introları ayrı olarak açıp kapatabilir. Bir temayı yenilemek veya aynı tema içinde başka bir arka plan seçmek intro oynatmaz.

Harika, özenle seçilmiş arka planlardan oluşan devasa bir koleksiyonu [dharmx/walls](https://github.com/dharmx/walls) adresinde bulabilirsiniz.

Kilit ekranı, video arka planının hareketsiz bir karesini gösterir; tıpkı animasyonlu bir GIF'in hareketsiz bir karesini gösterdiği gibi.
