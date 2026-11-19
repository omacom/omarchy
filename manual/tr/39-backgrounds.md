# Arka Planlar

Her tema kendi arka plan setiyle birlikte gelir ve siz de `~/.config/omarchy/backgrounds/[theme]` içine kendinize ait ekstralar ekleyebilirsiniz. Örneğin nord temasına ekstra bir arka plan görseli eklemek isterseniz, dosyayı `~/.config/omarchy/backgrounds/nord` içine koymanız yeterli.

Bunu en kolay şekilde Omarchy Menu'de _Install > Style > Background_ yolunu izleyerek yapabilirsiniz. Bu, o tema için arka planların saklandığı klasörü açar. Başka bir dosya yöneticisi başlatmak için `Super + Shift + F` tuşuna basın, arka planınızı bulun ve karşıya kopyalayın. Artık `Super + Ctrl + W` ile aralarında seçim yapabileceğiniz arka plan seçeneklerine dahil olacaktır.

Arka planlar hareketsiz görsellerin yanı sıra videolar da olabilir. Aynı klasöre bir `mp4`, `m4v`, `mov`, `webm`, `mkv` veya `avi` dosyası bırakın; görsellerin yanında görünecektir. Videolar OWE wallpaper engine tarafından oynatılır. Videoyu tüm monitörler için bir kez çözer, sesini varsayılan ses çıkışından çalar ve hiçbir şey onu göremediğinde oynatmayı durdurur. Bir video arka planı, hareketsiz bir arka plandan hâlâ çok daha fazla güç harcar.

Temalar, hareketsiz bir arka plan için kısa bir intro içerebilir. `backgrounds/road.webp` için eşleşen video `backgrounds/intros/road.mp4` konumunda bulunur. Açılışta, o arka planın seçili olduğu bir temaya geçildiğinde ve o arka plan seçildiğinde otomatik olarak oynar, ardından hareketsiz görsele döner. Intro videoları arka plan seçicinin dışında kalır ve asla döngüye girmez.

_Appearance > Animations_ seçeneğini kapatmak arka plan introlarını da kapatır. Omarchy bunu sanal bir makinede varsayılan olarak yapar. `omarchy theme bg intro toggle` komutu introları ayrıca açıp kapatabilir. Bir temayı yenilemek intro oynatmaz.

Hareketsiz bir görselin bir de loop'u olabilir; aynı resmin sürekli hareket eden sessiz bir sürümü, `backgrounds/loops/road.mp4` konumunda bulunur. Varsa introsundan sonra, hareketsiz görselin yerine oynar ve animasyonlar kapatıldığında durur. Loop'lar arka plan seçicinin dışında kalır ve herhangi bir video arka plan gibi hareketsiz bir görselden daha fazla güç harcar.

Harika seçilmiş arka planlardan oluşan devasa bir koleksiyonu [dharmx/walls](https://github.com/dharmx/walls) adresinde bulabilirsiniz.

Kilit ekranı, bir video arka planının hareketsiz bir karesini gösterir; tıpkı animasyonlu bir GIF'in hareketsiz bir karesini gösterdiği gibi.
