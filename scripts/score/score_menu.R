
# ------------ Score menus on how nutritional they are ----------------
# - - - More positive scores are always better - - -
# 1) On positive nutrients, you can't get a better score than 0
# 2) On must_restricts, a positive score means you're below the daily maximum on some must_restricts, which is good. 
    # a negative score means you're above the maximum on some must_restricts, which is bad.
# 3) The overall score adds these two together


# -------------------- Positive Nutrients ----------------
# No extra credit for going above the daily min. best score is 0, worst score is negative infinity.

# A positive score on any nutrient would mean you're above the min daily amount. no extra brownie points for that,
    # so we give you a 0
# A negative score on any nutrient means you're below the min daily amount
pos_score <- function(orig_menu) {
  total_nut_score <- 0
  
  for (p in seq_along(pos_df$positive_nut)) {    # for each row in the df of positives
    nut_considering <- pos_df$positive_nut[p]    # grab the name of the nutrient we're examining
    val_nut_considering <- (sum((orig_menu[[nut_considering]] * orig_menu$GmWt_1), 
                                na.rm = TRUE))/100   # get the total amount of that nutrient in our original menu
    
    nut_score <- (-1)*(pos_df$value[p] - val_nut_considering)    # (-1)*(min amount it's supposed to be - amount it is here)
    # print(paste0("nut_score is", nut_score))
    
    if (nut_score > 0) {
      nut_score <- 0
    } else if (is.na(nut_score)) {
      message("Nutrient has no score")
      break
    }
    total_nut_score <- total_nut_score + nut_score
  }
  return(total_nut_score)
}


# -------------------- Must Restricts ----------------
# We both penalize for going over the max daily limit and give you brownie points for getting below the max
# More positive score is better (same directionality of goodness as pos_score)

# A negative score on any one nutrient means you're over the max value you should be: bad
# A negative score means you're below the max: good job
mr_score <- function(orig_menu) {
  total_mr_score <- 0
  
  for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of positives
    mr_considering <- mr_df$must_restrict[m]    # grab the name of the nutrient we're examining
    val_mr_considering <- (sum((orig_menu[[mr_considering]] * orig_menu$GmWt_1), 
                                na.rm = TRUE))/100   # get the total amount of that nutrient in our original menu
    
    mr_score <- mr_df$value[m] - val_mr_considering  # max amount it's supposed to be - amount it is

    total_mr_score <- total_mr_score + mr_score

  }
  return(total_mr_score)
}


# -------------------- Combined Score ----------------
# Sum the two scores
score_menu <- function(orig_menu) {
  healthiness_score <- pos_score(orig_menu) + mr_score(orig_menu)
  return(healthiness_score)
}


