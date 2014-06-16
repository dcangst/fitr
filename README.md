# fitR - Growth Rate Fitting in R

## Goal: 
  - easy to use package to fit growth rates using a linear fit sliding window.
  - well definitions for blanking
  - growth/no growth identification
  - minimize steps before fitting routine, ideally directly from plate reader data
  - define easy to use data format for entry.
  - easy data handling


  input:  OD values, times, descriptors
  output: growthrates, quality indicators

  how much flexibility is desired? i.e. saving all fits for each curve?

## outline for fitting function:
  
  0. data prep -> long form? list?
    - separate data prep function ('legacy' support)
  1. blanking
    - different methods?
  2. loop for fitting
    - deciding on growth
      - different methods?
    - fitting if growth == TRUE
  3. output raw data (as list, with element reflecting the options)
    - method to save csv from this list.
  4. diagnostic plots
