library(tidyverse)

# Set seed for reproducibility
set.seed(2024)

# Shared parameters
n_questions <- 5
n_participants <- 1000
base_prob_mean <- 0.5
base_prob_sd <- 0.1
between_subjects_sd <- 0.1
within_subject_sd <- 0.1

# Function to generate data for one condition
generate_condition_data <- function(positive_mean, negative_mean, condition_name, id_offset = 0) {
  # Generate baseline probabilities for the 5 questions
  question_baselines <- tibble(
    question_id = 1:n_questions,
    baseline_prob = pmax(pmin(rnorm(n_questions, base_prob_mean, base_prob_sd), 1), 0)
  )
  
  # Generate participant-specific mean probabilities
  participant_effects <- tibble(
    participant_id = (id_offset + 1):(id_offset + n_participants),
    positive_participant_prob = pmax(pmin(rnorm(n_participants, positive_mean, between_subjects_sd), 1), 0),
    negative_participant_prob = pmax(pmin(rnorm(n_participants, negative_mean, between_subjects_sd), 1), 0)
  )
  
  # Create data frame
  expand_grid(
    participant_id = (id_offset + 1):(id_offset + n_participants),
    question_id = 1:n_questions
  ) %>%
    left_join(question_baselines, by = "question_id") %>%
    left_join(participant_effects, by = "participant_id") %>%
    mutate(
      condition = condition_name,
      persuasion_direction = if_else(question_id <= 3, "positive", "negative")
    ) %>%
    mutate(
      baseline_response = rbinom(n(), 1, baseline_prob)
    ) %>%
    mutate(
      actual_prob = case_when(
        persuasion_direction == "positive" ~ pmax(pmin(
          rnorm(n(), positive_participant_prob, within_subject_sd), 1), 0),
        persuasion_direction == "negative" ~ pmax(pmin(
          rnorm(n(), negative_participant_prob, within_subject_sd), 1), 0)
      ),
      actual_response = rbinom(n(), 1, actual_prob)
    ) %>%
    mutate(
      difference_score = case_when(
        persuasion_direction == "positive" ~ actual_response - baseline_response,
        persuasion_direction == "negative" ~ baseline_response - actual_response
      )
    )
}

# Generate data for both conditions with unique participant IDs
llm_data <- generate_condition_data(
  positive_mean = 0.85,
  negative_mean = 0.15,
  condition_name = "llm",
  id_offset = 0
)

human_data <- generate_condition_data(
  positive_mean = 0.65,
  negative_mean = 0.35,
  condition_name = "human",
  id_offset = n_participants
)

# Combine datasets
combined_data <- bind_rows(llm_data, human_data)