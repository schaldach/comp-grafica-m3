# feita no link https://cds.climate.copernicus.eu/datasets/reanalysis-era5-pressure-levels-monthly-means?tab=download

# parâmetros para ser próximos do artigo (mas não necessariamente iguais...)

# import cdsapi
# dataset = "reanalysis-era5-pressure-levels-monthly-means"
# request = {
#     "product_type": [
#         "monthly_averaged_reanalysis",
#         "monthly_averaged_reanalysis_by_hour_of_day"
#     ],
#     "variable": ["specific_cloud_ice_water_content"],
#     "pressure_level": [
#         "1", "2", "3",
#         "5", "7", "10",
#         "20", "30", "50",
#         "70", "100", "125",
#         "150", "175", "200",
#         "225", "250", "300",
#         "350", "400", "450",
#         "500", "550", "600",
#         "650", "700", "750",
#         "775", "800", "825",
#         "850", "875", "900",
#         "925", "950", "975",
#         "1000"
#     ],
#     "year": ["2012"],
#     "month": ["10"],
#     "time": ["00:00", "12:00"],
#     "data_format": "netcdf",
#     "download_format": "zip"
# }
# client = cdsapi.Client()
# client.retrieve(dataset, request).download()

# ------------------------------------------------------------
##################> SETUP
# ------------------------------------------------------------

######> Bibliotecas gerais usadas
if(!require(pacman)) {
  install.packages("pacman", dependencies = TRUE);
}
library(pacman)
######> Instalando pacotes
p_load(terra, leaflet, leafem, htmltools, ggplot2)

######> Definindo área de estudo
lat_min <- -28
lat_max <- -26
lon_min <- -50
lon_max <- -47.5

######> Função para converter um "ext" das coordenadas -180:180 para 0:360
######> Para analisar os dados, é muito mais rápido converter o extent que buscamos
######> do que rotacionar o raster inteiro
unrotate_ext <- function(lon_min, lon_max, lat_min, lat_max){
  new_ext <- ext((lon_min+360) %% 360, (lon_max+360) %% 360, lat_min, lat_max)
  new_ext
}

# ------------------------------------------------------------
##################> EXPLORANDO OS DADOS
# ------------------------------------------------------------

raster_1 <- terra::rast("b76a503a037434307704899d88dc158f/data_stream-mnth_stepType-avgua.nc")
print(head(names(raster_1))) # nome das layers
print(head(time(raster_1))) # data das layers
print(ext(raster_1)) # extensão dos dados
print(res(raster_1)) # resolução dos dados
print(nlyr(raster_1)) # número de layers
print(crs(raster_1))  # sistema de referência de coordenadas
print(varnames(raster_1)) # nome das variáveis
print(longnames(raster_1)) # nome longo das variáveis

raster_1_r <- rotate(raster_1[[1:2]])

######> Plotando com terra
terra::plot(raster_1[[20]], main="Unrotated Specific cloud ice water content") 
terra::plot(raster_1_r[[20]], main="Rotated Specific cloud ice water content")
