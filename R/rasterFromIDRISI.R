# Author: Robert J. Hijmans, r.hijmans@gmail.com
# Date : October 2009
# Version 0.9
# Licence GPL v3

.rasterFromIDRISIFile <- function(filename) {
	valuesfile <- .setFileExtensionValues(filename, "IDRISI")
	if (!file.exists(valuesfile )){
		stop( paste(valuesfile,  "does not exist"))
	}	
	filename <- .setFileExtensionHeader(filename, "IDRISI")
	
	ini <- readIniFile(filename, token=':')

	ini[,2] = toupper(ini[,2]) 

	byteorder <- .Platform$endian
	projstring <- ""
	nodataval <- -Inf
	layernames <- ''
	filetype <- ''
	
	for (i in 1:length(ini[,1])) {
		if (ini[i,2] == "MIN. X") {xn <- as.numeric(ini[i,3])
		} else if (ini[i,2] == "MAX. X") {xx <- as.numeric(ini[i,3])
		} else if (ini[i,2] == "MIN. Y") {yn <- as.numeric(ini[i,3])
		} else if (ini[i,2] == "MAX. Y") {yx <- as.numeric(ini[i,3])
		} else if (ini[i,2] == "MIN. VALUE") { minval <-  as.numeric(ini[i,3]) 
		} else if (ini[i,2] == "MAX. VALUE") { maxval <-  as.numeric(ini[i,3]) 
		} else if (ini[i,2] == "VALUE UNITS") { valunit <-  ini[i,3] 
		} else if (ini[i,2] == "ROWS") {nr <- as.integer(ini[i,3])
		} else if (ini[i,2] == "COLUMNS") {nc <- as.integer(ini[i,3])
		} else if (ini[i,2] == "DATA TYPE") {inidatatype <- toupper(ini[i,3])
		} else if (ini[i,2] == "FILE TYPE") {filetype <- toupper(ini[i,3])
		} else if (ini[i,2] == "FILE TITLE") {layernames <- ini[i,3]
		} else if (ini[i,2] == "FLAG VALUE") { try (nodataval <- as.numeric(ini[i,3]), silent=TRUE)
		}
    }  
	
	if (filetype=='PACKED BINARY') {
		stop('cannot read packed binary files, read via rgdal?')
	}
	
	x <- raster(ncols=nc, nrows=nr, xmn=xn, ymn=yn, xmx=xx, ymx=yx, projs=projstring)
	
	if (nchar(layernames) > 1) {
		layernames <- unlist(strsplit(layernames, ':'))
	}
	x@layernames <- layernames
	shortname <- gsub(" ", "_", ext(basename(filename), ""))
	x <- .enforceGoodLayerNames(x, shortname)
	
	x@file@name <- .fullFilename(filename)
	x@data@min <- minval
	x@data@max <- maxval
	x@data@haveminmax <- TRUE
	x@file@nodatavalue <- nodataval

	if (inidatatype == 'BYTE') {
		.setDataType(x) <- 'INT1U'
	} else if (inidatatype == 'INTEGER') {
		.setDataType(x) <- 'INT2S'
	} else if (inidatatype == 'REAL') {
		.setDataType(x) <- 'INT4S'
	} else {
		stop(paste('unsupported IDRISI data type:', inidatatype))
	}
	
	x@data@source <- 'disk'
	x@file@driver <- 'IDRISI'
    return(x)
}


