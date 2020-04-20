# Load packages ----------------------------------------------------------------

library(tidyverse)
library(gghighlight)

# Load data --------------------------------------------------------------------

ecdc_raw <- read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv")

# Calculate cumulative deaths / confirmed cases ratio --------------------------

ecdc <- ecdc_raw %>%
  mutate(
    death_confirmed_ratio     = total_deaths / total_cases,
    death_confirmed_ratio_lag = lag(death_confirmed_ratio),
    diff_in_ratio             = death_confirmed_ratio - death_confirmed_ratio_lag,
    diff_in_ratio_abs         = abs(diff_in_ratio)
    ) %>%
  relocate(date, total_deaths, total_cases, 
           death_confirmed_ratio, diff_in_ratio, diff_in_ratio_abs) %>%
  group_by(location) %>%
  filter(total_deaths > 9) %>%                             # after 10th confirmed death
  mutate(days_elapsed  = as.numeric(date - min(date))) %>% # calculate days elapsed since 10th death
  ungroup()

# Countries with more than 100 deaths ------------------------------------------

ecdc_mt100_deaths <- ecdc %>%
  group_by(location) %>%
  summarise(max_tot_deaths = max(total_deaths)) %>%
  filter(max_tot_deaths > 100) %>%
  inner_join(ecdc, by = "location")

# Select countries -------------------------------------------------------------

selected_countries <- c(
  "Turkey", 
  "China", 
  "Germany", 
  "Italy",
  "United States", 
  "United Kingdom"
)

# Line plots -------------------------------------------------------------------

avg_death_confirmed_ratio <- ecdc %>%
  group_by(days_elapsed) %>%
  summarise(avg_death_confirmed_ratio = mean(death_confirmed_ratio)) %>%
  ungroup()

ggplot(ecdc) +
  geom_line(aes(x = days_elapsed, y = death_confirmed_ratio, group = location, color = location), size = 0.8) +
  gghighlight(location %in% selected_countries,
              use_direct_label = FALSE,
              unhighlighted_params = list(size = 0.5)) +
  facet_wrap(~ location) +
  guides(color = FALSE) +
  facet_wrap(~ location) +
  theme_minimal() +
  labs(
    x = "Days elapsed since 10th confirmed death",
    y = "Cumulative deaths / confirmed cases ratio",
    title = "Cumulative deaths / confirmed cases ratio",
    subtitle = "All countries"
  ) +
  geom_line(data = avg_death_confirmed_ratio, aes(x = days_elapsed, y = avg_death_confirmed_ratio, group = 1), color = "pink")

# line plot --------------------------------------------------------------------

ggplot(ecdc) +
  geom_line(aes(x = days_elapsed, y = diff_in_ratio, group = location, color = location), size = 0.8) +
  gghighlight(location %in% selected_countries,
              use_direct_label = FALSE,
              unhighlighted_params = list(size = 0.5)) +
  #facet_wrap(~ location) +
  #guides(color = FALSE) +
  theme_minimal() +
  labs(
    x = "Days elapsed since 10th confirmed death",
    y = "Daily difference in total deaths / total confirmed cases ratio",
    title = "Daily differences in total deaths / total confirmed cases ratio",
    subtitle = "Difference calculated as today's ratio minus yesterday's ratio for each day",
    color = "Country"
  )

# heatmaps ---------------------------------------------------------------------

ecdc %>%
  filter(location %in% selected_countries) %>%
  group_by(location) %>%
  arrange(days_elapsed) %>%
  ggplot(aes(x = location, y = days_elapsed)) +
  geom_raster(aes(fill = death_confirmed_ratio)) +
  scale_fill_viridis_c() +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) +
  theme_minimal() +
  labs(
    x = "Country",
    y = "Days elapsed since 10th confirmed death",
    title = "Cumulative deaths / confirmed cases ratio over time",
    fill = "Total deaths / 
total confirmed 
cases ratio"
  )

ecdc %>%
  filter(location %in% selected_countries) %>%
  group_by(location) %>%
  arrange(days_elapsed) %>%
  ggplot(aes(x = location, y = days_elapsed)) +
  geom_raster(aes(fill = diff_in_ratio_abs)) +
  theme_minimal() +
  scale_fill_viridis_c() +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) +
  labs(
    x = "Country",
    y = "Days elapsed since 10th confirmed death",
    title = "Daily absolute differences in cumulative deaths / confirmed cases ratio",
    subtitle = "Difference calculated as today's ratio minus yesterday's ratio for each day",    
    fill = "Absolute diff in 
cumulative deaths / 
confirmed"
  )

ecdc_mt100_deaths %>%
  ggplot(aes(x = days_elapsed, y = fct_reorder(location, diff_in_ratio_abs, sd))) +
  geom_raster(aes(fill = diff_in_ratio_abs)) +
  theme_minimal() +
  scale_fill_viridis_c() +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) +
  labs(
    y = "Country (from least to most variable)",
    x = "Days elapsed since 10th confirmed death",
    title = "Daily absolute differences in cumulative deaths / confirmed cases ratio",
    subtitle = "Difference calculated as today's ratio minus yesterday's ratio for each day",    
    fill = "Absolute diff in 
cumulative deaths / 
confirmed"
  )

# gt ---------------------------------------------------------------------------

ecdc %>%
  select(days_elapsed, location, death_confirmed_ratio) %>%
  filter(location %in% selected_countries) %>% 
  pivot_wider(names_from = location, values_from = death_confirmed_ratio) %>%
  arrange(days_elapsed) %>%
  gt() %>%
  fmt_number(columns = 2:7, decimals = 3) %>%
  fmt_missing(columns = 2:7, missing_text = "") %>%
  data_color(
    columns = 2:7,
    colors = scales::col_numeric(
      palette = "viridis",
      domain = NULL,
      na.color = "white")
  ) %>%
  cols_width(vars(days_elapsed) ~ px(100)) %>%
  cols_label(days_elapsed = "Days elapsed since 10th death")
