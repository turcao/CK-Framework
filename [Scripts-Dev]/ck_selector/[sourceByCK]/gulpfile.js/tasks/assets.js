var browserSync = require("browser-sync");
var changed = require("gulp-changed");
var gulp = require("gulp");
var path = require("path");

var paths = {
  src: path.join(CONFIG.root.src, CONFIG.tasks.assets.src, "/**"),
  destDev: path.join(CONFIG.root.destDev, CONFIG.tasks.assets.dest),
  destProd: path.join(CONFIG.root.destProd, CONFIG.tasks.assets.dest)
};

var imagesTask = function imagesTask() {
  return gulp
    .src(paths.src)
    .pipe(
      global.PRODUCTION === true
        ? changed(paths.destProd)
        : changed(paths.destDev)
    )
    .pipe(
      global.PRODUCTION === true
        ? gulp.dest(paths.destProd)
        : gulp.dest(paths.destDev)
    )
    .pipe(browserSync.stream());
};

gulp.task("assets", imagesTask);
module.exports = imagesTask;
