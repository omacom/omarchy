# Mga Web App

Maaari kang magdagdag ng sarili mong mga web app gamit ang _Install > Web App_ sa menu ng Omarchy (`Super + Space`). Hihingin nito sa iyo ang pangalan ng app, URL ng app, at URL ng icon, kung hindi nito makuha ang mga ito sa pamamagitan ng favicon. Makakakuha ka ng magagandang PNG icon para sa maraming sikat na web app sa [Dashboard Icons](https://dashboardicons.com).

Mapupuntahan mo na ang mga ito sa pamamagitan ng app launcher (`Super + Space`), at gagamitin nila ang magandang frameless na window ng web-app.

Kung gusto mong mag-alis ng web app, pumunta lang sa _Remove > Web App_ sa menu ng Omarchy.

Pinakamainam na mag-log in ka muna sa lahat ng account mo gamit ang regular na browser bago gamitin ang mga shortcut ng web app. Hindi gumagana nang maayos ang manipis na wrapper frame sa 1password, kaya mas madali kung naka-log in ka na agad bago pa man.

Mababago ang lahat ng keyboard hotkey para sa mga web app na ito sa `~/.config/hypr/bindings.lua`.

Kapag nasa loob ka ng isang web app, maaari mong kopyahin ang kasalukuyang URL papunta sa clipboard gamit ang `Shift + Alt + L`.

Bilang default, may kasama nang iba't ibang default na app ang Omarchy:

## HEY

Ang [HEY](https://www.hey.com/) ay isang serbisyo ng email at kalendaryo na nagsisilbing mahusay na alternatibo para sa mga taong sawa na sa Gmail, Outlook, o Apple Mail. Gawa ito ng [37signals](https://37signals.com/) kung saan nagmula ang Omarchy.

Maaari mong simulan ang HEY Email gamit ang `Super + Shift + E`, dumiretso sa paggawa ng bagong email gamit ang `Super + Shift + Alt + E`, at simulan ang HEY Calendar gamit ang `Super + Shift + C`.

## Basecamp

Ang [Basecamp](https://basecamp.com/) ay isang serbisyo ng project management na tumutulong sa maliliit na team na kumilos nang mas mabilis at mas marami pang matapos. Sa halip na pagtagpi-tagpiin ang samu't saring Trello, Slack, Asana, Notion, o kung ano pa man, maaari mong makuha ang lahat ng iyon sa iisang lugar gamit ang Basecamp. Gawa ito ng [37signals](https://37signals.com/) kung saan nagmula ang Omarchy.

Maaari mong simulan ang Basecamp gamit ang application launcher (`Super + Space`)

## ChatGPT

Ang [ChatGPT](https://chatgpt.com) ang pinakasikat na AI chat bot sa mundo.

Maaari mong simulan ang ChatGPT gamit ang `Super + Shift + A`.

## Grok

Ang [Grok](https://grok.com) ay chat bot ng xAI.

Maaari mong simulan ang Grok gamit ang `Super + Shift + Alt + A`.

## WhatsApp

Ang [WhatsApp](https://www.whatsapp.com/) ay isa sa pinakasikat na serbisyo ng pagmemensahe sa mundo, at mahusay na opsyon para sa Linux ang web version nito.

Maaari mong simulan ang WhatsApp gamit ang `Super + Shift + Alt + G`.

## Mga app ng Google

Kasama rin bilang mga web app ang Google Messages, Google Photos, Google Maps, at Google Contacts.

Maaari mong simulan ang Google Messages gamit ang `Super + Shift + Ctrl + G`, ang Google Photos gamit ang `Super + Shift + P`, at ang Google Maps gamit ang `Super + Shift + S`. Mapupuntahan ang Google Contacts sa pamamagitan ng app launcher (`Super + Space`).

## X

Sa X sumisiklab ang mga balita.

Maaari mong simulan ang X gamit ang `Super + Shift + X` at dumiretso sa pagsulat ng bagong post gamit ang `Super + Shift + Alt + X`.

## YouTube

Ang [YouTube](https://youtube.com/) ang pinakasikat na platform ng video sa mundo.

Maaari mong simulan ang YouTube gamit ang `Super + Shift + Y`.

## Zoom

Ang [Zoom](https://zoom.us/) ang pinakasikat na sistema ng video chat na ginagamit sa US. Mahuhusay na koneksyon sa buong mundo. At maaaring magdaos ng 40-minutong mga meeting nang walang bayad na account. Binalot ng Omarchy ang web client ng Zoom, at direktang bubukas dito ang mga link ng meeting sa zoom.

Sinisimulan mo ang Zoom gamit ang application launcher (`Super + Space`).

## Discord

Ang [Discord](https://discord.com/) ang tambayan ng karamihan sa mga komunidad ng gaming at open source, kabilang ang [sarili ng Omarchy](https://discord.gg/tXFUdasqhY).

Sinisimulan mo ang Discord gamit ang application launcher (`Super + Space`).

## Mga app ng Microsoft

Piliin ang _Install > Service > Microsoft_ para idagdag ang Outlook, Word, Excel, PowerPoint, Teams, at OneDrive bilang mga web app. Bawat app ay may sarili nitong launcher at direktang bumubukas, gamit ang mga komersyal na URL ng Microsoft 365 at ang kasalukuyan mong profile sa browser. Bumubukas ang mga ito sa parehong mga window ng browser app gaya ng ibang mga web app ng Omarchy; hindi nila ini-install ang hiwalay na client ng Teams for Linux.

Alisin ang bundle gamit ang _Remove > Service > Microsoft_, o alisin ang mga indibidwal na app gamit ang _Remove > Web App_. Maaari mo ring i-install lang ang mga app na gusto mo sa pamamagitan ng _Install > Web App_.

Para sa cloud ng pamahalaan o sovereign cloud, i-edit ang URL sa linyang `Exec=` sa nauugnay na launcher sa ilalim ng `~/.local/share/applications/`, tulad ng `Microsoft Teams.desktop`, gamit ang URL na ibinigay ng iyong organisasyon. Isulat ang anumang literal na `%` sa linyang iyon bilang `%%`. Magkakabisa ang mga pagbabago sa susunod na paglulunsad. Kapag pinatakbo mo ulit ang installer ng bundle, papalitan nito ang mga launcher nito ng mga default na URL.

Para manatiling hiwalay ang mga sign-in sa trabaho, magdagdag ng direktoryo ng data ng browser sa linyang `Exec=` ng bawat launcher:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Palitan ang halimbawang direktoryo ng absolute path na gusto mo at gamitin ang parehong path para sa lahat ng anim na launcher para magbahagi ang mga ito ng mga sign-in sa trabaho. Ginagamit ng mga web app ang napiling sinusuportahang browser ng Omarchy, at babalik sa Chrome kapag hindi sinusuportahan ang default na browser.
