<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Ghostty</title>
  <desc>Ghostty's logo in the theme's colors: a dark terminal window with the ghost in the main color, the prompt cut into it in the highlight, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The terminal; one hard shadow, as Hype's slides. -->
    <rect x="84" y="84" width="344" height="344" rx="26" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="84" y="84" width="344" height="344" rx="26" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The logo's own drawing, on its 24 unit square. -->
    <g transform="translate(256 256) scale(11.5) translate(-12 -12)">
      <path d="M12 0C6.7 0 2.4 4.3 2.4 9.6v11.146c0 1.772 1.45 3.267 3.222 3.254a3.18 3.18 0 0 0 1.955-.686 1.96 1.96 0 0 1 2.444 0 3.18 3.18 0 0 0 1.976.686c.75 0 1.436-.257 1.98-.686.715-.563 1.71-.587 2.419-.018.59.476 1.355.743 2.182.699 1.705-.094 3.022-1.537 3.022-3.244V9.601C21.6 4.3 17.302 0 12 0z" fill="{{ icon_shadow }}" transform="translate(0 .8)"/>
      <!-- Shows through the prompt cut into the ghost. -->
      <rect x="4.5" y="6" width="15.5" height="7" fill="{{ icon_mark }}"/>
      <path d="M12 0C6.7 0 2.4 4.3 2.4 9.6v11.146c0 1.772 1.45 3.267 3.222 3.254a3.18 3.18 0 0 0 1.955-.686 1.96 1.96 0 0 1 2.444 0 3.18 3.18 0 0 0 1.976.686c.75 0 1.436-.257 1.98-.686.715-.563 1.71-.587 2.419-.018.59.476 1.355.743 2.182.699 1.705-.094 3.022-1.537 3.022-3.244V9.601C21.6 4.3 17.302 0 12 0M6.069 6.562a1 1 0 0 1 .46.131l3.578 2.065v.002a.974.974 0 0 1 0 1.687L6.53 12.512a.975.975 0 0 1-.976-1.687L7.67 9.602 5.553 8.38a.975.975 0 0 1 .515-1.818m7.438 2.063h4.7a.975.975 0 1 1 0 1.95h-4.7a.975.975 0 0 1 0-1.95" fill="url(#main)"/>
    </g>
  </g>
</svg>
