const fs = require('fs');
const path = require('path');
const sass = require('node-sass');

const filename = 'emoney_style_sheet';

sass.render({
  file: 'sass/app.scss',
  outputStyle: 'compressed',
  outFile: path.resolve(__dirname, 'assets', 'css') + '/' + filename + '.css',
  sourceMap: true,
  sourceMapContents: true
}, function(error, result) {
  if(!error){
    fs.writeFile(
      path.resolve(__dirname, 'assets', 'css') + '/' + filename + '.css',
      result.css,
      function(err) {
        if (err) throw err;
        console.log(filename + ' compiled with success!', '\x1b[32m', '[ok]', '\t\t\x1b[0m');
      });

      fs.writeFile(
        path.resolve(__dirname, 'assets', 'css') + '/' + filename + '.css.map',
        result.map,
        function(err) {
          if (err) throw err;
          console.log(filename + '.map generated with success!', '\x1b[32m', '[ok]', '\t\t\x1b[0m');
        });
  }
  else{
    console.log(error);
  }
});
