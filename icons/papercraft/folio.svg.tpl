<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Files</title>
  <desc>A folder seen from the front: a back with its tab, a pale sheet of paper inside, and a front panel, each with a hard shadow, on a transparent background.</desc>
  <defs>
    <linearGradient id="front" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -260)">
  <!-- Back of the folder with its tab; one hard shadow, as Hype's slides. -->
  <path d="M84 118Q84 98 104 98H196Q206 98 212 106L226 126H408Q428 126 428 146V392Q428 412 408 412H104Q84 412 84 392Z" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
  <path d="M84 118Q84 98 104 98H196Q206 98 212 106L226 126H408Q428 126 428 146V392Q428 412 408 412H104Q84 412 84 392Z" fill="{{ icon_mark }}"/>
  <!-- A sheet of paper inside, peeking over the front. -->
  <rect x="124" y="160" width="264" height="190" rx="14" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
  <rect x="124" y="160" width="264" height="190" rx="14" fill="{{ icon_paper }}"/>
  <rect x="156" y="194" width="124" height="16" rx="8" fill="{{ icon_ink }}"/>
  <rect x="156" y="226" width="176" height="16" rx="8" fill="{{ icon_ink }}" opacity=".55"/>
  <!-- Front of the folder. -->
  <rect x="84" y="250" width="344" height="172" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
  <rect x="84" y="250" width="344" height="172" rx="20" fill="url(#front)"/>
  <rect x="112" y="374" width="96" height="14" rx="7" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
