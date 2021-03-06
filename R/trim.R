# Author: Robert J. Hijmans
# contact: r.hijmans@gmail.com
# Date : December 2009
# Version 0.9
# Licence GPL v3


if (!isGeneric("trim")) {
	setGeneric("trim", function(x, ...)
		standardGeneric("trim"))
}	


setMethod('trim', signature(x='character'), 
	function(x, ...) {
		f <- function(s) {
			return( gsub('^[[:space:]]+', '',  gsub('[[:space:]]+$', '', s) ) )
		}
		return(unlist(lapply(x, f)))
	}
)

setMethod('trim', signature(x='data.frame'), 
	function(x, ...) {
		for (i in 1:ncol(x)) {
			if (class(x[,i]) == 'character') {
				x[,i] <- trim(x[,i])
			}
			if (class(x[,i]) == 'factor') {
				x[,i] <- as.factor(trim(as.character(x[,i])))
			}			
		}
		return(x)
	}
)


setMethod('trim', signature(x='matrix'), 
	function(x, ...) {
		if (is.character(x)) {
			x[] = trim(as.vector(x))
		} else {
			rows <- rowSums(is.na(x))
			cols <- colSums(is.na(x))
			rows <- which(rows != ncol(x))
			cols <- which(cols != nrow(x))
			if (length(rows)==0) {
				x <- matrix(ncol=0, nrow=0)
			} else {
				x <- x[min(rows):max(rows), min(cols):max(cols), drop=FALSE]
			}
		}
		return(x)
	}
)



setMethod('trim', signature(x='Raster'), 
function(x, padding=0, filename='', ...) {

	filename <- trim(filename)

	nr <- nrow(x)
	nc <- ncol(x)
	nrl <- nr * nlayers(x)
	ncl <- nc * nlayers(x)
	

	for (r in 1:nr) {
		v <- getValues(x, r)
		if (sum(is.na(v)) < ncl) { break }
	}
	if ( r == nr) { stop('only NA values found') }
	firstrow <- min(max(r-padding, 1), nr)
	
	for (r in nr:1) {
		v <- getValues(x, r)
		if (sum(is.na(v)) < ncl) { break }
	}
	lastrow <- max(min(r+padding, nr), 1)
	
	if (lastrow < firstrow) { 
		tmp <- firstrow
		firstrow <- lastrow
		lastrow <- tmp
	}
	
	for (c in 1:nc) {
		v <- getValuesBlock(x, 1 ,nrow(x), c, 1)
		if (sum(is.na(v)) < nrl) { break }
	}
	firstcol <- min(max(c-padding, 1), nc) 
	
	for (c in nc:1) {
		v <- getValuesBlock(x, 1 ,nrow(x), c, 1)
		if (sum(is.na(v)) < nrl) { break }
	}
	lastcol <- max(min(c+padding, nc), 1)
	
	if (lastcol < firstcol) { 
		tmp <- firstcol
		firstcol <- lastcol
		lastcol <- tmp
	}
	
	xr <- xres(x)
	yr <- yres(x)
	e <- extent(xFromCol(x, firstcol)-0.5*xr, xFromCol(x, lastcol)+0.5*xr, yFromRow(x, lastrow)-0.5*yr, yFromRow(x, firstrow)+0.5*yr)
	
	return( crop(x, e, filename=filename, ...) )
}
)

