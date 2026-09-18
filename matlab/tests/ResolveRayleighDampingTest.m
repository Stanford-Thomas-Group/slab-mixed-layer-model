classdef ResolveRayleighDampingTest < matlab.unittest.TestCase

    methods (Test)
        function rGivenDirectly(testCase)
            testCase.verifyEqual(slabmodel.resolveRayleighDamping(1.0e-4, 1.5e-5, []), 1.5e-5)
        end

        function neitherGivenDefaultsToZero(testCase)
            testCase.verifyEqual(slabmodel.resolveRayleighDamping(1.0e-4, [], []), 0.0)
        end

        function factorGivenPositiveF(testCase)
            testCase.verifyEqual(slabmodel.resolveRayleighDamping(1.0e-4, [], 0.1), 1.0e-5, "RelTol", 1e-12)
        end

        function factorGivenNegativeFStaysPositive(testCase)
            % Southern Hemisphere: f < 0, r must still come out positive.
            testCase.verifyEqual(slabmodel.resolveRayleighDamping(-1.0e-4, [], 0.1), 1.0e-5, "RelTol", 1e-12)
        end

        function bothGivenRaises(testCase)
            testCase.verifyError(@() slabmodel.resolveRayleighDamping(1.0e-4, 1.0e-5, 0.1), ...
                "slabmodel:resolveRayleighDamping:invalidArguments")
        end
    end

end
