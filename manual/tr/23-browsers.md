# Tarayıcılar

Omarchy, varsayılan tarayıcı olarak [Google Chrome](https://www.google.com/chrome/) ile gelir. Sisteminizin geri kalanıyla uyumlu olacak şekilde temalandırılmıştır ve `Super + Shift + Return` (veya `Super + Shift + B`) tuşlarının açtığı şey de, özel bir pencere için `Super + Shift + Alt + B` ile birlikte, her [web uygulamasının](25-web-apps.md) içinde çalıştığı şey de budur. Doğrudan bir tarayıcı penceresine açılır: karşılama ekranı veya oturum açma istemi yoktur, kullanım istatistikleri ve çökme raporları Google'a gönderilmez ve reklam gizliliği istemleri kapatılmıştır. Senkronizasyon istediğinizde profil düğmesinden Google hesabınızda yine oturum açabilirsiniz.

Chrome zevkinize uygun değilse, onunla yetinmek zorunda değilsiniz. Omarchy menüsünde _Kurulum > Tarayıcı_ altında [Chromium](https://www.chromium.org/) (Chrome'un kendisinden yapıldığı sade açık kaynak derleme), Edge, Brave, Brave Origin, Firefox ve [Zen](https://zen-browser.app/) bulacaksınız (Edge yalnızca x86 makinelerde). Birini seçin; Omarchy onu kurar, ilke dizinini ayarlar ve geçerli temanızı ona uygular.

## Birini varsayılan yapma

Bir tarayıcı kurmak onu öne çıkarmaz. Geçiş yapmak için _Ayarlar > Varsayılanlar > Tarayıcı_ yoluna gidin ve birini seçin. Geçerli varsayılan bir onay işaretiyle işaretlenmiştir ve henüz sahip olmadığınız bir tarayıcıyı seçmek onu önce kurar.

Terminalden şu şekilde yapılır:

```bash
omarchy default browser firefox
```

Hiçbir bağımsız değişken olmadan çalıştırırsanız size geçerli varsayılanı söyler. Bu, XDG işleyicisini ayarlar, yani yalnızca Omarchy'nin kısayol tuşları buna uymaz — bir sohbet uygulamasından bir terminal komutuna kadar bir bağlantıyı açan her şey, seçtiğiniz tarayıcıya gider.

## URL'yi Kopyala ve Video İndir

Chromium ailesi tarayıcılar (Chromium'un kendisi, Chrome, Edge, Brave ve Brave Origin), üç Omarchy uzantısıyla gelir: ikisi tarayıcının dışına, sisteminizin geri kalanına ulaşır ve biri WhatsApp'ı düzenler.

**Copy URL**, geçerli sekmenin adresini `Alt + Shift + L` ile panonuza koyar. Bu, adres çubuğuna tıklayıp kopyalamaktan daha hızlıdır ve tarayıcınınki yerine sistem panosu üzerinden gittiği için, bunu onaylayan bir Omarchy bildirimi alırsınız ve URL [pano geçmişinde](08-unified-clipboard-history.md) ve diğer her uygulamada hemen kullanılabilir olur. Tercih ederseniz tıklamanız için bir araç çubuğu düğmesi de vardır.

**Download Video**, baktığınız sayfada oynatılan videoyu `Alt + Shift + D` ile kapar. URL'yi [yt-dlp](https://github.com/yt-dlp/yt-dlp) aracına verir, yani YouTube'dan çok daha fazlasında çalışır ve indirme `~/Videos` içine iner. İlerleme, ses ve parlaklığın kullandığı aynı ekran üstü göstergede görünür ve bildirimleri üst üste yığmak yerine yerinde güncellenir. Dosyaların başka bir yere gitmesini tercih ederseniz `OMARCHY_YTDLP_DIR` değişkenini ayarlayın — ortam değişkenlerini nereye koyacağınız için [FAQ](46-faq.md) bölümüne bakın.

Her iki uzantı da Omarchy ile küçük bir yerel mesajlaşma ana bilgisayarı üzerinden konuşur; bu, tarayıcıyla birlikte sizin için kurulur. Bir web sayfasındaki videonun ana dizininize inmesine ve bir URL'nin pano yöneticinize düşmesine izin veren parça budur; normal bir uzantı bunu tek başına yapamaz.

**WhatsApp Slim**, WhatsApp Web'in sistem temanızı izlemesini sağlar ve pencere dar olduğunda sohbet listesini daraltır.

Bunlar yalnızca Chromium ailesine özeldir. Firefox ve Zen bunları almaz.

## Firefox ve Zen

Firefox ve Zen farklı bir ailedir, bu yüzden farklı muamele görürler: Omarchy, mantıklı varsayılanlar için bir ilkeler dosyası kurar ve onları yerel Wayland moduna geçirir; kesirli ölçeklendirme ve akıcı dokunmatik yüzey kaydırma için bunu istersiniz.

Yukarıdaki Chromium uzantılarını almazlar ve Omarchy tarafından temalandırılmazlar, yani deneyimin o kısımlarını ayarlamak size kalır.

## Birini tekrar kaldırma

Chrome dahil bu tarayıcılardan herhangi biri, _Kaldır > Tarayıcı_ altından tekrar kaldırılabilir. Diğeri hâlâ kuruluysa bağlantılar o zaman Chrome'a veya Chromium'a gider.
