
library(viridis)
library(ggplot2)
library(dplyr)
library(lemon)
############################################################################
###Creating an incidence map based on population density of Pennslyvania####
############################################################################
##########################################
###THIS IS FOR FIGURE 3 of the manucsript#
##########################################

#The five major tick species: scapularis, cookei, americanum, sangineus, and variabilis
FIVE_TICK_SPECIES <- subset(PA_SUB, PA_SUB$Species == 'scapularis' |
                              PA_SUB$Species == 'cookei'|
                              PA_SUB$Species == 'sanguineus'|
                              PA_SUB$Species == 'variabilis'|
                              PA_SUB$Species == 'americanum')
AGG_FIVE<-aggregate(FIVE_TICK_SPECIES$Individuals,
                    by=list(FIVE_TICK_SPECIES$Year,FIVE_TICK_SPECIES$Species),
                    'sum')
###You need the population data and the
###This reads in the PA population in 2010


PA_POP_2010 <- read.csv("pa_pop_2010.csv") #GET THIS FROMT HE PA_POP_DAT DIRECTORY
PA_POP_2010$Total.Pop<- as.numeric(gsub(',', '', PA_POP_2010$Total.Pop))
###County Populuation Data
PA_POP_2010$County <- tolower(PA_POP_2010$County)
###County Spatial Information
counties <- map_data("county")
pa_county <- subset(counties, region == 'pennsylvania')
colnames(pa_county)[6] <- 'County'

#######################
###I. Scapularis###
################
SCAP_DATA <- subset(FIVE_TICK_SPECIES, FIVE_TICK_SPECIES$Species=='scapularis')

SCAP_DATA_AGG <- aggregate(SCAP_DATA$Individuals, by=list(SCAP_DATA$County),'sum')

###GETS RID OF ANY DATA THAT HAS NO RECORD. 
SCAP_DATA_AGG <- subset(SCAP_DATA_AGG,SCAP_DATA_AGG$Group.1 != ""&
                          SCAP_DATA_AGG$Group.1 != 'no record ')
                          
#now let's rename the data frame
colnames(SCAP_DATA_AGG) <- c("County","Individuals")

pa_county_scap <-left_join(PA_POP_2010, SCAP_DATA_AGG, by=c('County'))
pa_county_scap$Individuals[is.na(pa_county_scap$Individuals)==TRUE]=0

pa_county_scap$incidence <- 
  (pa_county_scap$Individuals/pa_county_scap$Total.Pop)*100000

pa_county_scap$CUT_SCAP<-cut(pa_county_scap$incidence, 
                             breaks=  c(0,1,10,40,100,200,500,1000),
                             include.lowest = TRUE,dig.lab=10)

PA_SCAP_SPAT <- left_join(pa_county, pa_county_scap,by=c('County'))

SCAP_INCIDENCE<-ggplot(PA_SCAP_SPAT, aes(x= long, y= lat,group=group))+
  geom_polygon(data=PA_SCAP_SPAT,   aes(long+0.05,lat-0.05), fill="grey50")+
  geom_polygon(data=PA_SCAP_SPAT,
               aes(x= long, y= lat,group=group, fill =CUT_SCAP),color='black')+
  scale_fill_viridis(discrete=TRUE,option='magma',alpha=1,
                     name = 'Incidence\nper 100,000')+
  coord_map()+
  ggtitle("Ixodes scapularis") + 
  theme_void()+
  theme(plot.title = element_text(hjust = 0.5,lineheight=.8, face="bold.italic",
                                  size=15))
pa_county_scapincidence <- cbind.data.frame(County = pa_county_scap$County, 
                                            Incidence = pa_county_scap$incidence)
pa_county_scapincidence[order(-pa_county_scapincidence$Incidence),]
################
###Variabilis###
################


VAR_DATA <- subset(FIVE_TICK_SPECIES, FIVE_TICK_SPECIES$Species=='variabilis')

VAR_DATA_AGG <- aggregate(VAR_DATA$Individuals, 
                          by=list(VAR_DATA$County),'sum')

#The first row was unknown locaton

VAR_DATA_AGG<- subset(VAR_DATA_AGG,VAR_DATA_AGG$Group.1 != ""&
                        VAR_DATA_AGG$Group.1 != 'no record ')

colnames(VAR_DATA_AGG) <- c("County","Individuals")

pa_county_var <-left_join(PA_POP_2010,VAR_DATA_AGG, by=c('County'))
pa_county_var$Individuals[is.na(pa_county_var$Individuals)==TRUE]=0

pa_county_var$incidence <- 
  (pa_county_var$Individuals/pa_county_var$Total.Pop)*100000

pa_county_var$CUT_VAR<-cut(pa_county_var$incidence, 
                           breaks=  c(0,1,10,40,100,200,500,1000),
                           include.lowest = TRUE,dig.lab=10)

PA_VAR_SPAT <- left_join(pa_county, pa_county_var,by=c('County'))

VAR_INCIDENCE<-ggplot(PA_VAR_SPAT, aes(x= long, y= lat,group=group))+
  geom_polygon(data = PA_VAR_SPAT,  aes(long+0.05,lat-0.05), fill="grey50")+
  geom_polygon(data= PA_VAR_SPAT,aes(x= long, y= lat,group=group, fill =CUT_VAR),color = 'black')+
  scale_fill_viridis(discrete=TRUE,option='magma',alpha=0.9,
                     name = 'Incidence\nper 100,000')+
  coord_map()+
  ggtitle("Dermacentor variabilis") + 
  theme_void()+
  theme(plot.title = element_text(hjust = 0.5,lineheight=.8, face="bold.italic",
                                  size=15))
VAR_INCIDENCE

pa_county_varincidence <- cbind.data.frame(County = pa_county_var$County, 
                                            Incidence = pa_county_var$incidence)
pa_county_varincidence [order(-pa_county_varincidence $Incidence),]
################
###Cookei ###
################


COOK_DATA <- subset(FIVE_TICK_SPECIES,
                    FIVE_TICK_SPECIES$Species=='cookei')

COOK_DATA_AGG <- aggregate(COOK_DATA$Individuals, 
                           by=list(COOK_DATA$County),'sum')

#The first row was unknown locaton

COOK_DATA_AGG<- subset(COOK_DATA_AGG,COOK_DATA_AGG$Group.1 != ""&
                         COOK_DATA_AGG$Group.1 != 'no record ')
colnames(COOK_DATA_AGG) <- c("County","Individuals")

pa_county_cook<-left_join(PA_POP_2010,COOK_DATA_AGG, by=c('County'))
pa_county_cook$Individuals[is.na(pa_county_cook$Individuals)==TRUE]=0

pa_county_cook$incidence <- 
  (pa_county_cook$Individuals/pa_county_cook$Total.Pop)*100000

pa_county_cook$CUT_COOK<-cut(pa_county_cook$incidence, 
                             breaks=  c(0,1,10,40,100,200,500,1000),
                             include.lowest = TRUE,dig.lab=10
)

PA_COOK_SPAT <- left_join(pa_county, pa_county_cook,by=c('County'))

COOK_INCIDENCE<-ggplot(PA_COOK_SPAT, aes(x= long, y= lat,group=group))+
  geom_polygon(data=PA_COOK_SPAT,aes(long+0.05,lat-0.05), fill="grey50")+
  geom_polygon(data=PA_COOK_SPAT, aes(x= long, y= lat,group=group,
                                      fill =CUT_COOK),color='black')+
  scale_fill_viridis(discrete=TRUE,option='magma',alpha=0.9,
                     name = 'Incidence\nper 100,000',drop=FALSE)+coord_map()+
  ggtitle("Ixodes cookei") + theme_void()+
  theme(plot.title = 
          element_text(hjust = 0.5,lineheight=.8, face="bold.italic",
                       size=15))
COOK_INCIDENCE

pa_county_cookincidence <- cbind.data.frame(County = pa_county_cook$County, 
                                           Incidence = pa_county_cook$incidence)
pa_county_cookincidence [order(-pa_county_cookincidence $Incidence),]
################
###AMERICANUM###
################


AMERI_DATA <- subset(FIVE_TICK_SPECIES,
                     FIVE_TICK_SPECIES$Species=='americanum')

AMERI_DATA_AGG <- aggregate(AMERI_DATA$Individuals, 
                            by=list(AMERI_DATA$County),'sum')

#The first row was unknown locaton

AMERI_DATA_AGG<- subset(AMERI_DATA_AGG,AMERI_DATA_AGG$Group.1 != ""&
                          AMERI_DATA_AGG$Group.1 != 'no record')
colnames(AMERI_DATA_AGG) <- c("County","Individuals")

pa_county_ameri<-left_join(PA_POP_2010,AMERI_DATA_AGG, by=c('County'))
pa_county_ameri$Individuals[is.na(pa_county_ameri$Individuals)==TRUE]=0

pa_county_ameri$incidence <- 
  (pa_county_ameri$Individuals/pa_county_ameri$Total.Pop)*100000

pa_county_ameri$CUT_AMERI<-cut(pa_county_ameri$incidence, 
                               breaks=  c(0,1,10,40,100,200,500,1000),
                               include.lowest = TRUE,dig.lab=10)

PA_AMERI_SPAT <- left_join(pa_county, pa_county_ameri,by=c('County'))

AMERI_INCIDENCE<-ggplot(PA_AMERI_SPAT, aes(x= long, y= lat,group=group))+
  geom_polygon(data = PA_AMERI_SPAT, aes(long+0.05,lat-0.05), fill="grey50")+
  geom_polygon(data = PA_AMERI_SPAT, aes( x= long, y= lat,group=group, fill =CUT_AMERI),color='black')+
  scale_fill_viridis(discrete=TRUE,option='magma',alpha=0.9,
                     name = 'Incidence\nper 100,000',drop=FALSE)+coord_map()+
  ggtitle("Amblyomma americanum") + theme_void()+
  theme(plot.title = 
          element_text(hjust = 0.5,lineheight=.8, face="bold.italic",
                       size=15))
AMERI_INCIDENCE



################
###SANGUINEUS###
################


SANG_DATA <- subset(FIVE_TICK_SPECIES,
                    FIVE_TICK_SPECIES$Species=='sanguineus')

SANG_DATA_AGG <- aggregate(SANG_DATA$submission, 
                           by=list(SANG_DATA$County),'sum')

#The first row was unknown locaton

colnames(SANG_DATA_AGG) <- c("County","Submission")

pa_county_sang<-left_join(PA_POP_2010,SANG_DATA_AGG, by=c('County'))
pa_county_sang$Submission[is.na(pa_county_sang$Submission)==TRUE]=0

pa_county_sang$incidence <- 
  (pa_county_sang$Submission/pa_county_sang$Total.Pop)*100000

pa_county_sang$CUT_SANG<-cut(pa_county_sang$incidence, 
                             breaks=  c(0,1,10,40,100,200,500,1000),
                             include.lowest = TRUE,dig.lab=10)

PA_SANG_SPAT <-  left_join(pa_county, pa_county_sang,by=c('County'))

SANG_INCIDENCE<-ggplot(PA_SANG_SPAT, aes(x= long, y= lat,group=group))+
  geom_polygon(aes(long+0.05,lat-0.05), fill="grey50")+
  
  geom_polygon(aes( x= long, y= lat,group=group,fill =CUT_SANG),color='black')+
  scale_fill_viridis(discrete=TRUE,option='magma',alpha=0.9,
                     name = 'Incidence\nper 100,000',drop=FALSE)+coord_map()+
  ggtitle("Rhipicephalus sanguineus") + theme_void()+
  theme(plot.title = 
          element_text(hjust = 0.5,lineheight=.8, face="bold.italic",
                       size=15))
SANG_INCIDENCE

grid_arrange_shared_legend(SCAP_INCIDENCE, COOK_INCIDENCE,VAR_INCIDENCE, 
                           AMERI_INCIDENCE, SANG_INCIDENCE,ncol=2,nrow=3)
