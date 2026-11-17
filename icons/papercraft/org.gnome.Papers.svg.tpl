<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Document Viewer</title>
  <desc>Two pages seen from the front: one in the main color behind a pale page of text, and a magnifying glass in the highlight over its corner, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The page behind; one hard shadow per page, as Hype's slides. -->
    <rect x="144" y="72" width="256" height="320" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="144" y="72" width="256" height="320" rx="20" fill="url(#main)"/>
    <!-- The page being read. -->
    <rect x="100" y="112" width="256" height="324" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="100" y="112" width="256" height="324" rx="20" fill="{{ icon_paper }}"/>
    <g fill="{{ icon_ink }}">
      <rect x="132" y="148" width="132" height="16" rx="8"/>
      <rect x="132" y="184" width="192" height="16" rx="8" opacity=".55"/>
      <rect x="132" y="220" width="168" height="16" rx="8" opacity=".55"/>
      <rect x="132" y="256" width="120" height="16" rx="8" opacity=".55"/>
      <rect x="132" y="292" width="96" height="16" rx="8" opacity=".55"/>
    </g>
    <!-- The magnifying glass. -->
    <g transform="translate(0 8)" fill="none" stroke="{{ icon_shadow }}">
      <path d="M368 374L414 420" stroke-width="28" stroke-linecap="round"/>
      <circle cx="332" cy="338" r="50" stroke-width="22"/>
    </g>
    <circle cx="332" cy="338" r="50" fill="{{ icon_paper }}"/>
    <rect x="304" y="330" width="56" height="16" rx="8" fill="{{ icon_ink }}"/>
    <path d="M368 374L414 420" fill="none" stroke="{{ icon_mark }}" stroke-width="28" stroke-linecap="round"/>
    <circle cx="332" cy="338" r="50" fill="none" stroke="{{ icon_mark }}" stroke-width="22"/>
  </g>
</svg>
