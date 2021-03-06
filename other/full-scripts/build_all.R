
source("./scripts/build_and_test.R")

# Swap out must_restricts
smartly_swapped <- smart_swap(menu)
smartly_swapped_cutoff <- smart_swap(menu, cutoff = 3)

# Adjust positive nutrients
more_nutritious <- adjust_portion_sizes(menu)

# Build master menu
master_menu <- master_builder(menu)


# -------------- Score ----------------
pos_score(menu)
pos_score(master_menu)

mr_score(menu)
mr_score(master_menu)

score_menu(menu)
score_menu(master_menu)


# --------- Test Compliances ------
# all
test_all_compliance(menu)
test_all_compliance(master_menu)

# must_restricts
test_mr_compliance(menu)
test_mr_compliance(smartly_swapped)
test_mr_compliance(more_nutritious)
test_mr_compliance(master_menu)

# positives
test_pos_compliance(menu)
test_pos_compliance(smartly_swapped)
test_pos_compliance(more_nutritious)
test_pos_compliance(master_menu)

# calories
test_calories(menu)
test_calories(smartly_swapped)
test_calories(more_nutritious)
test_calories(master_menu)


# Main output we'd want to see
test_all_compliance_verbose(menu)
test_all_compliance(master_menu)


