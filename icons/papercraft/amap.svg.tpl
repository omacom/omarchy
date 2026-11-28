<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Amap</title>
  <desc>Amap's logo in the theme's colors: its rounded square in the main color with a pale navigation arrow, with a hard shadow.</desc>
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
        <path d="M6 1h12a5 5 0 0 1 5 5v12a5 5 0 0 1-5 5H6a5 5 0 0 1-5-5V6a5 5 0 0 1 5-5z"/>
        <path fill-rule="evenodd" d="M6 1h12a5 5 0 0 1 5 5v12a5 5 0 0 1-5 5H6a5 5 0 0 1-5-5V6a5 5 0 0 1 5-5zM18.2 5.8L5.6 11.2l5.3 1.9 1.9 5.3z"/>
      </g>
      <!-- What the logo leaves open, pale. -->
      <path fill="{{ icon_paper }}" d="M6 1h12a5 5 0 0 1 5 5v12a5 5 0 0 1-5 5H6a5 5 0 0 1-5-5V6a5 5 0 0 1 5-5z"/>
      <!-- The logo itself. -->
      <path fill="url(#main)" fill-rule="evenodd" d="M6 1h12a5 5 0 0 1 5 5v12a5 5 0 0 1-5 5H6a5 5 0 0 1-5-5V6a5 5 0 0 1 5-5zM18.2 5.8L5.6 11.2l5.3 1.9 1.9 5.3z"/>
    </g>
  </g>
</svg>
