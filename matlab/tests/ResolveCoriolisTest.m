classdef ResolveCoriolisTest < matlab.unittest.TestCase

    properties (Constant)
        Omega = 7.2921159e-5
    end

    methods (Test)
        function fGivenDirectly(testCase)
            testCase.verifyEqual(slabmodel.resolveCoriolis(1.23e-4, []), 1.23e-4)
        end

        function latitudeEquatorGivesZeroF(testCase)
            testCase.verifyEqual(slabmodel.resolveCoriolis([], 0.0), 0.0, "AbsTol", 1e-15)
        end

        function latitudeNorthPole(testCase)
            testCase.verifyEqual(slabmodel.resolveCoriolis([], 90.0), 2.0 * testCase.Omega, "RelTol", 1e-12)
        end

        function latitudeSouthPole(testCase)
            testCase.verifyEqual(slabmodel.resolveCoriolis([], -90.0), -2.0 * testCase.Omega, "RelTol", 1e-12)
        end

        function latitudeMatchesFormula(testCase)
            latitude = 37.5;
            expected = 2.0 * testCase.Omega * sind(latitude);
            testCase.verifyEqual(slabmodel.resolveCoriolis([], latitude), expected, "RelTol", 1e-12)
        end

        function bothGivenRaises(testCase)
            testCase.verifyError(@() slabmodel.resolveCoriolis(1.0e-4, 45.0), ...
                "slabmodel:resolveCoriolis:invalidArguments")
        end

        function neitherGivenRaises(testCase)
            testCase.verifyError(@() slabmodel.resolveCoriolis([], []), ...
                "slabmodel:resolveCoriolis:invalidArguments")
        end
    end

end
