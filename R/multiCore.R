# Author: Matteo Mattiuzzi and Robert J. Hijmans
# Date : November 2010
# Version 1.0
# Licence GPL v3


beginCluster <- function(n, type='SOCK', nice, exclude=NULL) {
	if (! require(snow) ) {
		stop('you need to install the "snow" package')
	}

	if (exists('raster_Cluster_raster_Cluster', envir=.GlobalEnv)) {
		endCluster()
	}

	if (missing(n)) {
		n <- .detectCores()
		cat(n, 'cores detected\n')
	}

#	if (missing(type)) {
#		type <- getClusterOption("type")
#		cat('cluster type:', type, '\n')
#	}
	
	cl <- makeCluster(n, type) 
	cl <- .addPackages(cl, exclude=exclude)
	options(rasterClusterObject = cl)
	options(rasterClusterCores = length(cl))
	options(rasterCluster = TRUE)
	options(rasterClusterExclude = exclude)
	
	
	if (!missing(nice)){ 
        if (.Platform$OS.type == 'unix') { 
            cmd <- paste("renice",nice,"-p")
            foo <- function() system(paste(cmd, Sys.getpid()))
            clusterCall(cl,foo) 
        } else { 
            warning("argument 'nice' only supported on UNIX like operating systems") 
        } 
    } 
	
}


endCluster <- function() {
	options(rasterCluster = FALSE)
	cl <- options('rasterClusterObject')[[1]]
	if (! is.null(cl)) {
		stopCluster( cl )
		options(rasterClusterObject = NULL)
	}
}


.doCluster <- function() {
	if ( isTRUE( getOption('rasterCluster')) ) {
		return(TRUE)
	} 
	return(FALSE)
}


getCluster <- function() {
	cl <- getOption('rasterClusterObject')
	if (is.null(cl)) { stop('no cluster available, first use "beginCluster"') }
	cl <- .addPackages(cl, exclude=c('raster', 'sp', getOption('rasterClusterExclude')))
	options( rasterClusterObject = cl )
	options( rasterCluster = FALSE )
	return(cl)
}


returnCluster <- function() {
	cl <- getOption('rasterClusterObject')
	if (is.null(cl)) { stop('no cluster available') }
	options( rasterCluster = TRUE )
}


.addPackages <- function(cl, exclude=NULL) {
	pkgs <- .packages()
	i <- which( pkgs %in% c(exclude, "stats", "graphics", "grDevices", "utils", "datasets", "methods", "base") )
	pkgs <- rev( pkgs[-i] )
	for ( pk in pkgs ) {
		clusterCall(cl, library, pk, character.only=TRUE )
	}
	return(cl)
}

