# 웹 앱

Omarchy 메뉴(`Super + Space`)에서 _Install > Web App_을 이용해 나만의 웹 앱을 추가할 수 있다. 앱 이름, 앱 URL, 그리고 favicon으로 가져올 수 없는 경우 아이콘 URL을 물어본다. 인기 있는 많은 웹 앱을 위한 훌륭한 PNG 아이콘은 [Dashboard Icons](https://dashboardicons.com)에서 구할 수 있다.

이렇게 추가한 앱은 앱 런처(`Super + Space`)를 통해 사용할 수 있으며, 아름다운 프레임 없는 웹 앱 창으로 열린다.

웹 앱을 제거하려면 Omarchy 메뉴에서 _Remove > Web App_으로 가면 된다.

웹 앱 바로가기를 사용하기 전에 일반 브라우저를 이용해 모든 계정에 로그인해 두는 것이 가장 좋다. 얇은 래퍼 프레임은 1password와 잘 맞지 않으니, 처음부터 직접 로그인해 두는 편이 그냥 더 쉽다.

이 웹 앱들의 모든 키보드 단축키는 `~/.config/hypr/bindings.lua`에서 변경할 수 있다.

웹 앱 안에 있을 때는 `Shift + Alt + L`을 이용해 현재 URL을 클립보드에 복사할 수 있다.

기본적으로 Omarchy에는 이미 다양한 기본 앱이 포함되어 있다:

## HEY

[HEY](https://www.hey.com/)는 Gmail, Outlook, Apple Mail에 지친 사람들을 위한 훌륭한 대안이 되는 이메일 및 캘린더 서비스이다. Omarchy가 시작된 곳인 [37signals](https://37signals.com/)에서 만들었다.

`Super + Shift + E`로 HEY Email을 시작하고, `Super + Shift + Alt + E`로 새 이메일 작성 화면으로 바로 이동하고, `Super + Shift + C`로 HEY Calendar를 시작할 수 있다.

## Basecamp

[Basecamp](https://basecamp.com/)는 작은 팀이 더 빠르게 움직이고 더 많은 성과를 내도록 돕는 프로젝트 관리 서비스이다. Trello, Slack, Asana, Notion 같은 것들을 뒤죽박죽으로 이어 붙이는 대신, Basecamp 하나로 모든 것을 한곳에서 해결할 수 있다. Omarchy가 시작된 곳인 [37signals](https://37signals.com/)에서 만들었다.

애플리케이션 런처(`Super + Space`)를 이용해 Basecamp를 시작할 수 있다

## ChatGPT

[ChatGPT](https://chatgpt.com)는 세상에서 가장 인기 있는 AI 챗봇이다.

`Super + Shift + A`를 이용해 ChatGPT를 시작할 수 있다.

## Grok

[Grok](https://grok.com)은 xAI의 챗봇이다.

`Super + Shift + Alt + A`를 이용해 Grok을 시작할 수 있다.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/)은 세상에서 가장 인기 있는 메시징 서비스 중 하나이며, 웹 버전은 Linux에서 훌륭한 선택지이다.

`Super + Shift + Alt + G`를 이용해 WhatsApp을 시작할 수 있다.

## Google 앱

Google Messages, Google Photos, Google Maps, Google Contacts도 모두 웹 앱으로 포함되어 있다.

`Super + Shift + Ctrl + G`로 Google Messages를, `Super + Shift + P`로 Google Photos를, `Super + Shift + S`로 Google Maps를 시작할 수 있다. Google Contacts는 앱 런처(`Super + Space`)를 통해 사용할 수 있다.

## X

X는 뉴스가 터지는 곳이다.

`Super + Shift + X`로 X를 시작하고, `Super + Shift + Alt + X`로 새 게시물 작성 화면으로 바로 이동할 수 있다.

## YouTube

[YouTube](https://youtube.com/)는 세상에서 가장 인기 있는 동영상 플랫폼이다.

`Super + Shift + Y`를 이용해 YouTube를 시작할 수 있다.

## Zoom

[Zoom](https://zoom.us/)은 미국에서 가장 인기 있는 화상 채팅 시스템이다. 전 세계에서 훌륭한 연결을 제공한다. 그리고 유료 계정 없이도 40분 회의를 열 수 있다. Omarchy는 Zoom의 웹 클라이언트를 감싸며, zoom 회의 링크는 바로 그 안에서 열린다.

애플리케이션 런처(`Super + Space`)를 이용해 Zoom을 시작한다.

## Discord

[Discord](https://discord.com/)는 [Omarchy 자체 커뮤니티](https://discord.gg/tXFUdasqhY)를 포함해 대부분의 게임 및 오픈 소스 커뮤니티가 모이는 곳이다.

애플리케이션 런처(`Super + Space`)를 이용해 Discord를 시작한다.

## Microsoft 앱

_Install > Service > Microsoft_를 선택하면 Outlook, Word, Excel, PowerPoint, Teams, OneDrive를 웹 앱으로 추가할 수 있다. 각 앱은 자체 런처를 갖고 있으며, 상용 Microsoft 365 URL과 기존 브라우저 프로필을 이용해 바로 열린다. Omarchy의 다른 웹 앱과 같은 브라우저 앱 창에서 열리며, 별도의 Teams for Linux 클라이언트를 설치하지 않는다.

_Remove > Service > Microsoft_로 번들을 제거하거나, _Remove > Web App_으로 개별 앱을 제거할 수 있다. _Install > Web App_을 통해 원하는 앱만 설치할 수도 있다.

정부용 또는 소버린 클라우드의 경우, 조직에서 제공한 URL을 이용해 `~/.local/share/applications/` 아래의 관련 런처, 예를 들어 `Microsoft Teams.desktop`에서 `Exec=` 줄의 URL을 편집한다. 그 줄에 들어가는 리터럴 `%`는 모두 `%%`로 쓴다. 변경 사항은 다음 실행 시 적용된다. 번들 설치 프로그램을 다시 실행하면 해당 런처들이 기본 URL로 교체된다.

업무용 로그인을 분리해 유지하려면, 각 런처의 `Exec=` 줄에 브라우저 데이터 디렉터리를 추가한다:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

예시 디렉터리를 원하는 절대 경로로 바꾸고, 여섯 개의 런처 모두에 같은 경로를 사용하면 그 사이에서 업무용 로그인을 공유할 수 있다. 웹 앱은 Omarchy에서 선택한 지원 브라우저를 사용하며, 기본 브라우저가 지원되지 않으면 Chrome으로 대체한다.
