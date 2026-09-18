classdef ComputeKinematicWindStressTest < matlab.unittest.TestCase

    properties (Constant)
        RhoAir = 1.225
    end

    methods (Test)
        function paUnitsJustDividesByRho0(testCase)
            amplitude = [10.0, 20.0];
            result = slabmodel.computeKinematicWindStress(amplitude, "Pa", 1025.0);
            testCase.verifyEqual(result, amplitude / 1025.0)
        end

        function ktsMatchesEquivalentMs(testCase)
            speedKts = [5.0, 12.0, 20.0];
            speedMs = speedKts * 0.514444;
            resultKts = slabmodel.computeKinematicWindStress(speedKts, "kts", 1025.0);
            resultMs = slabmodel.computeKinematicWindStress(speedMs, "m/s", 1025.0);
            testCase.verifyEqual(resultKts, resultMs, "RelTol", 1e-12)
        end

        function lowWindSpeedDragCoefficient(testCase)
            % Large & Pond (1981): Cd = 1.2e-3 for U10 < 11 m/s.
            rho0 = 1025.0;
            expectedTau = testCase.RhoAir * 1.2e-3 * 5.0^2;
            result = slabmodel.computeKinematicWindStress(5.0, "m/s", rho0);
            testCase.verifyEqual(result, expectedTau / rho0, "RelTol", 1e-12)
        end

        function highWindSpeedDragCoefficient(testCase)
            % Large & Pond (1981): Cd = (0.49 + 0.065*U10)*1e-3 for U10 >= 11 m/s.
            rho0 = 1025.0;
            cd = (0.49 + 0.065 * 15.0) * 1e-3;
            expectedTau = testCase.RhoAir * cd * 15.0^2;
            result = slabmodel.computeKinematicWindStress(15.0, "m/s", rho0);
            testCase.verifyEqual(result, expectedTau / rho0, "RelTol", 1e-12)
        end

        function unknownUnitsRaises(testCase)
            testCase.verifyError(@() slabmodel.computeKinematicWindStress(1.0, "furlongs/fortnight", 1025.0), ...
                "MATLAB:validators:mustBeMember")
        end
    end

end
