<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Basecamp</title>
  <desc>Basecamp's logo in the theme's colors: a rounded tile with a pale sky over two hills in the main color, the fold of the valley between them in shade, with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main_end }}"/>
      <stop offset="1" stop-color="{{ icon_main }}"/>
    </linearGradient>
    <clipPath id="tile">
      <rect x="84" y="84" width="344" height="344" rx="80"/>
    </clipPath>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The tile, as sky; one hard shadow, as Hype's slides. -->
    <rect x="84" y="84" width="344" height="344" rx="80" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="84" y="84" width="344" height="344" rx="80" fill="{{ icon_paper }}"/>
    <g clip-path="url(#tile)">
      <!-- The hills: a low one, the valley, and a taller peak. -->
      <path d="M84 290C101 256 127 230 153 232C187 234 204 286 243 286C282 286 316 170 364 167C389 166 415 191 428 213V428H84Z" fill="url(#main)"/>
      <!-- The fold of the valley, in shade. -->
      <path d="M153 232C187 234 204 286 243 286C282 286 316 170 364 167C342 213 308 333 247 338C196 340 179 269 153 232Z" fill="{{ icon_shadow }}" opacity=".22"/>
    </g>
  </g>
</svg>
