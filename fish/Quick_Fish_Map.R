setwd("~/GitHub/piscivorous")
load("Fish/Fish_Data_For_Birds.rda")

#===============================================================================
#Provide year constraint on Fish Data

Fish_Data <- Fish_Data%>%filter(Year>2015)

#===============================================================================
#Delta Base Layers and Station Coordinates

EDSM_Strata <- st_read("spatial/EDSM_extended_west/EDSM_extended_west.shp")%>%
  mutate(SubRegion = recode(SubRegion, "Mid San Pablo extended west" = "Mid San Pablo Bay ext."))%>%
  select(-c(OBJECTID,OBJECTID_1,Shape_Leng,Shape_Area,OBJECTID_2,Shape_Le_1))


marsh <- st_read(
  "spatial/hydro-delta-marsh/hydro_delta_marsh.shp")

stations <- Fish_Data %>% filter(Year>2001)%>%
  mutate(SurveySeason=factor(Study,levels=c("SLS","20mm","STN","FMWT","SKT")))%>%
  distinct(across(c(Study,StationCode,Latitude,Longitude)),.keep_all = T)%>%
  group_by(StationCode)%>%
  mutate(N_Studies = length(unique(Study)))%>%
  st_as_sf( coords = c("Longitude", "Latitude"), 
            crs = st_crs(marsh), agr = "constant")

#Transform marsh and station layers to be consistent with EDSM polygons
marsh <- st_transform(marsh,crs=st_crs(EDSM_Strata))
stations <- st_transform(stations,st_crs(EDSM_Strata))

#Quick map of station locations
#Note that the far west point is a typo in an EDSM station longitude 
ggplot()+theme_bw()+
  geom_sf(data = marsh, size = .25, color = "cornflowerblue", fill = "lightcyan",alpha=.5) + 
  geom_sf(data =EDSM_Strata, fill=NA,size=1) + 
  geom_sf(data = stations, aes(color=SubRegion),size=2)






