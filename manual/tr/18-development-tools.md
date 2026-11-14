# Geliştirme Araçları

## Alternatif Editörler

Omarchy varsayılan olarak [Neovim](https://neovim.io/) ile gelir, ama biraz daha yaygın ve tanıdık bir şey isterseniz, Omarchy Menu'yu (`Super + Space`) çalıştırıp _Install > Editor_ altındaki seçeneklere bakabilirsiniz. Orada VSCode, Cursor, Zed, Sublime Text, Helix, Vim ve Emacs listeleniyor. Aradığınızı bulamazsanız _Install > Package_ kısmına bakın ve bir Arch paketinde olup olmadığına bakın (ve yoksa, AUR'u kontrol etmek için _Install > AUR_ seçeneğini deneyin).

Orijinal `vi` editörü de kutudan çıkar çıkmaz kullanılabilir. Terminalde bir dosyayı düzenlemek için `vi filename` komutunu çalıştırın.

`VSCode`, `Cursor`, `VSCodium` ve `Helix` için tema eşleştirme sunulur.

Sistem genelinde varsayılan editörü `Setup > Defaults > Editor` altında ayarlayabilirsiniz.

## Ortam

Omarchy, Omarchy Menu'nun (`Super + Space`) _Install > Development_ bölümü üzerinden bir sürü geliştirme ortamının tamamını kurmayı destekler. Elbette _Ruby on Rails_ bulacaksınız, ama aynı zamanda JavaScript için üç büyük çalışma zamanının tamamını (Node.js, Bun, Deno) ve Laravel ve Symfony gibi popüler PHP framework'lerini de bulacaksınız. Ha, bir de Go, Rust, Python, Java, Elixir (Phoenix ile), .NET, OCaml, Zig, Clojure ve Scala var. Gerçekten çok geniş bir seçim!

Bu ortamların çoğunluğu [Mise](https://mise.jdx.dev/) tarafından yönetilir. Bu, aynı makinede bir programlama dilinin birden fazla sürümünü kurup çalıştırmanızı sağlayan bir araçtır. Ruby için rbenv veya rvm ya da Python için virtualenv gibidir, ama bir sürü farklı ortam için çalışır.

Örneğin Ruby kurmak için `mise use -g ruby` çalıştırırsınız; bu hem Ruby'yi kurar hem de onu global varsayılan olarak ayarlar. Ya da projenizde bir .ruby-version dosyası varsa, o projenin kök dizininde sadece `mise i` çalıştırabilirsiniz.

## Önceden kurulu CLI araçları

Omarchy, `gh`, `uv` ve çoğu [kodlama ajanı](17-ai.md) gibi araçları [mise's lazy installation](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) üzerinden kullanılabilir hale getirir. Bunlardan birini ilk kez çalıştırdığınızda mise onu kurar. Sonraki çalıştırmalar kurulu sürümü yeniden kullanır; her başlatışta güncelleme kontrolü yapmazlar.

Varsayılanları inceleyebilir veya onları önceden de kurabilirsiniz:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Kurulu araçları Omarchy'nin geri kalanıyla birlikte güncellemek için `omarchy update` çalıştırın. `mup` alias'ı yalnızca mise tarafından yönetilen araçları günceller. Kendi yapılandırmanıza başka bir araç eklemek için `mise use -g <tool>` kullanın.

Python kurulumu ayrıca mise üzerinden `uv` kurar. Python geliştirme ortamını kaldırmak, `uv` aracını bağımsız bir araç olarak kullanılabilir durumda bırakır.

### Kendi kurulumunuzu kullanma

mise'nin komutları `PATH` üzerinde `~/.local/bin` öncesinde gelir, bu yüzden örneğin Claude Code'un veya Cursor'ın kendi yükleyicisiyle kendiniz kurduğunuz bir araç yine de mise'nin kopyasını çalıştırır. Masaüstünden başlatılan uygulamalar da mise'nin komutlarını sistem paketlerinden önce bulur, bu yüzden `gh` çalıştıran bir uygulama, `github-cli` paketini pacman ile kurmuş olsanız bile mise'nin kopyasını alır ve mise o kopyayı ilk seferde kurar. Bunun yerine kendinizinkini kullanmak için mise'nin kopyasını `~/.config/mise/config.toml` içinde devre dışı bırakın. Örneğin, Cursor CLI'ı kendiniz kurduysanız:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Zaten bir `[settings]` tablonuz varsa, girişi oraya ekleyin; mevcut bir `disable_tools` listesini değiştirmek yerine onu genişletin. Kurulumunuzun `PATH` üzerinde olduğundan emin olun. Komutundan farklı olabilen mise araç adını kullanın: örneğin `oh-my-pi`, `omp` sağlar. Varsayılan ajan başlatıcısı da `~/.local/bin` içindeki kullanıcı tarafından kurulmuş bir Cursor veya Muse'u tercih eder.

### Varsayılanları kaldırma ve geri yükleme

_Remove Preinstalls_, mise'nin Omarchy'nin araç bildirimlerini kullanıcınız için atlamasını sağlar; bunu onları `~/.config/mise/miserc.toml` içindeki `ignored_config_paths` listesine ekleyerek yapar. _Restore Preinstalls_ o satırı tekrar kaldırır. Kendi yapılandırmanızda veya bir projenin `mise.toml` dosyasında kendiniz bildirdiğiniz araçlar her iki durumda da çalışmaya devam eder. Ön kurulumları kaldırdıktan sonra bir varsayılan ajan seçerseniz veya Python kurarsanız, o araç kendi yapılandırmanıza eklenir. Her ikisi de yalnızca kullanıcınız için geçerlidir; makinedeki diğer kullanıcılar kendi seçimlerini korur.

## Docker

[Docker](https://www.docker.com/) pek tanıtıma ihtiyaç duymaz. Yalıtılmış container'lar çalıştırmanızı sağlar ve Omarchy, Docker'ın kendisi ve [Docker Compose](https://docs.docker.com/compose/) dahil, onu iyi çalıştırmak için gereken her şeyi kurar.

Varsayılan olarak kullanıcınız `docker` grubunda *değildir*. O grup fiilen parolasız root'tur — içindeki her şey `docker run -v /:/host` çalıştırıp makineyi ele geçirebilir — bu yüzden sizin adınıza çalışan tek bir kötü niyetli script veya bağımlılık, aksi takdirde root'a bir komut uzakta olurdu. Bu yüzden komut satırında Docker'ı `sudo` ile çalıştırırsınız (`sudo docker ps`, `sudo docker compose up`) ve daemon ile konuşan grafik araçlar — Windows VM — gerektiğinde sizden yetkilendirme ister. Groupless kurulumun rahatlığını geri istiyorsanız ve bu ödünleşimi anlıyorsanız, bunu **Setup > Security > Sudoless Docker** üzerinden etkinleştirin (veya `omarchy-setup-security-sudoless-docker` çalıştırın); bu, bir uyarının ardından sizi `docker` grubuna ekler; ardından düz `docker` ve `d` alias'ı tekrar `sudo` olmadan çalışır.

Yerel geliştirme için yaygın veritabanlarını Docker'da Omarchy menüsündeki _Install > Development > Docker DB_ seçeneğini kullanarak kurabilirsiniz.

## GitHub CLI

[GitHub CLI](https://cli.github.com/), terminalden repository'ler, issue'lar ve pull request'lerle çalışmak için `gh` olarak kullanılabilir. İlk kullanımda kurmak ve kimlik doğrulaması yapmak için `gh auth login` çalıştırın, ardından bir repository'yi klonlamak için `gh repo clone org/repo` çalıştırın. Komutlarını keşfetmek için `gh --help` çalıştırın.

Pull request'ler için bir terminal arayüzü kullanmak üzere `ghui` çalıştırın; mise onu da ilk kullanımda kurar. Git'in kendisiyle çalışmak için [Lazygit](https://github.com/jesseduffield/lazygit) önceden kuruludur.
