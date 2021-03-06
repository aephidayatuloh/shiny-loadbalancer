# create redirect URL
# appnames: vector of shiny apps user are distributed to
# baseurl: Full URL of the directory with shiny apps, trailing slash must be added

makeRedirect <- function(appnames, baseurl) {
  # CPU <- read.table("/var/shiny-server/Data/CPU.txt") # 
  CPU <- read.table("CPU.txt") # 
  App <- data.frame(app = appnames)
  App <- merge(App, CPU, all.x = TRUE)
  App$usr[which(is.na(App$usr))] <- 0
  return(paste(baseurl, App$app[which.min(App$usr)],"/", sep = ""))
}

# list only dirs
list.dirs <- function(path=".", pattern=NULL, all.dirs=FALSE,
  full.names=FALSE, ignore.case=FALSE) {

  all <- list.files(path, pattern, all.dirs,
           full.names, recursive=FALSE, ignore.case)
  all[file.info(paste0(path,all))$isdir]
}

# returns current appname
pwd <- function() {
  path <- strsplit(getwd(), "/")
  return(path[[1]][length(path[[1]])])
}

shinyServer(function(input, output, session) {
 
  output$link <- renderUI({
  list(
       # Input that holds the redirect URL
       textInput(inputId = "url", label = "", value = makeRedirect(
                                                      # find directories with appname_NUMBER, e.g. 
                                                      # if the load balancer appname is "histogram" 
                                                      # all apps named "histogram_1" or "histogram_2" 
                                                      # will be considered for load balancing
                                                      list.dirs("../", pattern=paste0("^",pwd(),"_[0-9]")),
                                                      "http://servername.com/")),
       # JavaScript for redirecting
       tags$script(type="text/javascript", src = "shiny-redirect.js")
  )
  })
})
 
