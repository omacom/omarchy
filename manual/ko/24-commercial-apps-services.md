# 상용 앱/서비스

Omarchy는 주로 무료 오픈 소스 소프트웨어를 제공하는 데 집중하지만, 그 점에 대해 종교적이지는 않다. 때로는 최선의 해결책이 상용 제품일 때도 있고, 그건 전혀 문제없다. 다음은 간편한 설치를 제공하는 몇 가지 옵션이다.

## 1Password

비밀번호를 비밀번호 관리자에 보관하는 것은 모범 사례이다. 팀과 함께 일한다면 두 배로 그렇다. 그리고 [1password](https://1password.com/)는 훌륭한 해결책이며, 스크립트에서 키 조회를 연동할 수 있는 명령줄 도구도 함께 제공된다.

`Super + Shift + /`로 1Password를 실행한다. 아직 설치되지 않았다면, 해당 단축키가 먼저 설치를 시작한다(Omarchy 메뉴에서 _Install > Service > 1Password_를 사용해도 된다). 설치 프로그램은 1Password 명령줄 도구도 함께 가져오고 Chrome과 Chromium용 1Password 확장 프로그램을 설정한다. 브라우저를 다시 시작하면 로드된다.

## Bitwarden

[Bitwarden](https://bitwarden.com/)은 비밀번호 관리자 분야의 오픈 소스 대안으로, 대부분의 개인 용도를 커버하는 무료 등급을 제공한다. Omarchy 메뉴에서 _Install > Service > Bitwarden_으로 설치하면 Bitwarden 명령줄 도구도 함께 제공된다.

## Spotify

[Spotify](https://spotify.com/)는 세계에서 가장 인기 있는 스트리밍 음악 서비스이다. Omarchy는 이를 웹 앱으로 제공하며, 전체 플레이어, 미디어 키, Spotify Connect를 사용할 수 있지만 오프라인 다운로드는 지원하지 않는다. `Super + Shift + M`으로 실행한다.

## Slack

[Slack](https://slack.com/)은 많은 팀이 회사 내부뿐 아니라 외부 협력자와도 채팅하는 곳이다. Omarchy 메뉴에서 _Install > Service > Slack_으로 설치하면 준비되는 대로 바로 열린다.

## Notion

[Notion](https://www.notion.com/)은 노트, 문서, 프로젝트를 위한 작업 공간이다. Omarchy 메뉴에서 _Install > Service > Notion_으로 데스크톱 앱을 설치한다.

## Dropbox

[Dropbox](https://www.dropbox.com/)는 클라우드에 백업을 유지하면서 기기 간에 파일을 동기화하는 훌륭한 방법이다. 설정하려면 Omarchy 메뉴에서 _Install > Service > Dropbox_를 선택한다. 바에 Dropbox 아이콘이 추가된다. 이를 클릭해 로그인한 뒤, 같은 패널에서 저장 용량을 확인하고 최근에 동기화된 파일을 열 수 있다.

## Tailscale

[Tailscale](https://tailscale.com/)은 인터넷을 통해 모든 컴퓨터와 서버에 안전하게 접근하는 것을 매우 간단하게 만들어 주는 메시 VPN이다. 설정하려면 Omarchy 메뉴에서 _Install > Service > Tailscale_을 선택한다.

바에 패널, 관리 콘솔용 웹 앱, 기기 간 파일 전송을 위한 Taildrop이 제공된다 — [네트워킹](35-networking.md)을 참조하라.

## ONCE

[ONCE](https://once.com/)는 Campfire 채팅 시스템처럼 한 번 구매해 자신의 서버에서 운영하는 37signals의 소프트웨어 제품군이다. Omarchy 메뉴에서 _Install > Service > ONCE_를 선택해 설치하면 백그라운드 서비스가 활성화되고 ONCE 터미널 인터페이스로 이동해 거기서부터 진행할 수 있다.

## NordVPN

[NordVPN](https://nordvpn.com/)은 전 세계 대부분의 지역에서 트래픽을 나갈 수 있게 해주는 표준 VPN 서비스이다. 설정하려면 Omarchy 메뉴에서 _Install > Service > NordVPN_을 선택한다. 요청되는 재부팅이 끝나면 `nordvpn login`을 실행해 인증한다.
