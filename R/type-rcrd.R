# Constructor and basic methods  ---------------------------------------------

#' rcrd (record) S3 class
#'
#' The rcrd class extends [vctr]. A rcrd is composed of 1 or more [field]s,
#' which must be vectors of the same length. Is designed specifically for
#' classes that can naturally be decomposed into multiple vectors of the same
#' length, like [POSIXlt], but where the organisation should be considered
#' an implementation detail invisible to the user (unlike a [data.frame]).
#'
#' @details
#' Record-style objects created with [new_rcrd()] do not do much on their own.
#' For instance they do not have a default [format()] method, which means printing
#' the object causes an error. See [Record-style objects](https://vctrs.r-lib.org/articles/s3-vector.html?q=record#record-style-objects
#' for details on implementing methods for record vectors.
#'
#' @param fields A list or a data frame. Lists must be rectangular
#'   (same sizes), and contain uniquely named vectors (at least
#'   one). `fields` is validated with [df_list()] to ensure uniquely
#'   named vectors.
#' @param ... Additional attributes
#' @param class Name of subclass.
#' @export
#' @aliases ses rcrd
#' @keywords internal
new_rcrd <- function(fields, ..., class = character()) {
  if (obj_is_list(fields) && length(vec_unique(list_sizes(fields))) > 1L) {
    abort("All fields must be the same size.")
  }

  fields <- df_list(!!!fields)
  if (!length(fields)) {
    abort("`fields` must be a list of length 1 or greater.")
  }
  structure(fields, ..., class = c(class, "vctrs_rcrd", "vctrs_vctr"))
}

#' @export
vec_proxy.vctrs_rcrd <- function(x, ...) {
  new_data_frame(x)
}
#' @export
vec_restore.vctrs_rcrd <- function(x, to, ...) {
  x <- NextMethod()
  attr(x, "row.names") <- NULL
  x
}

#' @export
length.vctrs_rcrd <- function(x) {
  vec_size(x)
}

#' @export
names.vctrs_rcrd <- function(x) {
  NULL
}

#' @export
`names<-.vctrs_rcrd` <- function(x, value) {
  if (is_null(value)) {
    x
  } else {
    abort("Can't assign names to a <vctrs_rcrd>.")
  }
}

#' @export
format.vctrs_rcrd <- function(x, ...) {
  if (inherits(x, "vctrs_foobar")) {
    # For unit tests
    exec("paste", !!!vec_data(x), sep = ":")
  } else {
    stop_unimplemented(x, "format")
  }
}

#' @export
obj_str_data.vctrs_rcrd <- function(x, ...) {
  obj_str_leaf(x, ...)
}

#' @method vec_cast vctrs_rcrd
#' @export
vec_cast.vctrs_rcrd <- function(x, to, ...) UseMethod("vec_cast.vctrs_rcrd")

#' @export
vec_cast.vctrs_rcrd.vctrs_rcrd <- function(x, to, ...) {
  out <- vec_cast(vec_data(x), vec_data(to), ...)
  new_rcrd(out)
}


# Subsetting --------------------------------------------------------------

#' @export
`[.vctrs_rcrd` <-  function(x, i, ...) {
  if (!missing(...)) {
    abort("Can't index record vectors on dimensions greater than 1.")
  }
  vec_slice(x, maybe_missing(i))
}

#' @export
`[[.vctrs_rcrd` <- function(x, i, ...) {
  out <- vec_slice(vec_data(x), i)
  vec_restore(out, x)
}

#' @export
`$.vctrs_rcrd` <- function(x, i, ...) {
  stop_unsupported(x, "subsetting with $")
}

#' @export
rep.vctrs_rcrd <- function(x, ...) {
  out <- lapply(vec_data(x), base_vec_rep, ...)
  vec_restore(out, x)
}

#' @export
`length<-.vctrs_rcrd` <- function(x, value) {
  out <- vec_size_assign(vec_data(x), value)
  vec_restore(out, x)
}

# Replacement -------------------------------------------------------------

#' @export
`[[<-.vctrs_rcrd` <- function(x, i, value) {
  force(i)
  x[i] <- value
  x
}

#' @export
`$<-.vctrs_rcrd` <- function(x, i, value) {
  stop_unsupported(x, "subset assignment with $")
}

#' @export
`[<-.vctrs_rcrd` <- function(x, i, value) {
  i <- maybe_missing(i, TRUE)
  value <- vec_cast(value, x)
  out <- vec_assign(vec_data(x), i, vec_data(value))
  vec_restore(out, x)
}

# Equality and ordering ---------------------------------------------------

#' @export
vec_math.vctrs_rcrd <- function(.fn, .x, ...) {
  stop_unsupported(.x, "vec_math")
}
