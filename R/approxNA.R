
if (!isGeneric("approxNA")) {
	setGeneric("approxNA", function(x, ...)
		standardGeneric("approxNA"))
}	



setMethod('approxNA', signature(x='RasterStackBrick'), 
function(x, filename="", method="linear", yleft, yright, rule=1, f=0, ties=mean,...) { 

	filename <- trim(filename)
	out <- brick(x, values=FALSE)
	nl <- nlayers(out)
	xout <- 1:nl
	
	ifelse((missing(yleft) & missing(yright)), ylr <- 0L, ifelse(missing(yleft), ylr <- 1L, ifelse(missing(yright), ylr <- 2L, ylr <- 3L)))
	
	if (canProcessInMemory(x)) {
		x <- getValues(x)
		i <- rowSums(is.na(x))
		i <- i < nl & i > 1 # need at least two
		if (length(i) > 0 ) {
			if (ylr==0) {
				x[i,] <- t(apply(x[i,], 1, function(x) approx(x, y=NULL, xout=xout, method=method, rule=rule, f=f, ties=ties)$y ))
			} else if (ylr==1) {
				x[i,] <- t(apply(x[i,], 1, function(x) approx(x, y=NULL, xout=xout, method=method, yright=yright, rule=rule, f=f, ties=ties)$y ))			
			} else if (ylr==2) {
				x[i,] <- t(apply(x[i,], 1, function(x) approx(x, y=NULL, xout=xout, method=method, yleft=yleft, rule=rule, f=f, ties=ties)$y ))						
			} else {
				x[i,] <- t(apply(x[i,], 1, function(x) approx(x, y=NULL, xout=xout, method=method, yright=yright, yleft=yleft, rule=rule, f=f, ties=ties)$y ))
			}
		} else {
			warning('no NA values to approximate')
		}
		x <- setValues(out, x)
		if (filename != '') {
			x <- writeRaster(x, filename=filename, ...)
		}
		return(x)
	} 
	
	tr <- blockSize(out)
	pb <- pbCreate(tr$n, type=.progress(...))
	out <- writeStart(out, filename=filename, ...)
	
	if (ylr==0) {
	
		for (i in 1:tr$n) {
			v <- getValues(x, row=tr$row[i], nrows=tr$nrows[i])
			i <- rowSums(is.na(v))
			i <- i < nl & i > 1 # need at least two
			if (length(i) > 0 ) {
				v[i,] <- t( apply(v[i,], 1, function(x) approx(x, xout=xout, method=method, rule=rule, f=f, ties=ties)$y ) )
			}
			out <- writeValues(out, v)
			pbStep(pb)
		}
		
	} else {
	
		for (i in 1:tr$n) {
			v <- getValues(x, row=tr$row[i], nrows=tr$nrows[i])
			i <- rowSums(is.na(v))
			i <- i < nl & i > 1 # need at least two
			if (length(i) > 0 ) {
				if (ylr==1) {
					v[i,] <- t( apply(v[i,], 1, function(x) approx(x, xout=xout, method=method, yright=yright, rule=rule, f=f, ties=ties)$y ) )
				} else if (ylr==2) {
					v[i,] <- t( apply(v[i,], 1, function(x) approx(x, xout=xout, method=method, yleft=yleft, rule=rule, f=f, ties=ties)$y ) )
				} else {
					v[i,] <- t( apply(v[i,], 1, function(x) approx(x, xout=xout, method=method, yright=yright, yleft=yleft, rule=rule, f=f, ties=ties)$y ) )
				}
			}
			out <- writeValues(out, v)
			pbStep(pb)
		}
	}
	
	pbClose(pb)
	out <- writeStop(out)
	return(out)
}
)
