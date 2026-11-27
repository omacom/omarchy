# 웹 앱

Omarchy 메뉴(`Super + Space`)에서 _설치 > 웹 앱_을 이용해 나만의 웹 앱을 추가할 수 있습니다. favicon으로 아이콘을 가져올 수 없으면 앱 이름, 앱 URL, 아이콘 URL을 물어봅니다. 인기 있는 많은 웹 앱에 쓸 멋진 PNG 아이콘은 [Dashboard Icons](https://dashboardicons.com)에서 구할 수 있습니다.

그렇게 추가한 앱은 앱 실행기(`Super + Space`)를 통해 이용할 수 있으며, 아름다운 프레임 없는 웹 앱 창을 사용합니다.

웹 앱을 제거하고 싶으면 Omarchy 메뉴에서 _제거 > 웹 앱_으로 가면 됩니다.

웹 앱 단축키를 사용하기 전에 일반 브라우저로 모든 계정에 로그인해 두는 것이 가장 좋습니다. 얇은 래퍼 프레임은 1password와 잘 맞지 않으니, 그냥 먼저 직접 로그인해 두는 편이 더 쉽습니다.

이 웹 앱들의 모든 키보드 단축키는 `~/.config/hypr/bindings.lua`에서 변경할 수 있습니다.

웹 앱 안에 있을 때는 `Shift + Alt + L`을 이용해 현재 URL을 클립보드에 복사할 수 있습니다.

기본적으로 Omarchy에는 이미 다양한 기본 앱이 들어 있습니다:

## HEY

[HEY](https://www.hey.com/)는 Gmail, Outlook, Apple Mail에 지친 사람들에게 훌륭한 대안이 되는 이메일 및 캘린더 서비스입니다. Omarchy가 시작된 [37signals](https://37signals.com/)에서 만들었습니다.

`Super + Shift + E`를 이용해 HEY Email을 시작하고, `Super + Shift + Alt + E`를 이용해 바로 새 이메일 작성으로 이동하며, `Super + Shift + C`를 이용해 HEY Calendar를 시작할 수 있습니다.

## Basecamp

[Basecamp](https://basecamp.com/)는 소규모 팀이 더 빠르게 움직이고 더 많은 진전을 이루도록 돕는 프로젝트 관리 서비스입니다. Trello, Slack, Asana, Notion 등 온갖 것을 짜깁기로 붙여 쓰는 대신, Basecamp 하나로 한곳에서 모두 해결할 수 있습니다. Omarchy가 시작된 [37signals](https://37signals.com/)에서 만들었습니다.

애플리케이션 실행기(`Super + Space`)를 이용해 Basecamp를 시작할 수 있습니다

## ChatGPT

[ChatGPT](https://chatgpt.com)는 세계에서 가장 인기 있는 AI 챗봇입니다.

`Super + Shift + A`를 이용해 ChatGPT를 시작할 수 있습니다.

## Grok

[Grok](https://grok.com)은 xAI의 챗봇입니다.

`Super + Shift + Alt + A`를 이용해 Grok을 시작할 수 있습니다.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/)은 세계에서 가장 인기 있는 메시징 서비스 중 하나이며, 웹 버전은 Linux에서 쓰기에 훌륭한 선택입니다.

`Super + Shift + Alt + G`를 이용해 WhatsApp을 시작할 수 있습니다. Omarchy의 WhatsApp Slim 확장 기능과 함께 열리며, 이 확장 기능 덕분에 테마를 따르고 창이 좁아지면 채팅 목록이 접힙니다.

## Google 앱

Google Messages, Google Photos, Google Maps, Google Contacts도 모두 웹 앱으로 포함되어 있습니다.

`Super + Shift + Ctrl + G`를 이용해 Google Messages를, `Super + Shift + P`를 이용해 Google Photos를, `Super + Shift + S`를 이용해 Google Maps를 시작할 수 있습니다. Google Contacts는 앱 실행기(`Super + Space`)를 통해 이용할 수 있습니다.

## X

X는 뉴스가 터지는 곳입니다.

`Super + Shift + X`를 이용해 X를 시작하고 `Super + Shift + Alt + X`를 이용해 바로 새 글을 작성할 수 있습니다.

## YouTube

[YouTube](https://youtube.com/)는 세계에서 가장 인기 있는 동영상 플랫폼입니다.

`Super + Shift + Y`를 이용해 YouTube를 시작할 수 있습니다.

## Netflix

[Netflix](https://www.netflix.com/)는 새로 설치한 경우 웹 앱으로 포함되어 있습니다.

애플리케이션 실행기(`Super + Space`)를 이용해 Netflix를 시작합니다.

## Zoom

[Zoom](https://zoom.us/)은 미국에서 사용되는 가장 인기 있는 화상 채팅 시스템입니다. 전 세계 어디서든 연결이 훌륭합니다. 그리고 유료 계정 없이도 40분 회의를 열 수 있습니다. Omarchy는 Zoom의 웹 클라이언트를 감싸며, Zoom 회의 링크는 곧바로 그 안에서 열립니다.

애플리케이션 실행기(`Super + Space`)를 이용해 Zoom을 시작합니다.

## Discord

[Discord](https://discord.com/)는 대부분의 게이밍 및 오픈 소스 커뮤니티가 모이는 곳으로, [Omarchy 자체 커뮤니티](https://discord.gg/tXFUdasqhY)도 여기에 있습니다.

애플리케이션 실행기(`Super + Space`)를 이용해 Discord를 시작합니다.

## Microsoft 앱

_설치 > 서비스 > Microsoft_를 선택해 Outlook, Word, Excel, PowerPoint, Teams, OneDrive를 웹 앱으로 추가하세요. 각 앱마다 자체 실행기가 있으며, 상용 Microsoft 365 URL과 기존 브라우저 프로필을 사용해 바로 열립니다. Omarchy의 다른 웹 앱과 같은 브라우저 앱 창에서 열립니다. 별도의 Teams for Linux 클라이언트를 설치하지는 않습니다.

_제거 > 서비스 > Microsoft_로 번들을 제거하거나, _제거 > 웹 앱_으로 개별 앱을 제거하세요. _설치 > 웹 앱_을 통해 원하는 앱만 설치할 수도 있습니다.

정부용 또는 소버린 클라우드의 경우, `~/.local/share/applications/` 아래의 관련 실행기, 예를 들어 `Microsoft Teams.desktop`에서 `Exec=` 줄의 URL을 조직에서 제공한 URL로 편집하세요. 그 줄에 리터럴 `%`를 쓸 때는 `%%`로 쓰세요. 변경 사항은 다음 실행 시 적용됩니다. 번들 설치 프로그램을 다시 실행하면 그 실행기들이 기본 URL로 교체됩니다.

업무용 로그인을 분리해 두려면, 각 실행기의 `Exec=` 줄에 브라우저 데이터 디렉터리를 추가하세요:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

예시 디렉터리를 원하는 절대 경로로 바꾸고, 여섯 실행기 모두에 같은 경로를 사용해 업무용 로그인을 서로 공유하세요. 웹 앱은 Omarchy가 선택한 지원 브라우저를 사용하며, 기본 브라우저가 지원되지 않으면 Chrome으로 대체합니다.
