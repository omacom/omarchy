# Programu za Wavuti

Unaweza kuongeza programu zako mwenyewe za wavuti kwa kutumia _Install > Web App_ katika menyu ya Omarchy (`Super + Space`). Itakuuliza jina la programu, URL ya programu, na URL ya aikoni, ikiwa haiwezi kuipata kupitia favicon. Unaweza kupata aikoni nzuri za PNG kwa programu nyingi maarufu za wavuti kwenye [Dashboard Icons](https://dashboardicons.com).

Kisha zitaweza kufikiwa kupitia kizinduzi cha programu (`Super + Space`), na zinatumia dirisha zuri la programu ya wavuti lisilo na fremu.

Ikiwa unataka kuondoa programu ya wavuti, nenda tu kwenye _Remove > Web App_ katika menyu ya Omarchy.

Ni bora ukiingia katika akaunti zako zote kwa kutumia kivinjari cha kawaida kabla ya kutumia mikato ya programu za wavuti. Fremu nyembamba ya kifuniko haifanyi kazi vizuri na 1password, kwa hivyo ni rahisi zaidi kuingia moja kwa moja kwanza.

Mikato yote ya kibodi kwa programu hizi za wavuti inaweza kubadilishwa katika `~/.config/hypr/bindings.lua`.

Ukiwa katika programu ya wavuti, unaweza kunakili URL ya sasa kwenye ubao wa kunakili kwa kutumia `Shift + Alt + L`.

Kwa chaguo-msingi, Omarchy tayari inakuja na mkusanyiko wa programu chaguo-msingi:

## HEY

[HEY](https://www.hey.com/) ni huduma ya barua pepe na kalenda ambayo ni mbadala mzuri kwa watu waliochoka na Gmail, Outlook, au Apple Mail. Imetengenezwa na [37signals](https://37signals.com/) ambapo Omarchy ilianzia.

Unaweza kuwasha HEY Email kwa kutumia `Super + Shift + E`, kuruka moja kwa moja kutunga barua pepe mpya kwa kutumia `Super + Shift + Alt + E`, na kuwasha HEY Calendar kwa kutumia `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) ni huduma ya usimamizi wa miradi inayosaidia timu ndogo kusonga haraka na kupiga hatua zaidi. Badala ya kuunganisha pamoja mchanganyiko wa Trello, Slack, Asana, Notion, au chochote kile, unaweza kupata vyote mahali pamoja na Basecamp. Imetengenezwa na [37signals](https://37signals.com/) ambapo Omarchy ilianzia.

Unaweza kuwasha Basecamp kwa kutumia kizinduzi cha programu (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) ni roboti ya mazungumzo ya AI maarufu zaidi duniani.

Unaweza kuwasha ChatGPT kwa kutumia `Super + Shift + A`.

## Grok

[Grok](https://grok.com) ni roboti ya mazungumzo ya xAI.

Unaweza kuwasha Grok kwa kutumia `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) ni mojawapo ya huduma maarufu zaidi za kutuma ujumbe duniani, na toleo la wavuti ni chaguo zuri kwa Linux.

Unaweza kuwasha WhatsApp kwa kutumia `Super + Shift + Alt + G`.

## Programu za Google

Google Messages, Google Photos, Google Maps, na Google Contacts zote zimejumuishwa kama programu za wavuti pia.

Unaweza kuwasha Google Messages kwa kutumia `Super + Shift + Ctrl + G`, Google Photos kwa kutumia `Super + Shift + P`, na Google Maps kwa kutumia `Super + Shift + S`. Google Contacts inapatikana kupitia kizinduzi cha programu (`Super + Space`).

## X

X ndipo habari zinapotokea kwanza.

Unaweza kuwasha X kwa kutumia `Super + Shift + X` na kwenda moja kwa moja kuandika chapisho jipya kwa kutumia `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) ni jukwaa maarufu zaidi la video duniani.

Unaweza kuwasha YouTube kwa kutumia `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) ni mfumo maarufu zaidi wa mazungumzo ya video unaotumiwa katika US. Miunganisho mizuri kote duniani. Na mikutano ya dakika 40 inaweza kufanyika bila akaunti ya kulipia. Omarchy hufunika mteja wa wavuti wa Zoom, na viungo vya mikutano ya zoom vitafunguka moja kwa moja ndani yake.

Unaanza Zoom kwa kutumia kizinduzi cha programu (`Super + Space`).

## Discord

[Discord](https://discord.com/) ndipo jumuiya nyingi za michezo na open source hukutana, ikiwa ni pamoja na [ya Omarchy yenyewe](https://discord.gg/tXFUdasqhY).

Unaanza Discord kwa kutumia kizinduzi cha programu (`Super + Space`).

## Programu za Microsoft

Chagua _Install > Service > Microsoft_ kuongeza Outlook, Word, Excel, PowerPoint, Teams, na OneDrive kama programu za wavuti. Kila programu ina kizinduzi chake na hufunguka moja kwa moja, kwa kutumia URL za kibiashara za Microsoft 365 na wasifu wako uliopo wa kivinjari. Hufunguka katika madirisha sawa ya programu ya kivinjari kama programu zingine za wavuti za Omarchy; hazisakinishi mteja tofauti wa Teams for Linux.

Ondoa kifurushi kwa _Remove > Service > Microsoft_, au ondoa programu moja moja kwa _Remove > Web App_. Unaweza pia kusakinisha programu tu unazotaka kupitia _Install > Web App_.

Kwa wingu la serikali au la kujitegemea, hariri URL kwenye mstari wa `Exec=` katika kizinduzi husika chini ya `~/.local/share/applications/`, kama vile `Microsoft Teams.desktop`, ukitumia URL iliyotolewa na shirika lako. Andika `%` halisi yoyote katika mstari huo kama `%%`. Mabadiliko hutumika wakati ujao wa kuwasha. Kuendesha kisakinishi cha kifurushi tena hubadilisha vizinduzi vyake na URL chaguo-msingi.

Ili kuweka uingiaji wa kazini kuwa tofauti, ongeza saraka ya data ya kivinjari mwishoni mwa mstari wa `Exec=` wa kila kizinduzi:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Badilisha saraka ya mfano na njia kamili unayoichagua na utumie njia hiyo hiyo kwa vizinduzi vyote sita ili zishiriki uingiaji wa kazini kati yao. Programu za wavuti hutumia kivinjari kilichochaguliwa cha Omarchy kinachotumika, zikirejea kwa Chrome wakati kivinjari chaguo-msingi hakitumiki.
