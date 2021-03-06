#' Tile \code{Raster*} object with or without overlap
#'
#' @description
#' Tile \code{Raster*} object using an optional overlap between the tiles.
#'
#' @param raster \code{Raster*}. Object that should be tiled.
#' @param tilenbr 'integer'. Vector given the number of tiles in c(x,y) direction.
#' @param overlap 'integer'. Overlap in pixels between the individual tiles. Default NULL does not include any overlap.
#' @param outpath 'character'. Top level path of the output files.
#' @param subpath 'character'. Path created within each tile path (e.g. for naming the product).
#'
#' @return
#' None. Tiles are written to GeoTiff files in directory \code{outpath}.
#'
#' @references
#' NONE
#'
#' @examples
#' \notrun{
#' tileRaster(raster = ndvi, tilenbr = c(5,4), overlap = 30, outpath = modis_tiles)
#' }
#'
#' @export tileRaster
#' @name tileRaster
#'
tileRaster <- function(raster, tilenbr = c(2, 2), overlap = 0, outpath = NULL, subpath = NULL){
  
  if(is.null(outpath)){
    outpath = paste0(getwd(),"/")
  }
  
  if(is(raster, "Raster")){
    raster = stack(raster)
  }
  
  ## Compute col/row positions for cutting the tiles
  rows = nrow(raster[[1]])
  cols = ncol(raster[[1]])
  nr = rows%/%tilenbr[2]
  nc = cols%/%tilenbr[1]
  tilenbrs = tilenbr[1] * tilenbr[2]
  
  tc = lapply(seq(0, tilenbr[1]-1), function(i){
    data.frame(tc = c(i*nc+1, (i+1)*nc))
  })
  tc[[tilenbr[1]]][2,] = cols
  
  tr = lapply(seq(0, tilenbr[2]-1), function(i){
    data.frame(tr = c(i*nr+1, (i+1)*nr))
  })
  tr[[tilenbr[2]]][2,] = rows
  
  tr_non_ovlp = tr
  tc_non_ovlp = tc
  
  tr_non_ovlp = lapply(tr_non_ovlp, function(atr){
    colnames(atr) = "tr_non_ovlp"
    return(atr)
  })
  
  tc_non_ovlp = lapply(tc_non_ovlp, function(atc){
    colnames(atc) = "tc_non_ovlp"
    return(atc)
  })
  
  
  ## Add overlap
  tc[[1]][2,] = tc[[1]][2,] + overlap
  if(length(tc) > 2){
    for(i in seq(2, length(tc)-1)){
      tc[[i]][1, ] = tc[[i]][1, ] - overlap
      tc[[i]][2, ] = tc[[i]][2, ] + overlap
    }
  }
  tc[[tilenbr[1]]][1,] = tc[[tilenbr[1]]][1,] - overlap
  
  tr[[1]][2,] = tr[[1]][2,] + overlap
  if(length(tr) > 2){
    for(i in seq(2, length(tr)-1)){
      tr[[i]][1, ] = tr[[i]][1, ] - overlap
      tr[[i]][2, ] = tr[[i]][2, ] + overlap
    }
  }
  tr[[tilenbr[2]]][1,] = tr[[tilenbr[2]]][1,] - overlap
  
  
  ## Create tile list
  tiles = lapply(seq(length(tr)), function(itr){
    lapply(seq(length(tc)), function(itc){
      data.frame(tr = tr[[itr]],
                 tc = tc[[itc]],
                 tr_non_ovlp = tr_non_ovlp[[itr]],
                 tc_non_ovlp = tc_non_ovlp[[itc]]
      )
    })
  })
  
  tiles = unlist(tiles, recursive=FALSE)
  
  for(r in seq(nlayers(raster))){
    rst = raster[[r]]
    for(t in seq(length(tiles))){
      tile = tiles[[t]]
      lzeros = nchar(as.character(max(unlist(tiles))))
      tilepath = paste0(outpath, "/c", 
                        sprintf(paste0("%0", lzeros, "d"), tile$tc[1]), 
                        "_", 
                        sprintf(paste0("%0", lzeros, "d"), tile$tc[2]), 
                        "_r", 
                        sprintf(paste0("%0", lzeros, "d"), tile$tr[1]), 
                        "_", 
                        sprintf(paste0("%0", lzeros, "d"), tile$tr[2]), "/")
      if (!dir.exists(tilepath))
        dir.create(tilepath)
      metafilename = paste0(tilepath, "/", basename(tilepath), ".txt")
      write.csv(tile, file = metafilename, row.names = FALSE)
      filename = paste0(names(rst), "_c", 
                        sprintf(paste0("%0", lzeros, "d"), tile$tc[1]), 
                        "_", 
                        sprintf(paste0("%0", lzeros, "d"), tile$tc[2]), 
                        "_r", 
                        sprintf(paste0("%0", lzeros, "d"), tile$tr[1]), 
                        "_", 
                        sprintf(paste0("%0", lzeros, "d"), tile$tr[2]))
      rst_tile = crop(rst, extent(rst, tile$tr[1], tile$tr[2], tile$tc[1], tile$tc[2]))
      
      if(!is.null(subpath)){
        tilepath = paste0(tilepath, "/", subpath, "/")
      }
      
      if(!dir.exists(tilepath))
        dir.create(tilepath, recursive = TRUE)
      
      writeRaster(rst_tile, format = "GTiff",
                  filename = paste0(tilepath, filename),  
                  bylayer = FALSE, overwrite = FALSE)
    }
    
  }
}
