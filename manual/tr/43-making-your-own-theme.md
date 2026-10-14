# Kendi temanızı yapma

`~/.config/omarchy/themes` içine kendi temalarınızı ekleyebilirsiniz. Var olanlardan birini temel olarak kopyalayın (`/usr/share/omarchy/themes` içine bakın), ardından gönlünüzce ince ayar yapın. Temanız o klasörün içinde olduğu sürece, tema seçim menüsüne dahil edilecektir.

İnce ayar yapmanız gereken ana dosya `colors.toml` dosyasıdır. Bu, daha sonra terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian ve Omarchy kabuğunun tamamı (üst çubuk, menü, bildirimler, OSD ve kilit ekranı) için yapılandırmalar oluşturmak üzere kullanılan renk setini tanımlar.

Renklerle oynamak ve arka plan aramak için hoş bir GUI arayüzü kullanarak yeni bir tema oluşturmak için dahil edilen Aether uygulamasını da kullanabilirsiniz. Onu `Super + Alt + Space` üzerindeki uygulama ızgarasından başlatmanız yeterlidir.

### Kurulu bir temanın içerebilecekleri

`~/.config/omarchy/themes` içinde kendiniz yazdığınız bir tema istediğiniz her şeyi içerebilir — bu sizin makineniz ve sizin dosyanızdır, Omarchy hepsini uygular.

`omarchy theme install` ile başka birinin deposundan kurduğunuz bir tema, renk olan her şeyi korur ve makinenizde kod çalıştıracak az sayıdaki dosyayı kaybeder: herhangi bir `.lua` dosyası, terminal yapılandırmaları (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ve `vscode.json`. Bir temanın `hyprland.lua` dosyası, birleştiricinizin girişte çalıştırdığı Lua'dır, bir terminal yapılandırması terminalinizin başlattığı programı adlandırır ve `vscode.json` kurulacak bir VSCode uzantısını adlandırır. Birinin temasını kurmak, masaüstünüzün ne çalıştırdığını değil, neye benzediğini değiştirmelidir.

Diğer her şey tema yazarının yazdığı gibi aynen çalışır — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, arka planlar ve önizlemelerin hepsi korunur. Yalnızca bırakılanlar makinenizde `colors.toml` dosyasından yeniden oluşturulur.

Omarchy ikisini, temanın içinde kendi git deposuna sahip olup olmadığına bakarak ayırt eder; bu, `omarchy theme install` komutunun klonlarken geride bıraktığı şeydir. Böylece sizin yazdığınız bir tema sizde kalır ve internetten çektiğiniz biri renklerde kalır.

### Açık mod

Açık modlu bir tema yapıyorsanız, `colors.toml` dosyanızın en üstüne `mode = "light"` ayarlayın. Ardından tüm uygulamalar için açık modla otomatik olarak eşleştirilecektir. (Temanızın köküne `light.mode` adlı boş bir dosya bırakmanın eski yolu da hâlâ çalışır.)

### Simge renkleri

Dosya yöneticisi simgelerini temanıza renk olarak uydurmak isterseniz, kullanmak istediğiniz simge setinin adını içeren `icons.theme` adlı bir dosya ekleyin. Varsayılan olarak seçenekler şunlardır: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Kilit açma görüntüsü

`unlock.png` ve `preview-unlock.png` görüntüleriyle sağlanan temalar _Stil > Kilidi Aç_ altında listelenecektir. `unlock.png` dosyanız tercihen saydam bir png olmalıdır. Önizleme görüntüsünü `omarchy plymouth preview` kullanarak oluşturabilirsiniz.

### Omarchy'nin kapsamadığı uygulamaları temalandırma

O listede olmayan bir uygulama kullanıyorsanız, Omarchy'ye onu bir şablonla temalandırmayı kendiniz öğretebilirsiniz. `~/.config/omarchy/themed/` içine, oluşturduğu yapılandırmanın adı artı bir `.tpl` uzantısıyla adlandırılmış bir dosya bırakın ve yapılandırmayı yer tutucu olarak `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` ile `{{ color15 }}` arası ve paletin geri kalanıyla yazın. Temaları her değiştirişinizde, dosya o temanın renkleriyle yeniden oluşturulur.

O klasörde kopyalamak için tamamen yorumlanmış bir `alacritty.toml.tpl.sample` vardır — kullanabileceğiniz her değişkeni, ayrıca renklerini `#` işareti olmadan veya ondalık RGB olarak isteyen uygulamalar için `_strip` ve `_rgb` değiştiricilerini listeler. Şablonlarınız Omarchy'ninkilerinden önceliklidir, böylece bunu yerleşik bir uygulamanın nasıl temalandığını geçersiz kılmak için de kullanabilirsiniz.

### Temanızı dağıtma

Temanızı başkalarının kullanabilmesi için dağıtmak istiyorsanız, onu GitHub gibi genel bir git sunucusuna koymanız gerekir. Ardından insanlar onu, o URL'yi kullanarak Omarchy menüsündeki _Kur > Stil > Tema_ aracılığıyla kurabilir. `omarchy-[themename]-theme` adlandırma kuralını izlemeniz önerilir, çünkü tema kurulumdan sonra tema seçim menüsünde yalnızca `[themename]` olarak doğru şekilde görünecektir.

Geride kalan o `[themename]` temanın dizin adı olur, bu yüzden Omarchy'nin güvenli bir şekilde dolaştırabileceği bir ad olması gerekir: bir harf, bir rakam veya bir alt çizgiyle başlamalı ve geri kalanı harfler, rakamlar, `.`, `_`, `+` ve `-` içerebilir. Büyük harfler sizin için küçük harfe çevrilir, ancak başka her şey — bir boşluk, bir tırnak işareti, İngilizce olmayan bir karakter — bir dizin adına dönüştürülmek yerine kurulum sırasında reddedilir. Yani `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ve `omarchy-c++-theme` örneklerinin hepsi sorunsuz kurulur.

Unutmayın ki bir depodan kurulduktan sonra, içerdiği herhangi bir `.lua`, terminal yapılandırması veya `vscode.json` bırakılır, bu yüzden temayı bunların etrafında kurmayın.

Temanızı, [omarchy-site deposuna](https://github.com/omacom-io/omarchy-site) bir çekme isteği göndererek [ekstra temalar sayfasına](https://omarchy.org/themes/) ekletebilirsiniz.
