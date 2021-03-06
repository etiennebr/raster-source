# Author: Robert J. Hijmans, r.hijmans@gmail.com
# Date :  October 2009
# Version 0.9
# Licence GPL v3
 
.writeHdrIDRISI <- function(raster) {
	hdrfile <- filename(raster)
	hdrfile <- .setFileExtensionHeader(hdrfile, 'IDRISI')

	dtype <- .shortDataType(raster@file@datanotation)
	dsize <- dataSize(raster)
	if (dataType(raster) == 'INT1U') {
		pixtype <- 'byte'
	} else if (dataType(raster) == 'INT2S') {
		pixtype <- 'integer'
	} else { 
		pixtype <- 'real'
	}

	if (.couldBeLonLat(raster)) {
		refsystem <- 'latlong'
		refunits <- 'degrees';
	} else {
		refsystem <- 'plane';
		refunits <- 'm';
	}
	
	thefile <- file(hdrfile, "w")  # open an txt file connectionis
	cat('file format : IDRISI Raster A.1\n', file = thefile)
	cat('file title  : ', names(raster), "\n", sep='', file = thefile)
	cat('data type   : ', pixtype, "\n", sep='', file = thefile)
	cat('file type   : binary\n', sep='', file = thefile)
	cat('columns     : ', ncol(raster), "\n", sep='', file = thefile)
	cat('rows        : ', nrow(raster), "\n", sep='', file = thefile)
	cat('ref. system : ', refsystem, "\n", sep='', file = thefile)
	cat('ref. units  : ', refunits, "\n", sep='', file = thefile)
	cat('unit dist.  : 1.0000000', "\n", sep='', file = thefile)
	cat('min. X      : ', as.character(xmin(raster)), "\n", sep='', file = thefile)
	cat('max. X      : ', as.character(xmax(raster)), "\n", sep='', file = thefile)
	cat('min. Y      : ', as.character(ymin(raster)), "\n", sep='', file = thefile)
	cat('max. Y      : ', as.character(ymax(raster)), "\n", sep='', file = thefile)
	cat("pos'n error : unknown\n", file = thefile)
	cat('resolution  : ', xres(raster), "\n", sep='', file = thefile)
	cat('min. value  : ', minValue(raster), "\n", sep='', file = thefile)
	cat('max. value  : ', maxValue(raster), "\n", sep='', file = thefile)
  	cat('display min : ', minValue(raster), "\n", sep='', file = thefile)
  	cat('display max : ', maxValue(raster), "\n", sep='', file = thefile)
	cat('value units : unspecified\n', file = thefile)
	cat('value error : unknown\n', file = thefile)
	cat('flag value  : ', .nodatavalue(raster), "\n", sep='', file = thefile)
	cat("flag def'n  : no data\n", file = thefile)
	cat('legend cats : 0\n', file = thefile)

	close(thefile)
	
	return(invisible(TRUE))
}
