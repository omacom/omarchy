# Arka Planlar

Her tema kendi arka plan setiyle gelir ve `~/.config/omarchy/backgrounds/[theme]` içine kendi ekstralarınızı ekleyebilirsiniz. Örneğin nord temasına fazladan bir arka plan görüntüsü eklemek isterseniz, dosyayı `~/.config/omarchy/backgrounds/nord` içine koymanız yeterlidir.

Bunu en kolay şekilde Omarchy Menu içinde _Install > Style > Background_ yoluna giderek yapabilirsiniz. Bu, o temanın arka planlarının saklandığı klasörü açacaktır. Başka bir dosya yöneticisi başlatmak için `Super + Shift + F` tuşuna basın, arka planınızı bulun, oraya kopyalayın. Artık `Super + Ctrl + W` kullanarak aralarında seçim yapabileceğiniz arka plan seçeneklerine dahil edilecektir.

Kendine ait hiç arka planı olmayan bir tema, renklerinden çizilmiş bir tane alır: temanın arka plan rengi üzerinde, temanın vurgu renginde Omarchy logosu. Onun yerine geçmesi için kendinizinkini ekleyin.

Arka planlar hareketsiz görüntülerin yanı sıra videolar da olabilir. Aynı klasöre bir `mp4`, `m4v`, `mov`, `webm`, `mkv` veya `avi` dosyası bırakın, görüntülerin yanında görünecektir. Videolar OWE duvar kağıdı motoru tarafından oynatılır. Videoyu tüm monitörler için bir kez çözer, sesini varsayılan ses çıkışından oynatır ve hiçbir şey onu göremediğinde oynatmayı durdurur. Video duvar kağıdı yine de hareketsiz olandan çok daha fazla güce mal olur.

Temalar, hareketsiz bir arka plan için kısa bir giriş içerebilir. `backgrounds/road.webp` için eşleşen video `backgrounds/intros/road.mp4` konumunda bulunur. Açılışta, o arka planın seçili olduğu bir temaya geçildiğinde ve o arka plan seçildiğinde otomatik olarak oynar, ardından hareketsiz görüntüye döner. Giriş videoları arka plan seçicinin dışında kalır ve asla döngüye girmez.

_Appearance > Animations Off_ seçeneğini seçmek arka plan girişlerini de kapatır. Omarchy bunu bir sanal makinede varsayılan olarak yapar. `omarchy theme bg intro toggle` komutu girişleri ayrı olarak açıp kapatabilir. Bir temayı yenilemek bir giriş oynatmaz.

Hareketsiz bir görüntünün bir döngüsü de olabilir, aynı resmin hareket etmeye devam eden sakin bir sürümü, `backgrounds/loops/road.mp4` konumunda. Hareketsiz görüntünün yerine, varsa girişinden sonra oynar ve animasyonlar kapatıldığında durur. Pille çalışırken bunun yerine hareketsiz görüntü görünür ve fişe taktığınızda döngü geri gelir. Döngüler arka plan seçicinin dışında kalır.

[dharmx/walls](https://github.com/dharmx/walls) içinde devasa bir özenle seçilmiş harika arka plan koleksiyonu bulabilirsiniz.

Kilit ekranı, bir video arka planının hareketsiz bir karesini gösterir, tıpkı animasyonlu bir GIF'in hareketsiz bir karesini gösterdiği gibi.
