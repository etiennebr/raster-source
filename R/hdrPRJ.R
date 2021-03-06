# Author: Robert J. Hijmans, r.hijmans@gmail.com
# Date :  April 2011
# Version 1.0
# Licence GPL v3


.writeHdrPRJ <- function(x, ESRI=TRUE) {

	.requireRgdal()

	p4s <- try(	showWKT(projection(x), file = NULL, morphToESRI = ESRI) )
	if (class(p4s) != 'try-error') {
		prjfile <- filename(x)
		extension(prjfile) <- '.prj'
		cat(p4s, file=filename)
	} else {
		return(FALSE)
	}
	return(invisible(TRUE))
}

	
