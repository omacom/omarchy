<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Neovim</title>
  <desc>Neovim's mark in the theme's colors: an N folded from three bands, the left upright in the main color and the diagonal and right upright in the highlight, with a hard shadow. The mark is by Jason Long, CC BY 3.0.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="0" y2="1">
      <stop stop-color="{{ icon_main_end }}"/>
      <stop offset="1" stop-color="{{ icon_main }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The mark's own drawing, on its 602 by 734 canvas. -->
    <g transform="translate(256 256) scale(.52) translate(-300 -363)">
      <!-- One hard shadow, as Hype's slides. -->
      <g fill="{{ icon_shadow }}" transform="translate(0 17)">
        <path d="M0 155.5704L155 -1V727L0 572.237919Z"/>
        <path d="M598.939597 156.982405L442 -1L445.181208 727L600 572.219941Z"/>
        <path d="M154.986294 0L558 615.189696L445.224605 728L42 114.172017Z"/>
      </g>
      <!-- The left upright. -->
      <path d="M0 155.5704L155 -1V727L0 572.237919Z" fill="url(#main)"/>
      <!-- The right upright, in the shade of the diagonal. -->
      <path d="M598.939597 156.982405L442 -1L445.181208 727L600 572.219941Z" fill="{{ icon_mark }}"/>
      <path d="M598.939597 156.982405L442 -1L445.181208 727L600 572.219941Z" fill="{{ icon_shadow }}" opacity=".3"/>
      <!-- The diagonal, folding over both, and the shadow it casts on the left. -->
      <path d="M154.986294 0L558 615.189696L445.224605 728L42 114.172017Z" fill="{{ icon_mark }}"/>
      <path d="M155 283.83232L154.786754 308L31 124.710606L42.4619486 113Z" fill="{{ icon_shadow }}" opacity=".3"/>
    </g>
  </g>
</svg>
