# Web Uygulamaları

Kendi web uygulamalarınızı Omarchy menüsündeki (`Super + Space`) _Kur > Web App_ seçeneğini kullanarak ekleyebilirsiniz. Sizden uygulama adını, uygulama URL'sini ve favicon aracılığıyla alamazsa simge URL'sini isteyecektir. Birçok popüler web uygulaması için harika PNG simgelerini [Dashboard Icons](https://dashboardicons.com) adresinde bulabilirsiniz.

Bunlar daha sonra uygulama başlatıcı (`Super + Space`) aracılığıyla erişilebilir olacak ve güzel çerçevesiz web uygulaması penceresini kullanacaktır.

Bir web uygulamasını kaldırmak isterseniz, Omarchy menüsünde _Kaldır > Web App_ seçeneğine gitmeniz yeterlidir.

Web uygulaması kısayollarını kullanmadan önce tüm hesaplarınıza normal bir tarayıcı kullanarak giriş yapmanız en iyisidir. İnce sarmalayıcı çerçeve 1password ile iyi çalışmaz, bu yüzden doğrudan önceden giriş yapmış olmak daha kolaydır.

Bu web uygulamaları için tüm klavye kısayolları `~/.config/hypr/bindings.lua` içinde değiştirilebilir.

Bir web uygulamasındayken, geçerli URL'yi `Shift + Alt + L` kullanarak panoya kopyalayabilirsiniz.

Varsayılan olarak Omarchy, zaten bir dizi varsayılan uygulamayla birlikte gelir:

## HEY

[HEY](https://www.hey.com/), Gmail, Outlook veya Apple Mail'den bıkan insanlar için harika bir alternatif olan bir e-posta ve takvim hizmetidir. Omarchy'nin doğduğu [37signals](https://37signals.com/) tarafından yapılır.

HEY Email'i `Super + Shift + E` kullanarak başlatabilir, `Super + Shift + Alt + E` kullanarak doğrudan yeni bir e-posta oluşturmaya atlayabilir ve HEY Calendar'ı `Super + Shift + C` kullanarak başlatabilirsiniz.

## Basecamp

[Basecamp](https://basecamp.com/), küçük ekiplerin daha hızlı hareket etmesine ve daha fazla ilerleme kaydetmesine yardımcı olan bir proje yönetim hizmetidir. Trello, Slack, Asana, Notion veya her neyse karmakarışık bir derlemeyi bir araya getirmek yerine Basecamp ile hepsini tek bir yerde edinebilirsiniz. Omarchy'nin doğduğu [37signals](https://37signals.com/) tarafından yapılır.

Basecamp'i uygulama başlatıcıyı (`Super + Space`) kullanarak başlatabilirsiniz

## ChatGPT

[ChatGPT](https://chatgpt.com), dünyanın en popüler AI sohbet botudur.

ChatGPT'yi `Super + Shift + A` kullanarak başlatabilirsiniz.

## Grok

[Grok](https://grok.com), xAI'nın sohbet botudur.

Grok'u `Super + Shift + Alt + A` kullanarak başlatabilirsiniz.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/), dünyanın en popüler mesajlaşma hizmetlerinden biridir ve web sürümü Linux için harika bir seçenektir.

WhatsApp'ı `Super + Shift + Alt + G` kullanarak başlatabilirsiniz.

## Google uygulamaları

Google Messages, Google Photos, Google Maps ve Google Contacts da web uygulamaları olarak dahil edilmiştir.

Google Messages'ı `Super + Shift + Ctrl + G` kullanarak, Google Photos'u `Super + Shift + P` kullanarak ve Google Maps'i `Super + Shift + S` kullanarak başlatabilirsiniz. Google Contacts, uygulama başlatıcı (`Super + Space`) aracılığıyla kullanılabilir.

## X

X, haberlerin patladığı yerdir.

X'i `Super + Shift + X` kullanarak başlatabilir ve `Super + Shift + Alt + X` ile doğrudan yeni bir gönderi yazmaya gidebilirsiniz.

## YouTube

[YouTube](https://youtube.com/), dünyanın en popüler video platformudur.

YouTube'u `Super + Shift + Y` kullanarak başlatabilirsiniz.

## Zoom

[Zoom](https://zoom.us/), ABD'de kullanılan en popüler görüntülü sohbet sistemidir. Dünya çapında harika bağlantılar. Ve 40 dakikalık toplantılar ücretli bir hesap olmadan yapılabilir. Omarchy, Zoom'un web istemcisini sarar ve zoom toplantı bağlantıları doğrudan onun içinde açılacaktır.

Zoom'u uygulama başlatıcıyı (`Super + Space`) kullanarak başlatırsınız.

## Discord

[Discord](https://discord.com/), [Omarchy'nin kendi topluluğu](https://discord.gg/tXFUdasqhY) dahil çoğu oyun ve açık kaynak topluluğunun takıldığı yerdir.

Discord'u uygulama başlatıcıyı (`Super + Space`) kullanarak başlatırsınız.

## Microsoft uygulamaları

Outlook, Word, Excel, PowerPoint, Teams ve OneDrive'ı web uygulamaları olarak eklemek için _Kur > Service > Microsoft_ seçeneğini seçin. Her uygulamanın kendi başlatıcısı vardır ve ticari Microsoft 365 URL'lerini ve mevcut tarayıcı profilinizi kullanarak doğrudan açılır. Omarchy'nin diğer web uygulamalarıyla aynı tarayıcı uygulama pencerelerinde açılırlar; ayrı Teams for Linux istemcisini kurmazlar.

Paketi _Kaldır > Service > Microsoft_ ile kaldırın veya tek tek uygulamaları _Kaldır > Web App_ ile kaldırın. Ayrıca yalnızca istediğiniz uygulamaları _Kur > Web App_ aracılığıyla da kurabilirsiniz.

Devlet veya egemen bir bulut için, kuruluşunuz tarafından sağlanan URL'yi kullanarak `~/.local/share/applications/` altındaki ilgili başlatıcıdaki, örneğin `Microsoft Teams.desktop`, `Exec=` satırındaki URL'yi düzenleyin. Bu satırdaki herhangi bir gerçek `%` işaretini `%%` olarak yazın. Değişiklikler bir sonraki başlatmada geçerli olur. Paket kurulumcusunu yeniden çalıştırmak, başlatıcılarını varsayılan URL'lerle değiştirir.

İş amaçlı oturum açmaları ayrı tutmak için, her başlatıcının `Exec=` satırına bir tarayıcı veri dizini ekleyin:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Örnek dizini, seçtiğiniz mutlak bir yolla değiştirin ve iş amaçlı oturum açmaları aralarında paylaşmak için altı başlatıcının tümü için aynı yolu kullanın. Web uygulamaları, Omarchy'nin seçili desteklenen tarayıcısını kullanır; varsayılan tarayıcı desteklenmediğinde Chromium'a geri düşerler.
