# Author: Robert J. Hijmans
# Date :  June 2008
# Version 1.0
# Licence GPL v3

if (!isGeneric("getValuesBlock")) {
	setGeneric("getValuesBlock", function(x, ...)
		standardGeneric("getValuesBlock"))
}	



setMethod('getValuesBlock', signature(x='RasterStack'), 
	function(x, row=1, nrows=1, col=1, ncols=(ncol(x)-col+1), lyrs) {
		stopifnot(row <= x@nrows)
		stopifnot(col <= x@ncols)
		stopifnot(nrows > 0)
		stopifnot(ncols > 0)
		row <- max(1, min(x@nrows, round(row[1])))
		lastrow <- min(x@nrows, row + round(nrows[1]) - 1)
		nrows <- lastrow - row + 1
		col <- max(1, min(x@ncols, round(col[1])))
		lastcol <- col + round(ncols[1]) - 1
		ncols <- lastcol - col + 1

		
		nlyrs <- nlayers(x)
		if (missing(lyrs)) {
			lyrs <- 1:nlyrs
		} else {
			lyrs <- lyrs[lyrs %in% 1:nl]
			if (length(lyrs) == 0) {
				stop("no valid layers selected")
			}
			nlyrs <- length(lyrs)
			x <- x[[lyrs]]
		}
		
		startcell <- cellFromRowCol(x, row, col)
		lastcell <- cellFromRowCol(x, lastrow, lastcol)

		nc <- ncol(x)
		res <- matrix(ncol=nlyrs, nrow=nrows * ncols)
		
		inmem <- sapply(x@layers, function(x) x@data@inmemory)
		if (any(inmem)) {
			if (col==1 & ncols==nc) {
				cells <- startcell:lastcell
			}
			cells <- cellFromRowColCombine(x, row:lastrow, col:lastcol)
		}
		
		for (i in 1:nlyrs) {
			xx <- x@layers[[lyrs[i]]]
			if ( inMemory(xx) ) {			
				res[,i] <- xx@data@values[cells]		
			} else {
				res[,i] <- .readRasterLayerValues(xx, row, nrows, col, ncols)
			}
		}
		
		colnames(res) <- names(x)
		res
	}
)



setMethod('getValuesBlock', signature(x='RasterBrick'), 
	function(x, row=1, nrows=1, col=1, ncols=(ncol(x)-col+1), lyrs) {
		row <- max(1, round(row))
		col <- max(1, round(col))
		stopifnot(row <= x@nrows)
		stopifnot(col <= x@ncols)
		nrows <- min(round(nrows), x@nrows-row+1)		
		ncols <- min((x@ncols-col+1), round(ncols))
		stopifnot(nrows > 0)
		stopifnot(ncols > 0)

		
		nlyrs <- nlayers(x)
		if (missing(lyrs)) {
			lyrs <- 1:nlyrs
		} else {
			lyrs <- lyrs[lyrs %in% 1:nlyrs]
			if (length(lyrs) == 0) {
				stop("no valid layers")
			}
			nlyrs <- length(lyrs)
		}
		
		
		if ( inMemory(x) ){
			lastrow <- row + nrows - 1
			if (col==1 & ncols==x@ncols) {
				start <- cellFromRowCol(x, row, 1)
				end <-  cellFromRowCol(x, lastrow, ncol(x))
				res <- x@data@values[start:end, ]
			} else {
				lastcol <- col + ncols - 1
				res <- x@data@values[cellFromRowColCombine(x, row:lastrow, col:lastcol), ]
			}
			if (NCOL(res) > nlyrs) {
				res <- res[, lyrs, drop=FALSE]
			}
			colnames(res) <- names(x)[lyrs]
			
		} else if ( fromDisk(x) ) {
			res <- .readRasterBrickValues(x, row, nrows, col, ncols)
			if (NCOL(res) > nlyrs) {
				res <- res[, lyrs, drop=FALSE]
			}
		} else {
			res <- ( matrix(rep(NA, nrows * ncols * nlyrs), ncol=nlyrs) )
			colnames(res) <- names(x)[lyrs]
		}
		return(res)
	}
)



setMethod('getValuesBlock', signature(x='RasterLayer'), 
 	function(x, row=1, nrows=1, col=1, ncols=(ncol(x)-col+1), format='') {
		
		row <- max(1, min(x@nrows, round(row[1])))
		lastrow <- min(x@nrows, row + round(nrows[1]) - 1)
		nrows <- lastrow - row + 1
		col <- max(1, min(x@ncols, round(col[1])))
		lastcol <- col + round(ncols[1]) - 1
		ncols <- lastcol - col + 1
		
		startcell <- cellFromRowCol(x, row, col)
		lastcell <- cellFromRowCol(x, lastrow, lastcol)

		if (!(validRow(x, row))) {	stop(paste(row, 'is not a valid rownumber')) }
	
		if ( inMemory(x) ) {
			if (col==1 & ncols==ncol(x)) {
				res <- x@data@values[startcell:lastcell]
			} else {
				cells <- cellFromRowColCombine(x, row:lastrow, col:lastcol)
				res <- x@data@values[cells]
			}
		} else if ( fromDisk(x)) {
			res <- .readRasterLayerValues(x, row, nrows, col, ncols)
			
		} else  { # no values
			res <- rep(NA, nrows * ncols)			
		}
	
		if (format=='matrix') {
			res = matrix(res, nrow=nrows , ncol=ncols, byrow=TRUE )
			colnames(res) <- col:lastcol
			rownames(res) <- row:lastrow
		}
		res
	}
	
)




setMethod('getValuesBlock', signature(x='RasterLayerSparse'), 
 	function(x=1, row, nrows=1, col=1, ncols=(ncol(x)-col+1), format='') {
		
		row <- max(1, min(x@nrows, round(row[1])))
		lastrow <- min(x@nrows, row + round(nrows[1]) - 1)
		nrows <- lastrow - row + 1
		col <- max(1, min(x@ncols, round(col[1])))
		lastcol <- col + round(ncols[1]) - 1
		ncols <- lastcol - col + 1
		
		startcell <- cellFromRowCol(x, row, col)
		lastcell <- cellFromRowCol(x, lastrow, lastcol)

		if (!(validRow(x, row))) {	stop(paste(row, 'is not a valid rownumber')) }
	
		if ( inMemory(x) ) {
			i <- which(x@index >= startcell & x@index <= lastcell)
			if (length(i) > 0) {
				res <- cellFromRowColCombine(x, row:lastrow, col:lastcol)
				m <- match(i, res)
				res[] <- NA
				res[m] <- x@data@values[i]
			} else {
				res <- rep(NA, nrows * ncols)
			}	
		} else if ( fromDisk(x) ) {
			# not yet implemented
			#if (! fromDisk(x)) {
			#	return(rep(NA, times=(lastcell-startcell+1)))
			#}
			#res <- .readRasterLayerValues(x, row, nrows, col, ncols)
			
		} else  {
			res <- rep(NA, nrows * ncols)			
		} 
			
	
		if (format=='matrix') {
			res = matrix(res, nrow=nrows , ncol=ncols, byrow=TRUE )
			colnames(res) <- col:lastcol
			rownames(res) <- row:lastrow
		}
		res
	}
	
)

