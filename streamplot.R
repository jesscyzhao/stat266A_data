streamplot <- function(x, y, order.method = "as.is", frac.rand=0.1, spar=0.2, center=TRUE, ylab="", xlab="", border = NULL, lwd=1, col=rainbow(length(y[1,])), ylim=NULL, ...){
  if(sum(y < 0) > 0) error("y cannot contain negative numbers")
  if(is.null(border)) border <- par("fg")
  border <- as.vector(matrix(border, nrow=ncol(y), ncol=1))
  col <- as.vector(matrix(col, nrow=ncol(y), ncol=1))
  lwd <- as.vector(matrix(lwd, nrow=ncol(y), ncol=1))
  if(order.method == "max") {
    ord <- order(apply(y, 2, which.max))
    y <- y[, ord]
    col <- col[ord]
    border <- border[ord]
  }
  if(order.method == "min") {
    ord <- order(apply(y, 2, which.min))
    y <- y[, ord]
    col <- col[ord]
    border <- border[ord]
  }
  if(order.method == "first") {
    ord <- order(apply(y, 2, function(x) min(which(r>0))))
    y <- y[, ord]
    col <- col[ord]
    border <- border[ord]
  }
  bottom.old <- x*0
  top.old <- x*0
  polys <- vector(mode="list", ncol(y))
  for(i in seq(polys)){
    if(i %% 2 == 1){ #if odd
      top.new <- top.old + y[,i]
      polys[[i]] <- list(x=c(x, rev(x)), y=c(top.old, rev(top.new)))
      top.old <- top.new
    }
    if(i %% 2 == 0){ #if even
      bottom.new <- bottom.old - y[,i]
      polys[[i]] <- list(x=c(x, rev(x)), y=c(bottom.old, rev(bottom.new)))
      bottom.old <- bottom.new
    }
  }
  ylim.tmp <- range(sapply(polys, function(x) range(x$y, na.rm=TRUE)), na.rm=TRUE)
  outer.lims <- sapply(polys, function(r) rev(r$y[(length(r$y)/2+1):length(r$y)]))
  mid <- apply(outer.lims, 1, function(r) mean(c(max(r, na.rm=TRUE), min(r, na.rm=TRUE)), na.rm=TRUE))
  #center and wiggle
  if(center) {
    g0 <- -mid + runif(length(x), min=frac.rand*ylim.tmp[1], max=frac.rand*ylim.tmp[2])
  } else {
    g0 <- runif(length(x), min=frac.rand*ylim.tmp[1], max=frac.rand*ylim.tmp[2])
  }
  fit <- smooth.spline(g0 ~ x, spar=spar)
  for(i in seq(polys)){
    polys[[i]]$y <- polys[[i]]$y + c(fit$y, rev(fit$y))
  }
  if(is.null(ylim)) ylim <- range(sapply(polys, function(x) range(x$y, na.rm=TRUE)), na.rm=TRUE)
  plot(x,y[,1], ylab=ylab, xlab=xlab, ylim=ylim, t="n", ...)
  for(i in seq(polys)){
    polygon(polys[[i]], border=border[i], col=col[i], lwd=lwd[i])
  }
}
