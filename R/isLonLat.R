# Author: Robert J. Hijmans, r.hijmans@gmail.com
# Date :  October 2008
# Version 0.9
# Licence GPL v3



.isGlobalLonLat <- function(x) {
	res <- FALSE
	tolerance <- 0.1
	scale <- xres(x)
	if (isTRUE(all.equal(xmin(x), -180, tolerance=tolerance, scale=scale)) & 
		isTRUE(all.equal(xmax(x),  180, tolerance=tolerance, scale=scale))) {
		if (.couldBeLonLat(x)) {
 			res <- TRUE
		}
	}
	res
}


.couldBeLonLat <- function(x, warnings=TRUE) {
	crsLL <- isLonLat(x)
	if (class(x) == 'character') { 
		return(crsLL) 
	}
	crsNA <- projection(x)=='NA'
	e <- extent(x)
	extLL <- (e@xmin > -365 & e@xmax < 365 & e@ymin > -90.1 & e@ymax < 90.1) 
	if (extLL & crsLL) { 
		return(TRUE)
	} else if (extLL & crsNA) {
		if (warnings) warning('CRS is NA. Assuming it is longitude/latitude')
		return(TRUE)
	} else if (crsLL) {
		if (warnings) warning('raster has a longitude/latitude CRS, but coordinates do not match that')
		return(TRUE)
	} else {
		return(FALSE) 	
	}
}


if (!isGeneric("isLonLat")) {
	setGeneric("isLonLat", function(x)
		standardGeneric("isLonLat"))
}	


setMethod('isLonLat', signature(x='Spatial'), 
	function(x){
		isLonLat(projection(x))
    }
)


setMethod('isLonLat', signature(x='BasicRaster'), 
# copied from the SP package (slightly adapted)
#author:
# ...
	function(x){
		p4str <- projection(x)
		if (is.na(p4str) || nchar(p4str) == 0) {
			return(as.logical(NA))
		} 
		res <- grep("longlat", p4str, fixed = TRUE)
		if (length(res) == 0) {
			return(FALSE)
		} else {
			return(TRUE)
		}
    }
)

setMethod('isLonLat', signature(x='character'), 
# copied from the SP package (slightly adapted)
#author:
# ...
	function(x){
		res <- grep("longlat", x, fixed = TRUE)
		if (length(res) == 0) {
			return(FALSE)
		} else {
			return(TRUE)
		}
    }
)



setMethod('isLonLat', signature(x='CRS'), 
# copied from the SP package (slightly adapted)
#author:
# ...
	function(x){
		if (is.na(x@projargs)) { 
			return(NA)
		} else {
			p4str <- trim(x@projargs)
		}	
		if (is.na(p4str) || nchar(p4str) == 0) {
			return(as.logical(NA))
		} 
		res <- grep("longlat", p4str, fixed = TRUE)
		if (length(res) == 0) {
			return(FALSE)
		} else {
			return(TRUE)
		}
    }
)

