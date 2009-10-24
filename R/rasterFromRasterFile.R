# Author: Robert J. Hijmans, r.hijmans@gmail.com
# Date : June 2008
# Version 0.9
# Licence GPL v3


.rasterFromRasterFile <- function(filename, band=1, type='RasterLayer') {
	valuesfile <- .setFileExtensionValues(filename)
	if (!file.exists( valuesfile )){
		stop( paste(valuesfile,  "does not exist"))
	}	
	filename <- .setFileExtensionHeader(filename, "raster")
	
	ini <- readIniFile(filename)
	ini[,2] = toupper(ini[,2]) 

	byteorder <- .Platform$endian
	nbands <- as.integer(1)
	band <- as.integer(band)
	bandorder <- "BIL"
	projstring <- ""
	minval <- NA
	maxval <- NA
	nodataval <- -Inf
	layernames <- ''
	
	for (i in 1:length(ini[,1])) {
		if (ini[i,2] == "MINX") {xn <- as.numeric(ini[i,3])} 
		else if (ini[i,2] == "MAXX") {xx <- as.numeric(ini[i,3])} 
		else if (ini[i,2] == "MINY") {yn <- as.numeric(ini[i,3])} 
		else if (ini[i,2] == "MAXY") {yx <- as.numeric(ini[i,3])} 
		else if (ini[i,2] == "XMIN") {xn <- as.numeric(ini[i,3])} 
		else if (ini[i,2] == "XMAX") {xx <- as.numeric(ini[i,3])} 
		else if (ini[i,2] == "YMIN") {yn <- as.numeric(ini[i,3])} 
		else if (ini[i,2] == "YMAX") {yx <- as.numeric(ini[i,3])} 
		else if (ini[i,2] == "ROWS") {nr <- as.integer(ini[i,3])} 
		else if (ini[i,2] == "COLUMNS") {nc <- as.integer(ini[i,3])} 
		else if (ini[i,2] == "NROWS") {nr <- as.integer(ini[i,3])} 
		else if (ini[i,2] == "NCOLS") {nc <- as.integer(ini[i,3])} 
		
		else if (ini[i,2] == "MINVALUE") { try ( minval <-  as.numeric(unlist(strsplit(ini[i,3], ':'))), silent = TRUE ) }
		else if (ini[i,2] == "MAXVALUE") { try ( maxval <-  as.numeric(unlist(strsplit(ini[i,3], ':'))), silent = TRUE ) }
		else if (ini[i,2] == "VALUEUNIT") { try ( maxval <-  as.numeric(unlist(strsplit(ini[i,3], ':'))), silent = TRUE ) }
		
		else if (ini[i,2] == "NODATAVALUE") {nodataval <- as.numeric(ini[i,3])} 
		else if (ini[i,2] == "DATATYPE") {inidatatype <- ini[i,3]} 
		else if (ini[i,2] == "BYTEORDER") {byteorder <- ini[i,3]} 
		else if (ini[i,2] == "NBANDS") {nbands <- ini[i,3]} 
		else if (ini[i,2] == "BANDORDER") {bandorder <- ini[i,3]} 
		else if (ini[i,2] == "PROJECTION") {projstring <- ini[i,3]} 
		else if (ini[i,2] == "LAYERNAME") {layernames <- ini[i,3]} 
    }  
	
	if (projstring == 'GEOGRAPHIC') { projstring <- "+proj=longlat" }

	if (band < 1) {
		band <- 1
		warning('band set to 1')
	} else if  (band > nbands) {
		band <- nbands
		warning('band set to ', nbands)
	}
	
	minval <- minval[1:nbands]
	maxval <- maxval[1:nbands]
	minval[is.na(minval)] <- Inf
	maxval[is.na(maxval)] <- -Inf
	
	if (type == 'RasterBrick') {
		x <- brick(ncols=nc, nrows=nr, xmn=xn, ymn=yn, xmx=xx, ymx=yx, projs=projstring)
		x@data@nlayers <-  as.integer(nbands)
		x@data@min <- minval
		x@data@max <- maxval
	} else {
		x <- raster(ncols=nc, nrows=nr, xmn=xn, ymn=yn, xmx=xx, ymx=yx, projs=projstring)
		x@data@band <- as.integer(band)
		x@data@min <- minval[band]
		x@data@max <- maxval[band]
	}

	x@file@nbands <- as.integer(nbands)

	if (bandorder %in% c("BSQ", "BIP", "BIL")) {
		x@file@bandorder <- bandorder 
	}

	if (nchar(layernames) > 1) {
		layernames <- unlist(strsplit(layernames, ':'))
	}
	x@layernames <- layernames
	shortname <- gsub(" ", "_", ext(basename(filename), ""))
	x <- .enforceGoodLayerNames(x, shortname)
	
	x@file@name <- .fullFilename(filename)
	x@data@haveminmax <- TRUE  # should check?
	x@file@nodatavalue <- nodataval


	.setDataType(x) <- inidatatype
	
	if ((byteorder == "little") | (byteorder == "big")) { 
		x@file@byteorder <- byteorder 
	} 	
	x@data@source <- 'disk'
	x@file@driver <- "raster"
	
    return(x)
}