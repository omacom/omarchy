# Neovim

[Neovim](https://neovim.io/), Bill Joy tarafından 1976'da oluşturulan [vi editörünün](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) modern bir uygulamasıdır. Ekleme modu ile komut modunun ayrıldığı kip editörüdür ve inanılmaz derecede derin tuş komut kümesinin yalnızca bir alt kümesini bile öğrendiğinizde adeta bir süper güçtür. Ama öğrenme eğrisi de oldukça diktir!

Vim tarzı düzenlemede tamamen yeniyseniz, YouTube'daki [ThePrimeagen'ın Vim As Your Editor serisini](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) izlemenizi öneririm. Bu size temelleri öğretecektir. Sadece, daha benzer ana akım editörlerin aksine, vim ile temel yeterliliğe ulaşmanın daha uzun süreceğini bilin. Ama bunu yaptığınızda, getirisi de daha büyüktür.

Şimdi Neovim temelde sonsuz şekilde yapılandırılabilirdir. Gerçekten çılgınlaşmak isterseniz, kendi Neovim yapılandırmanızı sıfırdan oluşturabilirsiniz. [Typecraft'tan Neovim'i sıfırdan kurmak üzerine harika bir kurs](https://www.youtube.com/watch?v=zHTeCSVAFNY) var. Ve [ThePrimeagen'ın da biri var](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ancak Omarchy, kutudan çıktığı haliyle mümkün olanın en iyisini sergilemek için sevgiyle ayarlanmış eksiksiz bir Neovim kurulumuyla — `omarchy-nvim` paketi — birlikte gelir. Tek bir satır yapılandırma yazmanız gerekmeden! Neovim eklentileri ve yapılandırmalarının bir dağıtımı olan [LazyVim](https://www.lazyvim.org/) üzerine kuruludur. Harika.

## LazyVim Temelleri

Bahsettiğim gibi, bu kısa girişte size vim öğretmeyeceğim, ancak LazyVim'in birkaç temelini ve nasıl dolaşacağınızı gösterebilirim.

Önce, Neovim'de lider tuşu fikri vardır. Bu temelde tüm komutlara açılan kapıdır. LazyVim bunu `Space` olarak ayarlamış. Yani sadece buna basın, bir saniye bekleyin ve şöyle satır içinde açıklanan bir grup seçenek göreceksiniz:

İşte her zaman kullandığım bazı temel komutlar:

- `Space Space` - Geçerli dizindeki herhangi bir dosyayı bulanık bul.
- `Space S G` - Önizleme ile grep kullanarak tüm dosyaları ara.
- `Space E` - Dosya ağacını aç/kapat.
- `Ctrl + W W` - Dosya ağacından editöre ve geri atla.
- `Shift + H` - Açık sekmeler (vim bunlara arabellek der) arasında sola git.
- `Shift + L` - Açık sekmeler arasında sağa git.
- `Space B D` - Bir sekmeyi kapat.
- `Space B O` - Geçerli sekme dışındaki tüm sekmeleri kapat.
- `Space G G` - LazyGit'i geçerli dizinden yüzen bir bölmede başlat.
- `Space U W` - Yumuşak sarmayı aç/kapat.

Dosya ağacındayken (göstermek için `Space E`, oraya atlamak için `Ctrl + W W`), `a` ile yeni bir dosya veya `A` ile yeni bir dizin ekleyebilirsiniz. Tüm komutları görmek için ağaçtayken `?` tuşuna basın.

Temel vim dilini edinmek isterseniz, [üç parçalı sözdizimi](https://world.hey.com/dhh/wonderful-vi-a1d034d3) ve o müthiş kombo hareketleri nasıl yapacağınız hakkında yazdım!

Olası tüm komutları [LazyVim Keymaps sayfasında](https://www.lazyvim.org/keymaps) görebilirsiniz.

## Neovim'i Başlatmak

Neovim'i `Super + Shift + N` kullanarak başlatabilirsiniz (bağlama varsayılan editörünüzü başlatır ki bu kutudan çıktığı haliyle Neovim'dir), ancak genellikle onu terminalden çalışmak istediğiniz dizine gidip `n` yazarak sürmek daha kolaydır. `n`, varsayılan olarak mevcut dizini açmak için kullanan `nvim` için takma addır. Tek bir dosyayı `n myfile.txt` ile açabilirsiniz.

## sudo düzenlemeleri için Neovim kullanmak

Yalnızca süper kullanıcı olarak değiştirebileceğiniz dosyaları düzenlemeniz gerekirse, `sudoedit /etc/sudoers.d/00-sudo-only-file` çalıştırarak tüm eklentileriniz kurularak neovim'i kullanabilirsiniz.
