# Neovim

[Neovim](https://neovim.io/), Bill Joy tarafından ta 1976'da yaratılan [vi editörünün](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) modern bir uygulamasıdır. Ekleme modu ile komut modunun birbirinden ayrıldığı modal bir editördür ve inanılmaz derecede derin tuş komutu setinin yalnızca bir alt kümesini bile öğrenseniz adeta bir süper güce dönüşür. Ama öğrenme eğrisi de epey diktir!

vim tarzı düzenlemeye tamamen yeniyseniz, YouTube'da [ThePrimeagen'ın Vim As Your Editor serisine](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) göz atmanızı öneririm. Bu size temel bilgileri öğretecektir. Şunu bilin ki, daha alışıldık ana akım editörlerin aksine, vim'de temel yeterliliğe ulaşmanız daha uzun sürecektir. Ama ulaştığınızda, karşılığı da daha büyük olur.

Şimdi Neovim temelde sonsuz derecede yapılandırılabilir. Gerçekten işi çılgınlığa vurmak isterseniz, kendi Neovim yapılandırmanızı sıfırdan oluşturabilirsiniz. [Typecraft'ın Neovim'i sıfırdan kurma konusunda harika bir kursu](https://www.youtube.com/watch?v=zHTeCSVAFNY) var. [ThePrimeagen'ın da bir tane kursu var](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ama Omarchy, kutudan çıktığı haliyle mümkün olanın en iyisini sergilemek üzere özenle ayarlanmış eksiksiz bir Neovim kurulumuyla — `omarchy-nvim` paketiyle — geliyor. Tek bir satır yapılandırma yazmanıza gerek kalmadan! Neovim eklentileri ve yapılandırmalarından oluşan bir dağıtım olan [LazyVim](https://www.lazyvim.org/) üzerine inşa edilmiştir. Müthiş bir şey.

## LazyVim Temelleri

Belirtildiği gibi, bu kısa tanıtımda size vim öğretmeyeceğim, ama LazyVim'in birkaç temelini ve nasıl gezineceğinizi gösterebilirim.

Öncelikle, Neovim'de leader tuşu fikri var. Bu temelde tüm komutlara açılan kapıdır. LazyVim bunu `Space` olarak ayarlamıştır. Yani sadece ona basın, bir saniye bekleyin, bir sürü seçeneğin satır içinde şöyle açıklandığını göreceksiniz:

Sürekli kullandığım bazı temel komutlar şunlardır:

- `Space Space` - Geçerli dizindeki herhangi bir dosyayı bulanık aramayla bulun.
- `Space S G` - Tüm dosyaları grep kullanarak önizlemeyle arayın.
- `Space E` - Dosya ağacını açıp kapatın.
- `Ctrl + W W` - Dosya ağacı ile editör arasında gidip gelin.
- `Shift + H` - Açık sekmeler (vim bunlara buffers der) arasında sola gidin.
- `Shift + L` - Açık sekmeler arasında sağa gidin.
- `Space B D` - Bir sekmeyi kapatın.
- `Space B O` - Geçerli sekme dışındaki tüm sekmeleri kapatın.
- `Space G G` - Geçerli dizinden kayan bir bölmede LazyGit'i başlatın.
- `Space U W` - Yumuşak kaydırmayı açıp kapatın.

Dosya ağacındayken (görüntülemek için `Space E`, oraya geçmek için `Ctrl + W W`), `a` ile yeni bir dosya veya `A` ile yeni bir dizin ekleyebilirsiniz. Tüm komutları görmek için ağaçtayken `?` tuşuna basın.

Temel vim dilini kapmak isterseniz, [üç parçalı sözdizimi](https://world.hey.com/dhh/wonderful-vi-a1d034d3) ve o müthiş kombo hareketlerini nasıl yapacağınız hakkında yazdım!

Tüm olası komutları [LazyVim Keymaps sayfasında](https://www.lazyvim.org/keymaps) görebilirsiniz.

## Neovim'i Başlatma

`Super + Shift + N` varsayılan editörünüzü başlatır; bu, yeni kurulumlarda Plain'dir; bunun yerine Neovim'i başlatması için _Setup > Defaults > Editor_ altında Neovim'i seçin. Ama genellikle onu terminalden, çalışmak istediğiniz dizine gidip `n` yazarak kullanmak daha kolaydır. `n`, varsayılan olarak geçerli dizini kullanarak açacak olan `nvim` komutunun takma adıdır. Tek bir dosyayı `n myfile.txt` ile açabilirsiniz.

## Neovim'i sudo düzenlemeleri için kullanma

Yalnızca süper kullanıcı olarak değiştirebileceğiniz dosyaları düzenlemeniz gerekirse, `sudoedit /etc/sudoers.d/00-sudo-only-file` komutunu çalıştırın. Varsayılan editörünüzü açar, bu yüzden tüm eklentilerinizle birlikte orada da Neovim'i istiyorsanız _Setup > Defaults > Editor_ altında Neovim'i ayarlayın.
