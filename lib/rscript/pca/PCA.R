#pca script for moyashi
read_Moyashi <- function(path){
  raw_data <- read.table(path,header=TRUE,sep="\t", skip=1)
  return (list(raw_data[3:19894, colnames(raw_data) != "m.z"],as.character(raw_data$m.z[3:19894])))
}
scale_by_max <- function(data){
  n <- length(data)
  scaled_data <- data
  
  for (i in 1:n){
    scaled_data[i] <- data[i] / max(data[i])　*100
  }
  
  scaled_data
  
}
calibrate_by_median <- function(data){
  n <- length(data)
  calibrated_data <- data
  
  
  
  for (i in 1:n){
    calibrated_data[i] <- data[i] / median(unlist(data[i]))
    
  }
  as.data.frame(calibrated_data)
}
transpose_and_framelize <- function(data){
  a <- as.data.frame(t(data))
  
  
}
compress_data <- function(data){
  
  #bin width 0.1 to 1.0
  
  #未完成
  n <- length()
  start_index <- 4  #start from m/z 10.4
  end_index <- 19894 #end at m/z 1999.5
  
  for (i in 1:n){
    for (j in 1:1989){
      
    }
    
    
  }
}
compute_RSD <- function(data){
  RSD <- apply(data,2,sd) / apply(data, 2,mean) * 100
}
data_preprocessing <- function(path){
  data <- read_Moyashi(path)[[1]]
  data <- scale_by_max(data)
  data <- calibrate_by_median(data)
  data <- transpose_and_framelize(data)
}

args <- commandArgs(TRUE)
data1 <- 'data1.txt'
data2 <- 'data2.txt'



raw_data <- data_preprocessing(data1)


my_pca <- function(raw_data,mzMin=700,mzMax=1000, is_scaled=TRUE){

##execute pca using "prcomp" function with the data scaled
is_scaled <- TRUE
pca <- prcomp(raw_data, scale = is_scaled)
pc_summary <- summary(pca)

##set variables
sdev = pca$sdev
loading <- as.data.frame(pca$rotation) * pca$sdev
#loading["PC1"] <- loading$PC1 / sd(samples$X1) 
PC <- as.data.frame(pca$x) #dataframe made of all principal components
PC1 <- PC$PC1
PC2 <- PC$PC2
PC3 <- PC$PC3

PC1_2 <- PC[c("PC1","PC2")] #PC1 vs PC2
PC1_3 <- PC[c("PC1","PC3")] #PC1 vs PC3
PC2_3 <- PC[c("PC2","PC3")] #PC2 vs PC3


##plotting PC plot;


pdf('PC1_2.pdf')
plot(PC1_2, xlab=sprintf("PC1 (%.1f %s)", pc_summary$importance[2,1]*100,"%" ),ylab=sprintf("PC2 (%.1f %s) ", pc_summary$importance[2,2]*100,"%"))
title(main='PCA plot: PC1 vs PC2')
text(PC1_2[[1]],PC1_2[[2]],pos=3,cex=0.5)
#dev.off()


pdf('PC1_3.pdf')
plot(PC1_3, xlab=sprintf("PC1 (%.1f %s)", pc_summary$importance[2,1]*100,"%" ),ylab=sprintf("PC3 (%.1f %s) ", pc_summary$importance[2,3]*100,"%"))
title(main='PCA plot: PC1 vs PC3')
text(PC1_3[[1]],PC1_3[[2]],pos=3,cex=0.5)
#dev.off()


pdf('PC2_3.pdf')
plot(PC2_3,xlab=sprintf("PC2 (%.1f %s) ", pc_summary$importance[2,2]*100,"%"),ylab=sprintf("PC3 (%.1f %s) ", pc_summary$importance[2,3]*100,"%"))
title(main='PCA: plot: PC2 vs PC3')
text(PC2_3[[1]],PC2_3[[2]],pos=3,cex=0.5)
#dev.off()

##plot loading plot of PC1 ;
#svg(filename='loading.svg')
#cairo_ps('loading.svg',width=1500, height=500)
#cairo_ps("loading.ps",width=1500, height=500)
name <- c("10","500","1000","1500","2000")
png(filename='loading.png',width=1500, height=500)
#cairo_ps('loading.ps',width=1500, height=500)
par(oma = c(0, 0, 0, 2)) # 二つ目の y 軸を描くために余白を調整
plot(colMeans(raw_data, na.rm = FALSE, dims = 1),type='l',axes=FALSE,xaxt="n", ylim=c(0,100),xlab = "",ylab="",col="brown") #plot a averaged spectrum
title(main="Loading plot of PC1")
axis(side=1,at=c(100,5000,10000,15000,20000),labels=name)
#axis(1)
#axis(2)
axis(4)
par(new=T)
plot(loading$PC1,type='l',main='Loading plot of PC1' ,xaxt="n",xlab="",ylab="Factor loading",col="blue") #plot factor loading of PC1
legend("topright",legend=c("Factor Loading","Averaged intensity"),lty=c(1,1),fill=c("blue","brown"),col=c("blue","brown"), bg="gray90")
mtext("m/z", side = 1,line = 3,family="Times-Italic", cex=1.5)
#mtext("m/z", side = 1,line = 3, cex=1.5)
mtext("Averaged intensity", side=4, line=3)
#graphics.off()




##plotting scree plot
#svg(filename='scree_plot.svg')
#png(filename='proportion.png')
pdf('scree_plot.pdf')
plot(pc_summary$sdev**2,type='b', main='Scree plot', xlab="Component number",ylab="Eigenvalue",col="dark green")
#dev.off()

##plotting proportion of variance
#svg(filename='proportion.svg')
pdf('proportion.pdf')
plot(pc_summary$importance[2,]*100,type='b',ylim=range(0,100), main='Proportion', xlab="Component number",ylab="Propotion(%)",col="dark red")
par(new=T)
plot(pc_summary$importance[3,]*100,ylim=range(0,100),type='b',col="purple",xlab='',ylab='')
#dev.off()

##plotting cummulative proportion
#svg('cumulative_proportion.svg')
#png('cumulative_proportion.png')
pdf('cumulative_proportion.pdf')
plot(pc_summary$importance[3,]*100,type='b',ylim=range(0,100),main='Cumulutive Proportion',xlab="i th principal component",ylab="Propotion(%)",col="purple")
graphics.off()
}



my_pca(raw_data)