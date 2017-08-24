rm(list = ls())
library(cntk)
library(tidyverse)

#' Generate sample data
#'
#' @param sample_size integer for sample size
#' @param features integer for number of columns
#' @param num_classes integer for number of categories
#'
#' @return list of features and labels
create_random_data <- function(sample_size = 32, features = 2,
                               num_classes = 2) {

  # y: Labels, vector of random sample fo 0s and 1s of size `sample_size`
  y <- sample(x = 0:(num_classes-1), size = sample_size, replace = TRUE)
  # x: Features, matrix of standard gaussians, dims: `sample_size` x `features`
  x <- replicate(features, rnorm(sample_size))

  # make data separable
  X <- x*y + max(x)

  Y <- lapply(1:num_classes, function(x) as.integer(y == x))
  Y <- do.call(cbind, Y)

  list(x = X, y = Y)

}


#' Same as above but single data.frame
#'
#' @param sample_size
#' @param features
#' @param num_classes
#'
#' @return data.frame of labels and features
create_df <- function(sample_size = 32, features = 2,
                      num_classes = 2) {

  data <- data.frame(y = sample(x = 0:(num_classes-1), size = sample_size, replace = TRUE),
                     x = replicate(features, rnorm(sample_size)))

  data[, 2:ncol(data)] <- (data[, 2:ncol(data)] + 3) *  (data$y + 1)
  data

}

## Set parameters and generate the data
input_dim <- 2
num_classes <- 2
cancer_data <- create_df()

# Visualize data with ggplot2

ggplot(cancer_data) +
  geom_point(aes(x = x.1, y = x.2, colour = factor(y))) +
  theme_minimal() +
  labs(x = "Age (scaled)",
       y = "Tumor size (cm)",
       colour = "Tumor Indicator",
       title = "Age and Tumor Size for Cancer Prediction")

feature <- op_input_variable(shape = input_dim)

model_parms <- list()

linear_layer <- function(input_var, output_dim) {

  input_dim <- input_var$shape[[1]]
  weight_param <- op_parameter(shape=list(input_dim, output_dim))
  bias_param <- op_parameter(shape = output_dim)

  model_parms$w <- weight_param
  model_parms$b <- bias_param

  # op_plus(op_times(input_var, weight_param), bias_param)
  op_times(input_var, weight_param) %>% op_plus(bias_param)

}

output_dim <- num_classes
z <- linear_layer(feature, output_dim)
# dev.off()
visualize_network(z)

# Training ----------------------------------------------------------------

label <- op_input_variable(num_classes)
loss <- loss_cross_entropy_with_softmax(z, label)


# Evaluation --------------------------------------------------------------

eval_error <- classification_error(z, label)


# Configure Training ------------------------------------------------------

learning_rate <- 0.5
lr_schedule <- learning_rate_schedule(learning_rate, UnitType("minibatch"))
learner <- learner_sgd(parameters = z$parameters, lr = lr_schedule)
trainer <- Trainer(model = z, criterion = list(loss, eval_error),
                   parameter_learners = learner)

minibatch_size <- 25
num_samples_to_train <- 20000
num_minibatches_to_train <- as.integer(num_samples_to_train / minibatch_size)

print_training_progress <- function(trainer, mb, frequency, verbose = TRUE) {

  training_loss <- eval_error <- NA

  if (mb %% frequency == 0) {
    training_loss <- trainer$previous_minibatch_loss_average
    eval_error <- trainer$previous_minibatch_evaluation_average

    if (verbose) {
      p <- sprintf("Minibatch: %i, Loss: %f, Error: %f", as.integer(mb), training_loss, eval_error)
      print(p)
    }
  }

  list(mb, training_loss, eval_error)

}


training_progress_output_freq <- 50
plot_dim <- num_minibatches_to_train / training_progress_output_freq
plot_data <- data.frame(batch_size = double(plot_dim),
                        loss = double(plot_dim),
                        error = double(plot_dim))

for (i in 0:num_minibatches_to_train) {

  data <- create_random_data(minibatch_size, input_dim, num_classes)
  features <- data$x
  labels <- data$y

  trainer %>% train_minibatch(dict(feature = features,
                                   label = labels))

  res <- print_training_progress(trainer, i, training_progress_output_freq)
  batchsize <- res[[1]]
  loss <- res[[2]]
  error <- res[[3]]

  if (!is.na(loss) & !is.na(error)) {
    j <- i / 50
    plot_data[j, ] <- c(batchsize, loss, error)
  }

}

plot_data %>% gather(key = metric, value = loss, -batch_size) %>%
  ggplot(aes(x = batch_size, y = loss, colour = metric)) +
  geom_line(linetype = "dashed") +
  facet_wrap(~ metric, scales = "free_y") +
  theme_minimal() +
  labs(title = "Loss and Error Across Minibatches")
