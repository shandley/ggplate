.onAttach <- function(libname, pkgname) {
  if (.Platform$OS.type == "unix") {
    packageStartupMessage(
      "\U1F4CA Welcome to ggplateplus version ",
      utils::packageVersion("ggplateplus"),
      "! \U1F4C8
                            \n\U1F58D Have fun plotting your data! \U1F4BB"
    )
  }
  if (.Platform$OS.type == "windows") {
    packageStartupMessage(
      "Welcome to ggplateplus version ",
      utils::packageVersion("ggplateplus"), "!
                            \nHave fun plotting your data!"
    )
  }
}
