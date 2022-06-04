###########################################################################################
###                              NON PARAMETRIC REGRESSION                              ###
###########################################################################################
load('nlr_data.rda')
data = data.frame("age"=Wage$age,"wage"=Wage$wage)    # data = [X, Y]
x    = data[,1]
y    = data[,2]

### ---------------------------------------------------------------------------------------
### Linear model
### ---------------------------------------------------------------------------------------
m_linear = lm(y ~ x)
summary(m_linear)
x_grid   = seq(range(x)[1], range(x)[2], length.out=100)
y_pred   = predict(m_linear, list(x=x_grid), se=T)
se.bands = cbind(y_pred$fit+2*y_pred$se.fit, y_pred$fit-2*y_pred$se.fit)
plot(x, y, xlim=range(x_grid), cex=.5)
lines(x_grid, y_pred$fit, lwd=2, col='blue')
matlines(x_grid, se.bands, lwd=1, col='blue', lty=3)
par(mfrow=c(2,2))
plot(m_linear)
dev.off()

### ---------------------------------------------------------------------------------------
### Polynomial model (orthogonal polynomial)
### ---------------------------------------------------------------------------------------
m_list = lapply(1:10, function(degree){lm(y ~ poly(x, degree=degree))})
do.call(anova, m_list)
m_poly = m_list[[4]]
summary(m_poly)
x_grid   = seq(range(x)[1], range(x)[2], length.out=100)
y_pred   = predict(m_poly, list(x=x_grid), se=T)
se.bands = cbind(y_pred$fit+2*y_pred$se.fit, y_pred$fit-2*y_pred$se.fit)
plot(x, y, xlim=range(x_grid), cex=.5)
lines(x_grid, y_pred$fit, lwd=2, col='blue')
matlines(x_grid, se.bands, lwd=1, col='blue', lty=3)
par(mfrow=c(2,2))
plot(m_poly)
dev.off()

# Alternative: we can obtain non-orthogonal polynomial with:
# m_list = lapply(1:10, function(degree){lm(y ~ poly(x, degree=degree, raw=T))})

### ---------------------------------------------------------------------------------------
### Polynomial model for a probability (dummy_var = I_{y>val})
### ---------------------------------------------------------------------------------------
val = 250
m_list = lapply(1:5, function(degree){glm(I(y>val) ~ poly(x, degree=degree), family='binomial')})
do.call(anova, m_list)
m_poly = m_list[[4]]
summary(m_poly)
x_grid   = seq(range(x)[1], range(x)[2], length.out=100)
y_pred_0 = predict(m_poly, list(x=x_grid), se=T)
y_pred   = exp(y_pred_0$fit)/(1+exp(y_pred_0$fit))
se.bands = cbind(y_pred_0$fit+2*y_pred_0$se.fit, y_pred_0$fit-2*y_pred_0$se.fit)
se.bands = exp(se.bands)/(1+exp(se.bands))
plot(x, I(y>val), xlim=range(x_grid), cex=.5)
lines(x_grid, y_pred, lwd=2, col='blue')
matlines(x_grid, se.bands, lwd=1, col='blue', lty=3)

### ---------------------------------------------------------------------------------------
### Local Regression: CUT
### ---------------------------------------------------------------------------------------
n_cut = 4
table(cut(x,n_cut))
m_cut    = lm(y ~ cut(x,n_cut))
x_grid   = seq(range(x)[1], range(x)[2], length.out=100)
y_pred   = predict(m_cut, list(x=x_grid), se=T)
se.bands = cbind(y_pred$fit+2*y_pred$se.fit, y_pred$fit-2*y_pred$se.fit)
plot(x, y, xlim=range(x_grid), cex=.5)
lines(x_grid, y_pred$fit, lwd=2, col='blue')
matlines(x_grid, se.bands, lwd=1, col='blue', lty=3)

### ---------------------------------------------------------------------------------------
### Local Regression: CUT - probability (dummy_var = I_{y>val})
### ---------------------------------------------------------------------------------------
n_cut = 4
val   = 250
table(cut(x,n_cut))
m_logit = glm(I(y>val) ~ cut(x,n_cut), family='binomial')
x_grid   = seq(range(x)[1], range(x)[2], length.out=100)
y_pred_0 = predict(m_logit, list(x=x_grid), se=T)
y_pred   = exp(y_pred_0$fit)/(1+exp(y_pred_0$fit))
se.bands = cbind(y_pred_0$fit+2*y_pred_0$se.fit, y_pred_0$fit-2*y_pred_0$se.fit)
se.bands = exp(se.bands)/(1+exp(se.bands))
plot(x, I(y>val), xlim=range(x_grid), cex=.5)
lines(x_grid, y_pred, lwd=2, col='blue')
matlines(x_grid, se.bands, lwd=1, col='blue', lty=3)

### ---------------------------------------------------------------------------------------
### Local Regression: CUT in estabilished points
### ---------------------------------------------------------------------------------------
br       = c(min(x), mean(x), max(x))
# We can produce un-even bins (we may want smaller bins where we have a lot of data)
#br       = c(seq(min(x), mean(x), length.out=10), seq(mean(x)+1, max(x), length.out=20))
m_cut    = lm(y ~ cut(x, breaks=br))
x_grid   = seq(range(x)[1], range(x)[2], length.out=100)
y_pred   = predict(m_cut, list(x=x_grid), se=T)
se.bands = cbind(y_pred$fit+2*y_pred$se.fit, y_pred$fit-2*y_pred$se.fit)
plot(x, y, xlim=range(x_grid), cex=.5)
lines(x_grid, y_pred$fit, lwd=2, col='blue')
matlines(x_grid, se.bands, lwd=1, col='blue', lty=3)

### ---------------------------------------------------------------------------------------
### Local Regression: LOCAL AVERAGING
### ---------------------------------------------------------------------------------------
library(np)
band_w   = 10     # higher -> more points considered to do the average
m_loc    = npreg(x, y, ckertype='uniform', bws=band_w)
x_grid   = seq(range(x)[1], range(x)[2], length.out=100)
y_pred   = predict(m_loc, list(x=x_grid), se=T)
se.bands = cbind(y_pred$fit+2*y_pred$se.fit, y_pred$fit-2*y_pred$se.fit)
plot(x, y, xlim=range(x_grid), cex=.5)
lines(x_grid, y_pred$fit, lwd=2, col='blue')
matlines(x_grid, se.bands, lwd=1, col='blue', lty=3)

### ---------------------------------------------------------------------------------------
### Local Regression: KERNEL AVERAGING
### ---------------------------------------------------------------------------------------
library(np)
band_w   = 10     # higher -> more points considered to do the average
m_ker    = npreg(x, y, ckertype='gauss', bws=band_w)
x_grid   = seq(range(x)[1], range(x)[2], length.out=100)
y_pred   = predict(m_ker, list(x=x_grid), se=T)
se.bands = cbind(y_pred$fit+2*y_pred$se.fit, y_pred$fit-2*y_pred$se.fit)
plot(x, y, xlim=range(x_grid), cex=.5)
lines(x_grid, y_pred$fit, lwd=2, col='blue')
matlines(x_grid, se.bands, lwd=1, col='blue', lty=3)

### ---------------------------------------------------------------------------------------
### Local Regression: ADAPTIVE KERNEL
### ---------------------------------------------------------------------------------------
library(np)
band_w   = 10     # higher -> more points considered to do the average
m_ker    = npreg(x, y, ckertype='gauss', bws=band_w, bwscaling=T)
x_grid   = seq(range(x)[1], range(x)[2], length.out=100)
y_pred   = predict(m_ker, list(x=x_grid), se=T)
se.bands = cbind(y_pred$fit+2*y_pred$se.fit, y_pred$fit-2*y_pred$se.fit)
plot(x, y, xlim=range(x_grid), cex=.5)
lines(x_grid, y_pred$fit, lwd=2, col='blue')
matlines(x_grid, se.bands, lwd=1, col='blue', lty=3)

### ---------------------------------------------------------------------------------------
### Piecewise linear
### ---------------------------------------------------------------------------------------
cutoff      = mean(x)
x_cut       = x>cutoff
x_cut_model = (x-cutoff)*x_cut
model_cut   = lm(y ~ x + x_cut_model)
x_grid   = seq(range(x)[1], range(x)[2], length.out=100)
y_pred   = predict(model_cut, list(x=x_grid, x_cut_model=(x_grid-cutoff)*(x_grid>cutoff)), se=T)
se.bands = cbind(y_pred$fit+2*y_pred$se.fit, y_pred$fit-2*y_pred$se.fit)
plot(x, y, xlim=range(x_grid), cex=.5)
lines(x_grid, y_pred$fit, lwd=2, col='blue')
matlines(x_grid, se.bands, lwd=1, col='blue', lty=3)
summary(model_cut) # to see the change of slope

### ---------------------------------------------------------------------------------------
### Piecewise linear allowing discontinuities
### ---------------------------------------------------------------------------------------
cutoff      = mean(x)
x_cut       = x>cutoff
x_cut_model = (x-cutoff)*x_cut
model_cut   = lm(y ~ x + x_cut_model + I(x>cutoff))
x_grid   = seq(range(x)[1], range(x)[2], length.out=100)
y_pred   = predict(model_cut, list(x=x_grid, x_cut_model=(x_grid-cutoff)*(x_grid>cutoff)), se=T)
se.bands = cbind(y_pred$fit+2*y_pred$se.fit, y_pred$fit-2*y_pred$se.fit)
plot(x, y, xlim=range(x_grid), cex=.5)
lines(x_grid, y_pred$fit, lwd=2, col='blue')
matlines(x_grid, se.bands, lwd=1, col='blue', lty=3)
summary(model_cut) # to see the change of slope

### ---------------------------------------------------------------------------------------
### Piecewise allowing discontinuities and different functional forms
### ---------------------------------------------------------------------------------------
cutoff      = mean(x)
x_cut       = x>cutoff
x_cut_model = (x-cutoff)*x_cut
model_cut   = lm(y ~ poly(x, degree=3) + poly(x_cut_model, degree=3) + I(x>cutoff))
x_grid   = seq(range(x)[1], range(x)[2], length.out=100)
y_pred   = predict(model_cut, list(x=x_grid, x_cut_model=(x_grid-cutoff)*(x_grid>cutoff)), se=T)
se.bands = cbind(y_pred$fit+2*y_pred$se.fit, y_pred$fit-2*y_pred$se.fit)
plot(x, y, xlim=range(x_grid), cex=.5)
lines(x_grid, y_pred$fit, lwd=2, col='blue')
matlines(x_grid, se.bands, lwd=1, col='blue', lty=3)
summary(model_cut) # to see the change of slope