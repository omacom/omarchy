<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Google Messages</title>
  <desc>Google Messages' logo in the theme's colors: its speech bubble in the main color with the message inside it pale, with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The logo's own drawing, on its 24 unit square. -->
    <g transform="translate(88 88) scale(14)">
      <!-- Its silhouette, as one hard shadow, as Hype's slides. -->
      <g fill="{{ icon_shadow }}" transform="translate(0 .6)">
        <path d="M8 2.500h8a7.500 7.500 0 0 1 0 15h-5.500l-5.700 4.700a.5.5 0 0 1-.8-.4v-5.900a7.500 7.500 0 0 1 4-13.400z"/>
      </g>
      <!-- The logo's body. -->
      <path d="M8 2.500h8a7.500 7.500 0 0 1 0 15h-5.500l-5.700 4.700a.5.5 0 0 1-.8-.4v-5.900a7.500 7.500 0 0 1 4-13.400z" fill="url(#main)"/>
      <!-- Its mark, pale. -->
      <g fill="{{ icon_paper }}">
        <path d="M8.200 6h7.600a4 4 0 0 1 0 8h-7.600a4 4 0 0 1 0-8z"/>
      </g>
    </g>
  </g>
</svg>
