\name{contour}

\docType{methods}

\alias{contour}
\alias{contour,RasterLayer-method}
\alias{contour,RasterStackBrick-method}

\title{Contour plot}

\description{
Contour plot of a RasterLayer. This is a generic function, in this package implemented for RasterLayer objects.
}

\usage{
contour(x, ...) 
}

\arguments{
  \item{x}{A Raster* object}
  \item{...}{Any argument that can be passed to \code{\link[graphics]{contour}} (graphics package)}  
}


\section{Methods}{
\describe{

\code{contour(x, y=1, maxpixels=100000, ...)}

\tabular{rll}{
\tab \code{x} \tab RasterLayer object \cr
\tab \code{y} \tab The layer number (integer > 0) if x is a RasterStack or RasterBrick \cr
\tab \code{maxpixels}  \tab  Maximum number of pixels used to create the contours  \cr
\tab \code{...}  \tab  Any argument that can be passed to \code{\link[graphics]{contour}} (graphics package) \cr
}
}}

\seealso{ 
\code{\link{persp}}, \code{\link{filledContour} }

The rasterVis package has more advanced plotting methods for Raster* objects.
}



\examples{
r <- raster(system.file("external/test.grd", package="raster"))
plot(r)
contour(r, add=TRUE)
}

\keyword{methods}
\keyword{spatial}

