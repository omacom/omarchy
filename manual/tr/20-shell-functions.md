# Kabuk İşlevleri

Omarchy, yaygın görevleri basitleştirmek ve karmaşık parametre çağrılarını kapsüllemek için bir dizi kabuk işleviyle birlikte gelir.

## Sıkıştırma

- `compress [file/dir]`: Dosya/dizinden bir tar.gz arşivi oluşturun.
- `decompress [file.tar.gz]`: Bir tar.gz dosyasını genişletin.

## Sürücüler

- `iso2sd [image.iso]`: Başvurulan iso dosyasını kullanarak ve sürücüyü etkileşimli olarak seçerek bir SD kart üzerinde önyüklenebilir bir sürücü oluşturun.
- `format-drive [device] [name]`: Tüm bir diski tek bir exFAT bölümüyle biçimlendirin (bu, Windows ve macOS'ta da çalışır). Kullanılabilir sürücüleri görmek için argümansız çalıştırın. Dikkatli olun!

## Geliştirme düzenleri

tmux için anında çok bölmeli geliştirme düzenleri:

- `tdl [ai]`: Editörünüz, bir AI ajanı ve bir terminal ile bir Tmux Dev Layout oluşturun. opencode için `tdl c` veya Claude Code için `tdl cx` gibi ajan takma adlarını kullanın ya da ikisini birden çalıştırmak için ikinci bir ajan geçirin, örneğin `tdl c cx`.
- `tds`: Editör, diff izleme (`hunk diff --watch` aracılığıyla), terminal ve opencode ile bir Tmux Dev Square oluşturun.
- `tdlm [ai]`: Geçerli dizindeki her alt dizin için bir `tdl` penceresi oluşturun.
- `tsl [count] [command]`: Tümü aynı komutu çalıştıran, bir ızgara halinde döşenmiş bir bölme sürüsü oluşturun (AI ajanları için harika).

Aynı düzenler Herdr için `hdl`, `hds`, `hdlm` ve `hsl` olarak da kullanılabilir.

## Git worktree'leri

- `ga [branch]`: Geçerli deponun yanında yeni bir worktree ve dal oluşturun ve içine atlayın.
- `gd`: Geçerli worktree'yi ve dalını kaldırın (önce onay ister).

## Rsync izleyicileri

- `rsw [source] [destination]`: Bir şey değiştiğinde kaynağı hedefe rsync'leyen bir arka plan izleyicisi başlatın. Hedef uzak bir ana bilgisayar olabilir, örneğin `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Tüm etkin izleyicileri listeleyin.
- `dsw`: Tüm etkin izleyicileri durdurun.

## SSH Port Yönlendirme

Uzak bir kutuya karşı localhost güvenli bağlam ayrıcalıklarıyla web geliştirme yapmak için idealdir.

- `fip`: Bir veya daha fazla bağlantı noktasını uzak bir ana bilgisayardan SSH aracılığıyla localhost'a yönlendirin.
- `dip`: Yönlendirilen bir veya daha fazla bağlantı noktasının bağlantısını kesin.
- `lip`: Tüm etkin SSH port yönlendirmelerini listeleyin.

Diyelim ki `nyc-dev` olarak erişilebilen bir makinede `3000` numaralı bağlantı noktasında bir geliştirme sunucusu başlattınız, ardından o bağlantı noktasını yönlendirmek için `fip nyc-dev 3000` komutunu çalıştırabilirsiniz; böylece `localhost:3000` aslında `nyc-dev:3000` adresine ulaşır, ancak web soketlerini veya benzerlerini test etmek için gereken güvenli bağlamı oluşturmak üzere SSL sertifikalarına ihtiyaç duymadan.

## SSH yeniden bağlantısı

`ssh`'in kendisi, uzak bir tmux, Herdr veya editör terminali ele geçirmişken bir bağlantı ölürse terminali temizleyen ve ardından etkileşimli bir oturum düştüğünde otomatik olarak yeniden bağlanan bir işlevle sarmalanmıştır (Ctrl-C, yeniden deneme döngüsünü durdurur).
