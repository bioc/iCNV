#' Plot relationship between platforms and features for each individual.
#' @param r1L A list of NGS intensity data. Each entry is an individual. If no NGS data, no need to specify.
#' @param r2L A list of SNP array intensity data. Each entry is an individual. If no SNP array data, no need to specify.
#' @param baf1 A list of NGS BAF data. Each entry is an individual. If no NGS data, no need to specify.
#' @param baf2 A list of SNP array BAF data. Each entry is an individual. If no SNP array data, no need to specify.
#' @param rpos1 A list of NGS intensity postion data. Each entry is an individual with dimension= (#of bins or exons, 2(start and end position)). If no NGS data, no need to specify.
#' @param rpos2 A list of SNP array intensity postion data. Each entry is an individual with length=#of SNPs. If no SNP array data, no need to specify.
#' @param bpos1 A list of NGS BAF postion data. Each entry is an individual with length=#of BAFs. If no NGS data, no need to specify.
#' @param bpos2 A list of SNP array BAF postion data. Each entry is an individual with length=#of BAFs. If no SNP array data, no need to specify.
#' @param hmmcalls CNV inference result. First entry of the output from iCNV_detection()
#' @param I Indicating the position of the individual to plot
#' @param h start position of this plot. Default Start of the whole chromosome
#' @param t end position of this plot. Default End of the whole chromosome
#' @return void
#' @examples
#' pdf(file=paste0(projname,'.pdf'),width=13,height = 10)
#' plotindi(r1L,r2L,baf1,baf2,rpos1,rpos2,bpos1,bpos2,hmmcalls,I,h=100000, t=200000)
#' dev.off()
#' @export
plotindi = function(r1L,r2L,baf1,baf2,rpos1,rpos2,bpos1,bpos2,hmmcalls,I,h=min(hmmcalls[[1]][[2]]),t=max(hmmcalls[[1]][[2]])){
  r1i=r1L[[I]]
  r2i=r2L[[I]]
  baf1i=baf1[[I]]
  baf2i=baf2[[I]]
  rpos1i=rpos1[[I]]
  rpos2i=rpos2[[I]]
  bpos1i=bpos1[[I]]
  bpos2i=bpos2[[I]]
  res=hmmcalls[[I]]
  result=res[[1]]
  Lposi=res[[2]]
  rt=res[[3]]
  mu=res[[4]]
  sigma=res[[5]]
  score=res[[7]]

  sel=which(h<=Lposi[,1] & Lposi[,2]<=t)
  result=result[sel]
  score=score[sel]
  Lposi=Lposi[sel,]
  sel=which(h<=rpos1i[,1]&rpos1i[,2]<=t)
  r1i=r1i[sel]
  rpos1i=rpos1i[sel,]
  sel=which(h<=rpos2i & rpos2i<=t)
  r2i=r2i[sel]
  rpos2i=rpos2i[sel]
  sel=which(h<=bpos1i & bpos1i<=t)
  baf1i=baf1i[sel]
  bpos1i=bpos1i[sel]
  sel=which(h<=bpos2i & bpos2i<=t)
  baf2i=baf2i[sel]
  bpos2i=bpos2i[sel]
  b=1000
  ttlpos=seq(h-b/2,t+b/2,by=b)
  n=length(ttlpos)
  # row: z1, baf1, z2, baf2, score
  mat=matrix(NA,ncol=n-1,nrow=5)
  for (i in 1:(n-1)){
    sel=which(rpos2i>=ttlpos[i] & rpos2i<=ttlpos[i+1])
    if (length(sel)>0){
      mat[3,i]=mean(r2i[sel],na.rm=T)
    }
    sel=which(bpos1i>=ttlpos[i] & bpos1i<=ttlpos[i+1])
    if (length(sel)>0){
      mat[2,i]=mean(baf1i[sel],na.rm=T)
    }
    sel=which(bpos2i>=ttlpos[i] & bpos2i<=ttlpos[i+1])
    if (length(sel)>0){
      mat[4,i]=mean(baf2i[sel],na.rm=T)
    }
  }
  for (i in 1:length(r1i)){
    sel=which(ttlpos>=rpos1i[i,1] & ttlpos<=rpos1i[i,2])
    if (length(sel)>0){
      if (all(sel==1)){
        mat[1,sel]=r1i[i]
        if (is.na(mat[2,sel])){mat[2,sel]=1}
      }
      else{
        mat[1,sel-1]=r1i[i]
        for(j in 1:length(sel)){
          if (is.na(mat[2,sel[j]-1])){
            mat[2,sel[j]-1]=1
          }
        }
      }
    }
    else{
      sel=max(which(ttlpos<=rpos1i[i,1]))
      # cat(sel)
      if (!is.infinite(sel)){
        mat[1,sel]=r1i[i]
        if (is.na(mat[2,sel])){
          mat[2,sel]=1
        }
      }
    }
  }
  for (i in 1:length(score)){
    a=Lposi[i,1]
    b=Lposi[i,2]
    if(a==b){
      sel=which(ttlpos<=a)
      mat[5,max(sel)]=score[i]
    }
    else {
      sel=which(ttlpos>=a & ttlpos<=b)
      if (length(sel>0)){
        mat[5,sel-1]=score[i]
      }
      else{
        sel=which(ttlpos<=a)
        mat[5,max(sel)]=score[i]
      }
    }
  }

  sel=which(!is.na(mat[5,]))
  mat=mat[,sel]
  ttlpos=ttlpos[sel]
  n2=ncol(mat)
  rmax=max(abs(mat[c(1,3),]),na.rm=T)
  smax=max(abs(mat[5,]),na.rm=T)
  r1max=max(abs(mat[1,]),na.rm=T)
  r2max=max(abs(mat[3,]),na.rm=T)
  x=1:n2
  par(mfrow=c(1,1))
  l=3
  image.plot((as.matrix((pmin(pmax(mat[5,],-l),l)))),zlim=c(-l,l),axes=F,main='score',ylab=I)
  del = which(result<2)
  dup = which(result>2)
  cat(I,' del:',length(del),' dup:',length(dup),'\n')
  sel=unique(unlist(mapply(function(x,y,pos){which(x<=pos & y>=pos)},Lposi[del,1],Lposi[del,2],MoreArgs = list(pos=ttlpos),SIMPLIFY = F)))-1
  points(x=sel/length(ttlpos),y=rep(0,length(sel)),col='white',pch=20,cex=1)
  sel=unique(unlist(mapply(function(x,y,pos){which(x<=pos & y>=pos)},Lposi[dup,1],Lposi[dup,2],MoreArgs = list(pos=ttlpos),SIMPLIFY = F)))-1
  points(x=sel/length(ttlpos),y=rep(0,length(sel)),col='black',pch=20,cex=1)
  sel=unique(unlist(mapply(function(x,y,pos){which(x==y & abs(x-pos)<1000)},Lposi[del,1],Lposi[del,2],MoreArgs = list(pos=ttlpos),SIMPLIFY = F)))-1
  points(x=sel/length(ttlpos),y=rep(0,length(sel)),col='white',pch=20,cex=1)
  sel=unique(unlist(mapply(function(x,y,pos){which(x==y & abs(x-pos)<1000)},Lposi[dup,1],Lposi[dup,2],MoreArgs = list(pos=ttlpos),SIMPLIFY = F)))-1
  points(x=sel/length(ttlpos),y=rep(0,length(sel)),col='black',pch=20,cex=1)
  legend("topright",c("del", "dup"),
    col = c('white','black'),bg='green2',text.col = c('white','black'), pch = c(20,20),cex = 0.75)

  par(xaxs='i')
  plot(x,y=mat[5,],pch=20,xlab="",type='l', axes=F,col='green',ylab="",ylim=c(-smax,smax),xlim=c(0,n2),lwd=2)
  par(new=T,xaxs='i')
  plot(x,y=mat[1,],pch=20,col='grey',cex=0.5,xlab="", ylab=I,ylim=c(-r1max,r1max),xlim=c(0,n2),main='Sequencing')
  par(new=T,xaxs='i')
  plot(x,y=mat[2,],pch=20,cex=0.5,axes=FALSE,xlab="", ylab="",ylim=c(0,1),xlim=c(0,n2))
  axis(side = 4)
  legend("topright",c("intensity", "BAF","score"),
    col = c('grey','black','green'), pch = c(20,20,20),cex = 0.75)

  par(xaxs='i')
  plot(x,y=mat[5,],pch=20,xlab="",type='l', axes=F,col='green',ylab="",ylim=c(-smax,smax),xlim=c(0,n2),lwd=2)
  par(new=T,xaxs='i')
  plot(x,y=mat[3,],pch=20,col='grey',cex=0.5,xlab="",ylab=I,ylim=c(-r2max,r2max),xlim=c(0,n2),main='SNP')
  par(new=T,xaxs='i')
  plot(x,y=mat[4,],pch=20,cex=0.5,axes=FALSE,xlab="", ylab="",ylim=c(0,1),xlim=c(0,n2))
  axis(side = 4)
  legend("topright",c("intensity", "BAF","score"),
    col = c('grey','black','green'), pch = c(20,20,20),cex = 0.75)
  par(mfrow=c(1,1))
}
