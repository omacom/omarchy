# Geliştirme Araçları

## Alternatif Editörler

Omarchy, yeni kurulumlarda varsayılan editör olarak Plain ile gelir ve [Neovim](https://neovim.io/) önceden kuruludur, ancak biraz daha yaygın ve tanıdık bir şey isterseniz Omarchy Menüsünü (`Super + Space`) çalıştırıp _Yükle > Editör_ altındaki seçeneklere bakabilirsiniz. Orada VSCode, Cursor, Zed, Sublime Text, Helix, Vim ve Emacs listeleniyor. Aradığınızı bulamazsanız _Yükle > Paket_ bölümüne bakın ve bir Arch paketinde olup olmadığını görün (yoksa AUR'u kontrol etmek için _Yükle > AUR_ seçeneğini deneyin).

Orijinal `vi` editörü de kutudan çıktığı gibi kullanılabilir. Bir dosyayı terminalde düzenlemek için `vi filename` komutunu çalıştırın.

`VSCode`, `Cursor`, `VSCodium` ve `Helix` için tema eşleştirme sunulur.

Sistem genelinde varsayılan editörü `Setup > Defaults > Editor` altında ayarlayabilirsiniz.

## Ortam

Omarchy, Omarchy Menüsünün (`Super + Space`) _Yükle > Geliştirme_ bölümü üzerinden çok sayıda geliştirme ortamı kurmayı destekler. Elbette _Ruby on Rails_ bulacaksınız, ancak JavaScript için üç büyük çalışma zamanının tamamı (Node.js, Bun, Deno) ve Laravel ve Symfony gibi popüler PHP framework'leri de var. Ha, Go, Rust, Python, Java, Elixir (Phoenix ile birlikte), .NET, OCaml, Zig, Clojure ve Scala da var. Çok geniş bir seçim!

Bu ortamların çoğu [Mise](https://mise.jdx.dev/) tarafından yönetilir. Aynı makineye bir programlama dilinin birden fazla sürümünü kurup çalıştırmanızı sağlayan bir araçtır. Ruby için rbenv veya rvm ya da Python için virtualenv gibidir, ancak bir sürü farklı ortam için çalışır.

Örneğin Ruby kurmak için `mise use -g ruby` komutunu çalıştırırsınız; bu hem Ruby'yi kurar hem de onu genel varsayılan olarak ayarlar. Ya da projenizde bir .ruby-version dosyası varsa, o projenin kök dizininde `mise i` komutunu çalıştırmanız yeterlidir.

## Önceden Kurulu CLI Araçları

`uv`, Node.js ve `playwright-cli` (ajanların kurulu Chrome'u kullanarak bir tarayıcıyı kontrol etmesi için) paket olarak kurulu gelir ve `omarchy update` bunları sistemin geri kalanıyla birlikte güncel tutar. `ghui`, [Hunk](https://github.com/modem-dev/hunk) ve Basecamp, Cloudflare ve HEY CLI'ları _Yükle > CLI_ altında bir seçim uzağınızda, [kodlama ajanları](17-ai.md) ise _Yükle > AI > CLI_ altındadır.

mise yalnızca _Yükle > Geliştirme_ bölümünden kurduğunuz çalışma zamanlarını yönetir; Omarchy kendi başına onun üzerinden hiçbir şey kurmaz. Bunları Omarchy'nin geri kalanıyla birlikte güncellemek için `omarchy update` komutunu çalıştırın; `mup` takma adı yalnızca mise tarafından yönetilen araçları günceller. Kendi yapılandırmanıza başka bir araç eklemek için `mise use -g <tool>` kullanın.

## Docker

[Docker](https://www.docker.com/) pek tanıtıma ihtiyaç duymaz. Yalıtılmış konteynerler çalıştırmanızı sağlar ve Omarchy, Docker'ın kendisi ve [Docker Compose](https://docs.docker.com/compose/) dahil, onu iyi çalıştırmak için gereken her şeyi kurar.

Varsayılan olarak kullanıcınız `docker` grubunda *değildir*. Bu grup fiilen parolasız root'tur — içindeki her şey `docker run -v /:/host` çalıştırıp makineyi ele geçirebilir — bu yüzden siz olarak çalışan tek bir kötü amaçlı script veya bağımlılık, aksi takdirde root'a bir komut uzakta olurdu. Bu nedenle komut satırında Docker'ı `sudo` ile çalıştırırsınız (`sudo docker ps`, `sudo docker compose up`) ve arka plan hizmetiyle konuşan grafik araçlar — Windows VM — gerektiğinde sizden yetki ister. Grupsuz kurulum rahatlığını geri istiyorsanız ve bu ödünleşimi anlıyorsanız, bunu **Kurulum > Güvenlik > Sudoless Docker** bölümünden etkinleştirin (veya `omarchy-setup-security-sudoless-docker` komutunu çalıştırın); bu, bir uyarının ardından sizi `docker` grubuna ekler; ardından sade `docker` ve `d` takma adı tekrar `sudo` olmadan çalışır.

Yerel geliştirme için yaygın veritabanlarını Docker'da Omarchy menüsündeki _Yükle > Geliştirme > Docker DB_ ile kurabilirsiniz.

## GitHub CLI

[GitHub CLI](https://cli.github.com/), terminalden depolar, issue'lar ve pull request'lerle çalışmak için kullanılan `gh` aracıdır. _Kurulum > Git_, orada GitHub'da oturum açmayı seçtiğinizde onu kurar, ardından `gh repo clone org/repo` bir depoyu klonlar. Komutlarını keşfetmek için `gh --help` komutunu çalıştırın.

_Yükle > CLI > GitHub_, GitHub CLI'ı, `gh` ile birlikte pull request'ler için bir terminal arayüzü olan `ghui`yi kurar. [Lazygit](https://github.com/jesseduffield/lazygit), Git'in kendisiyle çalışmak için önceden kuruludur.
