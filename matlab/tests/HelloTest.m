classdef HelloTest < matlab.unittest.TestCase

    methods (Test)
        function hello(testCase)
            testCase.verifyEqual(slabmodel.hello(), "Hello from slabmodel!")
        end
    end

end
