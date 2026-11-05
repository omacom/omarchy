# 웹 앱

Omarchy 메뉴(`Super + Space`)의 _설치 > 웹 앱_을 사용해 자체 웹 앱을 추가할 수 있습니다. 앱 이름, 앱 URL, 그리고 favicon으로 가져올 수 없다면 아이콘 URL을 묻습니다. 인기 있는 많은 웹 앱을 위한 훌륭한 PNG 아이콘은 [Dashboard Icons](https://dashboardicons.com)에서 얻을 수 있습니다.

그러면 앱 실행 프로그램(`Super + Space`)을 통해 접근할 수 있으며, 아름다운 프레임 없는 웹 앱 창을 사용합니다.

웹 앱을 제거하려면 Omarchy 메뉴의 _제거 > 웹 앱_으로 가세요.

웹 앱 바로가기를 사용하기 전에 일반 브라우저로 모든 계정에 로그인하는 것이 가장 좋습니다. 얇은 래퍼 프레임은 1password와 잘 동작하지 않으므로, 처음부터 직접 로그인해 두는 것이 더 쉽습니다.

이러한 웹 앱에 대한 모든 키보드 단축키는 `~/.config/hypr/bindings.lua`에서 변경할 수 있습니다.

웹 앱에 있을 때는 `Shift + Alt + L`을 사용해 현재 URL을 클립보드에 복사할 수 있습니다.

기본적으로 Omarchy에는 이미 기본 앱 모음이 함께 제공됩니다:

## HEY

[HEY](https://www.hey.com/)는 Gmail, Outlook, Apple Mail에 지친 사람들에게 훌륭한 대안이 되는 이메일 및 캘린더 서비스입니다. Omarchy가 시작된 곳인 [37signals](https://37signals.com/)에서 만들었습니다.

`Super + Shift + E`로 HEY 이메일을 시작하고, `Super + Shift + Alt + E`로 바로 새 이메일 작성으로 이동하고, `Super + Shift + C`로 HEY Calendar를 시작할 수 있습니다.

## Basecamp

[Basecamp](https://basecamp.com/)는 작은 팀이 더 빨리 움직이고 더 많은 진전을 이룰 수 있도록 돕는 프로젝트 관리 서비스입니다. Trello, Slack, Asana, Notion 등 이것저것을 덕지덕지 붙이는 대신, Basecamp로 한 곳에서 모두 가질 수 있습니다. Omarchy가 시작된 곳인 [37signals](https://37signals.com/)에서 만들었습니다.

애플리케이션 실행 프로그램(`Super + Space`)을 사용해 Basecamp를 시작할 수 있습니다

## ChatGPT

[ChatGPT](https://chatgpt.com)는 세계에서 가장 인기 있는 AI 챗봇입니다.

`Super + Shift + A`를 사용해 ChatGPT를 시작할 수 있습니다.

## Grok

[Grok](https://grok.com)은 xAI의 챗봇입니다.

`Super + Shift + Alt + A`를 사용해 Grok을 시작할 수 있습니다.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/)은 세계에서 가장 인기 있는 메시징 서비스 중 하나이며, 웹 버전은 Linux를 위한 훌륭한 옵션입니다.

`Super + Shift + Alt + G`를 사용해 WhatsApp을 시작할 수 있습니다.

## Google 앱

Google Messages, Google Photos, Google Maps, Google Contacts도 모두 웹 앱으로 포함되어 있습니다.

`Super + Shift + Ctrl + G`로 Google Messages를, `Super + Shift + P`로 Google Photos를, `Super + Shift + S`로 Google Maps를 시작할 수 있습니다. Google Contacts는 앱 실행 프로그램(`Super + Space`)을 통해 사용할 수 있습니다.

## X

X는 뉴스가 터지는 곳입니다.

`Super + Shift + X`로 X를 시작하고, `Super + Shift + Alt + X`로 바로 새 게시물 작성으로 갈 수 있습니다.

## YouTube

[YouTube](https://youtube.com/)는 세계에서 가장 인기 있는 비디오 플랫폼입니다.

`Super + Shift + Y`를 사용해 YouTube를 시작할 수 있습니다.

## Zoom

[Zoom](https://zoom.us/)은 미국에서 가장 인기 있는 화상 채팅 시스템입니다. 전 세계적으로 훌륭한 연결을 제공합니다. 그리고 유료 계정 없이도 40분 회의를 열 수 있습니다. Omarchy는 Zoom의 웹 클라이언트를 래핑하며, Zoom 회의 링크는 바로 그 안에서 열립니다.

애플리케이션 실행 프로그램(`Super + Space`)을 사용해 Zoom을 시작합니다.

## Discord

[Discord](https://discord.com/)는 대부분의 게이밍 및 오픈 소스 커뮤니티가 어울리는 곳이며, [Omarchy 자체 커뮤니티](https://discord.gg/tXFUdasqhY)도 포함됩니다.

애플리케이션 실행 프로그램(`Super + Space`)을 사용해 Discord를 시작합니다.

## Microsoft 앱

_설치 > 서비스 > Microsoft_를 선택해 Outlook, Word, Excel, PowerPoint, Teams, OneDrive를 웹 앱으로 추가하세요. 각 앱은 자체 실행 프로그램을 갖고 직접 열리며, 상용 Microsoft 365 URL과 기존 브라우저 프로필을 사용합니다. Omarchy의 다른 웹 앱과 같은 브라우저 앱 창에서 열립니다. 별도의 Teams for Linux 클라이언트를 설치하지는 않습니다.

_제거 > 서비스 > Microsoft_로 번들을 제거하거나, _제거 > 웹 앱_으로 개별 앱을 제거하세요. _설치 > 웹 앱_을 통해 원하는 앱만 설치할 수도 있습니다.

정부 또는 주권 클라우드의 경우, 조직에서 제공한 URL을 사용해 `~/.local/share/applications/` 아래 관련 실행 프로그램(예: `Microsoft Teams.desktop`)의 `Exec=` 줄에 있는 URL을 편집하세요. 그 줄에 있는 리터럴 `%`는 `%%`로 적으세요. 변경 사항은 다음 시작 때 적용됩니다. 번들 설치 프로그램을 다시 실행하면 실행 프로그램이 기본 URL로 교체됩니다.

업무 로그인을 분리하려면 각 실행 프로그램의 `Exec=` 줄에 브라우저 데이터 디렉터리를 추가하세요:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

예제 디렉터리를 원하는 절대 경로로 바꾸고, 여섯 개 실행 프로그램 모두에 같은 경로를 사용해 그들 사이에 업무 로그인을 공유하세요. 웹 앱은 Omarchy가 선택한 지원 브라우저를 사용하며, 기본 브라우저가 지원되지 않을 때는 Chromium으로 대체합니다.
