#' Search index design documents
#'
#' @export
#' @template all
#' @template return
#' @param dbname (character) Database name. required.
#' @param design (character) Design document name. this is the design name
#' without \strong{_design/}, which is prepended internally. required.
#' @param view (character) a view, same as \code{fxn} param in
#' \code{\link{design_create_}}. required.
#'
#' @references \url{http://docs.couchdb.org/en/latest/api/ddoc/views.html}
#'
#' @details Note that we only support GET for this method, and not POST.
#' Let us know if you want POST support
#'
#' @examples \dontrun{
#' (x <- Cushion$new())
#'
#' file <- system.file("examples/omdb.json", package = "sofa")
#' strs <- readLines(file)
#'
#' ## create a database
#' if ("omdb" %in% db_list(x)) {
#'   invisible(db_delete(x, dbname="omdb"))
#' }
#' db_create(x, dbname='omdb')
#'
#' ## add the documents
#' invisible(db_bulk_create(x, "omdb", strs))
#'
#' # Create a view, the easy way, but less flexible
#' design_create(x, dbname='omdb', design='view1', fxnname="foobar1")
#' design_create(x, dbname='omdb', design='view2', fxnname="foobar2",
#'   value="doc.Country")
#' design_create(x, dbname='omdb', design='view5', fxnname="foobar3",
#'   value="[doc.Country,doc.imdbRating]")
#'
#' # Search using a view
#' compact <- function(l) Filter(Negate(is.null), l)
#' res <- design_search(x, dbname='omdb', design='view2', view ='foobar2')
#' head(
#'   do.call(
#'     "rbind.data.frame",
#'     Filter(
#'       function(z) length(z) == 2,
#'       lapply(res$rows, function(x) compact(x[names(x) %in% c('id', 'value')]))
#'     )
#'   )
#' )
#'
#' res <- design_search(x, dbname='omdb', design='view5', view = 'foobar3')
#' head(
#'   structure(do.call(
#'     "rbind.data.frame",
#'     lapply(res$rows, function(x) x$value)
#'   ), .Names = c('Country', 'imdbRating'))
#' )
#'
#' # query parameters
#' ## limit
#' design_search(x, dbname='omdb', design='view5', view = 'foobar3',
#'   limit = 5)
#' }
design_search_index <- function(cushion, dbname, design, index, q = '', include_docs = 'false', as = 'list', ...) {

  check_cushion(cushion)
  url <- cushion$make_url()
  call_ <- file.path(url, dbname, "_design", design, "_search", index)
  args <- paste("q=",q, "&include_docs=", include_docs, sep = "")
  sofa_GET(call_, as, query = args, cushion$get_headers(), ...)
}
