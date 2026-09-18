# slabmodel

MATLAB implementation of the slab mixed layer model. See the [repo root README](../README.md) for the theory and conventions.

## Usage

```matlab
[U, V] = slabmodel.slabTransport(...
    time, ...        % elapsed seconds
    amplitude, ...    % wind speed, m/s
    direction, ...    % compass bearing, degrees
    latitude=45.0, ...
    convention="bearing");
```
