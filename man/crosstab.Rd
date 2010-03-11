\name{crosstab}

\docType{methods}

\alias{crosstab}
\alias{crosstab,RasterLayer,RasterLayer-method}

\title{Cross-tabulate}

\description{
Cross-tabulate two RasterLayer objects to create a contingency table.
}

\usage{
crosstab(x, y, ...) 
}

\arguments{
  \item{x}{A RasterLayer object}
  \item{y}{A RasterLayer object}
  \item{...}{Additional arguments. See Details}  
}

\details{
 A full call to the crosstab method for a RasterLayer is:

 \code{crosstab(x, y, digits=0, progress) }

\tabular{rll}{
\tab \code{digits} \tab Integer. The number of digits for rounding the values before cross-tabulation\cr
\tab \code{progress} \tab Character. Valid values are "text", "tcltk", "windows" (on that platform only) and ""  \cr
}
}

\value{
A table
}

\seealso{ \code{\link[raster]{freq}}, \code{\link[raster]{zonal}} }

\author{Robert J. Hijmans}

\examples{
r <- raster()
r[] = runif(ncell(r)) * 5
s = setValues(r, runif(ncell(r)) * 10)
crosstab(r,s)
}

\keyword{methods}
\keyword{spatial}
