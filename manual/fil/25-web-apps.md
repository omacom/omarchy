# Mga Web App

Maaari kang magdagdag ng sarili mong mga web app gamit ang _Install > Web App_ sa Omarchy menu (`Super + Space`). Hihingin nito sa iyo ang pangalan ng app, URL ng app, at URL ng icon, kung hindi nito ito makuha sa pamamagitan ng favicon. Makakakuha ka ng magagandang PNG icon para sa maraming sikat na web app sa [Dashboard Icons](https://dashboardicons.com).

Mapupuntahan mo na ang mga ito sa pamamagitan ng app launcher (`Super + Space`), at gagamitin nila ang magandang frameless na web-app window.

Kung gusto mong mag-alis ng web app, pumunta lang sa _Remove > Web App_ sa Omarchy menu.

Pinakamainam na mag-log in ka muna sa lahat ng account mo gamit ang regular na browser bago gamitin ang mga web app shortcut. Hindi gumagana nang maayos ang manipis na wrapper frame sa 1password, kaya mas madali kung naka-log in ka na nang direkta.

Mababago ang lahat ng keyboard hotkey para sa mga web app na ito sa `~/.config/hypr/bindings.lua`.

Kapag nasa loob ka ng isang web app, maaari mong kopyahin ang kasalukuyang URL papunta sa clipboard gamit ang `Shift + Alt + L`.

Bilang default, may kasama nang iba't ibang default na app ang Omarchy:

## HEY

Ang [HEY](https://www.hey.com/) ay isang email at calendar service na mahusay na alternatibo para sa mga taong pagod na sa Gmail, Outlook, o Apple Mail. Gawa ito ng [37signals](https://37signals.com/) kung saan nagmula ang Omarchy.

Maaari mong simulan ang HEY Email gamit ang `Super + Shift + E`, dumiretso sa paggawa ng bagong email gamit ang `Super + Shift + Alt + E`, at simulan ang HEY Calendar gamit ang `Super + Shift + C`.

## Basecamp

Ang [Basecamp](https://basecamp.com/) ay isang project management service na tumutulong sa maliliit na team na gumalaw nang mas mabilis at mas marami ang magawa. Sa halip na pagtagpi-tagpiin ang samu't saring Trello, Slack, Asana, Notion, o kung ano pa man, maaari mong makuha ang lahat ng iyon sa iisang lugar gamit ang Basecamp. Gawa ito ng [37signals](https://37signals.com/) kung saan nagmula ang Omarchy.

Maaari mong simulan ang Basecamp gamit ang application launcher (`Super + Space`)

## ChatGPT

Ang [ChatGPT](https://chatgpt.com) ang pinakasikat na AI chat bot sa mundo.

Maaari mong simulan ang ChatGPT gamit ang `Super + Shift + A`.

## Grok

Ang [Grok](https://grok.com) ay chat bot ng xAI.

Maaari mong simulan ang Grok gamit ang `Super + Shift + Alt + A`.

## WhatsApp

Ang [WhatsApp](https://www.whatsapp.com/) ay isa sa pinakasikat na messaging service sa mundo, at ang web version ay isang mahusay na opsyon para sa Linux.

Maaari mong simulan ang WhatsApp gamit ang `Super + Shift + Alt + G`. Bumubukas ito kasama ang WhatsApp Slim extension ng Omarchy, na ginagawa itong sumunod sa iyong theme at tinutupi ang listahan ng chat kapag makitid ang window.

## Mga Google app

Kasama rin bilang mga web app ang Google Messages, Google Photos, Google Maps, at Google Contacts.

Maaari mong simulan ang Google Messages gamit ang `Super + Shift + Ctrl + G`, ang Google Photos gamit ang `Super + Shift + P`, at ang Google Maps gamit ang `Super + Shift + S`. Makukuha ang Google Contacts sa pamamagitan ng app launcher (`Super + Space`).

## X

Sa X unang sumisiklab ang mga balita.

Maaari mong simulan ang X gamit ang `Super + Shift + X` at dumiretso sa pagsulat ng bagong post gamit ang `Super + Shift + Alt + X`.

## YouTube

Ang [YouTube](https://youtube.com/) ang pinakasikat na video platform sa mundo.

Maaari mong simulan ang YouTube gamit ang `Super + Shift + Y`.

## Netflix

Kasama ang [Netflix](https://www.netflix.com/) bilang web app sa mga bagong install.

Sinisimulan mo ang Netflix gamit ang application launcher (`Super + Space`).

## Zoom

Ang [Zoom](https://zoom.us/) ang pinakasikat na video chat system na ginagamit sa US. Mahusay ang mga koneksyon sa buong mundo. At maaaring magdaos ng 40-minutong meeting nang walang bayad na account. Binalot ng Omarchy ang web client ng Zoom, at direktang bubukas dito ang mga zoom meeting link.

Sinisimulan mo ang Zoom gamit ang application launcher (`Super + Space`).

## Discord

Ang [Discord](https://discord.com/) ay kung saan tumatambay ang karamihan sa mga gaming at open source community, kabilang ang [sariling komunidad ng Omarchy](https://discord.gg/tXFUdasqhY).

Sinisimulan mo ang Discord gamit ang application launcher (`Super + Space`).

## Mga Microsoft app

Piliin ang _Install > Service > Microsoft_ upang idagdag ang Outlook, Word, Excel, PowerPoint, Teams, at OneDrive bilang mga web app. May sariling launcher ang bawat app at direktang bumubukas, gamit ang mga komersyal na Microsoft 365 URL at ang kasalukuyang profile ng iyong browser. Bumubukas ang mga ito sa parehong browser app window gaya ng ibang web app ng Omarchy; hindi nila ini-install ang hiwalay na Teams for Linux client.

Alisin ang bundle gamit ang _Remove > Services > Microsoft_, o alisin ang mga indibidwal na app gamit ang _Remove > Web App_. Maaari mo ring i-install lamang ang mga app na gusto mo sa pamamagitan ng _Install > Web App_.

Para sa government o sovereign cloud, i-edit ang URL sa linyang `Exec=` sa kaukulang launcher sa ilalim ng `~/.local/share/applications/`, gaya ng `Microsoft Teams.desktop`, gamit ang URL na ibinigay ng iyong organisasyon. Isulat ang anumang literal na `%` sa linyang iyon bilang `%%`. Magkakabisa ang mga pagbabago sa susunod na paglulunsad. Kapag pinatakbo mo ulit ang bundle installer, papalitan nito ang mga launcher nito ng mga default na URL.

Upang paghiwalayin ang mga work sign-in, magdagdag ng browser data directory sa linyang `Exec=` ng bawat launcher:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Palitan ang halimbawang directory ng absolute path na gusto mo at gamitin ang parehong path para sa lahat ng anim na launcher upang magbahaginan sila ng mga work sign-in. Ginagamit ng mga web app ang napiling suportadong browser ng Omarchy, at bumabalik sa Chrome kapag hindi suportado ang default na browser.
