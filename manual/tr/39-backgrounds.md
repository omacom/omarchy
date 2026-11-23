# Arka Planlar

Her tema kendi arka plan setiyle birlikte gelir ve `~/.config/omarchy/backgrounds/[theme]` içine kendinizinkileri de ekleyebilirsiniz. Örneğin nord temasına ekstra bir arka plan görseli eklemek isterseniz, dosyayı `~/.config/omarchy/backgrounds/nord` içine koymanız yeterlidir.

Bunu en kolay şekilde Omarchy Menu içinde _Install > Style > Background_ yolunu izleyerek yapabilirsiniz. Bu, o temanın arka planlarının saklandığı klasörü açar. Başka bir dosya yöneticisi başlatmak için `Super + Shift + F` tuşlarına basın, arka planınızı bulun ve karşıya kopyalayın. Artık `Super + Ctrl + W` ile aralarında seçim yapabileceğiniz arka plan seçeneklerine dahil edilecektir.

Arka planlar hareketsiz görsellerin yanı sıra videolar da olabilir. Aynı klasöre bir `mp4`, `m4v`, `mov`, `webm`, `mkv` veya `avi` dosyası bırakın; görsellerin yanında görünecektir. Videolar OWE wallpaper engine tarafından oynatılır. Videoyu tüm monitörler için bir kez çözer, sesini varsayılan ses çıkışından oynatır ve hiçbir şey onu göremediğinde oynatmayı durdurur. Video duvar kağıdı yine de hareketsiz bir duvar kağıdından çok daha fazla güç tüketir.

Temalar, hareketsiz bir arka plan için kısa bir giriş içerebilir. `backgrounds/road.webp` için eşleşen video `backgrounds/intros/road.mp4` konumunda bulunur. Açılışta, o arka planın seçili olduğu bir temaya geçildiğinde ve o arka plan seçildiğinde otomatik olarak oynar, ardından hareketsiz görsele döner. Giriş videoları arka plan seçicinin dışında kalır ve asla döngüye girmez.

_Appearance > Animations Off_ seçeneğini seçmek arka plan girişlerini de kapatır. Omarchy bunu bir virtual machine içinde varsayılan olarak yapar. `omarchy theme bg intro toggle` komutu girişleri ayrı olarak açıp kapatabilir. Bir temayı yenilemek giriş oynatmaz.

Hareketsiz bir görselin bir döngüsü de olabilir; aynı resmin sürekli hareket eden sessiz bir sürümü, `backgrounds/loops/road.mp4` konumunda bulunur. Varsa girişinden sonra hareketsiz görselin yerine oynar ve animasyonlar kapatıldığında durur. Pil ile çalışırken bunun yerine hareketsiz görsel gösterilir ve fişe taktığınızda döngü geri gelir. Döngüler arka plan seçicinin dışında kalır.

[dharmx/walls](https://github.com/dharmx/walls) içinde özenle seçilmiş, harika arka planlardan oluşan devasa bir koleksiyon bulabilirsiniz.

Kilit ekranı, animasyonlu bir GIF'in hareketsiz bir karesini gösterdiği gibi, video arka planın da hareketsiz bir karesini gösterir.
