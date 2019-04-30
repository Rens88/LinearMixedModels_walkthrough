# LinearMixedModels_walkthrough
A walkthrough of using Linear Mixed Models with random effects (useful for experimental comparisons with different subjects)

ReadMe - Linear Mixed Models (LMM) analysis in R
------------------------------------------------
Any questions, feel free to contact me.

Below a brief explanation of how to use the LMM R scripts (LMM_single and LMM_multiple).
LMM_single concerns the analysis for only 1 Factor (independent variable). This requires many less steps as it is not necessary to verify the coveriance matrix.
LMM_multiple concerns the anlaysis for multiple Factors. With this script you can include many different factors. This implies that you have to test which covariance matrix is most suited. In short, you could say that per Factor it is tested whether the coveriance matrix has to be adapted to the random effects model, or whether it can simply fit a standard model.
For some examples on how I have reported this LMM analysis in the past, see the methods sections of:

* Meerhoff, L. A., De Poel, H. J., & Button, C. (2014). How visual information influences coordination dynamics when following the leader. Neurosci Lett, 582, 12-15. doi: 10.1016/j.neulet.2014.08.022
* Meerhoff, L. A. (2016). Follow the Leader: The Role of Local and Global Visual Information for Keeping Distance in Interpersonal Coordination (Thesis, Doctor of Philosophy). University of Otago. Retrieved from http://hdl.handle.net/10523/6248
* Meerhoff, L.A., De Poel, H.J., Jowett, T.W.D. & Button, C. (2017). Influence of Gait Mode and Body Orientation on Following a Walking Avatar. Human Movement Science, 54, 377-387.
* Meerhoff, L.A., Pettré, J., Lynch, S.D., Crétual, A., & Olivier, A-H. (2018). Collision avoidance with multiple walkers: Sequential or simultaneous interactions? Front. Psychol. 9:2354. doi: 10.3389/fpsyg.2018.02354 https://www.frontiersin.org/articles/10.3389/fpsyg.2018.02354/full
* Meerhoff, L.A., De Poel, H.J., & Button, C. (2019). ‘Walking with avatars’: how visual information is used for regulating distance to other walkers.

------------------------------------------------
------------------------------------------------
------------------------------------------------

First things first - To make the script work, you need to:
1) Set the working directory
2) Declare the filename (.CSV) with the data.
3) Set the dependent variable that you want to examine.
(4) If you want to change the Factor (Independent Variable), you should change that too.)

Each numbered annotation explains a bit of code that you MUST execute (for example using ctrl + enter). There are also some tips and optional steps.
Note that every numbered annotation that requires user input is highlighted with 'USER INPUT'.
Pay close attention to the statements with 'ACTION REQUIRED'. These involve some steps you may need to take depending on your data distribution.

LMM_single
------------------------------------------------
It is entirely described in 20 steps. Note that steps 11-14 are less (or not) relevant for LMM analyses with a single factor. Typically, a single factor analysis should not require much 'ACTION REQUIRED'.

LMM_multiple
------------------------------------------------
Under 6), make sure you also load the other factors you want to include in your model.
Under 7), make sure you set the other other factors as factors. And for bwplot, you can also create these for the other factors.
Note that under 9a) I've given an example with the non-existing factors 'anotherFactor1' and 'anotherFactor2'.
Note that subsequently under 10) there are many more models to test for the lowest AIC.
Note that the model may not converge. You can set the maximum computation time using ", control = lmeControl(maxIter = 100 , msMaxIter =100, niterEM = 50 )" in the same line as the weights.
Under 15), you now have to test each factor separately. Especially if your main factor is behaving badly, you must try to improve the model (selecting different cov matrix, excluding outliers..).
Under 18-20), you can now export the statistics for each factor (and their interactions separately). Note that it is only meaningful to do this for the factors and interactions that were significant in the ANOVA at 16).


A note on the degrees of freedom
------------------------------------------------
A common question arising from reporting these LMMs will be how the degrees of freedom were determined.The short answer is that the degrees of freedom vary per dependent variable (which can be confusing if you present multiple variables in your paper), because the final model to which the statistics were applied were optimized using Akaike’s information criterion. That is, for some variables, all possible combinations of main effects and interaction effects may be included, whereas for others some of the possible combinations could be omitted.
The degrees of freedom can be computed using:
denDF = m_2 - (m_1 + p_2)
Where m_2 is total number of valid observations (NB: when using this is a repeated measures, the number of observiations is equal to the number of trials)
Where m_1 is the number of groups (NB: when using this is a repeated measures, the number of groups is equal to the number of participants)
And where p_2 are the degrees of freedom corresponding to the terms that are included in the final model.
p_2 can be calculated by -for each factor in the term- multiplying the cardinality - 1.
Consider the following example:
Your dataset contains the following independent variables: var1 with cardinality of 5, var2 with cardinality of 2 and var3 with cardinality 3.
Your dataset contains 15 participants (your level 1 grouping variable) and in total 545 valid (without missing cases) observations
Your final model includes: var1 + var2 + var3 + var2:var3
m_2 = 545
m_1 = 15
p_2 = (5 - 1) + (2 - 1) + (3 - 1) + ((2-1) * (3-1))
    = 9
denDF = 545 - (15 + 9)
      = 521

For more information, see:
Goldstein, H., Healy, M. J., & Rasbash, J. (1994). Multilevel time series models with applications to repeated measures data. Stat Med, 13(16), 1643-1655. 
