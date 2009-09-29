\name{rasterTmpFile}

\alias{rasterTmpFile}
\alias{removeTmpFiles}
\alias{showTmpFiles}

\title{Temporary files}

\description{
Functions in the raster package create temporary files if the values of an output RasterLayer cannot be stored in memory (ram). This can happen
when no filename is provided to a function and in functions where you cannot provide a filename (e.g. when using 'raster algebra').

Temporary files are automatically removed at the start of each session. During a session you can use \code{showTmpFiles} to see what is there and \code{removeTmpFiles} to delete all the temporary files.  \code{rasterTmpFile} returns a temporary filename. These can be useful when developing your own functions. }

\usage{
rasterTmpFile()
showTmpFiles()
removeTmpFiles()
}


\details{
The default path where the temporary files are stored is returned by \code{rasterOptions(show=TRUE)}; you can change it (for the current session) with \link[raster]{rasterOptions}. 
}

\value{
\code{rasterTmpFile} returns a temporary file name (for use in functions)

\code{showTmpFiles} returns the names (.grd only) of the files in the temp directory

\code{removeTmpFiles} returns nothing
}


\author{Robert J. Hijmans}

\seealso{ \code{\link[raster]{rasterOptions}}, \code{\link[base]{tempfile}} }  


\keyword{ spatial }