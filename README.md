# Slab Mixed Layer Model
This repository contains python and matlab implementations of the slab mixed layer model

## Installation

### Python

Requires Python >=3.12. Not published to PyPI — install directly from GitHub:

```bash
pip install "slabmodel @ git+https://github.com/Stanford-Thomas-Group/slab-mixed-layer-model.git#subdirectory=python"
```

or with [uv](https://docs.astral.sh/uv/):

```bash
uv add "slabmodel @ git+https://github.com/Stanford-Thomas-Group/slab-mixed-layer-model.git#subdirectory=python"
```

### Matlab

Requires MATLAB R2024b or later. Clone the repository:

```bash
git clone https://github.com/Stanford-Thomas-Group/slab-mixed-layer-model.git
```

and add the `matlab` folder to your MATLAB path:

```matlab
addpath('/path/to/slab-mixed-layer-model/matlab')
```


## Conventions

### Physical parameters

| Symbol | Meaning | Units |
| --- | --- | --- |
| $f$ | Coriolis frequency | $\mathrm{rad/s}$ |
| $r$ | Rayleigh damping coefficient ($r > 0$) | $\mathrm{s}^{-1}$ |
| $\rho_0$ | reference density of the ocean | $\mathrm{kg/m^3}$ |
| $(\tau_x, \tau_y)$ | wind stress components along $(x, y)$ | $\mathrm{Pa}$ |

### Wind direction

- `"polar"` (default) — $\theta$ in radians, positive counterclockwise from the
  x-axis (East), pointing in the direction the wind blows *toward*.
- `"bearing"` — compass bearing $\beta$ in degrees, clockwise from North, giving
  the direction the wind is coming *from*.

$$ \theta = \frac{3\pi}{2} - \beta \pmod{2\pi}. $$

Functions taking a wind direction accept a `convention` argument (`"polar"` or
`"bearing"`, default `"polar"`).

### Wind amplitude

Wind forcing magnitude is passed as `amplitude` with a `units` argument:

- `"m/s"` (default) — the wind speed at 10 m above the sea surface ($U_{10}$),
  converted to wind stress via the Large & Pond (1981) bulk drag coefficient,
  $C_d = 1.2\times10^{-3}$ for $U_{10} < 11~\mathrm{m/s}$ and
  $C_d = (0.49 + 0.065\,U_{10})\times10^{-3}$ for $U_{10} \geq 11~\mathrm{m/s}$,
  giving $\|\tau\| = \rho_{\mathrm{air}} C_d U_{10}^2$ with
  $\rho_{\mathrm{air}} = 1.225~\mathrm{kg/m^3}$.
- `"kts"` — $U_{10}$ in knots, converted to `"m/s"` using
  ($1~\mathrm{kt} = 0.514444~\mathrm{m/s}$) and then to wind stress as above.
- `"Pa"` — `amplitude` is already the wind stress magnitude $\|{\tau}\|$. Use
  this to supply wind stress from a different bulk parameterization.

## Theory

Integrate over the Ekman layer to get the slab mixed layer equations forced by
the wind stress $(\tau_x, \tau_y)$ and damped by Rayleigh damping with
coefficient $r$:

$$ \frac{\mathrm{d} U}{\mathrm{d} t} - fV + rU = \frac{\tau_x}{\rho_0}, $$

$$ \frac{\mathrm{d} V}{\mathrm{d} t} + fU + rV = \frac{\tau_y}{\rho_0}. $$

Let $W = U + \mathrm{i}V$ be the complex transport and $T = \rho_0^{-1}(\tau_x + \mathrm{i} \tau_y)$ the
complex kinematic wind stress, such that:

$$ \frac{\mathrm{d} W}{\mathrm{d} t} + \mathrm{i} fW + rW = T. $$

This is easily solved via an integrating factor:

$$ \frac{\mathrm{d}~}{\mathrm{d} t}\left(W\mathrm{e}^{(r+\mathrm{i} f)t}\right) = T(t)\,\mathrm{e}^{(r+\mathrm{i} f)t}. $$

Thus,

$$ W(t) = W_0\mathrm{e}^{-(r+\mathrm{i} f)(t - t_0)} + \mathrm{e}^{-(r+\mathrm{i} f)t} \int_{t_0}^t T(t')\,\mathrm{e}^{(r+\mathrm{i} f)t'}\,\mathrm{d}t'. $$

This package assumes the boundary condition $W_0 = 0$ at $t_0$ where $t_0$ is the first time in the timeseries.

