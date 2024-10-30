library(tidyverse)
library(bayestestR)
library(brms)

# Prepare the data
llm_summary <- llm_data %>%
  group_by(participant_id, persuasion_direction) %>%
  summarise(
    mean_diff = mean(difference_score),
    .groups = "drop"
  )

# Fit Bayesian model
bayesian_model <- brm(
  mean_diff ~ persuasion_direction + (1|participant_id),
  data = llm_summary,
  family = gaussian(),
  chains = 4,
  cores = 4,
  iter = 3000,
  warmup = 1000,
  seed = 123,
  prior = c(
    prior(normal(0, 1), class = "Intercept"),
    prior(normal(0, 1), class = "b"),
    prior(exponential(1), class = "sigma"),
    prior(exponential(1), class = "sd")
  )
)

# Model diagnostics
summary(bayesian_model)

# Conduct equivalence test
equiv_test <- equivalence_test(bayesian_model, range = c(-0.1, 0.1))
print(equiv_test)
