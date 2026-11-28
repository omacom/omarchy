<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>OBS Studio</title>
  <desc>OBS Studio's logo in the theme's colors: its disc in the main color with its pale ring and three pale blades, with a hard shadow.</desc>
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
      <circle cx="12" cy="12.6" r="12" fill="{{ icon_shadow }}"/>
      <circle cx="12" cy="12" r="12" fill="url(#main)"/>
      <!-- Its ring and blades, pale as the white of the logo. -->
      <path d="M12,24C5.383,24,0,18.617,0,12S5.383,0,12,0s12,5.383,12,12S18.617,24,12,24z M12,1.109 C5.995,1.109,1.11,5.995,1.11,12C1.11,18.005,5.995,22.89,12,22.89S22.89,18.005,22.89,12C22.89,5.995,18.005,1.109,12,1.109z M6.182,5.99c0.352-1.698,1.503-3.229,3.05-3.996c-0.269,0.273-0.595,0.483-0.844,0.78c-1.02,1.1-1.48,2.692-1.199,4.156 c0.355,2.235,2.455,4.06,4.732,4.028c1.765,0.079,3.485-0.937,4.348-2.468c1.848,0.063,3.645,1.017,4.7,2.548 c0.54,0.799,0.962,1.736,0.991,2.711c-0.342-1.295-1.202-2.446-2.375-3.095c-1.135-0.639-2.529-0.802-3.772-0.425 c-1.56,0.448-2.849,1.723-3.293,3.293c-0.377,1.25-0.216,2.628,0.377,3.772c-0.825,1.429-2.315,2.449-3.932,2.756 c-1.244,0.261-2.551,0.059-3.709-0.464c1.036,0.302,2.161,0.355,3.191-0.011c1.381-0.457,2.522-1.567,3.024-2.935 c0.556-1.49,0.345-3.261-0.591-4.54c-0.7-1.007-1.803-1.717-3.002-1.969c-0.38-0.068-0.764-0.098-1.148-0.134 c-0.611-1.231-0.834-2.66-0.528-3.996L6.182,5.99z" fill="{{ icon_paper }}" stroke="{{ icon_paper }}" stroke-width=".3" stroke-linejoin="round"/>
    </g>
  </g>
</svg>
