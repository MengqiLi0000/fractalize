# ```fractalize```
Takes a numeric time series (from a ```data.frame``` or ```data.table```) and transforms it into a fractal time series
<img src="https://github.com/user-attachments/assets/bc0c17bf-740d-4b6e-b059-420d025d8c0e" width="400"/>

## Introduction

The `fractalize` R package is designed to help you understand, estimate, and construct **fractal time series**. These are sequences that exhibit self-similarity over time, a property commonly found in nature, physiology, and complex systems.

Unlike traditional time series that assume fixed structure (e.g., ARMA models) or randomness (white noise), fractal time series capture **scale-free** dependencies — patterns that repeat no matter how far you zoom in or out.

This package allows you to:
- Estimate the fractal dimension (DFA alpha) of your data
- Transform existing time series to follow a fractal structure
- Automatically adjust data to match a target level of complexity


## What is a Fractal in Time?

### Spatial Fractals
In space, a fractal is a geometric object whose parts resemble the whole:
- Tree branches
- Coastlines
- Lungs

These systems show **self-similarity** across scales.

### Temporal Fractals
In time series, the fractal equivalent is a signal where:
- Variability occurs at many time scales
- Short-term and long-term behaviors are intertwined
- There is **no characteristic scale**

This is quantified by the **DFA alpha exponent**:

- `α ≈ 0.5`: white noise (uncorrelated randomness)
- `α ≈ 1.0`: pink noise (fractal-like, adaptive)
- `α ≈ 1.5`: brown noise (strong persistence)

## Background: Detrended Fluctuation Analysis (DFA)

DFA is a method to measure long-range correlations in non-stationary time series. Here's how it works:
(sorry for the layout, github does not support latex rendering)
1. **Integrate the time series**:  
   Y(i) = Σᵢ₌₁ⁱ (xᵢ - x̄)

2. **Divide into windows of length s**

3. **Fit a linear trend and subtract**:  
   Fₛ(i) = Y(i) - yₛ(i)

4. **Compute RMS fluctuation**:  
   F(s) = sqrt(1/N · Σ₁ⁿ Fₛ(i)²)

5. **Estimate α** from slope of log-log plot:  
   log F(s) ≈ α · log s
