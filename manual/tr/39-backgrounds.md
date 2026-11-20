# Arka Planlar

Her tema kendi arka plan setiyle gelir ve `~/.config/omarchy/backgrounds/[theme]` içine kendinize ait ek arka planlar ekleyebilirsiniz. Örneğin nord temasına ekstra bir arka plan görseli eklemek isterseniz, dosyayı `~/.config/omarchy/backgrounds/nord` içine koymanız yeterli.

Bunu yapmanın en kolay yolu, Omarchy Menu'de _Yükle > Stil > Arka Plan_ bölümüne gitmektir. Bu, o temaya ait arka planların saklandığı klasörü açar. Başka bir dosya yöneticisi başlatmak için `Super + Shift + F` tuşuna basın, arka planınızı bulun ve buraya kopyalayın. Artık `Super + Ctrl + W` ile aralarında seçim yapabileceğiniz arka plan seçeneklerine dahil edilecektir.

Arka planlar, durağan görsellerin yanı sıra videolar da olabilir. Aynı klasöre bir `mp4`, `m4v`, `mov`, `webm`, `mkv` veya `avi` dosyası bırakın; görsellerin yanında görünür. Videolar, OWE duvar kağıdı motoru tarafından oynatılır. Videoyu tüm monitörler için bir kez çözer, sesini varsayılan ses çıkışından oynatır ve hiçbir şey onu göremediğinde oynatmayı durdurur. Bir video duvar kağıdı yine de durağan bir duvar kağıdından çok daha fazla güç harcar.

Temalar, durağan bir arka plan için kısa bir giriş içerebilir. `backgrounds/road.webp` için eşleşen video, `backgrounds/intros/road.mp4` konumunda bulunur. Başlangıçta, o arka planın seçili olduğu bir temaya geçtiğinizde ve o arka planı seçtiğinizde otomatik olarak oynatılır, ardından durağan görsele döner. Giriş videoları arka plan seçicisinde yer almaz ve asla döngüye girmez.

_Görünüm > Animasyonlar_ seçeneğini kapatmak, arka plan girişlerini de kapatır. Omarchy bunu bir sanal makinede varsayılan olarak yapar. `omarchy theme bg intro toggle` komutu, girişleri ayrı olarak açıp kapatabilir. Bir temayı yenilemek bir giriş oynatmaz.

Bir durağan görselin, aynı resmin hareket etmeye devam eden sakin bir sürümü olan bir döngüsü de olabilir; bu, `backgrounds/loops/road.mp4` konumunda bulunur. Durağan görselin yerine, varsa girişinden sonra oynar ve animasyonlar kapatıldığında durur. Pille çalışırken onun yerine durağan görsel görünür ve fişe taktığınızda döngü geri gelir. Döngüler arka plan seçicisinde yer almaz.

Özenle seçilmiş, harika arka planlardan oluşan devasa bir koleksiyonu [dharmx/walls](https://github.com/dharmx/walls) içinde bulabilirsiniz.

Kilit ekranı, bir video arka planının durağan bir karesini gösterir; animasyonlu bir GIF'in durağan bir karesini göstermesiyle aynı şekilde.
