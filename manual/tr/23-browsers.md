# Tarayıcılar

Omarchy, varsayılan tarayıcı olarak [Google Chrome](https://www.google.com/chrome/) ile birlikte gelir. Sisteminizin geri kalanıyla uyuşacak şekilde temalandırılmıştır ve `Super + Shift + Return` (veya `Super + Shift + B`) kısayolunun açtığı tarayıcı budur; `Super + Shift + Alt + B` gizli pencere içindir ve her [web uygulaması](25-web-apps.md) bunun içinde çalışır. Doğrudan bir tarayıcı penceresine açılır: karşılama ekranı veya oturum açma istemi yoktur, kullanım istatistikleri ve çökme raporları Google'a gönderilmez ve reklam gizliliği istemleri kapatılmıştır. Senkronizasyon istediğinizde profil düğmesinden yine de Google hesabınızda oturum açabilirsiniz.

Chrome zevkinize göre değilse, ona mahkûm değilsiniz. Omarchy menüsünde _Install > Browser_ altında [Chromium](https://www.chromium.org/) (Chrome'un yapıldığı sade açık kaynaklı sürüm), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) ve [Ladybird](https://ladybird.org/) bulacaksınız (Edge yalnızca x86 makinelerde). Birini seçin; Omarchy onu kurar, politika dizinini ayarlar ve mevcut temanızı ona uygular.

## Birini varsayılan yapmak

Bir tarayıcı kurmak, onu varsayılan yapmaz. Geçiş yapmak için _Setup > Defaults > Browser_ bölümüne gidin ve birini seçin. Mevcut varsayılan bir onay işaretiyle belirtilir ve henüz sahip olmadığınız bir tarayıcıyı seçerseniz önce o kurulur.

Terminalden şöyle yapılır:

```bash
omarchy default browser firefox
```

Argümansız çalıştırırsanız mevcut varsayılanı söyler. Bu, XDG işleyicisini ayarlar; yani buna uyan yalnızca Omarchy'nin kısayol tuşları değildir — sohbet uygulamasından terminal komutuna kadar bağlantı açan her şey, seçtiğiniz tarayıcıya gider.

## URL'yi Kopyala ve Videoyu İndir

Chromium ailesi tarayıcılar (Chromium'un kendisi, Chrome, Edge, Brave ve Brave Origin) üç Omarchy uzantısıyla birlikte gelir: ikisi tarayıcının dışına, sisteminizin geri kalanına uzanır, biri de WhatsApp'ı derleyip toplar.

**Copy URL**, geçerli sekmenin adresini `Alt + Shift + L` ile panonuza kopyalar. Bu, adres çubuğuna tıklayıp kopyalamaktan daha hızlıdır ve tarayıcının panosu yerine sistem panosu üzerinden gittiği için bunu doğrulayan bir Omarchy bildirimi alırsınız ve URL anında [pano geçmişinde](08-unified-clipboard-history.md) ve diğer tüm uygulamalarda kullanılabilir olur. Tercih ederseniz tıklamanız için bir araç çubuğu düğmesi de vardır.

**Download Video**, baktığınız sayfada oynayan videoyu `Alt + Shift + D` ile alır. URL'yi [yt-dlp](https://github.com/yt-dlp/yt-dlp) aracına verir, bu yüzden YouTube'dan çok daha fazlasında çalışır ve indirme `~/Videos` klasörüne düşer. İlerleme, ses ve parlaklığın kullandığı aynı ekran üstü göstergede görünür; bildirimleri üst üste yığmak yerine yerinde güncellenir. Dosyaların başka bir yere gitmesini tercih ederseniz `OMARCHY_YTDLP_DIR` değişkenini ayarlayın — ortam değişkenlerini nereye koyacağınız için [SSS](46-faq.md) bölümüne bakın.

Her iki uzantı da Omarchy ile, tarayıcıyla birlikte sizin için kurulan küçük bir yerel mesajlaşma sunucusu üzerinden konuşur. Bir web sayfasındaki videonun ana dizininize, bir URL'nin de pano yöneticinize düşmesini sağlayan parça budur; normal bir uzantı bunu kendi başına yapamaz.

**WhatsApp Slim**, WhatsApp Web'in sistem temanızı izlemesini sağlar ve pencere dar olduğunda sohbet listesini daraltır.

Bunlar yalnızca Chromium ailesine özeldir. Firefox ve Zen bunları almaz.

## Firefox ve Zen

Firefox ve Zen farklı bir ailedir, bu yüzden farklı muamele görürler: Omarchy, mantıklı varsayılanlar için bir politikalar dosyası kurar ve onları yerel Wayland moduna geçirir; kesirli ölçeklendirme ve akıcı dokunmatik yüzey kaydırma için istediğiniz şey budur.

Yukarıdaki Chromium uzantılarını almazlar ve Omarchy tarafından temalandırılmazlar, bu yüzden deneyimin o kısımlarını ayarlamak size kalır.

## Ladybird

Ladybird, Chromium'un veya Firefox'un motoru yerine kendi motoruyla, sıfırdan yazılmış bir tarayıcıdır. Hâlâ alfa aşamasındadır, bu yüzden henüz çalışmayan sitelerle karşılaşmayı bekleyin; Omarchy onu olduğu gibi kurar: uzantı yok, tema yok, politika yok. Gizli penceresi de yoktur, bu yüzden `Super + Shift + Alt + B` onu, kapattığınızda silinen geçici bir profille açar. [Web uygulamaları](25-web-apps.md) Chrome veya Chromium içinde çalışmaya devam eder.

## Birini tekrar kaldırmak

Chrome da dahil olmak üzere bu tarayıcıların herhangi biri _Remove > Browser_ altından tekrar kaldırılabilir. Bağlantılar daha sonra, diğeri hâlâ kuruluysa Chrome veya Chromium'a gider.
