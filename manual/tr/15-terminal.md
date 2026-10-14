# Terminal

[Foot](https://codeberg.org/dnkl/foot), Omarchy için varsayılan terminaldir. Hızlı, hafif ve eski bilgisayarlarla bile uyumludur. Ancak yerel sekmeleri veya bölmeleri desteklemez.

Tmux kullanıyorsanız, umursamayabilirsiniz, ancak kullanmıyorsanız, seçenek olarak _Alacritty_, _Ghostty_ ve _Kitty_'yi de tamamen destekliyoruz. Tercihinizi Omarchy menüsündeki _Kur > Terminal_ altında seçin.

Yeni bir terminali `Super + Return` kullanarak başlatırsınız. (Bu bağlama, _Kur > Terminal_ yoluyla hangi Terminal'i kurduysanız otomatik olarak onu işaret eder ve kurulu terminaller arasında _Ayarlar > Varsayılanlar > Terminal_ altında geçiş yapabilirsiniz.)

## Tmux

Tmux, terminaliniz ne olursa olsun bölmeler, pencereler (diğer adıyla sekmeler) ve devam ettirilebilir oturumlar için tutarlı, programlanabilir bir arayüz sağlar. Uzak ana bilgisayarlarda bile çalışır, böylece bir sunucuya SSH ile bağlanırken aynı yaklaşımı kullanabilirsiniz.

`Super + Alt + Return` kullanarak yeni bir terminalde yeni bir Tmux oturumu başlatırsınız ve Tmux kalıcı bir süreç olduğundan, o terminali kapatsanız bile oturumunuzu devam ettirebilirsiniz. Tüm aktif oturumlarınızı görmek için `Ctrl + Space` (önek tuşu olarak adlandırılır) ardından `s` tuşuna basmanız yeterlidir.

Omarchy, öğrenilecek çok sayıda tuş bağlaması olan ergonomik olarak optimize edilmiş bir Tmux yapılandırmasıyla gelir, bu yüzden [kopya kağıdını el altında tutun](07-hotkeys.md#tmux).

## Tmux düzen işlevleri

Tmux programlanabilir olduğundan, düzenler oluşturmak için işlevler kullanabiliriz. Omarchy, yaygın geliştirici düzenleri için dört farklı işlevle birlikte gelir.

`tdl [agent]` soldaki `$EDITOR`, sağdaki seçtiğiniz AI ajanı (opencode için `c` veya Claude için `cx` veya OpenAI için `codex` gibi) ve ardından alttaki bir terminal ile üç yollu bölünmüş IDE benzeri bir arayüz başlatır.

Yani `tdl c` bunu başlatır (veya sadece `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

`tdl c cx` (opencode + claude) ile ikinci bir ajan da başlatabilirsiniz (veya sadece `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Ayrıca sol üstte editör, sağ üstte canlı bir diff izleyicisi, sol altta bir terminal ve sağ altta opencode ile dört yollu bir kare başlatan `tds` de var.

Bu düzen yapılandırmasını geçerli dizindeki her alt dizin için `tdlm [agent]` kullanarak da başlatabilir, ardından `alt + 1/2/3/4/5/...` kullanarak gezinebilirsiniz:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Son olarak, `tsl [panes] [command]` kullanarak bir ajan sürüsü başlatabilirsiniz. Yani `tsl 4 c` size dört yollu bir opencode ajanları ızgarası verecektir:

 ![tmux-tsl](images/tmux-tsl.webp)
