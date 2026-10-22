# Geliştirme Araçları

## Alternatif Editörler

Omarchy varsayılan olarak [Neovim](https://neovim.io/) ile gelir, ancak biraz daha yaygın ve aşina olduğunuz bir şey isterseniz Omarchy Menüsünü (`Super + Space`) açıp _Kur > Editor_ altındaki seçeneklere bakabilirsiniz. Orada VSCode, Cursor, Zed, Sublime Text, Helix, Vim ve Emacs listelenir. Aradığınızı bulamazsanız _Kur > Package_ bölümüne bakın ve bir Arch paketinde olup olmadığını kontrol edin (yoksa AUR'u kontrol etmek için _Kur > AUR_ seçeneğini deneyin).

Orijinal `vi` editörü de kutudan çıktığı gibi kullanılabilir. Terminalde bir dosyayı düzenlemek için `vi filename` komutunu çalıştırın.

Tema eşleştirme `VSCode`, `Cursor`, `VSCodium` ve `Helix` için sunulur.

Sistem genelindeki varsayılan editörü `Setup > Defaults > Editor` altında ayarlayabilirsiniz.

## Ortam

Omarchy, Omarchy Menüsünün (`Super + Space`) _Kur > Development_ bölümü aracılığıyla çok sayıda geliştirme ortamı kurmayı destekler. Elbette _Ruby on Rails_ bulacaksınız, ancak JavaScript için üç büyük çalışma zamanının (Node.js, Bun, Deno) yanı sıra Laravel ve Symfony gibi popüler PHP framework'lerini de bulacaksınız. Ah, bir de Go, Rust, Python, Java, Elixir (Phoenix ile), .NET, OCaml, Zig, Clojure ve Scala var. Çok geniş bir seçim!

Bu ortamların çoğu [Mise](https://mise.jdx.dev/) tarafından yönetilir. Bu araç, aynı makinede bir programlama dilinin birden çok sürümünü kurup çalıştırmanızı sağlar. Ruby için rbenv veya rvm'ye ya da Python için virtualenv'e benzer, ancak bir sürü farklı ortam için çalışır.

Örneğin Ruby kurmak için `mise use -g ruby` komutunu çalıştırırsınız; bu hem Ruby'yi kurar hem de genel varsayılan olarak ayarlar. Ya da projenizde bir .ruby-version dosyası varsa, o projenin kökünde `mise i` komutunu çalıştırmanız yeterlidir.

## Docker

[Docker](https://www.docker.com/) pek tanıtıma ihtiyaç duymaz. Yalıtılmış kapsayıcılar çalıştırmanızı sağlar ve Omarchy, Docker'ın kendisi ve [Docker Compose](https://docs.docker.com/compose/) dahil olmak üzere onu iyi çalıştırmak için gereken her şeyi kurar.

Varsayılan olarak kullanıcınız `docker` grubunda *değildir*. Bu grup fiilen parolasız root'tur — içindeki herhangi bir şey `docker run -v /:/host` çalıştırıp makineyi ele geçirebilir — bu yüzden sizin adınıza çalışan tek bir kötü niyetli betik veya bağımlılık, aksi takdirde root'a tek komut uzaklıkta olurdu. Bu nedenle komut satırında Docker'ı `sudo` ile çalıştırırsınız (`sudo docker ps`, `sudo docker compose up`) ve daemon ile konuşan grafik araçlar — Windows VM — gerektiğinde yetkilendirme ister. Grupsuz kurulumun kolaylığına geri dönmek isterseniz ve ödünleşimi anlıyorsanız, bunu **Setup > Security > Sudoless Docker** bölümünden etkinleştirin (veya `omarchy-setup-security-sudoless-docker` komutunu çalıştırın); bu, bir uyarının ardından sizi `docker` grubuna ekler; ardından düz `docker` ve `d` takma adı yeniden `sudo` olmadan çalışır.

Yerel geliştirme için yaygın veritabanlarını Docker'da, Omarchy menüsündeki _Kur > Development > Docker DB_ seçeneğini kullanarak kurabilirsiniz.

## GitHub CLI

[GitHub CLI](https://cli.github.com/), GitHub hesabınızla kimlik doğrulaması yapmanızı ve bunu kullanarak özel depoları klonlamanızı sağlar. Tembel yüklenen mise taslaklarından biri olarak bağlanmıştır, bu yüzden `gh` komutunu ilk çalıştırdığınızda kendini kurar. Kimlik doğrulaması için `gh auth login` komutunu çalıştırın. Ardından `gh repo clone org/repo` kullanarak özel depoları çekebilirsiniz.

Bu komutu kullanarak bir sürü başka GitHub işlemi de gerçekleştirebilirsiniz. Mümkün olan her şeyi görmek için `gh` komutunu çalıştırmanız yeterlidir.

Pull request'lerinizi bir TUI içinde yönetmek için tembel kurulumlu bir `ghui` taslağı da vardır. Ve git'in kendisini de bir TUI'dan kullanmak isterseniz [lazygit](https://github.com/jesseduffield/lazygit) önceden kurulu olarak gelir.
