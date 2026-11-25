# Web Uygulamaları

Omarchy menüsünde (`Super + Space`) _Install > Web App_ seçeneğini kullanarak kendi web uygulamalarınızı ekleyebilirsiniz. Sizden uygulama adını, uygulama URL'sini ve favicon üzerinden alamazsa simge URL'sini isteyecektir. Birçok popüler web uygulaması için harika PNG simgelerini [Dashboard Icons](https://dashboardicons.com) sitesinde bulabilirsiniz.

Bunlara daha sonra uygulama başlatıcı (`Super + Space`) üzerinden erişebileceksiniz ve güzel, çerçevesiz web uygulaması penceresini kullanacaklar.

Bir web uygulamasını kaldırmak isterseniz, Omarchy menüsünde _Remove > Web App_ seçeneğine gitmeniz yeterli.

Web uygulaması kısayollarını kullanmadan önce tüm hesaplarınıza normal bir tarayıcıyla giriş yapmanız en iyisi. İnce sarmalayıcı çerçeve 1password ile iyi çalışmıyor, bu yüzden doğrudan önceden giriş yapmış olmak daha kolay.

Bu web uygulamalarına ait tüm klavye kısayolları `~/.config/hypr/bindings.lua` içinde değiştirilebilir.

Bir web uygulamasındayken, `Shift + Alt + L` kullanarak geçerli URL'yi panoya kopyalayabilirsiniz.

Omarchy, varsayılan olarak zaten bir dizi varsayılan uygulamayla birlikte gelir:

## HEY

[HEY](https://www.hey.com/), Gmail, Outlook veya Apple Mail'den bıkanlar için harika bir alternatif sunan bir e-posta ve takvim hizmetidir. Omarchy'nin ortaya çıktığı [37signals](https://37signals.com/) tarafından yapılmıştır.

HEY Email'i `Super + Shift + E` ile başlatabilir, `Super + Shift + Alt + E` ile doğrudan yeni bir e-posta oluşturmaya atlayabilir ve HEY Calendar'ı `Super + Shift + C` ile başlatabilirsiniz.

## Basecamp

[Basecamp](https://basecamp.com/), küçük ekiplerin daha hızlı hareket etmesine ve daha fazla ilerleme kaydetmesine yardımcı olan bir proje yönetimi hizmetidir. Trello, Slack, Asana, Notion veya her neyse, karmakarışık bir yığın şeyi bir araya yamamak yerine Basecamp ile hepsini tek bir yerde bulabilirsiniz. Omarchy'nin ortaya çıktığı [37signals](https://37signals.com/) tarafından yapılmıştır.

Basecamp'i uygulama başlatıcıyı (`Super + Space`) kullanarak başlatabilirsiniz

## ChatGPT

[ChatGPT](https://chatgpt.com) dünyadaki en popüler yapay zeka sohbet botudur.

ChatGPT'yi `Super + Shift + A` kullanarak başlatabilirsiniz.

## Grok

[Grok](https://grok.com), xAI'nin sohbet botudur.

Grok'u `Super + Shift + Alt + A` kullanarak başlatabilirsiniz.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) dünyadaki en popüler mesajlaşma hizmetlerinden biridir ve web sürümü Linux için harika bir seçenektir.

WhatsApp'ı `Super + Shift + Alt + G` kullanarak başlatabilirsiniz. Omarchy'nin WhatsApp Slim uzantısıyla açılır; bu uzantı, temanıza uymasını sağlar ve pencere dar olduğunda sohbet listesini daraltır.

## Google apps

Google Messages, Google Photos, Google Maps ve Google Contacts da web uygulamaları olarak dahildir.

Google Messages'ı `Super + Shift + Ctrl + G`, Google Photos'u `Super + Shift + P` ve Google Maps'i `Super + Shift + S` kullanarak başlatabilirsiniz. Google Contacts'a uygulama başlatıcı (`Super + Space`) üzerinden erişilebilir.

## X

X, haberlerin patladığı yerdir.

X'i `Super + Shift + X` kullanarak başlatabilir ve `Super + Shift + Alt + X` ile doğrudan yeni bir gönderi yazmaya gidebilirsiniz.

## YouTube

[YouTube](https://youtube.com/) dünyadaki en popüler video platformudur.

YouTube'u `Super + Shift + Y` kullanarak başlatabilirsiniz.

## Netflix

[Netflix](https://www.netflix.com/) yeni kurulumlarda bir web uygulaması olarak dahildir.

Netflix'i uygulama başlatıcıyı (`Super + Space`) kullanarak başlatırsınız.

## Zoom

[Zoom](https://zoom.us/) ABD'de kullanılan en popüler görüntülü sohbet sistemidir. Dünyanın dört bir yanında harika bağlantılar. Ve ücretli bir hesap olmadan 40 dakikalık toplantılar yapılabilir. Omarchy, Zoom'un web istemcisini sarar ve Zoom toplantı bağlantıları doğrudan onun içinde açılır.

Zoom'u uygulama başlatıcıyı (`Super + Space`) kullanarak başlatırsınız.

## Discord

[Discord](https://discord.com/), [Omarchy'ninki](https://discord.gg/tXFUdasqhY) de dahil olmak üzere çoğu oyun ve açık kaynak topluluğunun takıldığı yerdir.

Discord'u uygulama başlatıcıyı (`Super + Space`) kullanarak başlatırsınız.

## Microsoft apps

Outlook, Word, Excel, PowerPoint, Teams ve OneDrive'ı web uygulamaları olarak eklemek için _Install > Service > Microsoft_ seçeneğini seçin. Her uygulamanın kendi başlatıcısı vardır ve ticari Microsoft 365 URL'lerini ve mevcut tarayıcı profilinizi kullanarak doğrudan açılır. Omarchy'nin diğer web uygulamalarıyla aynı tarayıcı uygulaması pencerelerinde açılırlar; ayrı Teams for Linux istemcisini kurmazlar.

Paketi _Remove > Services > Microsoft_ ile kaldırın veya tek tek uygulamaları _Remove > Web App_ ile kaldırın. Ayrıca yalnızca istediğiniz uygulamaları _Install > Web App_ üzerinden de kurabilirsiniz.

Bir devlet veya egemen bulut için, kuruluşunuz tarafından sağlanan URL'yi kullanarak `~/.local/share/applications/` altındaki ilgili başlatıcıda, örneğin `Microsoft Teams.desktop` içinde, `Exec=` satırındaki URL'yi düzenleyin. O satırdaki herhangi bir gerçek `%` karakterini `%%` olarak yazın. Değişiklikler bir sonraki başlatmada geçerli olur. Paket kurucusunu tekrar çalıştırmak, başlatıcılarını varsayılan URL'lerle değiştirir.

İş oturum açmalarını ayrı tutmak için, her başlatıcının `Exec=` satırına bir tarayıcı veri dizini ekleyin:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Örnek dizini seçtiğiniz bir mutlak yolla değiştirin ve iş oturum açmalarını aralarında paylaşmak için altı başlatıcının tamamında aynı yolu kullanın. Web uygulamaları, Omarchy'nin seçili desteklenen tarayıcısını kullanır; varsayılan tarayıcı desteklenmiyorsa Chrome'a geri döner.
