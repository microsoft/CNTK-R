library(testthat)
library(cntk)

expect_no_error <- function(expr) {
	expect_failure(expect_error(expr))
}

expect_no_error(Activation())
expect_no_error(AveragePooling(c(1, 1)))
expect_no_error(BatchNormalization())
expect_no_error(Convolution(c(1, 1)))
expect_no_error(Convolution1D(1))
expect_no_error(Convolution2D(c(1, 1)))
expect_no_error(Convolution3D(c(1, 1, 1)))
expect_no_error(ConvolutionTranspose(c(1, 1)))
