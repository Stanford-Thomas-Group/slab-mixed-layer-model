# slabmodel

Python implementation of the slab mixed layer model. See the [repo root README](../README.md) for the theory and conventions.

## Usage

```python
from slabmodel import slab_transport

result = slab_transport(
    time,  # elapsed seconds
    amplitude,  # wind speed, m/s
    direction,  # compass bearing, degrees
    latitude=45.0,
    convention="bearing",
)
result.U, result.V
```
