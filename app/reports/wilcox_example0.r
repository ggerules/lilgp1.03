# Data in two numeric vectors
women_weight <- c(38.9, 61.2, 73.3, 21.8, 63.4, 64.6, 48.4, 48.8, 48.5)
men_weight <-   c(67.8, 60, 63.4, 76, 89.4, 73.3, 67.3, 61.3, 62.4) 
# Create a data frame
my_data <- data.frame( 
                group = rep(c("Woman", "Man"), each = 9),
                weight = c(women_weight,  men_weight)
                )
print(my_data)
library(dplyr, quietly=TRUE, warn.conflicts = FALSE)
group_by(my_data, group) %>%
  summarise(
    count = n(),
    median = median(weight, na.rm = TRUE),
    IQR = IQR(weight, na.rm = TRUE)
  )

# Plot weight by group and color by group
library("ggpubr")
ggboxplot(my_data, x = "group", y = "weight", 
          color = "group", palette = c("#00AFBB", "#E7B800"),
          ylab = "Weight", xlab = "Groups")

print("shapiro.test on women_weight")
res <- shapiro.test(women_weight)
print(res$p.value)
print("From the output, the p-value > 0.05 implying that the distribution of the data are not significantly different from normal distribution. In other words, we can assume the normality.")

print("shapiro.test on men_weight")
res <- shapiro.test(men_weight)
print(res$p.value)
print("From the output, the p-value > 0.05 implying that the distribution of the data are not significantly different from normal distribution. In other words, we can assume the normality.")

print("wilcox.test with params women_weight, men_weight, exact = FALSE")
res <- wilcox.test(women_weight, men_weight, exact = FALSE)
print(res$p.value)

print("The p-value of the test is 0.02712, which is less than the significance level alpha = 0.05. We can conclude that men’s median weight is significantly different from women’s median weight with a p-value = 0.02712.")

print("wilcox.test with params women_weight, men_weight, exact = FALSE, alternative = less")
res <- wilcox.test(women_weight, men_weight, exact = FALSE, alternative = "less")
print(res$p.value)
print("wmean=")
print(mean(women_weight))
print("mmean=")
print(mean(men_weight))

print("wilcox.test with params women_weight, men_weight, exact = FALSE, alternative = greater")
res <- wilcox.test(women_weight, men_weight, exact = FALSE, alternative = "greater")
print(res$p.value)

print("wilcox.test with params women_weight, men_weight, exact = FALSE, alternative = two.side")
res <- wilcox.test(women_weight, men_weight, exact = FALSE, alternative = "two.side")
print(res$p.value)
quit()

#2) Compute two-samples Wilcoxon test - Method 2: The data are saved in a data frame.

res <- wilcox.test(weight ~ group, data = my_data, exact = FALSE)
# Print the p-value only
print(res$p.value)

#The p-value of the test is 0.02712, which is less than the significance level alpha = 0.05. We can conclude that men’s median weight is significantly different from women’s median weight with a p-value = 0.02712.
print("The p-value of the test is 0.02712, which is less than the significance level alpha = 0.05. We can conclude that men’s median weight is significantly different from women’s median weight with a p-value = 0.02712.")

#if you want to test whether the median men’s weight is less than the median women’s weight, type this:
res <- wilcox.test(weight ~ group, data = my_data, exact = FALSE, alternative = "less")
print(res$p.value)

#Or, if you want to test whether the median men’s weight is greater than the median women’s weight, type this
res <- wilcox.test(weight ~ group, data = my_data, exact = FALSE, alternative = "greater")
print(res$p.value)

quit()
