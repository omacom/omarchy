# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit), GitHub Desktop uygulaması gibi bir şeye keyifli bir alternatiftir ve terminalin içinde çalışır.

Doğrudan çalıştırabilirsin: git tarafından yönetilen herhangi bir dizine gidip `lazygit` çalıştırman yeterli. Ya da Neovim içinde çalıştırabilirsin; orada `Space G G` ile başlatılır.

Farklı bölmeler arasında `Tab` ile gezersin. Dosyalar bölmesinde, dosyaları `Space` ile sahneye eklersin, ardından `c` ile yeni bir commit oluşturabilirsin. Kullanılabilir tüm komutları `?` ile görebilirsin.

## Btop

[Btop](https://github.com/aristocratos/btop), bellek, CPU, disk ve ağ kullanımını gösteren güzel bir kaynak yöneticisidir. Ayrıca tüm etkin süreçleri listeler ve onları yönetmene olanak tanır.

Omarchy buna Etkinlik İzleyicisi der; uygulama başlatıcıdan ya da `Super + Shift + T` tuşlarına basarak başlatırsın. Yüzen bir pencere olarak açılır; `Super + T` ile döşeyebilirsin.

## Herdr

[Herdr](https://herdr.dev), sana çalışma alanları, sekmeler ve bölmeler sunan ve hepsini daha sonra ayrılıp geri dönebileceğin kalıcı bir oturumda çalışır durumda tutan bir terminal çalışma alanı yöneticisidir.

Uygulama başlatıcıdan ya da `Super + Ctrl + Return` ile başlatırsın (ya da mevcut oturumuna yeniden bağlanırsın). Omarchy, Tmux yapılandırmasını yansıtan bir Herdr yapılandırmasıyla gelir, bu yüzden önek tuşu burada da `Ctrl + Space` olur. Tüm tuş atamalarına `Super + Ctrl + K` ile göz atabilirsin.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch), çekirdek sürümü, çalışma süresi, tema, CPU, bellek ve daha fazlası gibi sistem bilgilerini gösterir. Popüler neofetch aracının halefidir.

Omarchy bunu, Omarchy menüsünde (`Super + Space`) _Sistem > Hakkında_ olarak paketledi.

## Cliamp

[Cliamp](https://www.cliamp.stream/), Winamp 2.x'den ilham alan, lo-fi beats için yerleşik radyo istasyonlarıyla birlikte gelen retro bir terminal müzik çalardır. `Super + Shift + Alt + M` ile ya da Omarchy menüsünde _Uygulamalar_ altından başlat. Tam tuş atama listesi için `?` tuşuna bas.

## Peki ya Wi-Fi ve Bluetooth?

Wi-Fi ve Bluetooth için TUIs bulamazsın — bu işler Omarchy kabuğuna aittir. Ağları görüp bağlanmak için üst çubuktaki Wi-Fi simgesine tıkla (ya da `Super + Ctrl + N` tuşlarına bas); cihazları eşleştirip bağlamak için Bluetooth simgesine tıkla (ya da `Super + Ctrl + B` tuşlarına bas). Hikâyenin tamamı için [ağ bağlantıları](35-networking.md) bölümüne bak.

## Kendininkini ekleme

Herhangi bir terminal programı, tam uygulama muamelesi görebilir. Omarchy menüsünde (`Super + Space`) _Kur > TUI_ bölümüne git, ona bir ad, bir başlatma komutu, bir pencere stili ve bir simge ver; uygulama başlatıcıda diğer uygulamalar gibi görünecektir. _Kaldır > TUI_ altından tekrar kaldırabilirsin.
