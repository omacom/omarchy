# Dotfiles

Omarchy, esas olarak `~/.config` içinde yaşayan sözde dotfiles üzerinden yapılandırılır. Bunlar, değişiklikleriniz için sizin dosyalarınız sayılır. `/usr/share/omarchy` içinde yaşayan dosyalar Omarchy'nin kendisine aittir ve onlarla uğraşmamalısınız. `/usr/share/omarchy` içinde bir şeyi değiştirmeniz gerekirse, bunun yerine değeri `~/.config` içinde geçersiz kılmalısınız.

Temel yapılandırmalar doğrudan Omarchy menüsünden (`Super + Space`) düzenlenebilir; örneğin _Setup > Keybindings_, _Setup > Input_ ve _Setup > Config > [file]_. Bu yolla yaptığınızda, yapılandırma düzenlemelerinden sonra yeniden başlatılması gereken tüm süreçler, editörden çıktıktan sonra otomatik olarak yeniden başlatılır (varsayılan olarak Neovim — `:wq`, unutmayın! — ancak bunu _Setup > Defaults > Editor_ üzerinden değiştirebilirsiniz).

İşte `~/.config` içindeki temel dosyaların ve neyi kontrol ettiklerinin listesi:

| Dosya | Amaç |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Ana Hyprland yapılandırması. Omarchy varsayılanlarını ve aşağıdaki geçersiz kılma dosyalarınızı yükler. [Hyprland yapılandırmaları hakkında daha fazla bilgi edinin](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Kendi tuş atamalarınız ve varsayılanları geçersiz kılmalarınız. |
| `~/.config/hypr/monitors.lua` | Monitör panelinin kapsamadığı monitör ayarları; döndürme, ek modlar veya bir monitörü kapalı tutma gibi. |
| `~/.config/hypr/input.lua` | Klavye düzeninizi, fare ve trackpad ayarlarınızı kontrol eder. |
| `~/.config/hypr/looknfeel.lua` | Boşlukları, kenarlıkları, animasyonları ve görünümün geri kalanını kontrol eder. |
| `~/.config/hypr/autostart.lua` | Oturumla birlikte başlatılan ek süreçleri kontrol eder. |
| `~/.config/omarchy/shell.json` | Omarchy shell'i kontrol eder: çubuk konumu, düzen ve widget'lar ile ekran koruyucu, kilit ve boşta kalma zamanlamaları. |
| `~/.config/foot/foot.ini` | Terminalinizi kontrol eder (varsayılan foot'tur). |
| `~/.XCompose` | Hızlı erişim emoji'lerinizi ve ad/e-posta otomatik tamamlamanızı tanımlar. Değişiklik yaptıktan sonra `omarchy-restart-xcompose` çalıştırmayı unutmayın. |

Kendi kurulumunuzu ince ayarlarla çok sayıda değişiklik yaparsanız, tüm bu dotfiles'ı yedeklemek iyi bir fikirdir. [Stow bunu yapmak için harika bir yoldur](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Kendi uygulamalarınızı oturumla başlatma

Her giriş yaptığınızda çalışmasını istediğiniz bir şey varsa — bir senkronizasyon daemon'ı, bir sohbet uygulaması, kendi komut dosyanız — onu `~/.config/hypr/autostart.lua` içine koyun:

```lua
o.launch_on_start("my-service")
```

Bu, komutu oturumun bir parçası olarak başlatır, böylece tekrar çıkış yaptığınızda düzgünce temizlenir.

### Sistem olaylarında komut dosyaları çalıştırma

Omarchy birkaç anda hook'lar tetikler ve kendi komut dosyalarınızı bunlara bağlayabilirsiniz. Bunlar `~/.config/omarchy/hooks/<event>.d/` içinde yaşar, her olay için bir dizin vardır ve olay gerçekleştiğinde oradaki her çalıştırılabilir dosya çalışır:

| Olay | Ne zaman çalışır |
| ----- | ------------ |
| `post-boot` | Masaüstü başladıktan hemen sonra |
| `post-update` | `omarchy update` işleminin sonuna doğru, paketler, geçişler ve hizmet yeniden başlatmalarından sonra, mise araçları güncellenmeden önce |
| `pre-refresh-pacman` | `omarchy refresh pacman` paket yapılandırmasını yeniden senkronize ettikten sonra, paketleri güncellemeden önce; kanal değişimi bunu aynı yenileme adımında çalıştırır |
| `theme-set` | Tema değişiminden sonra (tema adı `$1` içinde) |
| `font-set` | Yazı tipi değişiminden sonra (yazı tipi adı `$1` içinde) |
| `battery-low` | Pil azaldığında (yüzde `$1` içinde) |

`pre-refresh-pacman` hook'u, paket işleminden önce çalıştığı için özel depoların veya `IgnorePkg` satırlarının ait olduğu yerdir. Güncellemeyle ilgili her iki hook da Omarchy önbelleğe alınmış sudo yetkilendirmesini temizledikten sonra sizin kullanıcınız olarak çalışır, bu yüzden `sudo` kullanan bir hook'un kendi yetkilendirmesine ihtiyacı vardır ve parolanızı isteyebilir.

Bu dizinlerin her birinde zaten bir hook'un şeklini gösteren bir `.sample` dosyası bulunur — çalıştırmak için adından `.sample` kısmını çıkarın. Başka bir yerde yazdığınız bir komut dosyasını kurmak için `omarchy hook install post-boot ~/my-hook` kullanın; bu onu içeri kopyalar ve çalıştırılabilir yapar.

### Kendi menü girdilerinizi ekleme

Omarchy menüsü (`Super + Space`), `~/.config/omarchy/extensions/omarchy-menu.jsonc` düzenlenerek kendi satırlarınızla genişletilebilir. Girdiler noktalı bir id ile anahtarlanır ve onları ağaca yerleştiren şey bu id'dir; böylece `personal` kök menüde görünür ve `personal.notes` onun içinde görünür:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Var olan bir id'yi yeniden kullanırsanız, yeni bir satır eklemek yerine o satırı geçersiz kılarsınız. Dosya, kullanılabilir tüm alanlar yorum olarak belgelenmiş şekilde gelir.

### Kendi shell export'larınızı, fonksiyonlarınızı ve alias'larınızı ekleme

Omarchy bir sürü ergonomik alias ve yararlı fonksiyonla gelir, ancak kendi eklemelerinizi istemeniz çok yaygındır. Alias'ları, fonksiyonları ve export'ları `~/.bashrc` içine eklemelisiniz. Bu dosyanın üzerine güncellemelerde yazılmayacaktır. Omarchy varsayılanlarından herhangi birini değiştirmek isterseniz, onları da güvenle buraya ekleyebilirsiniz.

### Masaüstü için ortam değişkenlerini ayarlama

Masaüstü oturumu export'ları `~/.config/uwsm/env.d/` içine aittir. Bu dosyalar masaüstünüz başlamadan önce çalışır, bu yüzden bir shell hatası sizi giriş ekranına geri gönderebilir. Bunları düzenlerken çalışan bir terminali açık tutun. Bir geçersiz kılmayı devre dışı bırakmak için onu `env.d` dışına taşıyın. Bir değişiklik girişi engellerse [giriş kurtarma](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) bölümüne bakın.

### Dahili Omarchy dosyalarını değiştirme

Bak, bu senin bilgisayarın. Onunla istediğini yapabilirsin, ancak `/usr/share/omarchy` içindeki dosyalarda doğrudan değişiklik yapmamanı tavsiye ederim. Bunlar Omarchy pacman paketine aittir, bu yüzden değişikliklerinin üzerine bir sonraki güncellemede basitçe yazılacaktır. Bunun yerine beğenmediğin varsayılan değerleri `~/.config/*` klasöründe geçersiz kılman daha iyi olur.

Bu yolla neredeyse her şeyi değiştirebilirsin, varsayılan tuş atamaları gibi. Örneğin [Obsidian](https://obsidian.md/) yerine [Joplin](https://joplinapp.org/) kullanmak için `~/.config/hypr/bindings.lua` dosyasını düzenlemen yeterli (`omarchy-pkg-add joplin-bin` ile kur):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind`, yerine geçecek atamayı eklemeden önce mevcut atamayı kaldırır. Başlatma yardımcıları ve atama seçenekleri de dahil olmak üzere `o.bind` ile aynı argümanları alır. Bir atama eklemek için `o.bind`, yerine yenisini koymadan bir atamayı kaldırmak için `hl.unbind` kullanın.

Dahili Omarchy dosyalarını kurcalamakta ısrar ediyorsanız, _Update > Channel > Dev_ üzerinden dev kanalına geçin. Bu, Omarchy'yi `~/omarchy` içindeki kaynak kodun bir git checkout'una bağlar ve bunu gönlünüzce değiştirmekte özgürsünüz. Burada size ne yapacağınızı söyleyecek kimse yok!

### Değişiklikleri sıfırlama

Yapılandırmaları berbat ederseniz, Omarchy menüsündeki _Update > Config_ üzerinden onları her zaman varsayılanlara geri döndürebilirsiniz. Ya da her şeyi sıfırlamak için `omarchy reinstall configs` çalıştırabilirsiniz.
