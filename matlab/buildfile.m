function plan = buildfile()
import matlab.buildtool.tasks.CodeIssuesTask
import matlab.buildtool.tasks.TestTask

addpath(fileparts(mfilename("fullpath")));

plan = buildplan();
plan("check") = CodeIssuesTask(WarningThreshold=0, ErrorThreshold=0);
testTask = TestTask(SourceFiles="+slabmodel", TestResults="test-results/results.xml");
plan("test") = testTask.addCodeCoverage("code-coverage/coverage.xml");
end
