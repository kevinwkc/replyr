% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/quantile.R
\name{replyr_quantile}
\alias{replyr_quantile}
\title{Compute quantiles on remote column (NA's filtered out) using binary search.}
\usage{
replyr_quantile(x, cname, probs = seq(0, 1, 0.25), ...,
  tempNameGenerator = makeTempNameGenerator("replyr_quantile"))
}
\arguments{
\item{x}{tbl or item that can be coerced into such.}

\item{cname}{column name to compute over}

\item{probs}{numeric vector of probabilities with values in [0,1].}

\item{...}{force later arguments to be bound by name.}

\item{tempNameGenerator}{temp name generator produced by replyr::makeTempNameGenerator, used to record dplyr::compute() effects.}
}
\description{
NA's filtered out and does not break ties the same as stats::quantile.
}
\examples{

d <- data.frame(xvals=rev(1:1000))
replyr_quantile(d,'xvals')

}
