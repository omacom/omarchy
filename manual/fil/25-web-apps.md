# Mga Web App

Maaari kang magdagdag ng sarili mong mga web app gamit ang _Install > Web App_ sa Omarchy menu (`Super + Space`). Hihingin nito sa iyo ang pangalan ng app, URL ng app, at URL ng icon, kung hindi nito makuha sa pamamagitan ng favicon. Makakakuha ka ng magagandang PNG icon para sa maraming sikat na web app sa [Dashboard Icons](https://dashboardicons.com).

Maa-access mo sila pagkatapos sa pamamagitan ng app launcher (`Super + Space`), at gagamitin ang magandang frameless na web-app window.

Kung gusto mong alisin ang isang web app, pumunta lang sa _Remove > Web App_ sa Omarchy menu.

Pinakamahusay kung magla-log in ka sa lahat ng iyong account gamit ang isang regular na browser bago gamitin ang mga web app shortcut. Hindi gumagana nang maayos ang thin wrapper frame sa 1password, kaya mas madali na lang na naka-log in ka na nang direkta muna.

Maaaring baguhin ang lahat ng keyboard hotkey para sa mga web app na ito sa `~/.config/hypr/bindings.lua`.

Kapag nasa isang web app ka, maaari mong kopyahin ang kasalukuyang URL sa clipboard gamit ang `Shift + Alt + L`.

Bilang default, may kasama nang iba't ibang default na app ang Omarchy:

## HEY

Ang [HEY](https://www.hey.com/) ay isang serbisyo ng email at kalendaryo na nagsisilbing mahusay na alternatibo para sa mga taong pagod na sa Gmail, Outlook, o Apple Mail. Ginawa ito ng [37signals](https://37signals.com/) kung saan nagmula ang Omarchy.

Maaari mong simulan ang HEY Email gamit ang `Super + Shift + E`, dumiretso sa pag-compose ng bagong email gamit ang `Super + Shift + Alt + E`, at simulan ang HEY Calendar gamit ang `Super + Shift + C`.

## Basecamp

Ang [Basecamp](https://basecamp.com/) ay isang serbisyo ng project management na tumutulong sa maliliit na team na kumilos nang mas mabilis at gumawa ng mas maraming progreso. Sa halip na pagtagpi-tagpiin ang isang mishmash ng Trello, Slack, Asana, Notion, o kung ano pa man, maaari mong makuha ang lahat sa isang lugar gamit ang Basecamp. Ginawa ito ng [37signals](https://37signals.com/) kung saan nagmula ang Omarchy.

Maaari mong simulan ang Basecamp gamit ang application launcher (`Super + Space`)

## ChatGPT

Ang [ChatGPT](https://chatgpt.com) ay ang pinakasikat na AI chat bot sa mundo.

Maaari mong simulan ang ChatGPT gamit ang `Super + Shift + A`.

## Grok

Ang [Grok](https://grok.com) ay chat bot ng xAI.

Maaari mong simulan ang Grok gamit ang `Super + Shift + Alt + A`.

## WhatsApp

Ang [WhatsApp](https://www.whatsapp.com/) ay isa sa mga pinakasikat na serbisyo ng messaging sa mundo, at ang web version ay isang mahusay na pagpipilian para sa Linux.

Maaari mong simulan ang WhatsApp gamit ang `Super + Shift + Alt + G`.

## Mga Google app

Kasama rin bilang mga web app ang Google Messages, Google Photos, Google Maps, at Google Contacts.

Maaari mong simulan ang Google Messages gamit ang `Super + Shift + Ctrl + G`, ang Google Photos gamit ang `Super + Shift + P`, at ang Google Maps gamit ang `Super + Shift + S`. Magagamit ang Google Contacts sa pamamagitan ng app launcher (`Super + Space`).

## X

Ang X ay kung saan sumisikat ang balita.

Maaari mong simulan ang X gamit ang `Super + Shift + X` at dumiretso sa pagsulat ng bagong post gamit ang `Super + Shift + Alt + X`.

## YouTube

Ang [YouTube](https://youtube.com/) ay ang pinakasikat na video platform sa mundo.

Maaari mong simulan ang YouTube gamit ang `Super + Shift + Y`.

## Zoom

Ang [Zoom](https://zoom.us/) ay ang pinakasikat na video chat system na ginagamit sa US. Mahusay na koneksyon sa buong mundo. At maaaring magdaos ng 40-minutong meeting nang walang bayad na account. Binabalot ng Omarchy ang web client ng Zoom, at ang mga zoom meeting link ay bubukas nang direkta dito.

Sinisimulan mo ang Zoom gamit ang application launcher (`Super + Space`).

## Discord

Ang [Discord](https://discord.com/) ay kung saan tumatambay ang karamihan sa mga gaming at open source community, kasama ang [sarili ng Omarchy](https://discord.gg/tXFUdasqhY).

Sinisimulan mo ang Discord gamit ang application launcher (`Super + Space`).

## Mga Microsoft app

Piliin ang _Install > Service > Microsoft_ para idagdag ang Outlook, Word, Excel, PowerPoint, Teams, at OneDrive bilang mga web app. Ang bawat app ay may sariling launcher at bumubukas nang direkta, gamit ang mga komersyal na Microsoft 365 URL at ang iyong kasalukuyang browser profile. Bumubukas sila sa parehong browser app window tulad ng iba pang web app ng Omarchy; hindi nila ini-install ang hiwalay na Teams for Linux client.

Alisin ang bundle gamit ang _Remove > Service > Microsoft_, o alisin ang mga indibidwal na app gamit ang _Remove > Web App_. Maaari mo ring i-install lang ang mga app na gusto mo sa pamamagitan ng _Install > Web App_.

Para sa isang government o sovereign cloud, i-edit ang URL sa linyang `Exec=` sa kaukulang launcher sa ilalim ng `~/.local/share/applications/`, tulad ng `Microsoft Teams.desktop`, gamit ang URL na ibinigay ng iyong organisasyon. Isulat ang anumang literal na `%` sa linyang iyon bilang `%%`. Nalalapat ang mga pagbabago sa susunod na paglunsad. Ang pagpapatakbo ulit ng bundle installer ay papalitan ang mga launcher nito ng mga default na URL.

Para panatilihing hiwalay ang mga work sign-in, magdagdag ng browser data directory sa linyang `Exec=` ng bawat launcher:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Palitan ang halimbawang direktoryo ng isang absolute path na pinili mo at gamitin ang parehong path para sa lahat ng anim na launcher para magbahagi ng mga work sign-in sa pagitan nila. Ginagamit ng mga web app ang napiling sinusuportahang browser ng Omarchy, na bumabalik sa Chromium kapag hindi sinusuportahan ang default na browser.
