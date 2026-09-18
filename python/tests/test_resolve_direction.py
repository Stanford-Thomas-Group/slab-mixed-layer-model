import numpy as np
import pytest

from slabmodel import resolve_direction


def test_polar_is_passthrough():
    direction = np.array([0.0, 1.0, 2.0])
    result = resolve_direction(direction, "polar")
    np.testing.assert_array_equal(result, direction)


def test_bearing_from_north_blows_south():
    # Wind reported as coming FROM the North (bearing=0) blows TOWARD the South,
    # i.e. polar angle -pi/2 == 3*pi/2.
    result = resolve_direction(np.array([0.0]), "bearing")
    assert result[0] == pytest.approx(1.5 * np.pi)


def test_bearing_from_east_blows_west():
    result = resolve_direction(np.array([90.0]), "bearing")
    assert result[0] == pytest.approx(np.pi)


def test_bearing_from_south_blows_north():
    result = resolve_direction(np.array([180.0]), "bearing")
    assert result[0] == pytest.approx(np.pi / 2.0)


def test_bearing_from_west_blows_east():
    result = resolve_direction(np.array([270.0]), "bearing")
    assert result[0] == pytest.approx(0.0, abs=1e-12)


def test_unknown_convention_raises():
    convention: str = "sideways"
    with pytest.raises(ValueError):
        resolve_direction(np.array([0.0]), convention)  # ty: ignore[invalid-argument-type]
