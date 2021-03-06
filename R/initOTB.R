#'initOTB
#'@title initOTB setup the orfeo toolbox bindings for a rsession
#'@description  The function initOTB trys to locate all valid OTB installation
#'  and returns the pathes and environment settings. All valid means that it
#'  looks for the \code{otb_cli.bat} file. If the file is found in a \code{bin} folder it is assumed to be a valid OTB binary installation.
#'@param binPathOtb string contains path to where the otb binaries are located
#'@param rootPathOtb string provides the root folder of the \code{binPathOtb}
#'@param selectOtbVer boolean default is FALSE. If there is more than one OTB installation and \code{selectOtbVer} = TRUE the user can select interactively the preferred OTB version 
#'@param DL string hard drive letter default is \code{C:}
#'
#'@note It is strongly recommended to set the path manually. Using a osgeo4w installation it is typically \code{C:/OSGeo4W64/bin/}
#'@author CR
#'@return add otb pathes to the enviroment and creates global variables otbPath
#'@details if called without any parameter \code{initOTB()} it performs a full search over the hardrive \code{C:}. If it finds one or more OTB binaries it will take the first hit. You have to set \code{selectOtbVer = TRUE} for an interactive selection of the preferred version.
#'@export initOTB
#'  
#'@examples
#' \dontrun{
#' # call it for a default OSGeo4W installation of the OTB
#' initOTB("C:/OSGeo4W64/bin/")
#' 
#' # call it for a default Linux installation of the OTB
#' initOTB("/usr/bin/")
#'}

initOTB <- function(binPathOtb=NULL,
                    rootPathOtb= NULL, 
                    otbType=NULL,
                    DL="C:",
                    selectOtbVer=FALSE) {
  
  if (Sys.info()["sysname"] == "Linux") {
    # if no path is provided  we have to search
    
    otbParams <- system2("find", paste("/usr"," ! -readable -prune -o -type f -executable -iname 'otbcli' -print"),stdout = TRUE)
    binPathOtb <- substr(otbParams,1,nchar(otbParams) - 6) }
  makGlobalVar("otbPath", binPathOtb)
  
  # (R) set pathes  of OTB  binaries depending on OS WINDOWS
  if (is.null(binPathOtb)) {
    otbParams <- searchOSgeo4WOTB()
    # if just one valid installation was found take it
    if (nrow(otbParams) == 1) {  
      otbPath <- setOtbEnv(binPathOtb = otbParams$binDir[1],rootPathOtb = otbParams$baseDir[2])
      
      # if more than one valid installation was found you have to choose 
    } else if (nrow(otbParams) > 1 & selectOtbVer ) {
      cat("You have more than one valid OTB version\n")
      #print("installation folder: ",otbParams$baseDir,"\ninstallation type: ",otbParams$installationType,"\n")
      print(otbParams[1],right = FALSE,row.names = TRUE) 
      if (is.null(otbType)) {
        ver <- as.numeric(readline(prompt = "Please choose one:  "))
        otbPath <- setOTBEnv(path_otb = otbParams$binDir[[ver]], rootPathOtb = otbParams$baseDir[[ver]])
      } else {
        otbPath <- setOTBEnv(path_otb = otbParams[otbParams["installationType"] == otbType][1],rootPathOtb = otbParams[otbParams["installationType"] == otbType][2])
      }
    } else {
      otbPath <- setOTBEnv(path_otb = otbParams$binDir[[1]],rootPathOtb = otbParams$baseDir[[1]])
    }
    
    # if a setDefaultOTB was provided take this 
  } 
  return(otbPath)
}


