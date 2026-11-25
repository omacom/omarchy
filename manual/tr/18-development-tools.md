# Geliştirme Araçları

## Alternatif Editörler

Omarchy, yeni kurulumlarda varsayılan editör olarak Plain ile gelir ve [Neovim](https://neovim.io/) önceden kurulu olarak sunulur, ancak biraz daha yaygın ve tanıdık bir şey isterseniz Omarchy Menu'yü (`Super + Space`) çalıştırıp _Install > Editor_ altındaki seçeneklere bakabilirsiniz. Orada VSCode, Cursor, Zed, Sublime Text, Helix, Vim ve Emacs listelenmiştir. Aradığınızı bulamazsanız _Install > Package_ bölümüne bakın ve bir Arch paketinde olup olmadığını görün (yoksa AUR'u kontrol etmek için _Install > AUR_ seçeneğini deneyin).

Orijinal `vi` editörü de kutudan çıktığı gibi kullanılabilir. Bir dosyayı terminalde düzenlemek için `vi filename` komutunu çalıştırın.

`VSCode`, `Cursor`, `VSCodium` ve `Helix` için tema eşleştirme sunulur.

Sistem genelindeki varsayılan editörü `Setup > Defaults > Editor` altından ayarlayabilirsiniz.

## Ortam

Omarchy, Omarchy Menu'nün (`Super + Space`) _Install > Development_ bölümü üzerinden çok sayıda geliştirme ortamının kurulmasını destekler. Elbette _Ruby on Rails_ bulacaksınız, ancak JavaScript için üç büyük çalışma zamanının tamamını (Node.js, Bun, Deno) ve Laravel ve Symfony gibi popüler PHP framework'lerini de bulacaksınız. Ha, bir de Go, Rust, Python, Java, Elixir (Phoenix ile birlikte), .NET, OCaml, Zig, Clojure ve Scala da var. Çok geniş bir seçki!

Bu ortamların çoğu [Mise](https://mise.jdx.dev/) tarafından yönetilir. Aynı makinede bir programlama dilinin birden fazla sürümünü kurup çalıştırmanızı sağlayan bir araçtır. Ruby için rbenv veya rvm, Python için virtualenv gibidir, ancak bir sürü farklı ortam için çalışır.

Örneğin Ruby kurmak için `mise use -g ruby` çalıştırırsınız; bu hem Ruby'yi kurar hem de genel varsayılan olarak ayarlar. Ya da projenizde bir .ruby-version dosyası varsa, o projenin kök dizininde `mise i` çalıştırmanız yeterlidir.

## Önceden Kurulu CLI Araçları

`uv`, Node.js ve `playwright-cli` (ajanların kurulu Chrome'u kullanarak bir tarayıcıyı kontrol etmesi için) paket olarak kurulu gelir ve `omarchy update` bunları sistemin geri kalanıyla birlikte güncel tutar. [Hunk](https://github.com/modem-dev/hunk) ile GitHub, Basecamp, Cloudflare ve HEY CLI'ları _Install > CLI_ altında bir seçim uzağınızda, [kodlama ajanları](17-ai.md) ise _Install > AI > CLI_ altındadır.

mise yalnızca _Install > Development_ bölümünden kurduğunuz çalışma zamanlarını yönetir; Omarchy kendi başına onun üzerinden hiçbir şey kurmaz. Bunları Omarchy'nin geri kalanıyla birlikte güncellemek için `omarchy update` çalıştırın; `mup` alias'ı yalnızca mise tarafından yönetilen araçları günceller. Kendi yapılandırmanıza başka bir araç eklemek için `mise use -g <tool>` kullanın.

## Docker

[Docker](https://www.docker.com/) pek tanıtıma ihtiyaç duymaz. Yalıtılmış konteynerler çalıştırmanızı sağlar ve Omarchy, Docker'ın kendisi ve [Docker Compose](https://docs.docker.com/compose/) dahil, onu iyi çalıştırmak için gereken her şeyi kurar.

Varsayılan olarak kullanıcınız `docker` grubunda *değildir*. Bu grup fiilen parolasız root'tur — içindeki her şey `docker run -v /:/host` çalıştırıp makineyi ele geçirebilir — bu yüzden siz olarak çalışan tek bir kötü niyetli script veya bağımlılık, aksi takdirde root'a bir komut uzakta olurdu. Bu nedenle komut satırında Docker'ı `sudo` ile çalıştırırsınız (`sudo docker ps`, `sudo docker compose up`) ve daemon ile konuşan grafik araçlar — Windows VM — gerektiğinde sizden yetkilendirme ister. Grupsuz kurulumun rahatlığını geri istiyorsanız ve bu ödünleşimi anlıyorsanız, bunu **Setup > Security > Sudoless Docker** bölümünden etkinleştirin (veya `omarchy-setup-security-sudoless-docker` çalıştırın); bu, bir uyarının ardından sizi `docker` grubuna ekler; ardından düz `docker` ve `d` alias'ı yine `sudo` olmadan çalışır.

Omarchy menüsündeki _Install > Development > Docker DB_ seçeneğini kullanarak yerel geliştirme için yaygın veritabanlarını Docker'da kurabilirsiniz.

## GitHub CLI

[GitHub CLI](https://cli.github.com/), terminalden repository'ler, issue'lar ve pull request'lerle çalışmak için kullanılan `gh` aracıdır. _Setup > Git_, orada GitHub'da oturum açmayı seçtiğinizde onu kurar veya tek başına _Install > CLI > GitHub_ bölümünden kurabilirsiniz. Ardından `gh repo clone org/repo` bir repository'yi klonlar; komutlarını keşfetmek için `gh --help` çalıştırın.

[Lazygit](https://github.com/jesseduffield/lazygit), Git'in kendisiyle çalışmak için önceden kurulu gelir.
