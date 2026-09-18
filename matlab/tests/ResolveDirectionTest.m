classdef ResolveDirectionTest < matlab.unittest.TestCase

    methods (Test)
        function polarIsPassthrough(testCase)
            direction = [0.0, 1.0, 2.0];
            testCase.verifyEqual(slabmodel.resolveDirection(direction, "polar"), direction)
        end

        function bearingFromNorthBlowsSouth(testCase)
            % Wind reported as coming FROM the North (bearing=0) blows TOWARD
            % the South, i.e. polar angle -pi/2 == 3*pi/2.
            result = slabmodel.resolveDirection(0.0, "bearing");
            testCase.verifyEqual(result, 1.5 * pi, "RelTol", 1e-12)
        end

        function bearingFromEastBlowsWest(testCase)
            result = slabmodel.resolveDirection(90.0, "bearing");
            testCase.verifyEqual(result, pi, "RelTol", 1e-12)
        end

        function bearingFromSouthBlowsNorth(testCase)
            result = slabmodel.resolveDirection(180.0, "bearing");
            testCase.verifyEqual(result, pi / 2.0, "RelTol", 1e-12)
        end

        function bearingFromWestBlowsEast(testCase)
            result = slabmodel.resolveDirection(270.0, "bearing");
            testCase.verifyEqual(result, 0.0, "AbsTol", 1e-12)
        end

        function unknownConventionRaises(testCase)
            testCase.verifyError(@() slabmodel.resolveDirection(0.0, "sideways"), ...
                "MATLAB:validators:mustBeMember")
        end
    end

end
