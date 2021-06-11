# Thu Apr 01 19:49:36 2021 ------------------------------
## ---------------------------
##
## Script name: b15_FUNCTIONS_get_troughs.R
##(modified b12 of same name)
## Purpose of script:
##
##
## Date Created: 2021-04-01
## ---------------------------

# -- -- -- -- -- 
# COLORS ####
# -- -- -- -- --

ver4="#a50f15"
ver3="#cd1319"
ver2="#ea1f26"
ver1="#f16a6e"

roxo="#984ea3"
azul="#2e96dc"
verde="#66a61e"
rosa="#e7298a"

# -- -- -- -- -- 
# FUNCTIONS ####
# -- -- -- -- --

calc_troughs = function(df, cur_gen, lvl, cur_rep){
  
  # dat=df[df$gen == cur_gen & df$mean_pi_raw <= ini_div*lvl,]
  # dat=df[((df$gen == cur_gen) & (df$rep == cur_rep) & (df$mean_pi_raw <= ini_div*lvl)),]
  dat=df[((df$gen == cur_gen) & (df$rep == cur_rep) & (df$mean_pi_samp <= ini_div*lvl)),]
  
  if (nrow(dat)>0){
    i=1
    j=1
    
    while (i <= nrow(dat)) {
      a=i
      while ((dat$mid_win[i+1] - dat$mid_win[i]) <= 150000 & (i+1 <= nrow(dat))) {
        i=i+1
      }
      b=i
      for (k in a:b){
        dat$t_id[k]=j
      }
      
      j=j+1
      i=i+1
    }
    
    return(dat)
  } else {return(NA)}
  
}

# cur_gen=25001
# cur_rep=smp_rep
# dt=as.data.frame(df)
# color_trughs=T
# lvl=.1
# yli=1.5e-4
plot_graph_per_gen_complete = function(cur_gen, cur_rep, dt, color_troughs=NULL, lvl=NULL, yli=NULL) {
  
  if(is.null(yli)){
    yli=ini_div
  }
  
  dat=dt[((dt$gen == cur_gen) & (dt$rep == cur_rep)),]
  # dat=df[((df$gen == cur_gen) & (df$rep == cur_rep)),]
  
  if (!is.null(color_troughs)) {
    if(is.null(lvl)){
      lvl=0.1
    }
    tr_dat = calc_troughs(dt, cur_gen, lvl, cur_rep)
    
  }
  
  
  
  plot(dat$mid_win, dat$mean_pi_raw, type = "l", col="black", ylim = c(0, yli), main = sprintf("gen: %s; rep: %s;", cur_gen, cur_rep), xlab = "POS", ylab = "Mean Pi")
  abline(h=mean(dat$mean_pi_raw), col="blue")
  text(x=(102e6), y=(mean(dat$mean_pi_raw)+2.5e-6), labels = sprintf("%s%%", format((mean(dat$mean_pi_raw)*100/ini_div), scientific = F, digits = 3)), col="blue", cex = 0.8)
  abline(h=ini_div, col=ver1, lty="dashed", lwd=0.5)
  abline(h=(ini_div*0.5), col=ver2, lty="dashed", lwd=1)
  abline(h=ini_div*.25, col=ver3, lty="dashed", lwd=1.5)
  abline(h=ini_div*.10, col=ver4, lty="dashed", lwd=2)
  text(x = 0, adj = 1, y=(ini_div)+0.000005, labels = "100%", cex=0.8, col=ver1, font = 2)
  text(x = 0, adj = 1, y=(ini_div*.5)+0.000005, labels = "50%", cex=0.8, col=ver2, font = 2)
  text(x = 0, adj = 1, y=(ini_div*.25)+0.000005, labels = "25%", cex=0.8, col=ver3, font = 2)
  text(x = 0, adj = 1, y=(ini_div*.10)+0.000005, labels = "10%", cex=0.8, col=ver4, font = 2)
  
  
  if (!is.null(nrow(tr_dat))){
    cores=c(roxo, azul, verde, rosa)
    as_cor=rep(cores, (length(unique(tr_dat$t_id))/length(cores))+1)
    for (t in unique(tr_dat$t_id)){
      aff=tr_dat[tr_dat$t_id==t,]
      lines(aff$mid_win, aff$mean_pi_raw, col=as_cor[t], lwd=1.5)
      abline(v=mean(aff$mid_win), col=as_cor[t], lty="dashed")
      text(10e7, 0, labels = sprintf("nt: %s", length(unique(tr_dat$t_id))), cex=0.8)
      
    }
  }
  
  points(x=dat$mid_win[dat$mean_pi_raw == 0], y=dat$mean_pi_raw[dat$mean_pi_raw == 0], col=scales::alpha("gray0", 0.99), pch=42, cex=1)
  
}



get_summary_of_troughs = function (df, cur_gen, lvl, cur_rep){
  tr_dat=calc_troughs(df, cur_gen, lvl, cur_rep)
  if (is.null(nrow(tr_dat))){
    return(NA)
  } else {
    tmp= ddply(tr_dat, .(t_id, cpop, rep, gen), summarise, n_windows=length(t_id), mp_raw=mean(mean_pi_raw), mp_samp=mean(mean_pi_samp), ini=min(ini), end=max(end), mid_tr=mean(mid_win))
    tmp$size=tmp$end-tmp$ini
    tmp$tot_tr=nrow(tmp)
    
    return(tmp)
  }
}


summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
  library(plyr)
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm),
                     median = median(xx[[col]], na.rm=na.rm),
                     qt2 = quantile(xx[[col]], na.rm=na.rm)[2],
                     qt3 = quantile(xx[[col]], na.rm=na.rm)[3],
                     qt4 = quantile(xx[[col]], na.rm=na.rm)[4],
                     qt1 = quantile(xx[[col]], probs = 0.025, na.rm=na.rm),
                     qt5 = quantile(xx[[col]], probs = 0.975, na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # Rename the "mean" column
  datac <- rename(datac, c("mean" = measurevar))
  datac <- rename(datac, c("qt2.25%" = "qt2"))
  datac <- rename(datac, c("qt3.50%" = "qt3"))
  datac <- rename(datac, c("qt4.75%" = "qt4"))
  datac <- rename(datac, c("qt5.97.5%" = "qt5"))
  datac <- rename(datac, c("qt1.2.5%" = "qt1"))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval:
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}



# dff=tot_dat
# measure_variable="mean_size"
# group_variable="gen"
# color_qt=verde

plot_summary_variables=function(dff, measure_variable, group_variable, color_qt){
  
  tryCatch({
    s_dat = summarySE(dff, measurevar = measure_variable, groupvars = group_variable)}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  
  
  
  if (measure_variable == "tot_tr"){
    mv_label="Total number of troughs"
  } else if (measure_variable == "mean_size"){
    mv_label= "Trough mean size (bp)"
  } else if (measure_variable == "prop_tr"){
    mv_label="Proportion of the Chromosome in Troughs"
  } else {
    mv_label=measure_variable
  }
  
  if(group_variable == "gen"){
    gv_label="Time (generations)"
  } else {
    gv_label=group_variable
  }
  
  
  plot(x=s_dat[,group_variable], y=s_dat[,measure_variable], type="l", col="black", ylim = c(0, max(s_dat[,'qt4'])), xlab = gv_label, ylab = mv_label)
  lines(x=s_dat[,group_variable], y=s_dat[,'qt2'], col=scales::alpha(color_qt, 0.5))
  lines(x=s_dat[,group_variable], y=s_dat[,'qt4'], col=scales::alpha(color_qt, 0.5))
}


# Thu Mar 25 17:32:01 2021 ------------------------------

plot_different_models=function(level_trough, model1, model2, model3, measure_variable, group_variable, color1, color2, color3, log10_transform=F, f_trans=1, resc_ymax=1){
  
  d1= fread(sprintf("summary_data_lvl_%s_%s.txt", level_trough*100, model1))
  d2= fread(sprintf("summary_data_lvl_%s_%s.txt", level_trough*100, model2))
  d3= fread(sprintf("summary_data_lvl_%s_%s.txt", level_trough*100, model3))
  
  tryCatch({
    s1 = summarySE(d1, measurevar = measure_variable, groupvars = group_variable)}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  tryCatch({
    s2 = summarySE(d2, measurevar = measure_variable, groupvars = group_variable)}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  tryCatch({
    s3 = summarySE(d3, measurevar = measure_variable, groupvars = group_variable)}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  
  if (measure_variable == "tot_tr"){
    mv_label="Total number of troughs"
  } else if (measure_variable == "mean_size"){
    mv_label= "Trough mean size"
  } else if (measure_variable == "prop_tr"){
    mv_label="Proportion of the Chromosome in Troughs"
  } else {
    mv_label=measure_variable
  }
  
  if (log10_transform == T){
    mv_label= paste0(mv_label, " (log10)")
  }
  
  if(f_trans != 1){
    mv_label = paste0(mv_label, " (scaled 1:", formatC(f_trans, format = "g"), ")")
  }
  
  
  if(group_variable == "gen"){
    gv_label="Time (generations)"
  } else {
    gv_label=group_variable
  }
  
  
  poss_y=c(max(s1$qt5), max(s2$qt5), max(s3$qt5))
  min_y=c(min(s1$qt1), min(s2$qt1), min(s3$qt1))
  
  yli=max(poss_y)*resc_ymax
  min_yli=min(min_y)
  
  if (log10_transform == T){
    #bot, left, top, right
    par(oma=c(0,2,0,0))
    layout(matrix(c(1,1,1,1,1,2), 1, 6))
    mv_title=unlist(strsplit(mv_label, split = "\\("))[1]
    gv_title=unlist(strsplit(gv_label, split = " \\("))[1]
    
    plot(x=s1[,group_variable], y=log10(s1[,measure_variable]), type="l", col=color1, ylim = c(log10(min_yli), log10(yli)), main=sprintf("%s by %s;", mv_title, gv_title), sub = sprintf("Models: %s, %s, %s;", model1, model2, model3), xlab = gv_label, ylab = mv_label, cex.main=2, cex.lab=1.5, cex.axis=1.5)

    # title(main=sprintf("%s by %s;", mv_title, gv_title), sub = sprintf("Models: %s, %s, %s;", model1, model2, model3), xlab = gv_label, ylab = mv_label, main.cex=2, lab.cex=2)
    polygon(c(s1[,group_variable], rev(s1[,group_variable])), c(log10(s1[,'qt5']), rev(log10(s1[,'qt1']))), col=scales::alpha(color1, 0.35), border = NA)
    
    lines(x=s2[,group_variable], y=log10(s2[,measure_variable]), col=color2)
    polygon(c(s2[,group_variable], rev(s2[,group_variable])), c(log10(s2[,'qt5']), rev(log10(s2[,'qt1']))), col=scales::alpha(color2, 0.35), border = NA)
    
    lines(x=s3[,group_variable], y=log10(s3[,measure_variable]), col=color3)
    polygon(c(s3[,group_variable], rev(s3[,group_variable])), c(log10(s3[,'qt5']), rev(log10(s3[,'qt1']))), col=scales::alpha(color3, 0.35), border = NA)
    
    plot.new()
    par(oma=c(0,0,0,0))
    legend("right", c(model1, model2, model3), fill=c(azul, verde, rosa), cex = 2, xpd = NA)
    
    # lines(x=s1[,group_variable], y=log10(s1[,'qt3']), col=color1, lty="dashed")
    # lines(x=s1[,group_variable], y=log10(s1[,'qt1']), col=scales::alpha(color1, 0.35))
    # lines(x=s1[,group_variable], y=log10(s1[,'qt5']), col=scales::alpha(color1, 0.35))
    # lines(x=s1[,group_variable], y=log10(s1[,'qt2']), col=scales::alpha(color1, 0.5))
    # lines(x=s1[,group_variable], y=log10(s1[,'qt4']), col=scales::alpha(color1, 0.5))
  } else{
    par(oma=c(0,2,0,0))
    layout(matrix(c(1,1,1,1,1, 2), 1, 6))
    mv_title=unlist(strsplit(mv_label, split = "\\("))[1]
    gv_title=unlist(strsplit(gv_label, split = " \\("))[1]
    plot(x=s1[,group_variable], y=s1[,measure_variable]/f_trans, type="l", col=color1, ylim = c(min_yli/f_trans, yli/f_trans), main=sprintf("%s by %s;", mv_title, gv_title), sub = sprintf("Models: %s, %s, %s;", model1, model2, model3), xlab = gv_label, ylab = mv_label, cex.main=2, cex.lab=1.5, cex.axis=1.5)

    polygon(c(s1[,group_variable], rev(s1[,group_variable])), c(s1[,'qt5']/f_trans, rev(s1[,'qt1']/f_trans)), col=scales::alpha(color1, 0.35), border = NA)
    
    lines(x=s2[,group_variable], y=s2[,measure_variable]/f_trans, col=color2)
    polygon(c(s2[,group_variable], rev(s2[,group_variable])), c(s2[,'qt5']/f_trans, rev(s2[,'qt1']/f_trans)), col=scales::alpha(color2, 0.35), border = NA)
    
    lines(x=s3[,group_variable], y=s3[,measure_variable]/f_trans, col=color3)
    polygon(c(s3[,group_variable], rev(s3[,group_variable])), c(s3[,'qt5']/f_trans, rev(s3[,'qt1']/f_trans)), col=scales::alpha(color3, 0.35), border = NA)
    plot.new()
    par(oma=c(0,0,0,0))
    legend("right", c(model1, model2, model3), fill=c(azul, verde, rosa), cex = 2, xpd = NA)
    
  }
  
}


# Tue Apr 06 21:22:12 2021 ------------------------------


# level_trough=.1; model0="f10_m10_g5"; samp1=5; samp2=10; measure_variable="mean_size"; group_variable="gen"; color1=azul; color2=verde; color3=rosa; path=model0
# log10_transform=F; f_trans=1; resc_ymax=1

plot_different_sampling=function(level_trough, model0, samp1, samp2, measure_variable, group_variable, color1, color2, color3, path=".", log10_transform=F, f_trans=1, resc_ymax=1, gen_intervals=c(seq(25001, 25500))){
  
  d1= fread(sprintf("%s/summary_data_lvl_%s_%s.txt", path, level_trough*100, model0))
  d2= fread(sprintf("%s/summary_data_lvl_%s_%s_%sinds.txt", path, level_trough*100, model0, samp1))
  d3= fread(sprintf("%s/summary_data_lvl_%s_%s_%sinds.txt", path, level_trough*100, model0, samp2))
  
  d1=d1[d1$gen %in% gen_intervals,]
  d2=d2[d2$gen %in% gen_intervals,]
  d3=d3[d3$gen %in% gen_intervals,]
  
  tryCatch({
    s1 = summarySE(d1, measurevar = measure_variable, groupvars = group_variable)}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  tryCatch({
    s2 = summarySE(d2, measurevar = measure_variable, groupvars = group_variable)}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  tryCatch({
    s3 = summarySE(d3, measurevar = measure_variable, groupvars = group_variable)}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  
  if (measure_variable == "tot_tr"){
    mv_label="Total number of troughs"
  } else if (measure_variable == "mean_size"){
    mv_label= "Trough mean size"
  } else if (measure_variable == "prop_tr"){
    mv_label="Proportion of the Chromosome in Troughs"
  } else {
    mv_label=measure_variable
  }
  
  if (log10_transform == T){
    mv_label= paste0(mv_label, " (log10)")
  }
  
  if(f_trans != 1){
    mv_label = paste0(mv_label, " (scaled 1:", formatC(f_trans, format = "g"), ")")
  }
  
  
  if(group_variable == "gen"){
    gv_label="Time (generations)"
  } else {
    gv_label=group_variable
  }
  
  if (measure_variable == "mean_size"){
    poss_y=c(max(s1$qt5), max(s2$qt5), max(s3$qt5), 1e8)
  } else {
    poss_y=c(max(s1$qt5), max(s2$qt5), max(s3$qt5))
  }
  
  min_y=c(min(s1$qt1), min(s2$qt1), min(s3$qt1))
  
  yli=max(poss_y)*resc_ymax
  min_yli=min(min_y)*resc_ymax
  
  if (log10_transform == T){
    #bot, left, top, right
    par(oma=c(0,2,0,0))
    layout(matrix(c(1,1,1,1,1,2), 1, 6))
    mv_title=unlist(strsplit(mv_label, split = "\\("))[1]
    gv_title=unlist(strsplit(gv_label, split = " \\("))[1]
    
    plot(x=s1[,group_variable], y=log10(s1[,measure_variable]), type="l", col=color1, ylim = c(log10(min_yli), log10(yli)), main=sprintf("%s by %s;", mv_title, gv_title), sub = sprintf("Model: %s; Sampling: %s & %s inds;", model0, samp1, samp2), xlab = gv_label, ylab = mv_label, cex.main=2, cex.lab=1.5, cex.axis=1.5)
    
    polygon(c(s1[,group_variable], rev(s1[,group_variable])), c(log10(s1[,'qt5']), rev(log10(s1[,'qt1']))), col=scales::alpha(color1, 0.01), border = scales::alpha(color1, 0.35))
    
    lines(x=s2[,group_variable], y=log10(s2[,measure_variable]), col=color2)
    polygon(c(s2[,group_variable], rev(s2[,group_variable])), c(log10(s2[,'qt5']), rev(log10(s2[,'qt1']))), col=scales::alpha(color2, 0.01), border = scales::alpha(color2, 0.35))
    
    lines(x=s3[,group_variable], y=log10(s3[,measure_variable]), col=color3)
    polygon(c(s3[,group_variable], rev(s3[,group_variable])), c(log10(s3[,'qt5']), rev(log10(s3[,'qt1']))), col=scales::alpha(color3, 0.01), border = scales::alpha(color3, 0.35))
    
    plot.new()
    par(oma=c(0,0,0,0))
    legend("right", c(model0, paste0(samp1, " samp ind"), paste0(samp2, " samp ind")), fill=c(azul, verde, rosa), cex = 2, xpd = NA)
    
    # lines(x=s1[,group_variable], y=log10(s1[,'qt3']), col=color1, lty="dashed")
    # lines(x=s1[,group_variable], y=log10(s1[,'qt1']), col=scales::alpha(color1, 0.35))
    # lines(x=s1[,group_variable], y=log10(s1[,'qt5']), col=scales::alpha(color1, 0.35))
    # lines(x=s1[,group_variable], y=log10(s1[,'qt2']), col=scales::alpha(color1, 0.5))
    # lines(x=s1[,group_variable], y=log10(s1[,'qt4']), col=scales::alpha(color1, 0.5))
  } else{
    par(oma=c(0,2,0,0))
    layout(matrix(c(1,1,1,1,1, 2), 1, 6))
    mv_title=unlist(strsplit(mv_label, split = "\\("))[1]
    gv_title=unlist(strsplit(gv_label, split = " \\("))[1]
    plot(x=s1[,group_variable], y=s1[,measure_variable]/f_trans, type="l", col=color1, ylim = c(min_yli/f_trans, yli/f_trans), main=sprintf("%s by %s;", mv_title, gv_title), sub = sprintf("Model: %s; Sampling: %s & %s inds;", model0, samp1, samp2), xlab = gv_label, ylab = mv_label, cex.main=2, cex.lab=1.5, cex.axis=1.5)
    
    polygon(c(s1[,group_variable], rev(s1[,group_variable])), c(s1[,'qt5']/f_trans, rev(s1[,'qt1']/f_trans)), col=scales::alpha(color1, 0.01), border = scales::alpha(color1, 0.35))
    
    lines(x=s2[,group_variable], y=s2[,measure_variable]/f_trans, col=color2)
    polygon(c(s2[,group_variable], rev(s2[,group_variable])), c(s2[,'qt5']/f_trans, rev(s2[,'qt1']/f_trans)), col=scales::alpha(color2, 0.01), border = scales::alpha(color2, 0.35))
    
    lines(x=s3[,group_variable], y=s3[,measure_variable]/f_trans, col=color3)
    polygon(c(s3[,group_variable], rev(s3[,group_variable])), c(s3[,'qt5']/f_trans, rev(s3[,'qt1']/f_trans)), col=scales::alpha(color3, 0.01), border = scales::alpha(color3, 0.35))
    plot.new()
    par(oma=c(0,0,0,0))
    legend("right", c(model0, paste0(samp1, " samp ind"), paste0(samp2, " samp ind")), fill=c(azul, verde, rosa), cex = 2, xpd = NA)
    
  }
  
}


# Wed Apr 07 16:09:33 2021 ------------------------------



# level_trough=.1; model0="f10_m10_g5"; sampling=T; nsamp=5;
# measure_variable="mean_size"; group_variable="gen";
# color1=azul; color2=verde; color3=rosa; path=model0
# log10_transform=F; f_trans=1; resc_ymax=1
# 
# 
# gen_groups=list(comeco= c(25001, seq(25005, 25500, floor(step))),
#             meio= c(25001, seq(25007, 25500, floor(step)), 25500),
#             fim= c(25001, seq(25004, 25500, floor(step))))

plot_different_stage_sampling=function(level_trough, model0, sampling=F, nsamp=NULL, measure_variable, group_variable, color1, color2, color3, path=".", f_trans=1, resc_ymax=1, gen_groups, print_legend=T){
  
  if(length(gen_groups) != 3 | typeof(gen_groups) != "list"){
    sprintf("wrong generation input format")
    
  } else {
    
    if (sampling == T){
      dat= fread(sprintf("%s/summary_data_lvl_%s_%s_%sinds.txt", path, level_trough*100, model0, nsamp))
    } else if (sampling == F){ 
      dat= fread(sprintf("%s/summary_data_lvl_%s_%s.txt", path, level_trough*100, model0))
    }
  
  d1=dat[dat$gen %in% gen_groups[[1]],]
  d2=dat[dat$gen %in% gen_groups[[2]],]
  d3=dat[dat$gen %in% gen_groups[[3]],]
  
  tryCatch({
    s1 = summarySE(d1, measurevar = measure_variable, groupvars = group_variable)}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  tryCatch({
    s2 = summarySE(d2, measurevar = measure_variable, groupvars = group_variable)}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  tryCatch({
    s3 = summarySE(d3, measurevar = measure_variable, groupvars = group_variable)}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  
  if (measure_variable == "tot_tr"){
    mv_label="Total number of troughs"
  } else if (measure_variable == "mean_size"){
    mv_label= "Trough mean size"
  } else if (measure_variable == "prop_tr"){
    mv_label="Proportion of the Chromosome in Troughs"
  } else {
    mv_label=measure_variable
  }
  
  if (log10_transform == T){
    mv_label= paste0(mv_label, " (log10)")
  }
  
  if(f_trans != 1){
    mv_label = paste0(mv_label, " (scaled 1:", formatC(f_trans, format = "g"), ")")
  }
  
  
  if(group_variable == "gen"){
    gv_label="Time (generations)"
  } else {
    gv_label=group_variable
  }
  
  
  if (measure_variable == "mean_size"){
    poss_y=c(max(s1$qt5), max(s2$qt5), max(s3$qt5), 1e8)
  } else {
    poss_y=c(max(s1$qt5), max(s2$qt5), max(s3$qt5))
  }
  min_y=c(min(s1$qt1), min(s2$qt1), min(s3$qt1))
  
  yli=max(poss_y)*resc_ymax
  min_yli=min(min_y)
  

    par(oma=c(0,2,0,0))
    if (print_legend == T){
      layout(matrix(c(1,1,1,1,1, 2), 1, 6))
    }
    mv_title=unlist(strsplit(mv_label, split = "\\("))[1]
    gv_title=unlist(strsplit(gv_label, split = " \\("))[1]
    plot(x=s1[,group_variable], y=s1[,measure_variable]/f_trans, type="l", col=color1, ylim = c(min_yli/f_trans, yli/f_trans), main=sprintf("%s by %s;", mv_title, gv_title), sub = sprintf("Model: %s; Stages: %s, %s & %s; nSamps: %s", model0, names(gen_groups)[1], names(gen_groups)[2], names(gen_groups)[3], nsamp), xlab = gv_label, ylab = mv_label, cex.main=2, cex.lab=1.5, cex.axis=1.5)
    
    polygon(c(s1[,group_variable], rev(s1[,group_variable])), c(s1[,'qt5']/f_trans, rev(s1[,'qt1']/f_trans)), col=scales::alpha(color1, 0.01), border = scales::alpha(color1, 0.35))
    
    lines(x=s2[,group_variable], y=s2[,measure_variable]/f_trans, col=color2)
    polygon(c(s2[,group_variable], rev(s2[,group_variable])), c(s2[,'qt5']/f_trans, rev(s2[,'qt1']/f_trans)), col=scales::alpha(color2, 0.01), border = scales::alpha(color2, 0.35))
    
    lines(x=s3[,group_variable], y=s3[,measure_variable]/f_trans, col=color3)
    polygon(c(s3[,group_variable], rev(s3[,group_variable])), c(s3[,'qt5']/f_trans, rev(s3[,'qt1']/f_trans)), col=scales::alpha(color3, 0.01), border = scales::alpha(color3, 0.35))
    if (print_legend == T){
      plot.new()
      par(oma=c(0,0,0,0))
      legend("right", title = "Growth Stage", legend = c(names(gen_groups)[1], names(gen_groups)[2], names(gen_groups)[3]), fill=c(azul, verde, rosa), cex = 2, xpd = NA)
    }
  }
  
}

