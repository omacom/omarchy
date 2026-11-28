# Dotfiles

Omarchy öncelikle `~/.config` içinde yaşayan sözde dotfiles aracılığıyla yapılandırılır. Bunlar sizin dosyalarınız, sizin değişiklikleriniz için varlar. `/usr/share/omarchy` içinde yaşayan dosyalar Omarchy'nin kendisine aittir ve onlarla uğraşmamanız gerekir. `/usr/share/omarchy` içinde herhangi bir şeyi değiştirmeniz gerekirse, bunun yerine değeri `~/.config` içinde ezmelisiniz.

Temel yapılandırmalar doğrudan Omarchy menüsünden (`Super + Space`) düzenlenebilir; örneğin _Setup > Keyboard > Keybindings_, _Setup > Input_ ve _Setup > Config > [file]_. Bunu bu şekilde yaptığınızda, yapılandırma düzenlemelerinin ardından yeniden başlatılması gereken işlemler, siz düzenleyiciden çıktıktan sonra otomatik olarak yeniden başlatılır (varsayılan olarak Neovim — `:wq`, unutmayın! — ama bunu _Setup > Defaults > Editor_ üzerinden değiştirebilirsiniz).

İşte `~/.config` içindeki temel dosyaların ve neyi kontrol ettiklerinin listesi:

| Dosya                  | Amaç              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Ana Hyprland yapılandırması. Omarchy varsayılanlarını artı aşağıdaki ezme dosyalarınızı yükler. [Hyprland yapılandırmaları hakkında daha fazla bilgi edinin](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Kendi tuş atamalarınız ve varsayılanlara yönelik ezmeleriniz. |
| `~/.config/hypr/monitors.lua` | Döndürme, ek modlar ya da bir monitörü kapalı tutma gibi, monitör panelinin kapsamadığı monitör ayarları. |
| `~/.config/hypr/input.lua` | Klavye düzeninizi, farenizi ve dokunmatik yüzey ayarlarınızı kontrol eder. |
| `~/.config/hypr/looknfeel.lua` | Boşlukları, kenarlıkları, animasyonları ve görünümün geri kalanını kontrol eder. |
| `~/.config/hypr/autostart.lua` | Oturumla birlikte başlatılan ek işlemleri kontrol eder. |
| `~/.config/omarchy/shell.json` | Omarchy kabuğunu kontrol eder: çubuk konumu, düzen ve widget'lar, artı ekran koruyucu, kilit ve boşta kalma süreleri. |
| `~/.config/foot/foot.ini` | Terminalinizi kontrol eder (foot varsayılandır). |
| `~/.XCompose` | Hızlı erişim emojilerinizi ve ad/e-posta otomatik tamamlamanızı tanımlar. Değişiklik yaptıktan sonra `omarchy-restart-xcompose` çalıştırmayı unutmayın. |

Kendi kurulumunuzu ince ayarlarla epey değiştirirseniz, tüm bu dotfiles dosyalarını yedeklemek iyi bir fikirdir. [Stow bunu yapmanın harika bir yoludur](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Kendi uygulamalarınızı oturumla başlatma

Her oturum açışınızda bir şeyin çalışmasını istiyorsanız — bir senkronizasyon arka plan programı, bir sohbet uygulaması, kendi betiğiniz — onu `~/.config/hypr/autostart.lua` içine koyun:

```lua
o.launch_on_start("my-service")
```

Bu, komutu oturumun bir parçası olarak başlatır, böylece tekrar oturumu kapattığınızda düzgünce temizlenir.

### Sistem olaylarında betik çalıştırma

Omarchy birkaç anda kancalar (hook) tetikler ve siz de kendi betiklerinizi bunlara bağlayabilirsiniz. Bunlar `~/.config/omarchy/hooks/<event>.d/` içinde yaşar; her olay için bir dizin vardır ve orada `.sample` ile bitmeyen her dosya, olay gerçekleştiğinde bash ile çalışır:

| Olay | Ne zaman çalışır |
| ----- | ------------ |
| `post-boot` | Masaüstü başladıktan hemen sonra |
| `post-update` | `omarchy update` işleminin sonuna doğru, paketler, geçişler ve hizmet yeniden başlatmalarından sonra, mise araçları güncellenmeden önce |
| `pre-refresh-pacman` | `omarchy refresh pacman` paket yapılandırmasını yeniden senkronize ettikten sonra, paketleri güncellemeden önce; bir kanal değişimi bunu aynı yenileme adımında çalıştırır |
| `theme-set` | Bir tema değişikliğinden sonra (tema adı `$1` içinde) |
| `font-set` | Bir yazı tipi değişikliğinden sonra (yazı tipi adı `$1` içinde) |
| `battery-low` | Pil azaldığında (yüzde `$1` içinde) |

`pre-refresh-pacman` kancası, paket işleminden önce çalıştığı için özel depoların ya da `IgnorePkg` satırlarının ait olduğu yerdir. Her ikisi de sizin kullanıcınız olarak çalışır. `post-update`, `omarchy update` işleminin sudo yetkisi hâlâ taze iken çalışır, bu yüzden `sudo` kullanan bir kanca sizden tekrar parolanızı istemez; `pre-refresh-pacman`, `omarchy refresh pacman` sudo'yu kendisi kullandıktan hemen sonra çalışır.

Bu dizinlerin her birinde zaten bir kancanın şeklini gösteren bir `.sample` dosyası bulunur — işe koymak için adından `.sample` kısmını kaldırın. Başka bir yerde yazdığınız bir betiği kurmak için `omarchy hook install post-boot ~/my-hook` kullanın; bu, onu içeri kopyalar ve çalıştırılabilir yapar.

### Kendi menü girdilerinizi ekleme

Omarchy menüsü (`Super + Space`), `~/.config/omarchy/extensions/omarchy-menu.jsonc` dosyasını düzenleyerek kendi satırlarınızla genişletilebilir. Girdiler noktalı bir kimlikle (id) anahtarlanır ve onları ağaca yerleştiren şey bu kimliktir; yani `personal` kök menüde, `personal.notes` ise onun içinde görünür:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Mevcut bir kimliği tekrar kullanırsanız, yeni bir satır eklemek yerine o satırı ezersiniz. Dosya, kullanılabilir tüm alanlar yorum olarak belgelenmiş hâlde gelir.

### Kendi kabuk dışa aktarımlarınızı, işlevlerinizi ve takma adlarınızı ekleme

Omarchy bir sürü ergonomik takma ad ve faydalı işlevle gelir, ama kendi eklemelerinizi istemeniz çok yaygındır. Hem takma adları, hem işlevleri, hem de dışa aktarımları `~/.bashrc` içine eklemelisiniz. Bu dosya güncellemelerde ezilmez. Omarchy varsayılanlarından herhangi birini değiştirmek isterseniz, bunları da güvenle buraya ekleyebilirsiniz.

### Masaüstü için ortam değişkenleri ayarlama

Masaüstü oturumu dışa aktarımları `~/.config/uwsm/env.d/` içine aittir. Bu dosyalar masaüstünüz başlamadan önce çalışır, bu yüzden bir kabuk hatası sizi giriş ekranına geri gönderebilir. Bunları düzenlerken çalışır durumda bir terminali açık tutun. Bir ezmeyi devre dışı bırakmak için onu `env.d` dışına taşıyın. Bir değişiklik girişi engellerse bkz. [giriş kurtarma](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen).

### Dahili Omarchy dosyalarını değiştirme

Bakın, bu sizin bilgisayarınız. Onunla istediğiniz her şeyi yapabilirsiniz, ama `/usr/share/omarchy` içindeki dosyalarda doğrudan değişiklik yapmamanızı tavsiye ederim. Bunlar Omarchy pacman paketine aittir, bu yüzden değişiklikleriniz bir sonraki güncellemede kolayca ezilir. Onun yerine, beğenmediğiniz varsayılan değerleri `~/.config/*` klasöründe ezmeniz çok daha iyi olur.

Neredeyse her şeyi bu şekilde değiştirebilirsiniz, örneğin varsayılan tuş atamalarını. Diyelim ki [Obsidian](https://obsidian.md/) yerine [Joplin](https://joplinapp.org/) kullanmak için (`omarchy-pkg-add joplin-bin` ile kurun) `~/.config/hypr/bindings.lua` dosyasını düzenleyin:

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind`, yerine yenisini eklemeden önce mevcut atamayı kaldırır. Başlatma yardımcıları ve atama seçenekleri de dahil olmak üzere `o.bind` ile aynı argümanları alır. Bir atama eklemek için `o.bind`, yerine yenisini koymadan bir atamayı kaldırmak için `hl.unbind` kullanın.

Dahili Omarchy dosyaları üzerinde hackleme konusunda ısrarcıysanız, _Update > Channel > Dev_ üzerinden dev kanalına geçin. Bu, Omarchy'yi `~/omarchy` içindeki kaynak kodun bir git kopyasına bağlar; bunu gönlünüzce değiştirmekte özgürsünüz. Burada size ne yapacağınızı söyleyecek kimse yok!

### Yaptığınız değişiklikleri sıfırlama

Yapılandırmaları berbat ederseniz, Omarchy menüsünde _Update > Config_ üzerinden bunları her zaman varsayılanlara döndürebilirsiniz. Ya da her şeyi sıfırlamak için `omarchy reinstall configs` çalıştırabilirsiniz.
