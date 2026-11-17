<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Google Contacts</title>
  <desc>Google Contacts' logo in the theme's colors: its disc in the main color with a pale person, with a hard shadow.</desc>
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
        <path d="M12 0a12 12 0 1 0 0 24a12 12 0 1 0 0-24z"/>
      </g>
      <!-- The logo's body. -->
      <path d="M12 0a12 12 0 1 0 0 24a12 12 0 1 0 0-24z" fill="url(#main)"/>
      <!-- Its mark, pale. -->
      <g fill="{{ icon_paper }}">
        <path d="M12 5.600a3.300 3.300 0 1 0 0 6.600a3.300 3.300 0 1 0 0-6.600z"/>
        <path d="M5.400 18.300c0-2.900 3.300-4.300 6.600-4.300s6.600 1.400 6.600 4.300v.300a.9.9 0 0 1-.9.9h-11.400a.9.9 0 0 1-.9-.9z"/>
      </g>
    </g>
  </g>
</svg>
