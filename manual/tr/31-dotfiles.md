# Dotfiles

Omarchy öncelikle `~/.config` içinde bulunan ve dotfiles diye adlandırılan dosyalar aracılığıyla yapılandırılır. Bunlar, değişiklik yapmanız için sizin dosyalarınız olarak kabul edilir. `/usr/share/omarchy` içinde bulunan dosyalar Omarchy'nin kendisine aittir ve onlarla oynamamalısınız. `/usr/share/omarchy` içinde herhangi bir şeyi değiştirmeniz gerekirse, bunun yerine değeri `~/.config` içinde geçersiz kılmalısınız.

Temel yapılandırmalar doğrudan Omarchy menüsünden (`Super + Space`) düzenlenebilir; örneğin _Kurulum > Tuş Atamaları_, _Kurulum > Girdi_ ve _Kurulum > Yapılandırma > [dosya]_. Bu şekilde yaptığınızda, yapılandırma düzenlemelerinden sonra yeniden başlatılması gereken tüm işlemler, siz düzenleyiciden çıktıktan sonra otomatik olarak yeniden başlatılır (varsayılan olarak Neovim — `:wq`, unutmayın! — ancak bunu _Kurulum > Varsayılanlar > Düzenleyici_ üzerinden değiştirebilirsiniz).

İşte `~/.config` içindeki temel dosyaların ve neleri kontrol ettiklerinin bir listesi:

| Dosya | Amaç |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Ana Hyprland yapılandırması. Omarchy varsayılanlarını ve aşağıdaki geçersiz kılma dosyalarınızı yükler. [Hyprland yapılandırmaları hakkında daha fazla bilgi edinin](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Kendi tuş atamalarınız ve varsayılanları geçersiz kılan ayarlarınız. |
| `~/.config/hypr/monitors.lua` | Döndürme, ekstra modlar veya bir monitörü kapalı tutma gibi, monitör panelinin kapsamadığı monitör ayarları. |
| `~/.config/hypr/input.lua` | Klavye düzeninizi, farenizi ve dokunmatik yüzey ayarlarınızı kontrol eder. |
| `~/.config/hypr/looknfeel.lua` | Boşlukları, kenarlıkları, animasyonları ve görünümün geri kalanını kontrol eder. |
| `~/.config/hypr/autostart.lua` | Oturumla başlatılan ekstra işlemleri kontrol eder. |
| `~/.config/omarchy/shell.json` | Omarchy kabuğunu kontrol eder: çubuk konumu, düzen ve widget'lar ile ekran koruyucu, kilit ve boşta kalma süreleri. |
| `~/.config/foot/foot.ini` | Terminalinizi kontrol eder (foot varsayılandır). |
| `~/.XCompose` | Hızlı erişim emojilerinizi ve ad/e-posta otomatik tamamlamanızı tanımlar. Değişiklik yaptıktan sonra `omarchy-restart-xcompose` çalıştırmayı unutmayın. |

Kendi kurulumunuzu ince ayar yapmak için çok fazla değişiklik yaparsanız, tüm bu dotfiles dosyalarını yedeklemek iyi bir fikirdir. [Stow bunu yapmanın harika bir yoludur](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Kendi uygulamalarınızı oturumla başlatma

Her giriş yaptığınızda bir şeyin çalışmasını istiyorsanız — bir senkronizasyon hizmeti, bir sohbet uygulaması, kendi komut dosyanız — onu `~/.config/hypr/autostart.lua` dosyasına koyun:

```lua
o.launch_on_start("my-service")
```

Bu, komutu oturumun bir parçası olarak başlatır, böylece tekrar çıkış yaptığınızda düzgün şekilde temizlenir.

### Sistem olaylarında komut dosyaları çalıştırma

Omarchy birkaç anda kancalar tetikler ve kendi komut dosyalarınızı bunlara bağlayabilirsiniz. Bunlar `~/.config/omarchy/hooks/<event>.d/` içinde bulunur, her olay için bir dizin vardır ve olay gerçekleştiğinde oradaki her çalıştırılabilir dosya çalışır:

| Olay | Ne zaman çalışır |
| ----- | ------------ |
| `post-boot` | Masaüstü başladıktan hemen sonra |
| `post-update` | `omarchy update` işleminin sonuna doğru; paketlerden, geçişlerden ve hizmet yeniden başlatmalarından sonra, mise araçları güncellenmeden önce |
| `pre-refresh-pacman` | `omarchy refresh pacman` paket yapılandırmasını yeniden senkronize ettikten sonra, paketleri güncellemeden önce; kanal değişimi bunu aynı yenileme adımında çalıştırır |
| `theme-set` | Tema değişiminden sonra (tema adı `$1` içinde) |
| `font-set` | Yazı tipi değişiminden sonra (yazı tipi adı `$1` içinde) |
| `battery-low` | Pil azaldığında (yüzde `$1` içinde) |

`pre-refresh-pacman` kancası, paket işleminden önce çalıştığı için özel depoların veya `IgnorePkg` satırlarının ait olduğu yerdir. Güncellemeyle ilgili her iki kanca da Omarchy önbelleğe alınmış sudo yetkilendirmesini temizledikten sonra sizin kullanıcınız olarak çalışır, bu nedenle `sudo` kullanan bir kancanın kendi yetkilendirmesine ihtiyacı vardır ve şifrenizi isteyebilir.

Bu dizinlerin her birinde, bir kancanın şeklini gösteren bir `.sample` dosyası zaten bulunur — onu çalıştırmak için adından `.sample` kısmını kaldırın. Başka bir yerde yazdığınız bir komut dosyasını kurmak için `omarchy hook install post-boot ~/my-hook` kullanın; bu, onu içeri kopyalar ve çalıştırılabilir yapar.

### Kendi menü girişlerinizi ekleme

Omarchy menüsü (`Super + Space`), `~/.config/omarchy/extensions/omarchy-menu.jsonc` düzenlenerek kendi satırlarınızla genişletilebilir. Girişler noktalı bir id ile anahtarlanır ve onları ağaca yerleştiren şey bu id'dir; bu nedenle `personal` kök menüde görünür ve `personal.notes` onun içinde görünür:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Mevcut bir id'yi yeniden kullanırsanız, yeni bir satır eklemek yerine o satırı geçersiz kılarsınız. Dosya, mevcut tüm alanlar yorumlar olarak belgelenmiş şekilde gelir.

### Kendi kabuk dışa aktarımlarınızı, işlevlerinizi ve takma adlarınızı ekleme

Omarchy bir sürü ergonomik takma ad ve yararlı işlevle gelir, ancak kendinizinkileri eklemek istemeniz çok yaygındır. Takma adları, işlevleri ve dışa aktarımları `~/.bashrc` dosyasına eklemelisiniz. Bu dosya güncellemelerde geçersiz kılınmayacaktır. Omarchy varsayılanlarından herhangi birini değiştirmek isterseniz, onları da buraya güvenle ekleyebilirsiniz.

### Dahili Omarchy dosyalarını değiştirme

Bakın, bu sizin bilgisayarınız. Onunla istediğiniz her şeyi yapabilirsiniz, ancak `/usr/share/omarchy` içindeki dosyalarda doğrudan değişiklik yapmamanızı tavsiye ederim. Bunlar Omarchy pacman paketine aittir, bu nedenle değişiklikleriniz bir sonraki güncellemede basitçe geçersiz kılınacaktır. Bunun yerine, beğenmediğiniz varsayılan değerleri `~/.config/*` klasöründe geçersiz kılmanız çok daha iyidir.

Bu şekilde hemen hemen her şeyi değiştirebilirsiniz, örneğin varsayılan tuş atamalarını. Örneğin [Obsidian](https://obsidian.md/) yerine [Joplin](https://joplinapp.org/) kullanmak için `~/.config/hypr/bindings.lua` dosyasını düzenlemeniz yeterlidir (`omarchy-pkg-add joplin-bin` ile kurun):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind`, yerine koyduğu bağlamayı eklemeden önce mevcut bağlamayı kaldırır. Başlatma yardımcıları ve bağlama seçenekleri dahil olmak üzere `o.bind` ile aynı argümanları alır. Bir bağlama eklemek için `o.bind` kullanın veya bir bağlamayı yerine yenisini koymadan kaldırmak için `hl.unbind` kullanın.

Dahili Omarchy dosyaları üzerinde oynamakta ısrar ediyorsanız, _Güncelleme > Kanal > Dev_ üzerinden dev kanalına geçin. Bu, Omarchy'yi `~/omarchy` içindeki kaynak kodun bir git kopyasına bağlar ve bunu gönlünüzce değiştirmekte özgürsünüz. Burada size ne yapacağınızı söyleyecek kimse yok!

### Değişiklikleri sıfırlama

Yapılandırmaları karıştırırsanız, bunları Omarchy menüsünde _Güncelleme > Yapılandırma_ üzerinden her zaman varsayılanlara döndürebilirsiniz. Ya da her şeyi sıfırlamak için `omarchy reinstall configs` çalıştırarak.
