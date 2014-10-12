require! <[ gulp gulp-livescript gulp-concat gulp-sourcemaps express gulp-beautify gulp-filter gulp-print express-livereload ./server ]>

gulp.task 'serve' ->
  server.listen 3000
  expressLivereload server, watchDir: './'

gulp.task 'build:js' ->
  gulp.src jsFiles.map(-> 'app/scripts/' + it)
    .pipe gulpLivescript bare: true, prelude: true
    .pipe gulpBeautify { indentSize: 4 }
    .pipe gulpSourcemaps.init!
    .pipe gulpConcat('application.js')
    .pipe gulpSourcemaps.write!
    .on 'error' -> throw it
    .pipe gulp.dest 'public/js/'

gulp.task 'default' <[ serve ]> ->
  gulp.watch ['app/**/*'], <[ build:js build:jade build:scss ]>
  gulp.watch <[ bower_components/**/* app/stylesheets/* ]>, <[ build:js:vendor build:scss:vendor ]>
