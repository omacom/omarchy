<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Google Maps</title>
  <desc>Google Maps' logo in the theme's colors: its pin in the main color around a pale center, with a hard shadow.</desc>
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
        <path d="M12 .6C7.600 .6 4.200 4 4.200 8.300c0 2.600 1 4.400 2.600 6.400C8.900 17.300 10.800 19.700 12 23.400c1.200-3.700 3.100-6.100 5.200-8.700 1.600-2 2.600-3.800 2.600-6.400C19.800 4 16.400 .6 12 .6z"/>
      </g>
      <!-- The logo's body. -->
      <path d="M12 .6C7.600 .6 4.200 4 4.200 8.300c0 2.600 1 4.400 2.600 6.400C8.900 17.300 10.800 19.700 12 23.400c1.200-3.700 3.100-6.100 5.200-8.700 1.600-2 2.600-3.800 2.600-6.400C19.800 4 16.400 .6 12 .6z" fill="url(#main)"/>
      <!-- Its mark, pale. -->
      <g fill="{{ icon_paper }}">
        <path d="M12 5.300a3 3 0 1 0 0 6a3 3 0 1 0 0-6z"/>
      </g>
    </g>
  </g>
</svg>
