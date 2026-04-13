# Get a specific EVoC layer

Get a specific EVoC layer

## Usage

``` r
get_layer(x, i)

# S3 method for class 'Evoc'
get_layer(x, i)
```

## Arguments

- x:

  An `Evoc` object.

- i:

  Integer. Layer index to retrieve.

## Value

A named list with `labels`, `membership`, and `persistence` for the
requested layer.
