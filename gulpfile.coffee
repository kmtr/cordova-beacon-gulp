gulp = require 'gulp'
gutil = require 'gulp-util'
shell = require 'gulp-shell'
minimist = require 'minimist'
coffeekup = require  'gulp-coffeekup'
connect = require 'gulp-connect'
markdown = require 'gulp-markdown'
rimraf = require 'gulp-rimraf'
stylus = require 'gulp-stylus'
sass = require 'gulp-sass'
source = require 'vinyl-source-stream'
browserify = require 'browserify'

#error callback
watchError = (err)->
  gutil.log err
  @emit 'end'

gulp.task 'default', ['build']

gulp.task 'build', [
  'script'
  'stylus'
  'sass'
  'markdown'
  'coffeekup'
  'copy-img'
]

gulp.task 'clean', ->
  gulp
    .src './www'
    .pipe rimraf()

gulp.task 'script', ->
  browserify
    entries: ['./src/js/main.coffee']
    extensions: ['.coffee']
  .bundle()
  .on 'error', watchError
  .pipe source 'main.js'
  .pipe gulp.dest './www/js/'

gulp.task 'stylus', ->
  gulp
    .src './src/css/**/*.styl'
    .pipe stylus()
    .on 'error', watchError
    .pipe gulp.dest './www/css'

gulp.task 'sass', ->
  gulp
    .src './src/css/**/*.scss'
    .pipe sass()
    .on 'error', watchError
    .pipe gulp.dest './www/css'

gulp.task 'markdown', ->
  gulp
    .src './src/**/*.md'
    .pipe markdown()
    .on 'error', watchError
    .pipe gulp.dest './www/'

gulp.task 'coffeekup', ->
  gulp
    .src './src/**/*.ck'
    .pipe coffeekup {format:true}
    .on 'error', watchError
    .pipe gulp.dest './www/'

gulp.task 'copy-img', ->
  gulp
    .src './src/img/**/*'
    .pipe gulp.dest './www/img/'

#watch tasks
gulp.task 'watch',['connect'], ->
#live reload callback
  liveReload = (file)->
    gulp
      .src file.path
      .pipe connect.reload()
  gulp
    .watch './src/css/**/*', ['stylus', 'sass']
  gulp
    .watch './src/js/**/*', ['script']
  gulp
    .watch './src/**/*.md', ['markdown']
  gulp
    .watch './src/**/*.ck', ['coffeekup']
  gulp
    .watch './www/**/*'
    .on 'change', liveReload

#connect server
gulp.task 'connect', ->
  connect.server {
    root: [__dirname + '/www/'],
    port:9001,
    livereload: true,
  }

# cordova task options
cordovaTaskOpts = minimist process.argv.slice(2),
  {
    string: ['platform']
    default: {
      platform: ''
    }
  }

# cordova build ios
gulp.task 'cordova-build', ['build'], ->
  gulp
    .src ''
    .pipe shell './node_modules/.bin/cordova build ' +
      cordovaTaskOpts.platform

gulp.task 'cordova-run', ['cordova-build'], ->
  gulp
    .src ''
    .pipe shell './node_modules/.bin/cordova run ' +
      cordovaTaskOpts.platform
