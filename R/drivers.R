# Author: Robert J. Hijmans, r.hijmans@gmail.com
# Date :  November 2008
# Version 0.9
# Licence GPL v3


.nativeDrivers <- function() {
	return(  c("raster", "SAGA", "IDRISI", "BIL", "BSQ", "BIP") )
}

.nativeDriversLong <- function() {
	return(  c("R-raster", "SAGA GIS", "IDRISI", "Band by Line", "Band Sequential", "Band by Pixel") )
}


.isNativeDriver <- function(d) {
	return( d %in% .nativeDrivers() ) 
}


writeFormats <- function() {
	if ( .requireRgdal(FALSE) ) {
		gd <- .gdalWriteFormats() 
		short <- c(.nativeDrivers(),  'ascii', 'CDF', 'big', as.vector(gd[,1]))
		long <- c(.nativeDriversLong(), 'Arc ASCII', 'NetCDF', 'big.matrix', as.vector(gd[,2]))
	} else {
		short <- c(.nativeDrivers(), 'ascii', 'CDF', 'big', "")
		long <- c(.nativeDriversLong(), "Arc ASCII", "NetCDF", "big.matrix", "", "rgdal not installed")
	}
	
	m <- cbind(short, long)
	colnames(m) <- c("name", "long_name")
	return(m)
}

 