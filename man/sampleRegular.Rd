\name{sampleRegular}

\alias{sampleRegular}

\title{Regular sample}

\description{
Take a systematic sample from a Raster* object. 
}

\usage{
sampleRegular(x, size, extent=NULL, cells=FALSE, asRaster=FALSE, corners=FALSE)
}

\arguments{
  \item{x}{a Raster object}
  \item{size}{positive integer giving the number of items to choose.}  
  \item{extent}{Extent. To limit regular sampling to the area within that box}  
  \item{cells}{Logical. Also return sampled cell numbers (if asRaster=FALSE) }  
  \item{asRaster}{Logical. If \code{TRUE}, a rasterLayer is returned, rather then the sampled values}  
  \item{corners}{Logical. If \code{TRUE}, the extreme corner cells are always included. This makes for rather irregular sampling when n is small; but it can be useful when asRaster=TRUE, to maintain the same extent as the input RasterLayer}
}

\value{
A vector, matrix (if cells=TRUE; or for a multi-layered object), or RasterLayer (if asRaster=TRUE)
}

\seealso{\code{\link{sampleRandom}}}


\author{Robert J. Hijmans}

\examples{
 r <- raster(system.file("external/test.grd", package="raster"))
 v <- sampleRegular(r, size=100)
 x <- sampleRegular(r, size=100, asRaster=TRUE)
}

\keyword{spatial}