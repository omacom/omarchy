<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Hype</title>
  <desc>A pile of slides seen from the front. The top slide is dark with a Markdown headline: a hash, a title, and two lines of text.</desc>
  <defs>
    <linearGradient id="ink" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main_end }}"/>
      <stop offset="1" stop-color="{{ icon_mark }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.36) translate(-256 -259)">
    <!-- Each slide behind is narrower and peeks out above; one hard shadow per slide. -->
    <rect x="132" y="133" width="248" height="140" rx="16" fill="{{ icon_mark }}"/>
    <rect x="108" y="159" width="296" height="167" rx="17" fill="{{ icon_shadow }}"/>
    <rect x="108" y="159" width="296" height="161" rx="17" fill="{{ icon_main }}"/>
    <rect x="84" y="185" width="344" height="200" rx="18" fill="{{ icon_shadow }}"/>
    <rect x="84" y="185" width="344" height="194" rx="18" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <path d="M153.800 218.400L145 293.200M184.600 218.400L175.800 293.200M131.800 242.600H202.200M127.400 269H197.800" fill="none" stroke="url(#ink)" stroke-width="17" stroke-linecap="round"/>
    <rect x="228" y="243" width="164" height="25" rx="12.500" fill="{{ icon_paper }}"/>
    <rect x="122" y="320" width="270" height="15" rx="7.500" fill="{{ icon_ink }}"/>
    <rect x="122" y="347" width="186" height="15" rx="7.500" fill="{{ icon_ink }}" opacity=".55"/>
  </g>
</svg>
