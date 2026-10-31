# Kendi temanızı yapmak

Kendi temalarınızı `~/.config/omarchy/themes` içine ekleyebilirsiniz. Mevcut temalardan birini baz alarak kopyalayın (`/usr/share/omarchy/themes` içine bakın), sonra keyfinize göre ince ayar çekin. Temanız o klasörün içinde olduğu sürece tema seçim menüsüne dahil edilecektir.

İnce ayar çekmeniz gereken ana dosya `colors.toml`. Bu dosya; terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian ve tüm Omarchy kabuğu (üst çubuk, menü, bildirimler, OSD ve kilit ekranı) için yapılandırmalar üretmekte kullanılan renk kümesini tanımlar.

Birlikte gelen Aether uygulamasını kullanarak da renklerle oynamak ve arka planlar aramak için hoş bir GUI arayüzüyle yeni bir tema oluşturabilirsiniz. Onu uygulama ızgarasından `Super + Alt + Space` ile başlatmanız yeterli.

### Kurulu bir tema neleri içerebilir

`~/.config/omarchy/themes` içinde kendiniz yazdığınız bir tema ne isterseniz içerebilir — makine de dosya da sizin, Omarchy de hepsini uygular.

Başkasının deposundan `omarchy theme install` ile kurduğunuz bir tema, renk olan her şeyi korur ve makinenizde kod çalıştıracak bir avuç dosyayı kaybeder: herhangi bir `.lua` dosyası, terminal yapılandırmaları (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ve `vscode.json`. Bir temanın `hyprland.lua` dosyası, dizgileyicinizin oturum açılırken çalıştırdığı Lua'dır; bir terminal yapılandırması, terminalinizin başlatacağı programı adlandırır; `vscode.json` ise kurulacak bir VSCode eklentisini adlandırır. Birinin temasını kurmak masaüstünüzün nasıl göründüğünü değiştirmeli, ne çalıştırdığını asla değiştirmemelidir.

Diğer her şey tema yazarının yazdığı gibi aynen çalışır — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, arka planlar ve önizlemelerin hepsi korunur. Yalnızca düşürülenler, makinenizde `colors.toml` dosyasından yeniden üretilir.

Omarchy ikisini, temanın içinde kendi git deposu olup olmadığına bakarak ayırt eder; bu, `omarchy theme install` klonladığında geride bıraktığı şeydir. Böylece sizin yazdığınız bir tema sizin olarak kalır, internetten çektiğiniz bir tema ise renkler olarak kalır.

### Açık mod

Açık mod teması yapıyorsanız, `colors.toml` dosyanızın en üstüne `mode = "light"` ayarını koyun. O zaman tüm uygulamalar için otomatik olarak açık modla eşleştirilecektir. (Temanızın köküne `light.mode` adlı boş bir dosya bırakma şeklindeki eski yöntem de hâlâ çalışıyor.)

### Simge renkleri

Dosya yöneticisi simgelerini temanızla renk uyumlu hale getirmek isterseniz, kullanmak istediğiniz simge kümesinin adını içeren `icons.theme` adlı bir dosya ekleyin. Varsayılan olarak seçenekler şunlardır: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Kilit açma görseli

`unlock.png` ve `preview-unlock.png` görselleriyle birlikte gelen temalar _Görünüm > Kilit Açma_ altında listelenecektir. `unlock.png` dosyanız tercihen şeffaf bir png olmalıdır. Önizleme görselini de `omarchy plymouth preview` kullanarak oluşturabilirsiniz.

### Omarchy'nin kapsamadığı uygulamaları temalandırmak

O listede olmayan bir uygulama kullanıyorsanız, bir şablonla Omarchy'ye onu nasıl temalandıracağını kendiniz öğretebilirsiniz. `~/.config/omarchy/themed/` içine, ürettiği yapılandırmanın adını artı `.tpl` uzantısını taşıyan bir dosya bırakın ve yapılandırmayı `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` ile `{{ color15 }}` arası ve paletin geri kalanını yer tutucu olarak kullanarak yazın. Temaları her değiştirdiğinizde dosya, o temanın renkleriyle yeniden üretilir.

O klasörde, kopyalamanız için tamamen açıklamalı bir `alacritty.toml.tpl.sample` var — kullanabileceğiniz her değişkeni, ayrıca renklerini `#` olmadan veya ondalık RGB olarak isteyen uygulamalar için `_strip` ve `_rgb` değiştiricilerini de listeliyor. Şablonlarınız Omarchy'nin kendi şablonlarına göre önceliklidir, yani bunu yerleşik bir uygulamanın nasıl temalandırıldığını geçersiz kılmak için de kullanabilirsiniz.

### Temanızı dağıtmak

Temanızı başkalarının da kullanabilmesi için dağıtmak isterseniz, onu GitHub gibi herkese açık bir git sunucusuna koymanız gerekir. Sonra insanlar onu Omarchy menüsündeki _Kur > Stil > Tema_ yolunu kullanarak o URL ile kurabilirler. `omarchy-[themename]-theme` adlandırma kuralına uymanız önerilir; böylece tema, kurulumdan sonra tema seçim menüsünde doğru şekilde yalnızca `[themename]` olarak görünür.

Geriye kalan o `[themename]` temanın dizin adı olur, dolayısıyla Omarchy'nin güvenle elden ele dolaştırabileceği bir ad olması gerekir: bir harf, bir rakam veya bir alt çizgi ile başlamalı, geri kalanı harfler, rakamlar, `.`, `_`, `+` ve `-` içerebilir. Büyük harfler sizin için küçük harfe çevrilir, ancak başka herhangi bir şey — bir boşluk, bir tırnak işareti, İngilizce olmayan bir karakter — bir dizin adına dönüştürülmek yerine kurulum anında reddedilir. Yani `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ve `omarchy-c++-theme` temalarının hepsi sorunsuz kurulur.

Bir depodan kurulduktan sonra, temanın birlikte getirdiği herhangi bir `.lua`, terminal yapılandırması veya `vscode.json` dosyasının düşürüleceğini unutmayın; temayı bunların etrafında kurmayın.

[omarchy-site deposuna](https://github.com/omacom-io/omarchy-site) bir pull request göndererek temanızın [ekstra temalar sayfasına](https://omarchy.org/themes/) eklenmesini sağlayabilirsiniz.
