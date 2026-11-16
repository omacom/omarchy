<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Moonlight</title>
  <desc>Moonlight's logo in the theme's colors: its rim and spokes in the main color around a pale wheel, with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The logo's own drawing, on its 256 unit square. -->
    <g transform="translate(88 88) scale(1.3125)">
      <!-- Its silhouette, as one hard shadow, as Hype's slides. -->
      <circle cx="128" cy="134.4" r="128" fill="{{ icon_shadow }}"/>
      <circle cx="128" cy="128" r="128" fill="url(#main)"/>
      <!-- What the logo leaves open, pale. -->
      <circle cx="128" cy="128" r="96" fill="{{ icon_paper }}"/>
      <path d="M137.66 132L224 132L224 124L137.66 124L198.71 62.95L193.05 57.29L132 118.34L132 32L124 32L124 118.34L62.95 57.29L57.29 62.95L118.34 124L32 124L32 132L118.34 132L57.29 193.05L62.95 198.71L124 137.66L124 224L132 224L132 137.66L193.05 198.71L198.71 193.05L137.66 132z" fill="url(#main)" stroke="url(#main)" stroke-width="6" stroke-linejoin="round"/>
    </g>
  </g>
</svg>
