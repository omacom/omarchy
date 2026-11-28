<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>RAWmakase</title>
  <desc>RAWmakase's logo in the theme's colors: the maki roll's nori in the main color around pale rice, and its salmon in orange with an aperture's blades drawn into it, with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <clipPath id="salmon">
      <circle cx="512" cy="512" r="158"/>
    </clipPath>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The logo's own drawing, on its 1024 unit square, without its tile. -->
    <g transform="translate(256 256) scale(.528) translate(-512 -512)">
      <!-- Its silhouette, as one hard shadow, as Hype's slides. -->
      <circle cx="512" cy="528" r="318" fill="{{ icon_shadow }}"/>
      <!-- The nori. -->
      <circle cx="512" cy="512" r="318" fill="url(#main)"/>
      <!-- The rice. -->
      <circle cx="512" cy="512" r="262" fill="{{ icon_paper }}"/>
      <!-- The salmon, with the aperture's blades. -->
      <circle cx="512" cy="512" r="158" fill="{{ icon_orange }}"/>
      <path d="M492 454L912 454M552.2 465.7L762.2 829.4M572.2 523.7L362.2 887.4M532 570L112 570M471.8 558.3L261.8 194.6M451.8 500.3L661.8 136.6" fill="none" stroke="{{ icon_shadow }}" stroke-opacity=".4" stroke-width="16" stroke-linecap="round" clip-path="url(#salmon)"/>
    </g>
  </g>
</svg>
