const fs = require('fs');
const path = require('path');
const sass = require('node-sass');
const autoprefixer = require('autoprefixer');
const postcss = require('postcss');

const filename = 'emoney_style_sheet.css';

sass.render({
  file: 'sass/app.scss',
  outputStyle: 'compressed',
  outFile: path.resolve(__dirname, 'assets', 'css') + '/' + filename,
}, function(error, result) {
  if(!error){
    postcss([autoprefixer])
    .process(result.css, { from: 'assets/css/' + filename, to: 'assets/css/' + filename })
    .then(result => {
      fs.writeFile(
        path.resolve(__dirname, 'assets', 'css') + '/' + filename,
        result.css,
        err => {
          if (err) throw err;
          console.log(filename + ' compiled with success!', '\x1b[32m', '[ok]', '\t\t\x1b[0m');
        });
    });
  }
  else{
    console.log(error);
  }
});
