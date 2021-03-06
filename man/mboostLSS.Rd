\name{mboostLSS}
\alias{mboostLSS}
\alias{blackboostLSS}
\alias{glmboostLSS}
\alias{gamboostLSS}
\alias{mboostLSS_fit}

\title{
  Fitting GAMLSS by Boosting
}
\description{
  Functions for fitting GAMLSS (generalized additive models for
  location, scale and shape) using boosting techniques. 
  Two algorithms are implemented: (a) The cyclic algorithm
  iteratively rotates between the distribution parameters, updating one while using
  the current fits of the others as offsets (for details see Mayr et
  al., 2012). 
  (b) The noncyclic algorithm selects in each step the update of a base-learner 
  for the distribution parameter that best fits the negative gradient 
  (algorithm with inner loss of Thomas et al., 2018). 
  
}
\usage{
mboostLSS(formula, data = list(), families = GaussianLSS(),
          control = boost_control(), weights = NULL, 
          method = c("cyclic", "noncyclic"), ...)
glmboostLSS(formula, data = list(), families = GaussianLSS(),
            control = boost_control(), weights = NULL, 
            method = c("cyclic", "noncyclic"), ...)
gamboostLSS(formula, data = list(), families = GaussianLSS(),
            control = boost_control(), weights = NULL, 
            method = c("cyclic", "noncyclic"), ...)
blackboostLSS(formula, data = list(), families = GaussianLSS(),
              control = boost_control(), weights = NULL,
              method = c("cyclic", "noncyclic"), ...)

## fit function:
mboostLSS_fit(formula, data = list(), families = GaussianLSS(),
              control = boost_control(), weights = NULL,
              fun = mboost, funchar = "mboost", call = NULL, method, ...)
}

\arguments{
  \item{formula}{ a symbolic description of the model to be fit. See
    \code{\link{mboost}} for details. If \code{formula} is a single formula,
    the same formula is used for all distribution parameters. \code{formula}
    can also be a (named) list, where each list element corresponds
    to one distribution parameter of the GAMLSS distribution. The names must be
    the same as in the family (see example for details). }
  \item{data}{ a data frame containing the variables in the model.}
  \item{families}{ an object of class \code{families}. It can be either one of
    the pre-defined distributions that come along with the package or a new distribution
    specified by the user (see \code{\link{Families}} for details). Per
    default, we use the two-parametric \code{\link{GaussianLSS}} family.}
  \item{control}{ a list of parameters controlling the algorithm. For
    more details see \code{\link{boost_control}}. }
  \item{weights}{ a numeric vector of weights (optional). }
  \item{method}{ fitting method, currently two methods are supported:
  \code{"cyclic"} (see Mayr et al., 2012) and \code{"noncyclic"} 
   (algorithm with inner loss of Thomas et al., 2018). 
  The latter requires a one dimensional \code{mstop} value.}
  \item{fun}{ fit function. Either \code{\link{mboost}},
    \code{\link{glmboost}}, \code{\link{gamboost}} or
    \code{\link{blackboost}}. Specified directly via the corresponding LSS
    function. E.g. \code{gamboostLSS()} calls
    \code{mboostLSS_fit(..., fun = gamboost)}. }
  \item{funchar}{ character representation of fit function. Either \code{"mboost"},
    \code{"glmboost"}, \code{"gamboost"} or \code{"blackboost"}.
    Specified directly via the corresponding LSS function.}
  \item{call}{ used to forward the call from \code{mboostLSS},
    \code{glmboostLSS}, \code{gamboostLSS} and \code{blackboostLSS}.
    This argument should not be directly specified by users!}
  \item{\dots}{Further arguments to be passed to \code{mboostLSS_fit}.
    In  \code{mboostLSS_fit}, \code{\dots} represent further arguments to be
    passed to \code{\link{mboost}} and \code{\link{mboost_fit}}. So
    \code{\dots} can be all arguments of \code{mboostLSS_fit} and
    \code{mboost_fit}. }
}
\details{

  For information on GAMLSS theory see Rigby and Stasinopoulos (2005) or
  the information provided at \url{https://www.gamlss.com/}. For a tutorial on
  \code{\link{gamboostLSS}} see Hofner et al. (2016). Thomas et al. (2018) 
  developed a novel non-cyclic approach to fit gamboostLSS models. This approach
  is suitable for the combination with \code{\link{stabsel}} and speeds up
  model tuning via \code{\link{cvrisk}} (see also below).

  \code{glmboostLSS} uses \code{\link[mboost]{glmboost}} to fit the
  distribution parameters of a GAMLSS -- a linear boosting model is
  fitted for each parameter.

  \code{gamboostLSS} uses \code{\link[mboost]{gamboost}} to fit the
  distribution parameters of a GAMLSS -- an additive boosting model (by
  default with smooth effects) is fitted for each parameter. With the
  \code{formula} argument, a wide range of different base-learners can
  be specified (see \code{\link[mboost]{baselearners}}). The
  base-learners imply the type of effect each covariate has on the
  corresponding distribution parameter.

  \code{mboostLSS} uses \code{\link[mboost]{mboost}} to fit the
  distribution parameters of a GAMLSS. The type of model (linear,
  tree-based or smooth) is specified by \code{fun}.

  \code{blackboostLSS} uses \code{\link[mboost]{blackboost}} to fit the
  distribution parameters of a GAMLSS -- a tree-based boosting model is
  fitted for each parameter.

  \code{mboostLSS}, \code{glmboostLSS}, \code{gamboostLSS} and
  \code{blackboostLSS} all call \code{mboostLSS_fit} while \code{fun} is
  the corresponding \code{\link{mboost}} function, i.e., the same
  function without \code{LSS}. For further possible arguments see
  these functions as well as \code{\link{mboost_fit}}. 
  Note that \code{mboostLSS_fit} is usually not called directly by the user. 

  For \code{method = "cyclic"} it is possible to specify one or
  multiple \code{mstop} and \code{nu} values via
  \code{\link{boost_control}}. In the case of one single value, this
  value is used for all distribution parameters of the GAMLSS model.
  Alternatively, a (named) vector or a (named) list with separate values
  for each component can be used to specify a separate value for each
  parameter of the GAMLSS model. The names of the list must correspond
  to the names of the distribution parameters of the GAMLSS family. If
  no names are given, the order of the \code{mstop} or \code{nu} values
  is assumed to be the same as the order of the components in the
  \code{families}. For one-dimensional stopping, the user therefore can
  specify, e.g., \code{mstop = 100} via \code{\link{boost_control}}. For
  more-dimensional stopping, one can specify, e.g., \code{mstop =
  list(mu = 100, sigma = 200)} (see examples).

  If \code{method} is set to \code{"noncyclic"}, \code{mstop} has
  to be a one dimensional integer. Instead of cycling through all distribution 
  parameters, in each iteration only the best base-learner is used. One base-learner of every 
  parameter is selected via RSS, the distribution parameter is then chosen via the loss 
  (in Thomas et. al., 2018, called inner loss). 
  For details on the noncyclic fitting method see Thomas et. al. (2018). 

  To (potentially) stabilize the model estimation by standardizing the
  negative gradients one can use the argument \code{stabilization} of
  the families. See \code{\link{Families}} for details.

}
\value{
  An object of class \code{mboostLSS} or \code{nc_mboostLSS} (inheriting from 
  class \code{mboostLSS}) for models fitted with \code{method = "cyclic"}
  and \code{method = "non-cyclic"}, respectively, with corresponding methods to
  extract information. A \code{mboostLSS} model object is a named list 
  with one list entry for each modelled distribution parameter. 
  Special "subclasses" inheriting from \code{mboostLSS} exist for each of the 
  model-types (with the same name as the function, e.g., \code{gamboostLSS}).
}
\references{
B. Hofner, A. Mayr, M. Schmid (2016). gamboostLSS: An R Package for
Model Building and Variable Selection in the GAMLSS Framework.
Journal of Statistical Software, 74(1), 1-31.

Available as \code{vignette("gamboostLSS_Tutorial")}.

Mayr, A., Fenske, N., Hofner, B., Kneib, T. and Schmid, M. (2012):
Generalized additive models for location, scale and shape for
high-dimensional data - a flexible approach based on boosting. Journal
of the Royal Statistical Society, Series C (Applied Statistics) 61(3):
403-427.

M. Schmid, S. Potapov, A. Pfahlberg, and T. Hothorn. Estimation and
regularization techniques for regression models with multidimensional
prediction functions. Statistics and Computing, 20(2):139-150, 2010.

Rigby, R. A. and D. M. Stasinopoulos (2005). Generalized additive models
for location, scale and shape (with discussion). Journal of the Royal
Statistical Society, Series C (Applied Statistics), 54, 507-554.

Buehlmann, P. and Hothorn, T. (2007), Boosting algorithms: Regularization,
prediction and model fitting. Statistical Science, 22(4), 477--505.

  Thomas, J., Mayr, A., Bischl, B., Schmid, M., Smith, A., and Hofner, B. (2018), 
  Gradient boosting for distributional regression - faster tuning and improved 
  variable selection via noncyclical updates. 
  \emph{Statistics and Computing}. 28: 673-687. 
  \doi{10.1007/s11222-017-9754-6}\cr
  (Preliminary version: \url{https://arxiv.org/abs/1611.10171}).
}

\seealso{
  \code{\link{Families}} for a documentation of available GAMLSS distributions.

  The underlying boosting functions \code{\link{mboost}}, \code{\link{gamboost}}, \code{\link{glmboost}},
  \code{\link{blackboost}} are contained in the \code{\link{mboost}} package.

  See for example \code{\link{risk}} or \code{\link{coef}} for methods
  that can be used to extract information from \code{\link{mboostLSS}} objects.
}
\examples{

### Data generating process:
set.seed(1907)
x1 <- rnorm(1000)
x2 <- rnorm(1000)
x3 <- rnorm(1000)
x4 <- rnorm(1000)
x5 <- rnorm(1000)
x6 <- rnorm(1000)
mu    <- exp(1.5 +1 * x1 +0.5 * x2 -0.5 * x3 -1 * x4)
sigma <- exp(-0.4 * x3 -0.2 * x4 +0.2 * x5 +0.4 * x6)
y <- numeric(1000)
for( i in 1:1000)
    y[i] <- rnbinom(1, size = sigma[i], mu = mu[i])
dat <- data.frame(x1, x2, x3, x4, x5, x6, y)

### linear model with y ~ . for both components: 400 boosting iterations
model <- glmboostLSS(y ~ ., families = NBinomialLSS(), data = dat,
                     control = boost_control(mstop = 400),
                     center = TRUE)
coef(model, off2int = TRUE)


### estimate model with different formulas for mu and sigma:
names(NBinomialLSS())      # names of the family

\donttest{### Do not test the following code per default on CRAN as it takes some time to run:
# Note: Multiple formulas must be specified via a _named list_
#       where the names correspond to the names of the distribution parameters
#       in the family (see above)
model2 <- glmboostLSS(formula = list(mu = y ~ x1 + x2 + x3 + x4,
                                    sigma = y ~ x3 + x4 + x5 + x6),
                     families = NBinomialLSS(), data = dat,
                     control = boost_control(mstop = 400, trace = TRUE),
                     center = TRUE)
coef(model2, off2int = TRUE)
### END (don't test automatically)
}


### Offset needs to be specified via the arguments of families object:
model <- glmboostLSS(y ~ ., data = dat,
                     families = NBinomialLSS(mu = mean(mu),
                                             sigma = mean(sigma)),
                     control = boost_control(mstop = 10),
                     center = TRUE)
# Note: mu-offset = log(mean(mu)) and sigma-offset = log(mean(sigma))
#       as we use a log-link in both families
coef(model)
log(mean(mu))
log(mean(sigma))

\donttest{### Do not test the following code per default on CRAN as it takes some time to run:
### use different mstop values for the two distribution parameters
### (two-dimensional early stopping)
### the number of iterations is passed to boost_control via a named list
model3 <- glmboostLSS(formula = list(mu = y ~ x1 + x2 + x3 + x4,
                                    sigma = y ~ x3 + x4 + x5 + x6),
                     families = NBinomialLSS(), data = dat,
                     control = boost_control(mstop = list(mu = 400,
                                                          sigma = 300),
                                             trace  = TRUE),
                     center = TRUE)
coef(model3, off2int = TRUE)

### Alternatively we can change mstop of model2:
# here it is assumed that the first element in the vector corresponds to
# the first distribution parameter of model2 etc.
mstop(model2) <- c(400, 300)
par(mfrow = c(1,2))
plot(model2, xlim = c(0, max(mstop(model2))))
## all.equal(coef(model2), coef(model3)) # same!
### END (don't test automatically)
}
}

\keyword{models}
\keyword{nonlinear}
\keyword{fitting}
