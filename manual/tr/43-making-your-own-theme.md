# Kendi temanızı oluşturma

Kendi temalarınızı `~/.config/omarchy/themes` içine ekleyebilirsiniz. Mevcut temalardan birini temel olarak kopyalamanız (bkz. `/usr/share/omarchy/themes`), sonra da keyfinize göre ince ayar yapmanız yeterli. Temanız o klasörün içinde olduğu sürece tema seçim menüsüne dahil edilecektir.

Asıl ince ayar yapacağınız dosya `colors.toml`. Bu, daha sonra terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian ve tüm Omarchy kabuğu (üst çubuk, menü, bildirimler, OSD ve kilit ekranı) için yapılandırmalar üretmekte kullanılan renk kümesini tanımlar.

Birlikte gelen Aether uygulamasını kullanarak da yeni bir tema oluşturabilirsiniz; renklerle oynamak ve arka plan aramak için hoş bir GUI arayüzü sunar. Onu `Super + Alt + Space` ile uygulama ızgarasından başlatmanız yeterli.

### Kurulu bir tema neleri içerebilir

`~/.config/omarchy/themes` içinde kendiniz yazdığınız bir tema ne isterseniz onu içerebilir — bu sizin makineniz ve sizin dosyanız, Omarchy de hepsini uygular.

Başkasının bir reposundan `omarchy theme install` ile kurduğunuz bir tema renk olan her şeyi korur, makinenizde kod çalıştıracak bir avuç dosyayı ise kaybeder: her türlü `.lua` dosyası, terminal yapılandırmaları (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ve `vscode.json`. Bir temanın `hyprland.lua` dosyası, dizgicinizin oturum açarken çalıştırdığı Lua'dır; bir terminal yapılandırması, terminalinizin başlattığı programı adlandırır; `vscode.json` ise kurulacak bir VSCode uzantısını adlandırır. Birinin temasını kurmak masaüstünüzün nasıl göründüğünü değiştirmeli, asla ne çalıştırdığını değiştirmemelidir.

Geri kalan her şey tema yazarının yazdığı gibi aynen çalışır — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, arka planlar ve önizlemelerin hepsi korunur. Yalnızca atılanlar makinenizde `colors.toml` dosyasından yeniden üretilir.

Omarchy ikisini, temanın içinde kendine ait bir git reposu olup olmadığına bakarak ayırt eder; bu, `omarchy theme install` klonlarken geride bıraktığı şeydir. Böylece kendiniz yazdığınız bir tema sizin olarak kalır, internetten çektiğiniz bir tema ise renkler olarak kalır.

### Açık mod

Açık mod teması yapıyorsanız `colors.toml` dosyanızın en üstüne `mode = "light"` yazın. O zaman tüm uygulamalar için otomatik olarak açık modla eşleştirilir. (Temanızın köküne `light.mode` adlı boş bir dosya bırakma şeklindeki eski yöntem de hâlâ çalışıyor.)

### Kilit açma görseli

`unlock.png` ve `preview-unlock.png` görselleriyle gelen temalar _Görünüm > Kilit Açma_ altında listelenir. `unlock.png` dosyanız tercihen şeffaf bir png olmalı. Önizleme görselini de `omarchy plymouth preview` kullanarak oluşturabilirsiniz.

### Omarchy'nin kapsamadığı uygulamaları temalandırma

O listede olmayan bir uygulama kullanıyorsanız, bir şablonla Omarchy'ye onu nasıl temalandıracağını kendiniz öğretebilirsiniz. `~/.config/omarchy/themed/` içine, ürettiği yapılandırmanın adını taşıyan ve üstüne bir `.tpl` uzantısı eklenmiş bir dosya bırakın ve yapılandırmayı `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` ile `{{ color15 }}` arasını ve paletin geri kalanını yer tutucu olarak kullanarak yazın. Tema her değiştirdiğinizde dosya o temanın renkleriyle yeniden üretilir.

O klasörde kopyalayabileceğiniz baştan sona yorumlanmış bir `alacritty.toml.tpl.sample` var — kullanabileceğiniz her değişkeni, üstüne renklerini `#` olmadan ya da ondalık RGB olarak isteyen uygulamalar için `_strip` ve `_rgb` değiştiricilerini listeler. Şablonlarınız Omarchy'nin kendi şablonlarına göre önceliklidir, dolayısıyla bunu yerleşik bir uygulamanın nasıl temalandırıldığını geçersiz kılmak için de kullanabilirsiniz.

### Temanızı dağıtma

Temanızı başkalarının da kullanabilmesi için dağıtmak istiyorsanız onu GitHub gibi herkese açık bir git sunucusuna koymanız gerekir. Sonra insanlar Omarchy menüsünde _Kur > Stil > Tema_ yolunu kullanarak ve o URL'yi girerek onu kurabilir. `omarchy-[themename]-theme` adlandırma kuralına uymanız önerilir, çünkü tema kurulumdan sonra tema seçim menüsünde doğru şekilde yalnızca `[themename]` olarak görünür.

Geriye kalan o `[themename]` kısmı temanın dizin adı hâline gelir, dolayısıyla Omarchy'nin güvenle elden ele taşıyabileceği bir ad olmalı: bir harf, bir rakam ya da bir alt çizgiyle başlamalı ve geri kalanında harfler, rakamlar, `.`, `_`, `+` ve `-` bulunabilir. Büyük harfler sizin için küçük harfe çevrilir, ancak geri kalan her şey — boşluk, tırnak işareti, İngilizce dışı bir karakter — bir dizin adına dönüştürülmek yerine kurulum sırasında reddedilir. Dolayısıyla `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ve `omarchy-c++-theme` sorunsuzca kurulur.

Bir repodan kurulduktan sonra, birlikte geldiği her türlü `.lua`, terminal yapılandırması ya da `vscode.json` dosyasının atılacağını unutmayın; bu yüzden temayı bunların üzerine kurmayın.

Temanızın [ek temalar sayfasına](https://omarchy.org/themes/) eklenmesini, [omarchy-site reposuna](https://github.com/omacom-io/omarchy-site) bir pull request göndererek sağlayabilirsiniz.
