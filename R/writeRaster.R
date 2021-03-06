# Author: Robert J. Hijmans, r.hijmans@gmail.com
# Date: September 2009
# Version 0.9
# Licence GPL v3

if (!isGeneric('writeRaster')) {
	setGeneric('writeRaster', function(x, filename, ...)
		standardGeneric('writeRaster')) 
}


setMethod('writeRaster', signature(x='RasterLayer', filename='character'), 
function(x, filename, format, ...) {

	if (!hasValues(x)) {
		warning('all cell values are NA')
	}
	
	filename <- trim(filename)
	if (filename == '') {	
		stop('provide a filename')	
	}
	filename <- .fullFilename(filename, expand=TRUE)
		
	if (!file.exists(dirname(filename))) {
		stop("Attempting to write a file to a path that does not exist:\n  ", dirname(filename))
	}
	
	filetype <- .filetype(format , filename=filename)
	filename <- .getExtension(filename, filetype)
	
	if (filetype == 'KML') {
		KML(x, filename, ...) 
		return(invisible(x))
	}
	
	
	if (! inMemory(x) ) {
		if ( toupper(x@file@name) == toupper(filename) ) {
			stop('filenames of source and target should be different')
		}
		r <- raster(x)
		tr <- blockSize(r)
		pb <- pbCreate(tr$n, ...)			
		# use x to keep layer names
		r <- writeStart(x, filename=filename, format=filetype, ...)
		for (i in 1:tr$n) {
			v <- getValues(x, row=tr$row[i], nrows=tr$nrows[i])
			r <- writeValues(r, v, tr$row[i])
			pbStep(pb, i) 			
		}
		if (isTRUE(any(is.factor(x)))) {
			levels(r) <- levels(x)
		}
		r <- writeStop(r)
		pbClose(pb)
		return(r)
	}

	if (.isNativeDriver(filetype)) {
		x <- .writeRasterAll(x, filename=filename, filetype=filetype, ...)
		
	} else if (filetype=='ascii') {
		x <- .writeAscii(x, filename=filename,...)
		
	} else if (filetype=='big.matrix') {
		x <- .writeBigMatrix(x, filename=filename,...)

	} else if (filetype=='CDF') {
		x <- .startWriteCDF(x, filename=filename, ...)
		x <- .writeValuesCDF(x, getValues(x))
		return( .stopWriteCDF(x) )
		
	} else { 
		x <- .writeGDALall(x, filename=filename, format=filetype, ...)
	}
	return(x)
}	
)




setMethod('writeRaster', signature(x='RasterStackBrick', filename='character'), 
function(x, filename, format, bylayer=FALSE, suffix='numbers', ...) {

	
	if (!hasValues(x)) {
		warning('all cell values are NA')
	}
	
	
	filename <- trim(filename)
	
	if (bylayer) {
		
		nl <- nlayers(x)
		
		if (length(filename) > 1) {
			if (length(filename) != nlayers(x) ) {
				stop('the number of filenames is > 1 but not equal to the number of layers')	
			}
			
			filename <- .fullFilename(filename, expand=TRUE)
			filetype <- .filetype(format, filename=filename[1])
			filename <- .getExtension(filename, filetype)
				   
		} else {
		
			if (filename == '') { 
				stop('provide a filename') 
			}
			filename <- .fullFilename(filename, expand=TRUE)
			filetype <- .filetype(format, filename=filename)
			filename <- .getExtension(filename, filetype)

			ext <- extension(filename)
			filename <- extension(filename, '')
			if (suffix[1] == 'numbers') {
				filename <- paste(filename, '_', 1:nl, ext, sep='')
			} else if (suffix[1] == 'names') {
				filename <- paste(filename, '_', names(x), ext, sep='')
			} else if (length(suffix) == nl) {
				filename <- paste(filename, '_', suffix, ext, sep='')
			} else {
				stop('invalid "suffix" argument')
			}
		}
		
		
		if (filetype == 'KML') {
			layers <- lapply(1:nl, function(i) KML(x[[i]], filename=filename[i], ...))	
			return(invisible(x))
		}
			
		if (inherits(x, 'RasterBrick')) {
			x <- stack(x)
		}
		layers <- lapply(1:nl, function(i) writeRaster(x[[i]], filename=filename[i], format=filetype, ...))	
		return(stack(layers))
	}
	

	if (filename == '') {	
		stop('provide a filename')	
	}
	filename <- .fullFilename(filename, expand=TRUE)
	filetype <- .filetype(format, filename=filename)
	filename <- .getExtension(filename, filetype)
	
	
	if (filetype == 'KML') {
		KML(x, filename, ...) 
		return(invisible(x))
	}
	
	if (.isNativeDriver(filetype)) {
		if (! filetype %in% c("raster", "BIL", "BSQ", "BIP") ) {
			stop('this file format is not supported for multi-band files')
		}
	
		out <- brick(x, values=FALSE)
		names(out) <- names(x)
		z <- getZ(x)
		if (!is.null(z)) {
			out <- setZ(out, z)
		}
		out <- writeStart(out, filename, format=filetype, ...)
	
		if (inMemory(x)) {
			out <- writeValues(out, getValues(x), 1)
		} else {
			tr <- blockSize(x)
			pb <- pbCreate(tr$n, ...)
			for (i in 1:tr$n) {
				out <- writeValues(out, getValues(x, tr$row[i], tr$nrows[i]), tr$row[i])
				pbStep(pb, i)
			}
			pbClose(pb)
		}
		out <- .stopRasterWriting(out)
		return( out )
	}  
	
	# else 

	if ( inMemory(x) ) {
	
		if (filetype=='CDF') {
			b <- brick(x, values=FALSE)
			b@z  <- x@z
			b <- .startWriteCDF(b, filename=filename,  ...)
			x <- .writeValuesBrickCDF(b, values(x) )	
			x <- .stopWriteCDF(x) 
		} else {
			x <- .writeGDALall(x, filename=filename, format=filetype, ...) 
		}
		
		return(x)
		
	} else {
			
		if ( toupper(filename(x)) == toupper(filename) ) {
			stop('filenames of source and destination should be different')
		}
		
		b <- brick(x, values=FALSE)
		if (filetype=='CDF') {
			b@z  <- x@z
		}

		tr <- blockSize(b)
		pb <- pbCreate(tr$n, ...)
		b <- writeStart(b, filename=filename, format=filetype, ...)
		for (i in 1:tr$n) {
			v <- getValues(x, row=tr$row[i], nrows=tr$nrows[i])
			b <- writeValues(b, v, tr$row[i])
			pbStep(pb, i)
		}
		b <- writeStop(b)
		pbClose(pb)
		return(b)	
	} 
}
)

