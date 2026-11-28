<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>LocalSend</title>
  <desc>A file passing between two devices seen from the front: a dark phone with a screen in the main color, a pale one beside it, and the file crossing from one to the other in the highlight, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The sending device; one hard shadow, as Hype's slides. -->
    <rect x="64" y="112" width="168" height="288" rx="24" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="64" y="112" width="168" height="288" rx="24" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <rect x="84" y="132" width="128" height="220" rx="12" fill="url(#main)"/>
    <rect x="120" y="368" width="56" height="12" rx="6" fill="{{ icon_edge }}"/>
    <!-- The receiving device. -->
    <rect x="280" y="112" width="168" height="288" rx="24" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="280" y="112" width="168" height="288" rx="24" fill="{{ icon_paper }}"/>
    <g fill="{{ icon_ink }}">
      <rect x="336" y="150" width="88" height="14" rx="7"/>
      <rect x="336" y="180" width="64" height="14" rx="7" opacity=".55"/>
      <rect x="336" y="368" width="56" height="12" rx="6" opacity=".55"/>
    </g>
    <!-- The file on its way across, with the direction it is heading. -->
    <rect x="168" y="212" width="176" height="104" rx="18" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="168" y="212" width="176" height="104" rx="18" fill="{{ icon_mark }}"/>
    <path d="M208 264H300M270 234L300 264L270 294" fill="none" stroke="{{ icon_shadow }}" stroke-width="18" stroke-linecap="round" stroke-linejoin="round" opacity=".45"/>
  </g>
</svg>
