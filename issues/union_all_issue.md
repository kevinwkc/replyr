`union_all` issue with `SQLite`. Submitted as [dplyr issue 2270](https://github.com/hadley/dplyr/issues/2270).

<!-- Generated from .Rmd. Please edit that file -->
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
packageVersion('dplyr')
 #  [1] '0.5.0'
my_db <- dplyr::src_sqlite("replyr_sqliteEx.sqlite3", create = TRUE)
dr <- dplyr::copy_to(my_db,
                     data.frame(x=c(1,2),y=c('a','b'),stringsAsFactors = FALSE),'dr',
                     overwrite=TRUE)
dr <- head(dr,1)
# dr <- compute(dr)
print(dr)
 #  Source:   query [?? x 2]
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  
 #        x     y
 #    <dbl> <chr>
 #  1     1     a
print(dplyr::union_all(dr,dr))
 #  Source:   query [?? x 2]
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  Error in sqliteSendQuery(conn, statement): error in statement: LIMIT clause should come after UNION ALL not before
```

``` r
rm(list=ls())
gc()
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 455991 24.4     750400 40.1   592000 31.7
 #  Vcells 647782  5.0    1308461 10.0   883021  6.8
```

``` r
version
 #                 _                           
 #  platform       x86_64-apple-darwin13.4.0   
 #  arch           x86_64                      
 #  os             darwin13.4.0                
 #  system         x86_64, darwin13.4.0        
 #  status                                     
 #  major          3                           
 #  minor          3.2                         
 #  year           2016                        
 #  month          10                          
 #  day            31                          
 #  svn rev        71607                       
 #  language       R                           
 #  version.string R version 3.3.2 (2016-10-31)
 #  nickname       Sincere Pumpkin Patch
```