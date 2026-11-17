# 배경

모든 테마에는 자체 배경 세트가 함께 제공되며, `~/.config/omarchy/backgrounds/[theme]`에 직접 추가할 수도 있습니다. 예를 들어 nord 테마에 배경 이미지를 하나 더 추가하고 싶다면, 파일을 `~/.config/omarchy/backgrounds/nord`에 넣으면 됩니다.

가장 쉬운 방법은 Omarchy Menu에서 _Install > Style > Background_로 이동하는 것입니다. 해당 테마의 배경이 저장된 폴더가 열립니다. `Super + Shift + F`를 눌러 다른 파일 관리자를 실행하고, 원하는 배경을 찾아서 복사해 넣으세요. 이제 `Super + Ctrl + W`로 선택할 수 있는 배경 목록에 포함됩니다.

배경은 정지 이미지뿐만 아니라 동영상도 사용할 수 있습니다. `mp4`, `m4v`, `mov`, `webm`, `mkv`, 또는 `avi` 파일을 같은 폴더에 넣으면 이미지와 함께 표시됩니다. 동영상은 OWE wallpaper engine으로 재생됩니다. 모든 모니터에 대해 동영상을 한 번만 디코딩하고, 사운드는 기본 오디오 출력으로 재생하며, 아무것도 보이지 않을 때는 재생을 중지합니다. 동영상 배경은 정지 이미지 배경보다 여전히 훨씬 더 많은 전력을 소모합니다.

테마는 정지 배경을 위한 짧은 인트로를 포함할 수 있습니다. `backgrounds/road.webp`의 경우, 대응하는 동영상은 `backgrounds/intros/road.mp4`에 있습니다. 부팅 시, 해당 배경이 선택된 테마로 전환할 때, 그리고 해당 배경을 선택할 때 자동으로 재생된 뒤 정지 이미지로 돌아갑니다. 인트로 동영상은 배경 선택기에 표시되지 않으며 절대 반복 재생되지 않습니다.

_Appearance > Animations_를 끄면 배경 인트로도 함께 꺼집니다. Omarchy는 virtual machine에서는 기본적으로 이렇게 동작합니다. `omarchy theme bg intro toggle` 명령으로 인트로를 별도로 토글할 수 있습니다. 테마를 새로 고침하면 인트로는 재생되지 않습니다.

엄선된 멋진 배경의 방대한 컬렉션은 [dharmx/walls](https://github.com/dharmx/walls)에서 찾을 수 있습니다.

잠금 화면은 동영상 배경의 정지 프레임을 표시하는데, 이는 animated GIF의 정지 프레임을 표시하는 방식과 같습니다.
