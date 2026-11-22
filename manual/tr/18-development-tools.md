# Geliştirme Araçları

## Alternatif Editörler

Omarchy, yeni kurulumlarda varsayılan editör olarak Plain ile gelir ve [Neovim](https://neovim.io/) önceden kuruludur, ama biraz daha yaygın ve tanıdık bir şey isterseniz Omarchy Menu'yü (`Super + Space`) çalıştırıp _Install > Editor_ altındaki seçeneklere bakabilirsiniz. Orada VSCode, Cursor, Zed, Sublime Text, Helix, Vim ve Emacs listelenmiştir. Aradığınızı bulamazsanız _Install > Package_ bölümüne bakın ve bir Arch paketinde olup olmadığını görün (ve yoksa, AUR'u kontrol etmek için _Install > AUR_ seçeneğini deneyin).

Orijinal `vi` editörü de kutudan çıktığı gibi kullanılabilir. Terminalde bir dosyayı düzenlemek için `vi filename` çalıştırın.

`VSCode`, `Cursor`, `VSCodium` ve `Helix` için tema eşleştirme sunulur.

Sistem genelindeki varsayılan editörü `Setup > Defaults > Editor` altında ayarlayabilirsiniz.

## Ortam

Omarchy, Omarchy Menu (`Super + Space`) içindeki _Install > Development_ bölümü üzerinden bir sürü geliştirme ortamı kurmayı destekler. Elbette _Ruby on Rails_ bulacaksınız, ama aynı zamanda JavaScript için üç büyük çalışma zamanının tamamını (Node.js, Bun, Deno) ve Laravel ve Symfony gibi popüler PHP framework'lerini de bulacaksınız. Ha, bir de Go, Rust, Python, Java, Elixir (Phoenix ile birlikte), .NET, OCaml, Zig, Clojure ve Scala var. Çok geniş bir seçki!

Bunların çoğu [Mise](https://mise.jdx.dev/) tarafından yönetilir. Aynı makinede bir programlama dilinin birden çok sürümünü kurup çalıştırmanızı sağlayan bir araçtır. Ruby için rbenv ya da rvm, Python için virtualenv gibidir, ama bir sürü farklı ortam için çalışır.

Diyelim ki Ruby kurmak için `mise use -g ruby` çalıştırırsınız; bu hem Ruby'yi kurar hem de küresel varsayılan olarak ayarlar. Ya da projenizde bir .ruby-version dosyası varsa, o projenin kök dizininde sadece `mise i` çalıştırabilirsiniz.

## Önceden kurulmuş CLI araçları

Omarchy, `gh`, `uv` gibi araçları ve [kodlama ajanlarının](17-ai.md) çoğunu [mise'ın tembel kurulumu](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) üzerinden kullanılabilir hale getirir. Bunlardan birini ilk kez çalıştırdığınızda mise onu kurar. Kodlama ajanları daha sonra çalışmadan önce, en fazla dört saatte bir, güncelleme olup olmadığını kontrol eder; `gh` ve `uv` gibi diğer araçlar ise siz güncelleyene kadar kurulu sürümü kullanmaya devam eder.

Varsayılanları inceleyebilir ya da önceden kurabilirsiniz:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Kurulu araçları Omarchy'nin geri kalanıyla birlikte güncellemek için `omarchy update` çalıştırın. `mup` takma adı yalnızca mise tarafından yönetilen araçları günceller. Kendi yapılandırmanıza başka bir araç eklemek için `mise use -g <tool>` kullanın.

Python kurulumu ayrıca mise üzerinden `uv` kurar. Python geliştirme ortamını kaldırmak, `uv` aracını bağımsız bir araç olarak kullanılabilir durumda bırakır.

### Kendi kurulumunuzu kullanma

mise'ın komutları `PATH` üzerinde `~/.local/bin` öncesinde geldiği için, örneğin Claude Code'un ya da Cursor'ın kendi yükleyicisiyle kendiniz kurduğunuz bir araç yine de mise'ın kopyasını çalıştırır. Masaüstünden başlatılan uygulamalar da mise'ın komutlarını sistem paketlerinden önce bulur; yani `gh` çalıştıran bir uygulama, `github-cli` paketini pacman ile kurmuş olsanız bile mise'ın kopyasını alır ve mise o kopyayı ilk seferde kurar. Bunun yerine kendinizinkini kullanmak için `~/.config/mise/config.toml` içinde mise'ın kopyasını devre dışı bırakın. Örneğin, Cursor CLI'ı kendiniz kurduysanız:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Zaten bir `[settings]` tablonuz varsa girdiyi oraya ekleyin; mevcut bir `disable_tools` listesini değiştirmek yerine genişletin. Kurulumunuzun `PATH` üzerinde olduğundan emin olun. Komutundan farklı olabilen mise araç adını kullanın: örneğin `oh-my-pi`, `omp` sağlar. Varsayılan ajan başlatıcısı da `~/.local/bin` içinde kullanıcı tarafından kurulmuş bir Cursor ya da Muse'u tercih eder.

### Varsayılanları kaldırma ve geri getirme

_Remove > Preinstalls_, Omarchy'nin önceden kurulmuş web uygulamalarını, TUI'lerini ve uygulamalarını kaldırır ve bunları `~/.config/mise/miserc.toml` içindeki `ignored_config_paths` listesine ekleyerek mise'ın kullanıcınız için Omarchy'nin araç bildirimlerini atlamasını sağlar. _Install > Preinstalls_ bunları geri getirir ve o satırı tekrar kaldırır. Kendi yapılandırmanızda ya da bir projenin `mise.toml` dosyasında kendiniz bildirdiğiniz araçlar her iki durumda da çalışmaya devam eder. Ön kurulumları kaldırdıktan sonra varsayılan bir ajan seçerseniz ya da Python kurarsanız, o araç kendi yapılandırmanıza eklenir. mise ayarı yalnızca sizin kullanıcınız için geçerlidir ve diğer kullanıcılar kendi seçimlerini korur; ancak uygulamalar paket olduğu için, onları kaldırmak ya da geri getirmek makinedeki herkes için değiştirir.

## Docker

[Docker](https://www.docker.com/) tanıtmaya pek gerek duymaz. Yalıtılmış konteynerler çalıştırmanızı sağlar ve Omarchy, Docker'ın kendisi ve [Docker Compose](https://docs.docker.com/compose/) dahil, onu iyi çalıştırmak için gereken her şeyi kurar.

Varsayılan olarak kullanıcınız `docker` grubunda *değildir*. O grup fiilen parolasız root demektir — içindeki her şey `docker run -v /:/host` çalıştırıp makineyi ele geçirebilir — yani sizin adınıza çalışan tek bir kötü niyetli betik ya da bağımlılık, aksi halde root'a bir komut uzakta olurdu. Bu yüzden komut satırında Docker'ı `sudo` ile çalıştırırsınız (`sudo docker ps`, `sudo docker compose up`) ve daemon ile konuşan grafik araçlar — Windows VM'i — gerektiğinde sizden yetki ister. Grupsuz kurulumun rahatlığını geri istiyorsanız ve ödün verdiğiniz şeyin farkındaysanız, bunu **Setup > Security > Sudoless Docker** üzerinden etkinleştirin (ya da `omarchy-setup-security-sudoless-docker` çalıştırın); bu, bir uyarının ardından sizi `docker` grubuna ekler; o zaman düz `docker` ve `d` takma adı tekrar `sudo` olmadan çalışır.

Yerel geliştirme için yaygın veritabanlarını Omarchy menüsündeki _Install > Development > Docker DB_ ile Docker'da kurabilirsiniz.

## GitHub CLI

[GitHub CLI](https://cli.github.com/), terminalden repository'ler, issue'lar ve pull request'lerle çalışmak için `gh` olarak kullanılabilir. İlk kullanımda kurmak ve kimlik doğrulaması yapmak için `gh auth login` çalıştırın, ardından bir repository'yi klonlamak için `gh repo clone org/repo` çalıştırın. Komutlarını keşfetmek için `gh --help` çalıştırın.

Pull request'ler için bir terminal arayüzü olarak `ghui` çalıştırın; mise onu da ilk kullanımda kurar. Git'in kendisiyle çalışmak için [Lazygit](https://github.com/jesseduffield/lazygit) önceden kuruludur.
