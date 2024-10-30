# Description for data simulation and statistical analysis scripts

## Overview
The data simulation script (binaryV_v2.R) generates simulated data for a study comparing the persuasive effectiveness of LLMs (Large Language Models) versus humans.
The simulation creates binary response data for two independent groups of participants, with each participant responding to multiple questions under both positive and negative persuasion conditions.

## Parameters

### Sample Size and Structure
- `n_questions`: 5 questions per participant (assumption: every participant is presented with exactly the same 5 questions)
- `n_participants`: 25,000 participants per condition (50,000 total)
- Questions 1-3: Positive persuasion (assumption: Q1 - Q3 are always assigned to the positive persuasion condition)
- Questions 4-5: Negative persuasion (assumption: Q4 and Q5 are always assigned to the negative persuasion condition)

### Probability Parameters
- `base_prob_mean`: 0.5 (baseline probability of correct response)
- `base_prob_sd`: 0.1 (variation in baseline probabilities - each question should have different baseline probabilites at the group level)
- `between_subjects_sd`: 0.1 (individual differences between participants - each participant should exhibit differential baseline probabilites to the questions)
- `within_subject_sd`: 0.1 (variation in individual responses)

### Condition-Specific Parameters
LLM Condition:
- Positive persuasion: 0.8 (strong positive effect)
- Negative persuasion: 0.2 (strong negative effect)

Human Condition:
- Positive persuasion: 0.65 (moderate positive effect)
- Negative persuasion: 0.35 (moderate negative effect)

## Data Structure
The script generates the following variables:
- `participant_id`: Unique identifier for each participant (1-25000 for LLM, 25001-50000 for human)
- `question_id`: Question identifier (1-5)
- `condition`: "llm" or "human"
- `persuasion_direction`: "positive" or "negative"
- `baseline_response`: Binary (0/1) baseline response
- `actual_response`: Binary (0/1) response after persuasion
- `difference_score`: Difference between actual and baseline responses
  * For positive persuasion: actual - baseline
  * For negative persuasion: baseline - actual

## Key Features
1. Maintains independence between conditions (unique participant IDs)
2. Incorporates both between-subject and within-subject variability
3. Generates binary outcomes based on underlying probabilities
4. Calculates difference scores that account for persuasion direction

## Usage
The script outputs a combined data frame (`combined_data`) containing all responses from both conditions, suitable for subsequent analysis of persuasive effectiveness.

## Simulation Assumptions
1. Responses follow a binary distribution
2. Individual differences are normally distributed
3. Question effects are independent
4. No learning or order effects
5. Equal sample sizes across conditions

## Related Analyses
The generated data can be subject to two subsequent Bayesian equivalence testing analyses:

1. Within-Condition Analysis (see eqTestingBayes1.R)
* Examines equivalence between positive and negative persuasion effects within the LLM condition
* Uses Bayesian linear mixed modelling with appropriate ROPE values (only random intercept is included for this example, but random slopes can also be included)
* Focuses on comparing effectiveness of different persuasion directions

Based on the current setting, the results should be as follows:

```
# Test for Practical Equivalence

  ROPE: [-0.10 0.10]

Parameter                    |        H0 | inside ROPE |        95% HDI
-----------------------------------------------------------------------
Intercept                    |  Rejected |      0.00 % |   [0.34, 0.35]
persuasion_directionpositive | Undecided |     32.05 % | [-0.11, -0.09]
```



2. Between-Condition Analysis (see eqTestingBayes2.R)
* Compares overall effectiveness between LLM and human conditions
* Uses Bayesian between-groups comparison (no mixed modelling)
* Assesses whether LLM persuasion is as effective as human persuasion

Based on the current setting, the results should be as follows:

```
# Test for Practical Equivalence

  ROPE: [-0.10 0.10]

Parameter    |       H0 | inside ROPE |      95% HDI
----------------------------------------------------
Intercept    | Rejected |      0.00 % | [0.15, 0.16]
conditionllm | Rejected |      0.00 % | [0.13, 0.14]
```

Both analyses employ Bayesian equivalence testing to assess practical equivalence, allowing for flexible definition of equivalence bounds (ROPE) and providing posterior distributions and credible intervals for comprehensive inference.
