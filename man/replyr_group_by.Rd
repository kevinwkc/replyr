% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/underscoreReplacements.R
\name{replyr_group_by}
\alias{replyr_group_by}
\title{group_by by a single column}
\usage{
replyr_group_by(.data, colname)
}
\arguments{
\item{.data}{data object to work on}

\item{colname}{character column name}
}
\description{
group_by by a single column
}
\examples{

d <- data.frame(Sepal_Length= c(5.8,5.7),
                Sepal_Width= c(4.0,4.4),
                Species= 'setosa')
replyr_group_by(d, 'Species')

}
