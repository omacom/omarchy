<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Google Chrome</title>
  <desc>Chrome's logo in the theme's colors: its three-part ring in the main color around a center, the gaps between them pale, with a hard shadow.</desc>
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
        <path d="M12 0C8.21 0 4.831 1.757 2.632 4.501l3.953 6.848A5.454 5.454 0 0 1 12 6.545h10.691A12 12 0 0 0 12 0z"/>
        <path d="M1.931 5.47A11.943 11.943 0 0 0 0 12c0 6.012 4.42 10.991 10.189 11.864l3.953 -6.847a5.45 5.45 0 0 1 -6.865 -2.29z"/>
        <path d="M15.273 7.636a5.446 5.446 0 0 1 1.45 7.09l.002 .001h-.002l-5.344 9.257c.206 .01 .413 .016 .621 .016c6.627 0 12 -5.373 12 -12c0 -1.54 -.29 -3.011 -.818 -4.364z"/>
        <path d="M12 16.364a4.364 4.364 0 1 1 0 -8.728a4.364 4.364 0 0 1 0 8.728z"/>
      </g>
      <!-- What the logo leaves open, pale. -->
      <g fill="{{ icon_paper }}">
        <path d="M12 0C8.21 0 4.831 1.757 2.632 4.501l3.953 6.848A5.454 5.454 0 0 1 12 6.545h10.691A12 12 0 0 0 12 0z"/>
        <path d="M1.931 5.47A11.943 11.943 0 0 0 0 12c0 6.012 4.42 10.991 10.189 11.864l3.953 -6.847a5.45 5.45 0 0 1 -6.865 -2.29z"/>
        <path d="M15.273 7.636a5.446 5.446 0 0 1 1.45 7.09l.002 .001h-.002l-5.344 9.257c.206 .01 .413 .016 .621 .016c6.627 0 12 -5.373 12 -12c0 -1.54 -.29 -3.011 -.818 -4.364z"/>
        <path d="M12 16.364a4.364 4.364 0 1 1 0 -8.728a4.364 4.364 0 0 1 0 8.728z"/>
      </g>
      <!-- The logo itself. -->
      <path d="M12 0C8.21 0 4.831 1.757 2.632 4.501l3.953 6.848A5.454 5.454 0 0 1 12 6.545h10.691A12 12 0 0 0 12 0zM1.931 5.47A11.943 11.943 0 0 0 0 12c0 6.012 4.42 10.991 10.189 11.864l3.953-6.847a5.45 5.45 0 0 1-6.865-2.29zm13.342 2.166a5.446 5.446 0 0 1 1.45 7.09l.002.001h-.002l-5.344 9.257c.206.01.413.016.621.016 6.627 0 12-5.373 12-12 0-1.54-.29-3.011-.818-4.364zM12 16.364a4.364 4.364 0 1 1 0-8.728 4.364 4.364 0 0 1 0 8.728Z" fill="url(#main)"/>
    </g>
  </g>
</svg>
