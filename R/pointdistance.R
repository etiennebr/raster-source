# Author: Robert J. Hijmans  and Jacob van Etten
# Date :  June 2008
# Version 0.9
# Licence GPL v3

.pointsToMatrix <- function(p) {
	if (inherits(p, 'SpatialPoints')) {
		p <- coordinates(p)
	} else if (is.data.frame(p)) {
		p <- as.matrix(p)
	} else if (is.vector(p)){
		if (length(p) != 2) {
			stop('Wrong length for a vector, should be 2')
		} else {
			p <- matrix(p, ncol=2) 
		}
	}
	if (is.matrix(p)) {
		if (ncol(p) != 2) {
			stop( 'A points matrix should have 2 columns')
		}
		cn <- colnames(p)
		if (length(cn) == 2) {
			if (toupper(cn[1]) == 'Y' | toupper(cn[2]) == 'X')  {
				stop('Highly suspect column names (x and y reversed?)')
			}
			if (toupper(substr(cn[1],1,3) == 'LAT' | toupper(substr(cn[2],1,3)) == 'LON'))  {
				stop('Highly suspect column names (longitude and latitude reversed?)')
			}
		}		
	} else {
		stop('points should be vectors of length 2, matrices with 2 columns, or a SpatialPoints* object')
	}

	return(p)
}


.distm <- function (x, longlat) {
	if (longlat) { 
		fun <- .haversine 
	} else { 
		return(.planedist2(x, x))
	#	fun <- .planedist
	}
    n = nrow(x)
    dm = matrix(ncol = n, nrow = n)
    dm[cbind(1:n, 1:n)] = 0
    if (n == 1) {
        return(dm)
    }
    for (i in 2:n) {
        j = 1:(i - 1)
        dm[i, j] = fun(x[i, 1], x[i, 2], x[j, 1], x[j, 2])
    }
    return(dm)
}


.distm2 <- function (x, y, longlat) {
	if (longlat) { 
		fun <- .haversine 
	} else { 
		return(.planedist2(x, y))
		# fun <- .planedist
	}
	n = nrow(x)
	m = nrow(y)
	dm = matrix(ncol=m, nrow=n)
	for (i in 1:n) {
		dm[i,] = fun(x[i, 1], x[i, 2], y[, 1], y[, 2])
	}
	return(dm)
}


pointDistance <- function (p1, p2, longlat,  ...) {

	type <- list(...)$type
	if (!is.null(type)) {
		stop("'type' is a depracated argument. Use 'longlat'")
	}		
	if (missing(longlat)) {
		stop('you must provide a "longlat" argument (TRUE/FALSE)')
	}
	stopifnot(is.logical(longlat)) 
	
	p1 <- .pointsToMatrix(p1)
	if (missing(p2)) {
		return(.distm(p1, longlat))
	}
	
	p2 <- .pointsToMatrix(p2)
	
	if(length(p1[,1]) != length(p2[,1])) {
		if(length(p1[,1]) > 1 & length(p2[,1]) > 1) {
			return(.distm2(p1, p2, longlat))
		}
	}
	
	if (! longlat ) {
		return( .planedist(p1[,1], p1[,2], p2[,1], p2[,2]) )
	} else { 
		return( .haversine(p1[,1], p1[,2], p2[,1], p2[,2], r=6378137) )
	}
}

.planedist <- function(x1, y1, x2, y2) {
	sqrt(( x1 -  x2)^2 + (y1 - y2)^2) 
}


.planedist2 <- function(p1, p2) {
# code by Bill Venables, CSIRO Laboratories
# https://stat.ethz.ch/pipermail/r-help/2008-February/153841.html
	z0 <- complex(, p1[,1], p1[,2])
	z1 <- complex(, p2[,1], p2[,2])
	outer(z0, z1, function(z0, z1) Mod(z0-z1))
}



.haversine <- function(x1, y1, x2, y2, r=6378137) {
	adj <- pi / 180
	x1 <- x1 * adj
	y1 <- y1 * adj
	x2 <- x2 * adj
	y2 <- y2 * adj
	x <- sqrt((cos(y2) * sin(x1-x2))^2 + (cos(y1) * sin(y2) - sin(y1) * cos(y2) * cos(x1-x2))^2)
	y <- sin(y1) * sin(y2) + cos(y1) * cos(y2) * cos(x1-x2)
	return ( r * atan2(x, y) )
}

