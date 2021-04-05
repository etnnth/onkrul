#!/bin/sh

#define parameters which are passed in.
NAME=$(basename $1 .html)
#define the template.
cat  << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <link rel="favicon" type="image/ico" href="favicon.ico"  />
  <script src="$NAME.min.js"></script>
  <style>body { padding: 0; margin: 0; }</style>
</head>
<body>
  <script>
    var app = Elm.$NAME.init()
  </script>
</body>
</html>
EOF

