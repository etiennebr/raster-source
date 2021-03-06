\name{interpolate}

\docType{methods}

\alias{interpolate}
\alias{interpolate,Raster-method}

\title{Interpolate}

\description{
Make a RasterLayer with interpolated values using a fitted model object of classes such as 'gstat' (gstat package) or 'Krige' (fields pacakge). That is, these are models that have location ('x' and 'y', or 'longitude' and 'latitude') as independent variables. If x and y are the only independent variables provide an empty (no associated data in memory or on file) RasterLayer for which you want predictions. If there are more spatial predictor variables provide these as a Raster* object in the first argument of the function. If you do not have x and y locations as implicit predictors in your model you should use \code{\link[raster]{predict}} instead.
}

\usage{
\S4method{interpolate}{Raster}(object, model, filename="", fun=predict, 
    xyOnly=TRUE, ext=NULL, const=NULL, index=1, na.rm=TRUE, debug.level=1, ...)
}

\arguments{
\item{object}{Raster* object}
\item{model}{Fitted model object}
\item{filename}{Output filename (optional)}
\item{fun}{function. Default value is 'predict', but can be replaced with e.g. 'predict.se' (depending on the class of the model object)}
\item{xyOnly}{Logical. If \code{TRUE}, values of the Raster* object are not considered as co-variables; and only x and y (longitude and latitude) are used. This should match the model}
\item{ext}{Extent object to limit the prediction to a sub-region of \code{x}}
\item{const}{data.frame. Can be used to add a constant for which there is no Raster object for model predictions. This is particulary useful if the constant is a character-like factor value}
\item{index}{integer. To select the column if 'predict.model' returns a matrix with multiple columns}
\item{na.rm}{logical. Remove cells with NA values in the predictors before solving the model (and return \code{NA} for those cells). In most cases this will not affect the output. This option prevents errors with models that cannot handle \code{NA} values}
\item{debug.level}{for gstat models only. See ?}
\item{...}{additional arguments passed to the predict.'model' function}
}

\value{
Raster* object
}

\seealso{ \code{\link[raster]{predict}}, \code{\link[gstat]{predict.gstat}}, \code{\link[fields]{Tps}} }



\examples{
\dontrun{
## Thin plate spline interpolation with x and y only
library(fields) 
r <- raster(system.file("external/test.grd", package="raster"))
ra <- aggregate(r, 10)
xy <- data.frame(xyFromCell(ra, 1:ncell(ra)))
v <- getValues(ra)
tps <- Tps(xy, v)
p <- raster(r)
p <- interpolate(p, tps)
p <- mask(p, r)
plot(p)
se <- interpolate(p, tps, fun=predict.se)
se <- mask(se, r)
plot(se)


## gstat examples
library(gstat)
data(meuse)

## inverse distance weighted (IDW)
r <- raster(system.file("external/test.grd", package="raster"))
data(meuse)
mg <- gstat(id = "zinc", formula = zinc~1, locations = ~x+y, data=meuse, 
            nmax=7, set=list(idp = .5))
z <- interpolate(r, mg)
z <- mask(z, r)

## kriging
coordinates(meuse) <- ~x+y
projection(meuse) <- projection(r)

## ordinary kriging
v <- variogram(log(zinc)~1, meuse)
m <- fit.variogram(v, vgm(1, "Sph", 300, 1))
gOK <- gstat(NULL, "log.zinc", log(zinc)~1, meuse, model=m)
OK <- interpolate(r, gOK)

# examples below provided by Maurizio Marchi
## universial kriging
vu <- variogram(log(zinc)~elev, meuse)
mu <- fit.variogram(vu, vgm(1, "Sph", 300, 1))
gUK <- gstat(NULL, "log.zinc", log(zinc)~elev, meuse, model=mu)
names(r) <- 'elev'
UK <- interpolate(r, gUK, xyOnly=FALSE)

## co-kriging
gCoK <- gstat(NULL, 'log.zinc', log(zinc)~1, meuse)
gCoK <- gstat(gCoK, 'elev', elev~1, meuse)
gCoK <- gstat(gCoK, 'cadmium', cadmium~1, meuse)
gCoK <- gstat(gCoK, 'copper', copper~1, meuse)
coV <- variogram(gCoK)
plot(coV, type='b', main='Co-variogram')
coV.fit <- fit.lmc(coV, gCoK, vgm(model='Sph', range=1000))
coV.fit
plot(coV, coV.fit, main='Fitted Co-variogram')
coK <- interpolate(r, coV.fit)
plot(coK)
}
}

\keyword{methods}
\keyword{spatial}
