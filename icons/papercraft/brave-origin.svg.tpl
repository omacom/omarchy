<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Brave Origin</title>
  <desc>Brave Origin's outlined lion in the theme's colors: the lion's head, brow, nose and chin drawn in one line of the main color, with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The lion of the app icon, on its 512 unit square. -->
    <g transform="translate(256 256) scale(.84) translate(-256 -256)" fill="none" stroke-width="26" stroke-linecap="round" stroke-linejoin="round">
      <!-- Its line, as one hard shadow, as Hype's slides. -->
      <path d="M132 76L196 90C226 70 286 70 316 90L380 76L444 166Q452 180 442 192L378 262Q360 282 372 306Q390 336 342 352L256 318L170 352Q122 336 140 306Q152 282 134 262L70 192Q60 180 68 166zM152 156L212 170L214 266L256 276L298 266L300 170L360 156M256 276V318M178 364L256 438L334 364" stroke="{{ icon_shadow }}" transform="translate(0 10)"/>
      <path d="M132 76L196 90C226 70 286 70 316 90L380 76L444 166Q452 180 442 192L378 262Q360 282 372 306Q390 336 342 352L256 318L170 352Q122 336 140 306Q152 282 134 262L70 192Q60 180 68 166zM152 156L212 170L214 266L256 276L298 266L300 170L360 156M256 276V318M178 364L256 438L334 364" stroke="url(#main)"/>
    </g>
  </g>
</svg>
