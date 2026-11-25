<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Cards</title>
  <desc>Two playing cards seen from the front: one in the dark body color tilted behind, and one in the main color before it with a spade in the highlight, each piece with a hard shadow, on a transparent background.</desc>
  <defs>
    <linearGradient id="face" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-262 -258)">
  <!-- The card behind, tilted away; one hard shadow per piece, as Hype's slides. -->
  <g transform="rotate(-12 256 300)">
    <rect x="118" y="78" width="232" height="340" rx="34" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="118" y="78" width="232" height="340" rx="34" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
  </g>
  <!-- The card in front, leaning the other way. -->
  <g transform="rotate(8 256 300)">
    <rect x="160" y="84" width="232" height="340" rx="34" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="160" y="84" width="232" height="340" rx="34" fill="url(#face)"/>
    <!-- Its spade, in the accent, standing out as Omacut's trim handles do. -->
    <path d="M12 2C17 8 22 11 22 15A4.6 4.6 0 0 1 13.2 16.6C13.4 19 14.2 20.6 15.5 22H8.5C9.8 20.6 10.6 19 10.8 16.6A4.6 4.6 0 0 1 2 15C2 11 7 8 12 2Z" fill="{{ icon_shadow }}" transform="translate(276 262) scale(7.4) translate(-12 -12)"/>
    <path d="M12 2C17 8 22 11 22 15A4.6 4.6 0 0 1 13.2 16.6C13.4 19 14.2 20.6 15.5 22H8.5C9.8 20.6 10.6 19 10.8 16.6A4.6 4.6 0 0 1 2 15C2 11 7 8 12 2Z" fill="{{ icon_mark }}" transform="translate(276 254) scale(7.4) translate(-12 -12)"/>
  </g>
  </g>
</svg>
