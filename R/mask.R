# Author: Robert J. Hijmans
# Date : November 2009
# Version 1.0
# Licence GPL v3


if (!isGeneric("mask")) {
	setGeneric("mask", function(x, mask, ...)
		standardGeneric("mask"))
}	


setMethod('mask', signature(x='Raster', mask='Spatial'), 
function(x, mask, filename="", inverse=FALSE, ...){ 
	
	if (inverse) {
		mask <- rasterize(mask, x, 1)
		mask(x, mask, filename=filename, inverse=TRUE, maskvalue=NA, ...)
	
	} else {
	
		if (nlayers(x) > 1) {
			mask <- rasterize(mask, x, 1)
			mask(x, mask, filename=filename, maskvalue=NA, ...)
		} else {
			rasterize(mask, x, filename=filename, mask=TRUE, ...)
		}
	}
} )



setMethod('mask', signature(x='RasterLayer', mask='RasterLayer'), 
function(x, mask, filename="", inverse=FALSE, maskvalue=NA, ...){ 

	maskvalue <- maskvalue[1]
	compareRaster(x, mask)
	ln <- names(x)
	out <- raster(x)
	names(out) <- ln		
	
	if ( canProcessInMemory(x, 3)) {

		x <- getValues(x)
		mask <- getValues(mask)
		if (is.na(maskvalue)) {
			if (inverse) {
				x[!is.na(mask)] <- NA
			} else {
				x[is.na(mask)] <- NA
			}
		} else {
			x[mask==maskvalue] <- NA
		}
		x <- setValues(out, x)
		if (filename != '') {
			x <- writeRaster(x, filename, ...)
		}
		return(x)
		
	} else {

		if (filename=='') { 	
			filename <- rasterTmpFile() 
		}

		out <- writeStart(out, filename=filename, ...)
		tr <- blockSize(out)
		pb <- pbCreate(tr$n, label='mask', ...)

		if (is.na(maskvalue)) {
			if (inverse) {
				for (i in 1:tr$n) {
					v <- getValues( x, row=tr$row[i], nrows=tr$nrows[i] )
					m <- getValues( mask, row=tr$row[i], nrows=tr$nrows[i] )
					v[!is.na(m)] <- NA
					out <- writeValues(out, v, tr$row[i])
					pbStep(pb, i)
				} 		
			} else {
				for (i in 1:tr$n) {
					v <- getValues( x, row=tr$row[i], nrows=tr$nrows[i] )
					m <- getValues( mask, row=tr$row[i], nrows=tr$nrows[i] )
					v[is.na(m)] <- NA
					out <- writeValues(out, v, tr$row[i])
					pbStep(pb, i)
				} 
			}
		} else {
			for (i in 1:tr$n) {
				v <- getValues( x, row=tr$row[i], nrows=tr$nrows[i] )
				m <- getValues( mask, row=tr$row[i], nrows=tr$nrows[i] )
				v[m==maskvalue] <- NA
				out <- writeValues(out, v, tr$row[i])
				pbStep(pb, i)
			} 		
		}
		pbClose(pb)
		out <- writeStop(out)
		names(out) <- ln		
		return(out)
	}
}
)


setMethod('mask', signature(x='RasterStackBrick', mask='RasterLayer'), 
function(x, mask, filename="", inverse=FALSE, maskvalue=NA, ...){ 

	compareRaster(x, mask)
	
	out <- brick(x, values=FALSE)
	names(out) <- ln <- names(x)
	
	if (canProcessInMemory(x, nlayers(x)+4)) {

		x <- getValues(x)
		if (is.na(maskvalue)) {
			if (inverse) {
				x[!is.na(getValues(mask)), ] <- NA
			} else {
				x[is.na(getValues(mask)), ] <- NA
			}
		} else {
			x[getValues(mask)==maskvalue, ] <- NA
		}
		out <- setValues(out, x)
		if (filename != '') {
			out <- writeRaster(out, filename, ...)
		} 
		return(out)
		
	} else {

		if ( filename=='') { 
			filename <- rasterTmpFile() 
		}

		out <- writeStart(out, filename=filename, ...)
		tr <- blockSize(out)
		pb <- pbCreate(tr$n, label='mask', ...)

		if (is.na(maskvalue)) {
			if (inverse) {
				for (i in 1:tr$n) {
					v <- getValues( x, row=tr$row[i], nrows=tr$nrows[i] )
					m <- getValues( mask, row=tr$row[i], nrows=tr$nrows[i] )
					v[!is.na(m), ] <- NA
					out <- writeValues(out, v, tr$row[i])
					pbStep(pb, i)
				} 
			} else {
				for (i in 1:tr$n) {
					v <- getValues( x, row=tr$row[i], nrows=tr$nrows[i] )
					m <- getValues( mask, row=tr$row[i], nrows=tr$nrows[i] )
					v[is.na(m), ] <- NA
					out <- writeValues(out, v, tr$row[i])
					pbStep(pb, i)
				} 
			}
		} else {
			for (i in 1:tr$n) {
				v <- getValues( x, row=tr$row[i], nrows=tr$nrows[i] )
				m <- getValues( mask, row=tr$row[i], nrows=tr$nrows[i] )
				v[m==maskvalue, ] <- NA
				out <- writeValues(out, v, tr$row[i])
				pbStep(pb, i)
			} 
		}

		pbClose(pb)
		out <- writeStop(out)
		names(out) <- ln
		return(out)
	}
}
)


setMethod('mask', signature(x='RasterLayer', mask='RasterStackBrick'), 
function(x, mask, filename="", inverse=FALSE, maskvalue=NA, ...){ 

	compareRaster(x, mask)

	out <- brick(mask, values=FALSE)
	
	if (canProcessInMemory(mask, nlayers(x)*2+2)) {

		x <- getValues(x)
		x <- matrix(rep(x, nlayers(out)), ncol=nlayers(out))
		if (is.na(maskvalue)) {
			if (inverse) {
				x[!is.na(getValues(mask))] <- NA
			} else {
				x[is.na(getValues(mask))] <- NA
			}
		} else {
			x[getValues(mask)==maskvalue] <- NA
		}
		out <- setValues(out, x)
		if (filename != '') {
			out <- writeRaster(out, filename, ...)
		} 
		return(out)
		
	} else {
	
		if ( filename=='') { filename <- rasterTmpFile() }
		out <- writeStart(out, filename=filename, ...)
		tr <- blockSize(out)
		pb <- pbCreate(tr$n, label='mask', ...)

		if (is.na(maskvalue)) {
			if (inverse) {
				for (i in 1:tr$n) {
					v <- getValues( x, row=tr$row[i], nrows=tr$nrows[i] )
					v <- matrix(rep(v, nlayers(out)), ncol=nlayers(out))
					m <- getValues( mask, row=tr$row[i], nrows=tr$nrows[i] )
					v[!is.na(m)] <- NA
					out <- writeValues(out, v, tr$row[i])
					pbStep(pb, i)
				} 
			} else {
				for (i in 1:tr$n) {
					v <- getValues( x, row=tr$row[i], nrows=tr$nrows[i] )
					v <- matrix(rep(v, nlayers(out)), ncol=nlayers(out))
					m <- getValues( mask, row=tr$row[i], nrows=tr$nrows[i] )
					v[is.na(m)] <- NA
					out <- writeValues(out, v, tr$row[i])
					pbStep(pb, i)
				} 
			}
		} else {
			for (i in 1:tr$n) {
				v <- getValues( x, row=tr$row[i], nrows=tr$nrows[i] )
				v <- matrix(rep(v, nlayers(out)), ncol=nlayers(out))
				m <- getValues( mask, row=tr$row[i], nrows=tr$nrows[i] )
				v[m==maskvalue] <- NA
				out <- writeValues(out, v, tr$row[i])
				pbStep(pb, i)
			} 
		}

		pbClose(pb)
		out <- writeStop(out)
		return(out)
	}
}
)



setMethod('mask', signature(x='RasterStackBrick', mask='RasterStackBrick'), 
function(x, mask, filename="", inverse=FALSE, maskvalue=NA, ...){ 


	if ( nlayers(x) != nlayers(mask) ) {
		if (nlayers(x) == 1) {
			x <- raster(x)
			return(mask(x, mask, filename, inverse, maskvalue=maskvalue, ...))
		}
		if (nlayers(mask) == 1) {
			mask <- raster(mask)
			return(mask(x, mask, filename, inverse, maskvalue=maskvalue, ...))
		}
		stop('number of layers of x and mask must match')
	}
	
	compareRaster(x, mask)
	out <- brick(x, values=FALSE)
	ln <- names(x)
	names(out) <- ln
	
	if (canProcessInMemory(x, nlayers(x)+4)) {

		x <- getValues(x)
		if (is.na(maskvalue)) {
			if (inverse) {
				x[!is.na(getValues(mask))] <- NA		
			} else {
				x[is.na(getValues(mask))] <- NA
			}
		} else {
			x[getValues(mask) == maskvalue] <- NA
		}
		out <- setValues(out, x)
		if (filename != '') {
			out <- writeRaster(out, filename, ...)
			names(out) <- ln
		} 
		return(out)
		
	} else {

		if ( filename=='') { filename <- rasterTmpFile() }

		out <- writeStart(out, filename=filename, ...)
		tr <- blockSize(out)
		pb <- pbCreate(tr$n, label='mask', ...)

		if (is.na(maskvalue)) {
			if (inverse) {
				for (i in 1:tr$n) {
					v <- getValues( x, row=tr$row[i], nrows=tr$nrows[i] )
					m <- getValues( mask, row=tr$row[i], nrows=tr$nrows[i] )
					v[!is.na(m)] <- NA
					out <- writeValues(out, v, tr$row[i])
					pbStep(pb, i)
				} 
			} else {
				for (i in 1:tr$n) {
					v <- getValues( x, row=tr$row[i], nrows=tr$nrows[i] )
					m <- getValues( mask, row=tr$row[i], nrows=tr$nrows[i] )
					v[is.na(m)] <- NA
					out <- writeValues(out, v, tr$row[i])
					pbStep(pb, i)
				} 
			}
		} else {
			for (i in 1:tr$n) {
				v <- getValues( x, row=tr$row[i], nrows=tr$nrows[i] )
				m <- getValues( mask, row=tr$row[i], nrows=tr$nrows[i] )
				v[m == maskvalue] <- NA
				out <- writeValues(out, v, tr$row[i])
				pbStep(pb, i)
			} 		
		}
			
		pbClose(pb)
		out <- writeStop(out)
		names(out) <- ln
		return(out)
	}
}
)

