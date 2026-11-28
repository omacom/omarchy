# 브라우저

Omarchy는 [Google Chrome](https://www.google.com/chrome/)을 기본 브라우저로 제공합니다. 시스템의 나머지 부분과 어울리도록 테마가 적용되어 있으며, `Super + Shift + Return`(또는 `Super + Shift + B`)으로 열리는 브라우저이자, 시크릿 창을 여는 `Super + Shift + Alt + B`로 열리는 브라우저이며, 모든 [웹 앱](25-web-apps.md)이 그 안에서 실행됩니다. 바로 브라우저 창이 열립니다. 시작 화면도 로그인 프롬프트도 없고, 사용 통계와 충돌 보고서가 Google로 전송되지 않으며, 광고 개인정보 프롬프트는 꺼져 있습니다. 동기화를 원할 때는 언제든 프로필 버튼에서 Google 계정에 로그인할 수 있습니다.

Chrome이 취향에 맞지 않는다면, 굳이 그것만 쓸 필요는 없습니다. Omarchy 메뉴의 _Install > Browser_ 아래에는 [Chromium](https://www.chromium.org/)(Chrome의 기반이 되는 순수 오픈 소스 빌드), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/), 그리고 [Ladybird](https://ladybird.org/)가 있습니다(Edge는 x86 컴퓨터에서만 제공됩니다). 하나를 선택하면 Omarchy가 이를 설치하고, 정책 디렉터리를 설정하며, 현재 테마를 적용합니다.

## 기본 브라우저로 설정하기

브라우저를 설치한다고 해서 기본 브라우저가 되는 것은 아닙니다. 바꾸려면 _Setup > Defaults > Browser_로 이동해 하나를 선택하세요. 현재 기본 브라우저에는 체크 표시가 되어 있고, 아직 설치되지 않은 브라우저를 선택하면 먼저 설치합니다.

터미널에서는 다음과 같습니다:

```bash
omarchy default browser firefox
```

인수 없이 실행하면 현재 기본 브라우저를 알려줍니다. 이는 XDG 핸들러를 설정하므로, Omarchy의 단축키만 따르는 것이 아닙니다. 채팅 앱부터 터미널 명령까지, 링크를 여는 모든 것이 당신이 선택한 브라우저로 이동합니다.

## URL 복사와 비디오 다운로드

Chromium 계열 브라우저(Chromium 자체, Chrome, Edge, Brave, Brave Origin)에는 세 가지 Omarchy 확장 프로그램이 함께 제공됩니다. 두 개는 브라우저를 벗어나 시스템의 나머지 부분까지 닿고, 하나는 WhatsApp을 깔끔하게 정리합니다.

**Copy URL**은 `Alt + Shift + L`로 현재 탭의 주소를 클립보드에 넣습니다. 주소 표시줄을 클릭해 복사하는 것보다 빠르며, 브라우저가 아닌 시스템 클립보드를 거치기 때문에 Omarchy 알림으로 확인을 받을 수 있고, URL을 [클립보드 히스토리](08-unified-clipboard-history.md)와 다른 모든 앱에서 즉시 사용할 수 있습니다. 클릭하는 방식을 선호한다면 툴바 버튼도 있습니다.

**Download Video**는 `Alt + Shift + D`로 보고 있는 페이지에서 재생 중인 비디오를 가져옵니다. URL을 [yt-dlp](https://github.com/yt-dlp/yt-dlp)에 넘기므로 YouTube보다 훨씬 많은 곳에서 작동하고, 다운로드는 `~/Videos`에 저장됩니다. 진행 상황은 볼륨과 밝기가 사용하는 것과 같은 온스크린 디스플레이에 표시되며, 알림이 계속 쌓이는 대신 그 자리에서 업데이트됩니다. 파일을 다른 곳에 저장하고 싶다면 `OMARCHY_YTDLP_DIR`을 설정하세요. 환경 변수를 어디에 넣어야 하는지는 [FAQ](46-faq.md)를 참고하세요.

두 확장 프로그램 모두 작은 네이티브 메시징 호스트를 통해 Omarchy와 통신하며, 이 호스트는 브라우저와 함께 설치됩니다. 웹페이지의 비디오가 홈 디렉터리에 저장되고 URL이 클립보드 관리자에 들어갈 수 있게 해주는 것이 바로 이 부분인데, 일반적인 확장 프로그램만으로는 할 수 없는 일입니다.

**WhatsApp Slim**은 WhatsApp Web이 시스템 테마를 따르게 하고, 창이 좁을 때 채팅 목록을 접습니다.

이들은 Chromium 계열에서만 사용할 수 있습니다. Firefox와 Zen에는 제공되지 않습니다.

## Firefox와 Zen

Firefox와 Zen은 다른 계열이므로 취급도 다릅니다. Omarchy는 합리적인 기본값을 위한 정책 파일을 설치하고, 네이티브 Wayland 모드로 전환하는데, 이는 분수 배율 조정과 부드러운 트랙패드 스크롤에 꼭 필요합니다.

위의 Chromium 확장 프로그램은 제공되지 않고, Omarchy가 테마를 적용하지도 않으므로, 그 부분의 경험은 직접 설정해야 합니다.

## Ladybird

Ladybird는 Chromium이나 Firefox의 엔진이 아닌 자체 엔진을 사용해 처음부터 새로 작성한 브라우저입니다. 아직 알파 단계이므로 아직 작동하지 않는 사이트가 있을 것으로 예상하세요. Omarchy는 이를 있는 그대로 설치합니다. 확장 프로그램도, 테마도, 정책도 없습니다. 시크릿 창도 없으므로, `Super + Shift + Alt + B`를 누르면 닫을 때 삭제되는 임시 프로필로 열립니다. [웹 앱](25-web-apps.md)은 계속 Chrome이나 Chromium에서 실행됩니다.

## 다시 제거하기

Chrome을 포함해 이 브라우저들은 모두 _Remove > Browser_ 아래에서 다시 제거할 수 있습니다. 그러면 링크는 다른 하나가 아직 설치되어 있을 경우 Chrome이나 Chromium으로 이동합니다.
