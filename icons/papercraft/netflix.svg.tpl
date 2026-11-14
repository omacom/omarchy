<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Netflix</title>
  <desc>Netflix's logo in the theme's colors: its ribbon N in the main color, with a hard shadow.</desc>
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
        <path d="M5.398 0l8.348 23.602c2.346 .059 4.856 .398 4.856 .398L10.113 0H5.398z"/>
        <path d="M13.887 0v9.172l4.715 13.33V0h-4.715z"/>
        <path d="M5.398 1.5V24c1.873 -.225 2.81 -.312 4.715 -.398V14.83L5.398 1.5z"/>
      </g>
      <!-- What the logo leaves open, pale. -->
      <g fill="{{ icon_paper }}">
        <path d="M5.398 0l8.348 23.602c2.346 .059 4.856 .398 4.856 .398L10.113 0H5.398z"/>
        <path d="M13.887 0v9.172l4.715 13.33V0h-4.715z"/>
        <path d="M5.398 1.5V24c1.873 -.225 2.81 -.312 4.715 -.398V14.83L5.398 1.5z"/>
      </g>
      <!-- The logo itself. -->
      <path d="m5.398 0 8.348 23.602c2.346.059 4.856.398 4.856.398L10.113 0H5.398zm8.489 0v9.172l4.715 13.33V0h-4.715zM5.398 1.5V24c1.873-.225 2.81-.312 4.715-.398V14.83L5.398 1.5z" fill="url(#main)"/>
    </g>
  </g>
</svg>
