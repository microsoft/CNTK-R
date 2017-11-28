# R Interface to the Microsoft Cognitive Toolkit

Please take a look at the package website [microsoft.github.io/CNTK-R](https://microsoft.github.io/CNTK-R//index.html) for complete documentation.

`CNTK-R` is an R package for [CNTK](https://github.com/microsoft/cntk), which uses the [reticulate package](https://github.com/rstudio/reticulate) to bind to CNTK's Python API. Since it binds directly to Python, the R interface can perform any operation the Python
bindings can, including running on the GPU. See the [CIFAR-10 image classification vignette](https://microsoft.github.io/CNTK-R//articles/cifar10_example.html) to see a basic example of training and evaluation of image classification on the CIFAR-10 dataset.

## Installation

To use CNTK with R you'll need to have the appropriate Python wheel for your system already
installed. See
[CNTK's documentation](https://docs.microsoft.com/en-us/cognitive-toolkit/Setup-CNTK-on-your-machine)
for help setting up CNTK's Python wheel on your system. 

Then run the following to install CNTK's R package:

    devtools::install_github("Microsoft/CNTK-R")
    
You can also take a look at our article on [setting up CNTK and CNTK-R on your machine](https://microsoft.github.io/CNTK-R//articles/installation.html).

## Usage

Documentation is still a work in progress, but the R package closely follows the
CNTK Python interface where possible ([Python docs](https://www.cntk.ai/pythondocs/index.html)). Here's the basic rundown of the differences:

1. Properties are the same as in Python, and are accessed using the dollar sign
   ($) syntax:

```R
l <- Learner(parameters, lrschedule)
l$parameters # returns parameters associated with learner
```

2. Class methods are made global, and take the class object as the first
   property:

```R
learner.update(...) # Python
update_learner(learner, ...) # R equivalent
learner %>% update_learner(...) # R equivalent via pipe
```
Since class methods are made global, some renaming from the original python API was necessary to avoid conflicts. See the [documentation](https://microsoft.github.io/CNTK-R//index.html) for a list of all available functions.

3. R matrices are automatically converted to and from NumPy array's with
   float32 dtype.
4. Python enums are accessed via function argument, e.g.:

```R
UnitType.Error # Python
UnitType("Error") # R equivalent
```
