require! <[ gulp gulp-livescript gulp-concat gulp-sourcemaps express gulp-beautify gulp-uglify gulp-filter gulp-print express-livereload ./server ]>

jsFiles = <[ jquery*.js upload.js pace.min.js *.js ]>

gulp.task 'serve' <[build:js]> ->
  gulp.watch ['public/**/*'], <[ build:js ]>
  server.listen 3000
  expressLivereload server, watchDir: './'

gulp.task 'serve:prod' <[build:production:js]> ->
  server.listen 80

gulp.task 'build:js' ->
  gulp.src jsFiles.map(-> 'public/' + it)
    .pipe gulpBeautify { indentSize: 4 }
    .pipe gulpSourcemaps.init!
    .pipe gulpConcat('application.js')
    .pipe gulpSourcemaps.write!
    .on 'error' -> throw it
    .pipe gulp.dest 'public/'

gulp.task 'build:production:js' ->
  gulp.src jsFiles.map(-> 'public/' + it)
    .pipe gulpUglify!
    .pipe gulpConcat('application.js')
    .on 'error' -> throw it
    .pipe gulp.dest 'public/'
