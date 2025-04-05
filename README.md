# Statistical-Stopping-Criteria

The script uses the statistical stopping criteria described by Callaghan and Müller-Hansen (2020) in their paper:

Callaghan, M.W., Müller-Hansen, F. Statistical stopping criteria for automated screening in systematic reviews. Syst Rev 9, 273 (2020). https://doi.org/10.1186/s13643-020-01521-4

For our paper, we extracted time-to-discovery data from completed simulation runs through ASReview, an active learning tool for screening articles for literature reviews using title and abstract:

https://asreview.nl/ 

Time-to-Discovery data, which includes the specific article numbers in which each record was discovered by the screening tool, was used to retroactively assess the p-values at each point in the screening process (i.e. after each labeling instance), which was then used to determine when the simulation should have stopped given a pre-determined significance value (e.g. p < 0.05, p < 0.01). 

For researchers going through a dataset for the first time, the methodologies and tools provided by Callaghan and Müller-Hansen (2020) may be of benefit for determining when to stop the screening process.
