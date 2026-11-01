# Kabuk Araçları

Standart Linux araçlarına ek olarak Omarchy, bir sürü geliştirilmiş kabuk aracıyla da birlikte gelir. İşte temel olanlar.

## fzf

[fzf](https://junegunn.github.io/fzf/), `ff` takma adı aracılığıyla dosyalarda bulanık arama (fuzzy finding) yapmanızı sağlar. Herhangi bir dizine gidin, `ff` yazın ve sağ tarafta daralttığınız dosyaların önizlemesini görürken o ağaçtaki herhangi bir dosyaya bulanık aramayla ulaşabileceksiniz.

Komut geçmişinizde fzf ile bulanık arama yapmak için `Ctrl + R` tuşlarını kullanabilirsiniz.

Bu araç, `Space Space` yazdığınızda Neovim tarafından da kullanılır.

Tam kılavuzu `man fzf` ile bulabilirsiniz.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide), cd'nin yerine geçer. Bulunduğunuz dizinleri hatırlar, böylece bir dahaki sefere onlara daha kolay atlayabilirsiniz. Diyelim ki bir kez `cd ~/.config/omarchy` yaptınız. Bir dahaki sefere sadece `cd omarchy` (hatta sadece `cd oma`) yapabilirsiniz ve Zoxide sizi doğrudan oraya götürecektir.

Tam kılavuzu `man zoxide` ile bulabilirsiniz.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep), `rg <pattern> <path>` kullanarak dosyaların içeriğini arar; örneğin app dizinindeki tüm `Controller` sözcüklerini bulmak için `rg Controller app/` gibi.

Bu araç, `Space S G` yazdığınızda Neovim tarafından da kullanılır.

Tam kılavuzu `man rg` ile bulabilirsiniz.

## eza

[eza](https://eza.rocks/), ls'nin yerine geçer. Size daha fazla bilgi, renk ve simge içeren dizin listeleri verir. Varsayılan olarak eza, ls olarak takma adlanmıştır. İki düzey derinliğinde iç içe liste almak için `lt` de kullanabilirsiniz. `lsa` size gizli dosyaları içeren bir liste verir. Ve `lta`, gizli dosyalarla birlikte iç içe bir liste verir.

Tam kılavuzu `man eza` ile bulabilirsiniz.

## fd

[fd](https://github.com/sharkdp/fd), kullanımı daha kolay bir `find` alternatifidir. Geçerli ağaç içinde `person.rb` adlı bir dosyayı bulmak için `fd person.rb` kullanın. `fd person.rb /` tüm dosya sistemini arayacaktır. `fd person.rb / -H`, gizli dizinler dahil tüm dosya sistemini arar.

Tam kılavuzu `man fd` ile bulabilirsiniz.

## bat

[bat](https://github.com/sharkdp/bat), sözdizimi vurgulama, satır numaraları ve sayfalama özelliklerine sahip `cat`'tir. `bat somefile.rb` komutunu çalıştırın ve geri dönmenin neden zor olduğunu göreceksiniz. Ayrıca başka yerlerde de sessizce sizin için çalışır: man sayfalarınızı renklendiren ve `ff` içindeki önizlemeleri oluşturan odur.

Tam kılavuzu `man bat` ile bulabilirsiniz.

## tldr

[tldr](https://tldr.sh/), size tek bir örnek göstermeden önce üç ekran tarihle açılan man sayfalarının panzehiridir. `tldr tar`, size gerçekten istediğiniz bir avuç çağrıyı verir.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp), YouTube ve yüzlerce başka siteden video indirir. `yt-dlp <url>`, mevcut en iyi kaliteyi geçerli dizine indirir.

Tam kılavuzu `man yt-dlp` ile bulabilirsiniz.

## try

[try](https://github.com/tobi/try), programlama deneylerini tarih damgalı dizinlerle yönetmeyi kolaylaştırır. Tüm deneyler `~/Work/tries` içinde yaşar ve onlara `try` aracılığıyla erişebilirsiniz.

Omarchy, bir projenin `bin/` dizinini `PATH`'e otomatik olarak eklemez. Güvenilir proje-yerel araçları, `bin/rails` veya `./bin/dev` gibi açık bir göreli yolla çalıştırın.
