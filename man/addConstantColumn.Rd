% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/addCol.R
\name{addConstantColumn}
\alias{addConstantColumn}
\title{Add constant to a table.}
\usage{
addConstantColumn(d, colName, val, ...,
  tempNameGenerator = makeTempNameGenerator("replyr_addConstantColumn"))
}
\arguments{
\item{d}{data.frame like object to add column to.}

\item{colName}{character, name of column to add.}

\item{val}{scalar, value to add.}

\item{...}{force later arguments to be bound by name.}

\item{tempNameGenerator}{temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.}
}
\value{
table with new column added.
}
\description{
Work around different treatment of character types accross remote
data soures when adding a
constant column to a table.
}
\examples{

d <- data.frame(x= c(1:3))
addConstantColumn(d, 'newCol', 'newVal')

}
