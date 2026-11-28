<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Tailscale</title>
  <desc>Tailscale's logo in the theme's colors: its three by three grid of dots, the T among them in the main color and the rest dimmed, each with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The logo's own drawing, on its 24 unit square. -->
    <g transform="translate(88 88) scale(14)">
      <!-- One hard shadow per dot, as Hype's slides. -->
      <g fill="{{ icon_shadow }}" transform="translate(0 .6)">
        <path d="M4.2 1.1a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
        <path d="M12 1.1a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
        <path d="M19.8 1.1a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
        <path d="M4.2 8.9a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
        <path d="M12 8.9a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
        <path d="M19.8 8.9a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
        <path d="M4.2 16.7a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
        <path d="M12 16.7a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
        <path d="M19.8 16.7a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
      </g>
      <!-- The dots outside the T, dimmed. -->
      <g fill="{{ icon_edge }}">
        <path d="M4.2 1.1a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
        <path d="M12 1.1a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
        <path d="M19.8 1.1a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
        <path d="M4.2 16.7a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
        <path d="M19.8 16.7a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z"/>
      </g>
      <!-- The T: the middle row and the dot below its center. -->
      <path d="M4.2 8.9a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z" fill="url(#main)"/>
      <path d="M12 8.9a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z" fill="url(#main)"/>
      <path d="M19.8 8.9a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z" fill="url(#main)"/>
      <path d="M12 16.7a3.1 3.1 0 1 0 0 6.2a3.1 3.1 0 1 0 0 -6.2z" fill="url(#main)"/>
    </g>
  </g>
</svg>
