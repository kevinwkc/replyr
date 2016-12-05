<!-- README.md is generated from README.Rmd. Please edit that file -->
It comes as a bit of a shock when [R](https://cran.r-project.org) `dplyr` users switch from using a `tbl` implementation based on R in-memory `data.frame`s to one based on a remote database or service. A lot of the power and convenience of the `dplyr` notation is hard to maintain with these more restricted data service providers. Things that work locally can't always be used remotely at scale. It is emphatically not yet the case that one can practice with `dplyr` in one modality and hope to move to another back-end without significant debugging and work-arounds. `replyr` attempts to provide a few helpful work-arounds.

<a href="https://www.flickr.com/photos/42988571@N08/18029435653" target="_blank"><img src="18029435653_4d64c656c8_z.jpg"> </a>

`replyr` supplies methods to get a grip on working with remote `tbl` sources (`SQL` databases, `Spark`) through `dplyr`. The idea is to add convenience functions to make such tasks more like working with an in-memory `data.frame`. Results still do depend on which `dplyr` service you use, but with `replyr` you have fairly uniform access to some useful functions.

Example: the following should work across more than one `dplyr` back-end (such as `RMySQL` or `RPostgreSQL`).

``` r
library('replyr')
d <- data.frame(x=c(1,2,2),y=c(3,5,NA),z=c(NA,'a','b'),
                stringsAsFactors = FALSE)
summary(d)
 #         x               y            z            
 #   Min.   :1.000   Min.   :3.0   Length:3          
 #   1st Qu.:1.500   1st Qu.:3.5   Class :character  
 #   Median :2.000   Median :4.0   Mode  :character  
 #   Mean   :1.667   Mean   :4.0                     
 #   3rd Qu.:2.000   3rd Qu.:4.5                     
 #   Max.   :2.000   Max.   :5.0                     
 #                   NA's   :1
replyr_summary(d)
 #    column     class nrows nna nunique min max     mean        sd lexmin lexmax
 #  1      x   numeric     3   0       2   1   2 1.666667 0.5773503   <NA>   <NA>
 #  2      y   numeric     3   1       2   3   5 4.000000 1.4142136   <NA>   <NA>
 #  3      z character     3   1       2  NA  NA       NA        NA      a      b
```

`replyr` may not seem to add much until you use a remote data service:

``` r
my_db <- dplyr::src_sqlite("replyr_sqliteEx.sqlite3", create = TRUE)
dRemote <- dplyr::copy_to(my_db,d,'d')
summary(dRemote)
 #      Length Class          Mode
 #  src 2      src_sqlite     list
 #  ops 3      op_base_remote list
replyr_summary(dRemote)
 #    column     class nrows nna nunique min max     mean        sd lexmin lexmax
 #  1      x   numeric     3   0       2   1   2 1.666667 0.5773503   <NA>   <NA>
 #  2      y   numeric     3   1       2   3   5 4.000000 1.4142136   <NA>   <NA>
 #  3      z character     3   1       2  NA  NA       NA        NA      a      b
```

Data types, capabilities, and row-orders all vary a lot as we switch remote data services. But the point of `replyr` is to provide at least some convenient version of typical functions such as: `summary`, `nrow`, unique values, and filter rows by values in a set.

`replyr` is also trying to work through notation issues. `replyr::let` removes the need for use of `lazyeval::interp` and `.dots=stats::setNames` to use the `dplyr` "underbar forms" (please see [here](http://www.win-vector.com/blog/2016/12/parametric-variable-names-and-dplyr/) for explanation). `replyr::let` provides an execution block where we can re-map parametrically supplied names (that is variable or column names that are stored in variables, and not know to the programmer) to concrete names known by the programmer. This allows code such as the following:

``` r
library('dplyr')
 #  
 #  Attaching package: 'dplyr'
 #  The following objects are masked from 'package:stats':
 #  
 #      filter, lag
 #  The following objects are masked from 'package:base':
 #  
 #      intersect, setdiff, setequal, union
d <- data.frame(Sepal_Length=c(5.8,5.7),
                Sepal_Width=c(4.0,4.4),
                Species='setosa',
                rank=c(1,2))
mapping = list(RankColumn='rank')
let(alias=mapping,
    expr={
       d %>% mutate(RankColumn=RankColumn-1) -> dres
    })()
print(dres)
 #    Sepal_Length Sepal_Width Species rank
 #  1          5.8         4.0  setosa    0
 #  2          5.7         4.4  setosa    1
```

This is a *very* new package with no guarantees or claims of fitness for purpose. Some implemented operations are going to be slow and expensive (part of why they are not exposed in `dplyr` itself).

We will probably only ever cover:

-   Native `data.frame`s (and `tbl`/`tibble`)
-   `RMySQL`
-   `RPostgreSQL`
-   `SQLite`
-   `sparklyr` (`Spark` 2 preferred)

The type of functions `replyr` supplies is illustrated through `replyr::replyr_filter` and `replyr::replyr_inTest`. These are designed to subset data based on a columns values being in a given set. These allow selection of rows by testing membership in a set (very useful for partitioning data). Example below:

``` r
library('dplyr')
```

``` r
values <- c(2)
dRemote %>% replyr::replyr_filter('x',values)
 #  Source:   query [?? x 3]
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     2     5     a
 #  2     2    NA     b
```

To install `replyr`:

``` r
# install.packages('devtools')
devtools::install_github('WinVector/replyr')
```

The project URL is: <https://github.com/WinVector/replyr>

I would like this to become a bit of a ["stone soup"](https://en.wikipedia.org/wiki/Stone_Soup) project. If you have a neat function you want to add please contribute a pull request with your attribution and assignment of ownership to [Win-Vector LLC](http://www.win-vector.com') (so Win-Vector LLC can control the code, which we are currently distributing under a GPL3 license) in the code comments.

There are a few (somewhat incompatible) goals for `replyr`:

-   Providing missing convenience functions that work well over all common `dplyr` service providers. Examples include `replyr_summary`, `replyr_filter`, and `replyr_nrow`.
-   Providing a basis for "row number free" data analysis. SQL back-ends don't commonly supply row number indexing (or even deterministic order of rows), so a lot of tasks you could do in memory by adjoining columns have to be done through formal key-based joins.
-   Providing emulations of functionality missing from non-favored service providers (such as windowing functions, `quantile`, `sample_n`, `cumsum`; missing from `SQLite` and `RMySQL`).
-   Working around corner case issues, and some variations in semantics.
-   Sheer bull-headedness in emulating operations that don't quite fit into the pure `dplyr` formulation.

Good code should fill one important gap and work on a variety of `dplyr` back ends (you can test `RMySQL`, and `RPostgreSQL` using docker as mentioned [here](http://www.win-vector.com/blog/2016/11/mysql-in-a-container/) and [here](http://www.win-vector.com/blog/2016/02/databases-in-containers/); `sparklyr` can be tried in local mode as described [here](http://spark.rstudio.com)). I am especially interested in clever "you wouldn't thing this was efficiently possible, but" solutions (which give us an expanded grammar of useful operators), and replacing current hacks with more efficient general solutions. Targets of interest include `sample_n` (which isn't currently implemented for `tbl_sqlite`), `cumsum`, and `quantile`.

Right now we have an expensive implementation of `quantile` based on binary search.

``` r
replyr_quantile(dRemote,'x')
 #     0 0.25  0.5 0.75    1 
 #     1    1    2    2    2
```

`replyr` services include:

-   Moving data into or out of the remote data store (including adding optional row numbers), `replyr_copy_to` and `replyr_copy_from`.
-   Basic summary info: `replyr_nrow`, `replyr_dim`, and `replyr_summary`.
-   Random row sampling (like `dplyr::sample_n`, but working with more service providers). Some of this functionality is provided by `replyr_filter` and `replyr_inTest`.
-   Emulating [The Split-Apply-Combine Strategy](https://www.jstatsoft.org/article/view/v040i01), which is the purpose `replyr_gapply`, `replyr_split`, and `replyr_bind_rows`.
-   Emulating `tidyr` gather/spread (or pivoting and anti-pivoting), which is the purpose of `replyr_gather` and `replyr_spread` (still under development).
-   Patching around differences in `dplyr` services providers (and documenting the reasons for the patches).
-   Making use of "parameterized names" much easier (that is: writing code does not know the name of the column it is expected to work over, but instead takes the column name from a user supplied variable).

Additional desired capabilities of interest include:

-   `cumsum` or row numbering (interestingly enough if you have row numbering you can implement cumulative sum in log-n rounds using joins to implement pointer chasing/jumping ideas, but that is unlikely to be practical, `lag` is enough to generate next pointers, which can be boosted to row-numberings).
-   Inserting random values (or even better random unique values) in a remote column. Most service providers have a pseudo-random source you can use.

Note we are deliberately using prefixed names `replyr_` and not using common `S3` method names to avoid the possibility of `replyr` functions interfering with basic `dplyr` functionality.
