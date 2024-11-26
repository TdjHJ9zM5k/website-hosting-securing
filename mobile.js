
<html>
  <title>My Custom Title</title>
    <link rel="icon" href="https://storage.googleapis.com/www.your-website.com/favicon.ico" type="image/x-icon">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    /* Hide only the Wix ad banner */
    iframe {
      position: fixed;
      left: 0;
      top: -39px; /* Adjust as needed to hide the banner */
      width: 100%;
      height: calc(100% + 39px); /* Adjusted to cover the area hidden by the banner */
      border: none;
    }
    /* Remove any padding and margin */
    body {
      margin: 0;
      padding: 0;
      background-color:#E9CAB1;
    }
  </style>

  <body>
  
    <iframe src="https://username.wixsite.com/name" style="    position: fixed;    left: 0px;    top: -39px;    width: 100%;    height: 108%;}">
    </iframe>  
    <script>
      function resizeIframe() {
        const iframe = document.querySelector('iframe');
        const screenWidth = window.innerWidth;
        const screenHeight = window.innerHeight;

        // Define the base width and top offset of the Wix content
        const baseWidth = 320; // Original width of the Wix content
        const baseTop = -39;   // Original `top` offset
        const scaleFactor = screenWidth / baseWidth;

        // Apply scaling to the iframe
        iframe.style.transform = `scale(${scaleFactor})`;
        iframe.style.transformOrigin = "top left";

        // Adjust iframe's dimensions and position
        iframe.style.width = `${baseWidth}px`; // Original content width
        const newHeight = (screenHeight / scaleFactor) - (baseTop * scaleFactor); // Compensate for banner removal
        iframe.style.height = `${newHeight}px`; // Scaled height to fit the viewport
        iframe.style.left = `calc((100vw - ${baseWidth}px * ${scaleFactor}) / 2)`; // Center horizontally
        iframe.style.top = `${baseTop * scaleFactor}px`; // Scale the top offset
      }

      // Run resize function immediately after DOM is loaded
      document.addEventListener('DOMContentLoaded', resizeIframe);

      // Resize on window resize events (debounced for better performance)
      let resizeTimeout;
      window.addEventListener('resize', () => {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(resizeIframe, 100);
      });
    </script>
  </body>
</html>
