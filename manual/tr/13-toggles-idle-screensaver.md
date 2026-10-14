# Aç/Kapat, Boşta ve Ekran Koruyucu

Günden güne değiştirdiğiniz şeylerin çoğu aslında bir ayar değildir. Bir saatliğine açıp tekrar kapattığınız bir moddur: geç çalışırken gece ışığı, sunum yaparken rahatsız etme, bir şey izlerken uyanık tut. Omarchy bunlara aç/kapat der ve hepsi aynı şekilde çalışır — bir kısayol, bir menü girdisi ve bir komut, hepsi aynı anahtara basar.

### Aç/kapat menüsü

`Super + Ctrl + O`, _Tetikle > Aç/Kapat_ öğesini doğrudan açar veya oraya Omarchy menüsünden (`Super + Space`) gidebilirsiniz. Bu listedeki her şey, durumun nerede yaşadığını düşünmeden çevirebileceğiniz bir anahtardır. Masaüstünün nasıl göründüğüne ilişkin anahtarlar yanında, _Tetikle > Görünüm_ altında oturur.

Terminalden, aynı anahtarlar `omarchy toggle <thing>` şeklindedir. Tüm grubu görmek için `omarchy toggle` komutunu tek başına çalıştırın.

| Aç/Kapat | Kısayol | Komut |
| ------ | ------ | ------- |
| Gece Işığı | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Bildirimleri sessize al | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Uyanık tut (boşta kilidi yok) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Çökme Yakalama | — | `omarchy toggle crash-capture` |
| Ekran Koruyucu | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) tema eşitlemesi | — | `omarchy toggle theme sync` |
| Menü Çubuğu | `Super + Shift + Space` | `omarchy toggle bar` |
| Dokunmatik Yüzey | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Dokunmatik Ekran | — | `omarchy toggle touchscreen` |
| Uyku | — | `omarchy toggle suspend` |
| Hibrit GPU | — | `omarchy toggle hybrid gpu` |

Dokunmatik yüzey, dokunmatik ekran ve hibrit GPU anahtarları, Aç/Kapat altında değil _Tetikle > Donanım_ (`Super + Ctrl + H`) altında yaşar, çünkü bunlar yalnızca o donanıma gerçekten sahip olduğunuzda ortaya çıkar. Dokunmatik yüzey ve dokunmatik ekran anahtarları Hyprland yeniden yüklemesinden sağ çıkar — devre dışı bırakılmış cihazın adı, Hyprland'in başlangıçta onu tekrar devre dışı bırakmak için okuduğu küçük bir durum dosyasına kaydedilir.

_Tetikle > Görünüm_, menü çubuğu ve Animasyonlar ile, `omarchy toggle` komutları olmayan ancak aynı şekilde davranan birkaç şeyi tutar: çubuktaki Pil Yüzdesi, varsayılan Çalışma Alanı Düzeni, Pencere Boşlukları (`Super + Shift + Backspace`) ve 1-pencere kare oranı (`Super + Ctrl + Backspace`).

Bunların çoğu `~/.local/state/omarchy/toggles/` altında sadece bir bayrak dosyasıdır. Bir betikte birine dallanmak isterseniz, `omarchy-toggle-enabled` sizi arayışa çıkarmak yerine size bir çıkış kodu verir:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bayraklar kapalı duruma göre adlandırılır — `screensaver-off`, `suspend-off`, `bar-off` — böylece varlıkları özelliğin devre dışı olduğu anlamına gelir.

### Çubuktaki göstergeler

Bir mod açıkken, saatin yanında üst çubuğun ortasında küçük bir simge alırsınız. Bu, göstergeler widget'ıdır ve dikte, ekran kaydı, bekleyen hatırlatıcılar, gece ışığı, rahatsız etme ve uyanık tutu taşır.

Aktif olmayan göstergeler gizlidir. Etraflarındaki alana gelin, soluk bir şekilde belirirler, böylece kısayolunu bilmeden birini açmak için tıklayabilirsiniz. Aktif birine tıklamak onu tekrar kapatır. Hepsini her zaman görmeyi tercih ederseniz, `~/.config/omarchy/shell.json` içindeki `omarchy.indicators` girdisinde `alwaysShow` seçeneğini `true` olarak ayarlayın — çubuk widget'larının nasıl yapılandırılacağı için bkz. [üst çubuk](05-the-top-bar.md).

### Gece Işığı

`Super + Ctrl + N` ekranı 4000K'ya ısıtır ve ona tekrar basmak onu 6500K'ya geri getirir. Aç/kapat, zaten çalışmıyorsa sizin için başlattığı hyprsunset tarafından sürülür.

Varsayılan olarak hyprsunset ekranınıza hiçbir şey yapmaz. `~/.config/hypr/hyprsunset.conf`, siz sıcaklık isteyene kadar ekran dokunulmadan kalsın diye tam olarak bir kimlik profiliyle gönderilir. Saate göre değişmesini tercih ederseniz, bunu bir zaman profiliyle değiştirin:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ardından `~/.config/hypr/autostart.lua` dosyasına `o.launch_on_start("hyprsunset")` ekleyerek hyprsunset'ı oturum açmada başlatın. Aç/kapat tarafından kullanılan 4000K/6500K çifti sabittir, bu yüzden farklı bir sıcaklık isterseniz gidilecek yer yapılandırma dosyasıdır.

### Rahatsız Etme

`Super + Ctrl + ,` bildirimleri sessize alır. Açıkken hiçbir bildirim belirmez ve üstü çizili çan göstergesi, masaüstünün neden sessizleştiğini hatırlatmak için çubukta oturur.

Ancak hiçbir şey kaybolmaz. Sessize alınmış bir bildirim doğrudan bildirim geçmişinize yazılır; bu, geri geldiğinizde neyi kaçırdığınızı merak ettiğinizde tam olarak isteyeceğiniz kayıttır. Onu `Super + Shift + Alt + ,` ile açın. Bildirim hikayesinin geri kalanı için bkz. [bildirimler](10-notices.md).

İki tür mesaj yine de geçer: Omarchy'nin az önce yaptığınız bir şey için kendi onay bildirimleri ("Theme changed", "Screenshot saved") ve komut satırından gönderilen kritik uyarılar. Önünüze geçmek için her şeyi kritik olarak işaretleyen sohbet uygulamaları buna uygun değildir.

### Boşta

Omarchy kabuğu boşta davranışına sahiptir ve zamanlamalar `~/.config/omarchy/shell.json` içinde üst düzey bir `idle` bloğudur:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Her iki sayı da boşta kaldığınız andan itibaren sayılan saniyelerdir — birbirinden değil. Böylece varsayılanlarla, ekran koruyucu iki buçuk dakika sonra devreye girer ve kilit ekranı, ekran koruyucu çalışsa da çalışmasa da beş dakikada devreye alır. Dosyayı kaydedin, kabuk yeni zamanlamaları hemen alır.

Kilit süresinden önce ekran koruyucuyu kapatırsanız, bu aktivite sayılır ve bekleyen kilit iptal edilir. Makinenize göz attığınız için dışarı kilitlenmezsiniz.

Boşta kilitlenmeyi tamamen durdurmak için, `Super + Ctrl + I` — veya `omarchy toggle idle` — uyanık tutu açar ve çubukta kahve fincanı göstergesi görünür. Uzun bir sunum veya izlemek istediğiniz bir derleme öncesi basılacak olan budur. Normale dönmek için tekrar basın. Bir betikten ihtiyacınız olursa `omarchy toggle idle status` geçerli durumu JSON olarak yazar.

Bu, kilitleme ve ekran koruyucu ile ilgilidir, güçle değil. Uyku ve hazırda bekletmenin [sistem uykusu](36-system-sleep.md) bölümünde kendi kurulumları vardır.

### Ekran Koruyucu

Omarchy'nin Ekran Koruyucusu, monitör başına bir örnek olmak üzere rastgele metin efektlerinden geçen ASCII sanatıdır. Herhangi bir tuş veya fare hareketi ondan çıkar.

Onu _Sistem > Ekran Koruyucu_ (`Super + Esc`) yoluyla isteğe bağlı olarak başlatabilirsiniz; bu, boşta ekran koruyucuyu kapatmış olsanız bile onu zorla açar. Varsayılan olarak ona bağlı bir kısayol yoktur.

`omarchy toggle screensaver`, doğrudan çalışmadan kilitli duruma gitmeyi tercih ederseniz boşta olanı kapatan şeydir. Nasıl yapılandırılacağını bildiği bir terminale ihtiyaç duyar — Alacritty, Foot, Ghostty veya Kitty — ve varsayılan terminaliniz başka bir şeyse bunu size söyler.

Çizdiği logo, _Stil > Ekran Koruyucu_ altında sizindir değiştirmek. Bir png veya svg yükleyin, Omarchy onu ASCII'ye dönüştürür. Bkz. [markalama](41-branding.md).

### Kilit ekranı

`Super + Ctrl + L` makineyi kilitler. Bu, Omarchy kabuğundan kilit ekranını çalıştırır, ekranı karartır, parolanızı yanlış alfabede yazmamanız için klavye düzeninizi ilkine sıfırlar ve — çalıştırıyorsanız — çıkışta 1Password'ü kilitler.

Kilit ekranı bir parola alır ve birini kurduktan sonra Parmak İzi de alır. Bu ve kimlik doğrulamanın diğer yolları [donanım kimlik doğrulama](37-hardware-authentication.md) bölümünde ele alınmıştır.
