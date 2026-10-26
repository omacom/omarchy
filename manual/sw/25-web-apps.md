# Programu za Wavuti

Unaweza kuongeza programu zako mwenyewe za wavuti kwa kutumia _Sakinisha > Programu ya wavuti_ katika menyu ya Omarchy (`Super + Space`). Itakuuliza jina la programu, URL ya programu, na URL ya aikoni, kama haiwezi kuipata kupitia favicon. Unaweza kupata aikoni bora za PNG kwa programu nyingi maarufu za wavuti kwenye [Dashboard Icons](https://dashboardicons.com).

Zitafikiwa kisha kupitia kizinduzi cha programu (`Super + Space`), na kutumia dirisha zuri la programu ya wavuti lisilo na fremu.

Kama ungependa kuondoa programu ya wavuti, nenda tu kwenye _Ondoa > Programu ya wavuti_ katika menyu ya Omarchy.

Ni bora kama ukiingia katika akaunti zako zote kwa kutumia kivinjari cha kawaida kabla ya kutumia mikato ya programu za wavuti. Fremu nyembamba ya kufunika haifanyi kazi vizuri na 1password, hivyo ni rahisi tu kuingia moja kwa moja kwanza.

Mikato yote ya kibodi kwa programu hizi za wavuti inaweza kubadilishwa katika `~/.config/hypr/bindings.lua`.

Unapokuwa katika programu ya wavuti, unaweza kunakili URL ya sasa kwenye ubao wa kunakili kwa kutumia `Shift + Alt + L`.

Kwa chaguomsingi, Omarchy tayari huja na mkusanyiko wa programu chaguomsingi:

## HEY

[HEY](https://www.hey.com/) ni huduma ya barua pepe na kalenda inayotumika kama mbadala bora kwa watu waliochoka na Gmail, Outlook, au Apple Mail. Imetengenezwa na [37signals](https://37signals.com/) ambapo Omarchy ilianzia.

Unaweza kuanzisha HEY Email kwa kutumia `Super + Shift + E`, kuruka moja kwa moja kutunga barua pepe mpya kwa kutumia `Super + Shift + Alt + E`, na kuanzisha HEY Calendar kwa kutumia `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) ni huduma ya usimamizi wa miradi inayosaidia timu ndogo kusonga haraka zaidi na kufanya maendeleo zaidi. Badala ya kuunganisha mchanganyiko wa Trello, Slack, Asana, Notion, au chochote, unaweza kuwa na vyote katika sehemu moja na Basecamp. Imetengenezwa na [37signals](https://37signals.com/) ambapo Omarchy ilianzia.

Unaweza kuanzisha Basecamp kwa kutumia kizinduzi cha programu (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) ni roboti ya gumzo ya AI maarufu zaidi duniani.

Unaweza kuanzisha ChatGPT kwa kutumia `Super + Shift + A`.

## Grok

[Grok](https://grok.com) ni roboti ya gumzo ya xAI.

Unaweza kuanzisha Grok kwa kutumia `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) ni moja ya huduma maarufu zaidi za ujumbe duniani, na toleo la wavuti ni chaguo bora kwa Linux.

Unaweza kuanzisha WhatsApp kwa kutumia `Super + Shift + Alt + G`.

## Programu za Google

Google Messages, Google Photos, Google Maps, na Google Contacts zote zimejumuishwa kama programu za wavuti pia.

Unaweza kuanzisha Google Messages kwa kutumia `Super + Shift + Ctrl + G`, Google Photos kwa kutumia `Super + Shift + P`, na Google Maps kwa kutumia `Super + Shift + S`. Google Contacts inapatikana kupitia kizinduzi cha programu (`Super + Space`).

## X

X ni mahali ambapo habari huvunjika.

Unaweza kuanzisha X kwa kutumia `Super + Shift + X` na kwenda moja kwa moja kuandika chapisho jipya kwa `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) ni jukwaa maarufu zaidi la video duniani.

Unaweza kuanzisha YouTube kwa kutumia `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) ni mfumo maarufu zaidi wa gumzo la video unaotumiwa nchini Marekani. Miunganisho mizuri duniani kote. Na mikutano ya dakika 40 inaweza kufanywa bila akaunti ya kulipia. Omarchy hufunika mteja wa wavuti wa Zoom, na viungo vya mikutano ya zoom vitafunguka moja kwa moja ndani yake.

Unaanzisha Zoom kwa kutumia kizinduzi cha programu (`Super + Space`).

## Discord

[Discord](https://discord.com/) ni mahali ambapo jamii nyingi za michezo na chanzo huria hukutana, ikiwa ni pamoja na [ya Omarchy yenyewe](https://discord.gg/tXFUdasqhY).

Unaanzisha Discord kwa kutumia kizinduzi cha programu (`Super + Space`).

## Programu za Microsoft

Chagua _Sakinisha > Huduma > Microsoft_ kuongeza Outlook, Word, Excel, PowerPoint, Teams, na OneDrive kama programu za wavuti. Kila programu ina kizinduzi chake na hufunguka moja kwa moja, kwa kutumia URL za kibiashara za Microsoft 365 na wasifu wako uliopo wa kivinjari. Zinafunguka katika madirisha ya programu ya kivinjari kama programu nyingine za wavuti za Omarchy; hazisakinishi mteja tofauti wa Teams for Linux.

Ondoa kifurushi kwa _Ondoa > Huduma > Microsoft_, au ondoa programu za mtu binafsi kwa _Ondoa > Programu ya wavuti_. Unaweza pia kusakinisha tu programu unazozitaka kupitia _Sakinisha > Programu ya wavuti_.

Kwa wingu la serikali au huru, hariri URL kwenye mstari wa `Exec=` katika kizinduzi husika chini ya `~/.local/share/applications/`, kama `Microsoft Teams.desktop`, kwa kutumia URL iliyotolewa na shirika lako. Andika `%` yoyote halisi katika mstari huo kama `%%`. Mabadiliko hutumika katika uzinduzi unaofuata. Kuendesha kisakinishi cha kifurushi tena hubadilisha vizinduzi vyake na URL chaguomsingi.

Ili kuweka uingiaji wa kazi tofauti, ongeza saraka ya data ya kivinjari kwenye mstari wa `Exec=` wa kila kizinduzi:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Badilisha saraka ya mfano na njia kamili ya chaguo lako na utumie njia ile ile kwa vizinduzi vyote sita kushiriki uingiaji wa kazi kati yake. Programu za wavuti hutumia kivinjari kinachoungwa mkono kilichochaguliwa na Omarchy, ikirudi kwenye Chromium wakati kivinjari chaguomsingi hakikubaliki.
