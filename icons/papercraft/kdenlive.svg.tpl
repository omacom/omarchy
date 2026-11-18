<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Kdenlive</title>
  <desc>Kdenlive's logo in the theme's colors: the clips and the play button in the main color and the playhead in the highlight, with a hard shadow.</desc>
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
        <path d="M2.727 6.502V9.8h7.091c.003-.83 0-1.672-.006-2.498 0-.383-.356-.732-.718-.8H2.727zM15.03 6.503c-.402.024-.835.41-.834.837l-.014 12.619c0 .57.767 1.065 1.207.727l8.28-6.331c.441-.335.44-1.12 0-1.455l-8.265-6.287a.553.553 0 0 0-.374-.11zM-.001 12v3.299h9.818V12zM4.362 17.497v3.3h5.455v-3.3z"/>
        <path d="M8.727 1.554l2.727 4.334v16.558h1.091V5.889l2.728-4.335z"/>
      </g>
      <path d="M2.727 6.502V9.8h7.091c.003-.83 0-1.672-.006-2.498 0-.383-.356-.732-.718-.8H2.727zM15.03 6.503c-.402.024-.835.41-.834.837l-.014 12.619c0 .57.767 1.065 1.207.727l8.28-6.331c.441-.335.44-1.12 0-1.455l-8.265-6.287a.553.553 0 0 0-.374-.11zM-.001 12v3.299h9.818V12zM4.362 17.497v3.3h5.455v-3.3z" fill="url(#main)"/>
      <!-- The playhead. -->
      <path d="M8.727 1.554l2.727 4.334v16.558h1.091V5.889l2.728-4.335z" fill="{{ icon_mark }}"/>
    </g>
  </g>
</svg>
