# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit), GitHub Desktop gibi bir uygulamaya keyifli bir alternatiftir ve terminalin içinde çalışır.

Onu doğrudan çalıştırabilirsin: git ile yönetilen herhangi bir dizine gidip `lazygit` çalıştırman yeterli. Ya da Neovim içinde çalıştırabilirsin; orada `Space G G` ile başlatılır.

Farklı bölmeler arasında `Tab` ile atlarsın. Files bölmesinde, dosyaları aşamalandırmak üzere `Space` ile seçersin ve ardından `c` ile yeni bir commit oluşturabilirsin. Kullanılabilir tüm komutları `?` ile görebilirsin.

## Btop

[Btop](https://github.com/aristocratos/btop), bellek, CPU, disk ve ağ kullanımını gösteren güzel bir kaynak yöneticisidir. Ayrıca tüm etkin süreçleri listeler ve onları yönetmene olanak tanır.

Omarchy ona Activity Monitor der ve onu uygulama başlatıcıdan veya `Super + Shift + T` tuşlarına basarak başlatırsın. Yüzen bir pencere olarak açılır; onu `Super + T` ile döşeyebilirsin.

## Herdr

[Herdr](https://github.com/omacom-io/herdr), sana çalışma alanları, sekmeler ve bölmeler sunan bir terminal çalışma alanı yöneticisidir ve hepsini, ayrılıp daha sonra geri dönebileceğin kalıcı bir oturumda çalışır durumda tutar.

Onu `Super + Ctrl + Return` ile başlatırsın (veya mevcut oturumuna yeniden bağlanırsın). Omarchy, Tmux yapılandırmasını yansıtan bir Herdr yapılandırmasıyla gelir, bu yüzden burada da önek tuşu `Ctrl + Space` tuşudur. Tüm tuş atamalarına `Super + Ctrl + K` ile göz atabilirsin.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch), çekirdek sürümü, çalışma süresi, tema, CPU, bellek ve daha fazlası gibi sistem bilgilerini gösterir. Popüler neofetch aracının halefidir.

Omarchy bunu Omarchy menüsünde (`Super + Space`) _About_ olarak paketlemiştir.

## Cliamp

[Cliamp](https://www.cliamp.stream/), Winamp 2.x'ten ilham alan, lo-fi beat'ler için yerleşik radyo istasyonlarıyla birlikte gelen retro bir terminal müzik çalarıdır. Onu `Super + Shift + Alt + M` ile veya Omarchy menüsünde _Apps_ altından başlat. Tüm tuş atamalarının listesi için `?` tuşuna bas.

## Wi-Fi ve Bluetooth ne olacak?

Wi-Fi ve Bluetooth için TUI bulamazsın — bu işler Omarchy kabuğuna aittir. Ağları görmek ve bağlanmak için üst çubuktaki Wi-Fi simgesine tıkla (veya `Super + Ctrl + N` tuşlarına bas), cihazları eşleştirmek ve bağlamak için de Bluetooth simgesine tıkla (veya `Super + Ctrl + B` tuşlarına bas). Hikâyenin tamamı için bkz. [ağ bağlantıları](35-networking.md).

## Kendi TUI'ni ekleme

Herhangi bir terminal programı tam uygulama muamelesi görebilir. Omarchy menüsünde (`Super + Space`) _Install > TUI_ yoluna git, ona bir ad, bir başlatma komutu, bir pencere stili ve bir simge ver; o da diğer uygulamalar gibi uygulama başlatıcıda görünecektir. Onu _Remove > TUI_ altından tekrar kaldırabilirsin.
