# Slab Mixed Layer Model
This repository contains python and matlab implementations of the slab mixed layer model

## Installation

### Python

### Matlab


## Conventions

### Physical parameters

| Symbol | Meaning |
| --- | --- |
| $f$ | Coriolis parameter |
| $r$ | Rayleigh damping coefficient ($r > 0$) |
| $\rho_0$ | reference density of the ocean |
| $H$ | mixed layer depth |
| $(\tau_x, \tau_y)$ | wind stress components along $(x, y)$ |

### Wind direction

- `"polar"` (default) — $\theta$ in radians, positive counterclockwise from the
  x-axis (East), pointing in the direction the wind blows *toward*.
- `"bearing"` — compass bearing $\beta$, clockwise from North, giving the
  direction the wind is coming *from*.

$$ \theta = \frac{3\pi}{2} - \beta \pmod{2\pi} $$

Functions taking a wind direction accept a `convention` argument (`"polar"` or
`"bearing"`, default `"polar"`).

### Wind amplitude

Wind forcing magnitude is passed as `amplitude` with a `units` argument:

- `"m/s"` (default) — wind speed, converted to wind stress magnitude
  $\|{\tau}\|$ via a bulk parameterization.
- `"kts"` — wind speed, converted to `"m/s"` using ($1~\mathrm{kt} = 0.514444~\mathrm{m/s}$) and then to wind stress magnitude.
- `"Pa"` — `amplitude` is already the wind stress magnitude $\|{\tau}\|$.

## Theory

Integrate over the Ekman layer, with unspecified depth $H$, to get the slab
mixed layer equations forced by the wind stress $(\tau_x, \tau_y)$ and damped by
Rayleigh damping with coefficient $r$:

$$ \frac{\mathrm{d} U}{\mathrm{d} t} - fV + rU = \frac{\tau_x}{\rho_0} $$

$$ \frac{\mathrm{d} V}{\mathrm{d} t} + fU + rV = \frac{\tau_y}{\rho_0} $$

### Complex formulation

Let $W = U + \mathrm{i}V$, such that 

$$ \frac{\mathrm{d} W}{\mathrm{d} t} + \mathrm{i} fW + rW = \rho_0^{-1}(\tau_x + \mathrm{i} \tau_y) $$

$$ \frac{\mathrm{d}~}{\mathrm{d} t}\left(W\mathrm{e}^{(r+\mathrm{i} f)t}\right) = \rho_0^{-1}(\tau_x + \mathrm{i} \tau_y)\mathrm{e}^{(r+\mathrm{i} f)t} $$

### Exact solution

Expressing the wind stress in polar form,
$\rho_0^{-1}(\tau_x + \mathrm{i} \tau_y) = \tilde{\tau} \mathrm{e}^{\mathrm{i} \theta}$:

$$ W = \mathrm{e}^{-(r+\mathrm{i} f)t} \int \tilde{\tau}(t)\mathrm{e}^{(r+\mathrm{i} f)t + \mathrm{i}\theta (t)}\mathrm{d}t $$

$$ U = \mathrm{e}^{-rt}\cos(ft) \int \tilde{\tau}(t) \mathrm{e}^{rt}\cos(ft + \theta(t) )\mathrm{d}t + \mathrm{e}^{-r t}\sin(ft) \int \tilde{\tau}(t)\mathrm{e}^{rt}\sin(ft + \theta(t)) \mathrm{d}t $$

$$ V = \mathrm{e}^{-rt}\cos(ft) \int \tilde{\tau}(t) \mathrm{e}^{rt}\sin(ft + \theta(t) )\mathrm{d}t - \mathrm{e}^{-r t}\sin(ft) \int \tilde{\tau}(t)\mathrm{e}^{rt}\cos(ft + \theta(t)) \mathrm{d}t $$

