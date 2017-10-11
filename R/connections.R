conn_file <- "~/.RDBIconnections"

#' Connect to a database
#'
#' @param connection_name the name of the connection you wish to connect to
#'
#' @return a DBI connecction
#' @export
#'
#' @examples
connect <- function(connection_name) {
  connections <- load_connections()
  if (!(connection_name %in% names(connections))) {
    stop(connection_name, "not in connections file. Available connections:\n",
         paste(names(connections)))
  }
  spec <- connections[[connection_name]]
  if (spec$args$password == "ask") {
    spec$args$password <- readline("Enter password: ")
  }
  connect_from_spec(spec)
}

#' Adds a connection to the connection file.
#'
#' @return NULL
#' @export
#'
#' @examples
add_connection <- function() {
  existing_connections <- load_connections()
  name <- readline("Connection name: ")
  if (name %in% names(existing_connections)) {
    if(prompt_with_reqs(paste0("Connection ", name, " already exists. Overwrite? [y/n] ")) == 'n') {
      stop("Connection '", name, "' already exists.")
    }
  }
  driver_constructor <- readline("Driver constructor in R (e.g. RMariaDB::MariaDB()")
  args <- list(
    user = readline("Username: "),
    password = readline("Password (set to \"ask\" to prompt for password each time): "),
    host = readline("Host: "),
    dbname = readline("Database name: "),
    ssl.cert = readline("Path to ssl cert: ")
  )
  add_args <- prompt_with_reqs("Do you wish to add more arguments? [y/n] ")
  while (add_args == "y") {
    key <- readline("Argument name: ")
    val <- readline("Argument value: ")
    args[[key]] <- val
    add_args <- prompt_with_reqs("Do you wish to add more arguments? [y/n] ")
  }
  existing_connections[[name]] <- list(driver_constructor = driver_constructor,
                                       args = args)
  cat(yaml::as.yaml(existing_connections), file = conn_file, append = F)
}

#' Remove a connection
#'
#' @param name name of the connection you wish to remove
#'
#' @return NULL
#' @export
#'
#' @examples
remove_connection <- function(name) {
  connections <- load_connections()
  if (name %in% names(connections)) {
    connections[[name]] <- NULL
  }
  else {
    stop("Connection \"", name, "\" not in connections file.")
  }
  cat(yaml::as.yaml(connections), file = conn_file, append = F)
}

#' List available connections
#'
#' @return a list of connections from connections file
#' @export
#'
#' @examples
list_connections <- function() {
  names(load_connections())
}

prompt_with_reqs <- function(prompt, reqs = c('y', 'n')) {
  user_in <- readline(prompt)
  while (!(user_in %in% reqs)) {
    cat(paste0("Input must be one of [", paste(reqs, collapse = '/'), "]"))
    user_in <- readline(prompt)
  }
  user_in
}

connect_from_spec <- function(spec) {
  # connects from a connection specification (a list with driver_constructor and args)
  drv <- eval(parse(text = spec$driver_constructor))
  return(do.call(DBI::dbConnect, c(drv = drv, spec$args)))
}

load_connections <- function() {
  yaml::yaml.load_file(conn_file)
}
