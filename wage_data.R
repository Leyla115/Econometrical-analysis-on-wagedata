
##1.	Data prepara

```{r}
library(tidyverse)
library(dplyr)
df<- read.csv("http://kodu.ut.ee/~avork/files/oppetoo/micro/piaac9Feb2017.csv")
df <- df %>% filter(country == "est", wage>0, !is.na(edcat), !is.na(fathed), !is.na(mothed), !is.na(books)) 
df$lwage <- log(df$wage)  
set.seed(21+03+06)
df <- dplyr::sample_frac(df, 0.9)

```


##2.	Linear regression model  ## 

```{r}
olsmodel <- lm(lwage ~ factor(ageg5lfs) + male + edcat + whours, data=df)
summary(olsmodel)
```

#If education increases by one unit, then wages increase on average 11.9%

 
            Present the model results in a stargazer-like table

```{r}
library(stargazer)
stargazer(olsmodel, type='text', dep.var.labels=c("olsmodel"))

```


##3. Next, estimate manually two-step least squares ##


a) In the first stage, estimate the regression model where education (edcat) depends on father's and mother's education (treated as continuo us) and number of books. All these three variables are used as instruments. Add also other explanatory variables from the original regression model. (They must be included.)

```{r}
ivmodelstep1 <- lm(edcat ~ factor(ageg5lfs) + male + whours + fathed + mothed + books, data=df)

```

b)	Use F-test (anova command) to test if fathed, mothed and books are jointly statistically significant. (This is a test of weak instruments. It tests if instruments are related to the problematic variable). Hint: you need to estimate another model where edcat depends only on factor(ageg5lfs), male, whours.


```{r}
ivmodelstep1 <- lm(edcat ~ factor(ageg5lfs) + male + whours + fathed + mothed + books, data=df)
ivmodelstep1restricted <- lm(edcat ~ factor(ageg5lfs) + male + whours, data=df) 
anova(ivmodelstep1, ivmodelstep1restricted)
```
#in order to test weak insturments we use F test. It tests if instruments are related to the problematic variable. 
#We state hypothesis
#H0=weak insturment (do not explain the regression variable)
#H1=reject weak insturment
#if p>0.05 do not rwjwct NH.   #F-statistic 230.33, p=2.2e-16 ***  We reject NH



c)	Predict both predicted values and predicted residuals from the first step

```{r}
df$edcathat <- predict(ivmodelstep1)
df$vhat <- residuals(ivmodelstep1) 


```

d)	Estimate the second stage of the 2SLS in two ways

```{r}
ivmodelstep2a <- lm(lwage ~ factor(ageg5lfs) + male + edcathat + whours, data=df)
summary(ivmodelstep2a)
ivmodelstep2b <- lm(lwage ~ factor(ageg5lfs) + male + edcat + whours + vhat, data=df)
summary(ivmodelstep2b)


```

#Check that the parameter of education is the same in both cases: 

#In both cases education parametr equals to 0.1998414



*Did the parameter of education change in the expected direction when you compare OLS and IV estimates? If not, what could be the     explanation?       Yes, the parametr of education has changed while comparing OLS ( 0.1188328) and IV estimate(0.1998414)

```{r}
library(stargazer)
stargazer(olsmodel,ivmodelstep2b, type="text")

```


e) Use the t-test or anova command to test if the vhat is statistically significant in the second stage regression.

```{r}
anova(olsmodel,ivmodelstep2b)

```



##4. Estimate the instrumental variable regression model with the command ##

```{r}
library(AER)  
library(ivmodel)
library(sandwich)
library(survival)
library(zoo)
library(dplyr)

ivmodel<-ivreg(formula = lwage ~ factor(ageg5lfs) + male + edcat + whours | 
                 factor(ageg5lfs) + male + whours + fathed + mothed + books, data=df)
summary(ivmodel)


```


               
              Check that you get the same coefficient of education that you got manually.
              
#according to stargazer table coefficient of education is the same with manually way(0.200***)

```{r}
library(stargazer)
stargazer(ivmodelstep2a, ivmodelstep2b,ivmodel, type="text")


```

     
     What is the quantitative effect of education on wages in the IV model? Present the model results in a stargazer-like table.

#If education increases by one unit, then wages increase on average 20%


```{r}
summary(ivmodel, diagnostics = TRUE)

```

## 4- 1)  an F test of the first stage regression for weak instruments (that you did manually above). We want this to be statistically significant (p <.05).##



#in order to test weak insturments we use F test. It tests if instruments are related to the problematic variable. 
#We state hypothesis
#H0=weak insturment (do not explain the regression variable)
#H1=reject weak insturment
#if p>0.05 do not reject NH.   #F-statistic 230.33, p=2e-16 *** Therefore,  We reject NH


 

## 4-2) a Wu-Hausman test 
```{r}
waldtest(lm(formula=lwage ~ factor(ageg5lfs) + male + edcat + whours, data=df), lm(formula=lwage ~ factor(ageg5lfs) + male + edcat + whours + vhat, data=df), test = "Chisq")

```
#H0: cor(u, x2)=0
#H1: cor(u,x2) not equal 0     if p>0.05 do not reject NH
#if we do not reject NH, OLS will be consistent, if we reject NH,  2SLS will be more consistent 

# in our case , (p<0.05) residual is statistically significant then parameters of OLS and IV are statistically different, therefore it suggests that we should use IV. 



## 4-3) a Sargan test of overidentifying restrictions##

```{r}
sargan_regmodel<-lm(ivmodel$residuals~factor(ageg5lfs) + male +whours+fathed + mothed + books, data=df)
summary(sargan_regmodel)

Sargan_test <- summary(sargan_regmodel)$r.squared*nrow(sargan_regmodel$model)
print(Sargan_test)
print(1-pchisq(Sargan_test,2))  # prints p-value

```
# H0: instruments are valid (intruments exogenity, corellation betwen instruments and residuals is equal zero)
# H1: reject NH  instruments are invalid (instruments endogenous)

# if p>0.05 do not rejet Null hypothesis, p>0.05 we reject NH
#as a result of sargan model we got p value 0.03 which lower than 0.05. We reject NH. So, our instruments are invalid.

#One of the three instruments is invalid which is books.


#We are satisfied with 2 istrumets(fathed and mothed) because there is not correlation between residual and theese instruments. However, we are not satisfied with books instrumets because there is correlation between resual and book.

#We can explain economic relationship, women with average level of education tend to marry men who at least have the same level of knowledge. Considering this fact they seek ways to give good education to their children. But even on average with the same level of education people chooose different jobs on labor market, for example a man graduated from university can choose to work at university as professor and earn rather less money that if he worked in a company in a good position.  To conclude high education does not mean high earnings foreach individual. 




















