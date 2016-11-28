
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' @importFrom dplyr collect copy_to
NULL


#' grouped apply
#'
#' Partitions from by values in grouping column, applies a generic transform
#' to each group and then binds the groups back together.  Only advised for a
#' moderate number of groups and better if grouping column is an index.
#' This is powerfull
#' enough to implement "The Split-Apply-Combine Strategy for Data Analysis"
#' https://www.jstatsoft.org/article/view/v040i01
#'
#'
#' @param df remote dplyr data item
#' @param gcolumn grouping column
#' @param f transform function
#' @param ocolumn ordering column (optional)
#' @param ... force later values to be bound by name
#' @param decreasing if TRUE sort in decreasing order by ocolumn
#' @param maxgroups maximum number of groups to work over
#' @return transformed frame
#'
#' @examples
#'
#' library('dplyr')
#' d <- data.frame(group=c(1,1,2,2,2),
#'                 order=c(.1,.2,.3,.4,.5),
#'                 values=c(10,20,2,4,8))
#'
#' # User supplied window functions.  They depend on known column names and
#' # the data back-end matching function names (as cumsum).
#' cumulative_sum <-. %>% arrange(order) %>% mutate(cv=cumsum(values))
#' sumgroup <- . %>% summarize(group=min(group),
#'                    minv=min(values),maxv=max(values))
#' # group=min(group) is a "pseudo aggregation" as group constant in groups.
#' rank_in_group <-. %>% mutate(constcol=1) %>%
#'           mutate(rank=cumsum(constcol)) %>% select(-constcol)
#'
#' d %>% replyr_gapply('group',cumulative_sum,'order')
#' d %>% replyr_gapply('group',sumgroup)
#' d %>% replyr_gapply('group',rank_in_group,'order')
#' d %>% replyr_gapply('group',rank_in_group,'order',decreasing=TRUE)
#'
#' # # below only works for services which have a cumsum operator
#' # my_db <- dplyr::src_postgres(host = 'localhost',port = 5432,user = 'postgres',password = 'pg')
#' # dR <- replyr_copy_to(my_db,d,'dR')
#' # dR %>% replyr_gapply('group',cumulative_sum,'order')
#' # dR %>% replyr_gapply('group',sumgroup)
#' # dR %>% replyr_gapply('group',rank_in_group,'order')
#' # dR %>% replyr_gapply('group',rank_in_group,'order',decreasing=TRUE)
#'
#' @export
replyr_gapply <- function(df,gcolumn,f,ocolumn=NULL,
                          ...,
                          decreasing=FALSE,
                          maxgroups=100) {
  if((!is.character(gcolumn))||(length(gcolumn)!=1)||(nchar(gcolumn)<1)) {
    stop('replyr_gapply gcolumn must be a single non-empty string')
  }
  if(!is.null(ocolumn)) {
    if((!is.character(ocolumn))||(length(ocolumn)!=1)||(nchar(ocolumn)<1)) {
      stop('replyr_gapply ocolumn must be a single non-empty string or NULL')
    }
  }
  if(length(list(...))>0) {
    stop('replyr_gapply unexpected arguments')
  }
  df %>% replyr_uniqueValues(gcolumn) %>%
    replyr_copy_from(maxrow=maxgroups) -> groups
  reslist <- lapply(groups[[gcolumn]],
                    function(gi) {
                      df %>% replyr_filter(cname=gcolumn,values=gi,verbose=FALSE) -> gsubi
                      if(!is.null(ocolumn)) {
                        if(decreasing) {
                          #gsubi %>% arrange_(.dots=stats::setNames(paste0('desc(',ocolumn,')'),ocolumn)) -> gsubi
                          gsubi %>% arrange_(interp(~desc(x),x=as.name(ocolumn))) -> gsubi
                        } else {
                          gsubi %>% arrange_(ocolumn) -> gsubi
                        }
                      }
                      f(gsubi)
                    })
  replyr_bind_rows(reslist)
}