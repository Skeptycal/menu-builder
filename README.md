# Smart Menu Builder

Various things this project touches upon: APIs, algorithms, simulations, web scraping, NLP, networks.


The main poriton of this project is a daily menu planning and optimization using foods from the [USDA food database](https://ndb.nal.usda.gov/ndb/doc/index) and the `Rglpk` package interface to the [GNU linear programming solver](https://www.gnu.org/software/glpk/) to implement the simplex algorithm. This minimizes the cost of each menu while keeping us above the minimum daily nutrient values and below the daily maximum "must restrict" values.

The latest phase is intended to optimize the tastiness of menus. Menus were scraped from [Allrecipes](http://allrecipes.com)  in order to identify which foods tend to co-occur in menus in which portion sizes. 


## Structure
* `api`
   * Grab data from the USDA API
	* Recursively sends GET requests to the USDA API (in chunks of max 1500 rows at a time)
	* Tidy the JSON and send that chunk to a database (Postgres, MySQL) such that only one chunk is kept in memory at a time
* `data`
    * Raw abbreviated data in `ABBREV.csv`
        * Normalized in `scaled.csv`
    * Daily nutrient constraints in `all_nut_and_mr_df.csv`
* `menu-builder`
    * Code for the [Shiny app](https://amandadobbyn.shinyapps.io/menu-builder/) for building a random menu and tweaking it into compliance
* `scripts`
    * All scripts are stored in sub-directories here. These are pure scripts and do not contain any assignment of data to variables so that they can easily be loaded
    * `prep`
        * Read in, clean, and standardize data
        * Define daily guidelines for
            * "Must restricts" (i.e. macros that have an daily upper limit)
            * "Positive nutrients" (i.e. micronutrients that have a daily lower bound)
    * `build.R` sources all scripts in `build_menu`
        * `build_menu.R` adds random foods (1 serving size per food) until we reach 2300 calories (the daily minimum)
        * `test_compliance.R` tests for compliance on the three dimensions we care about: must restricts, positives, and calorie content
        * `smart_swap.R` loops through must restricts; if the daily value of that must restrict is over the max limit, until we're compliant, swap out the "worst offender" that respect and replace it  
            * if possible, with a food from our corpus that is < 0.5 standard deviations below the mean per gram on that nutrient
            * else, with a random food 
        * `adjust_portion_sizes.R` is a brute force alternative to a linear programming solver that only addresses positive nutrients
            * If the combined amount of a nutrient in our menu is below the minimum, find the food in our menu that is highest in this positive nutrient per gram and increase its amount by 10% until we're above that particular nutrient threshold
            * `adjust_portion_sizes_and_square_calories.R` does the same while decreasing the total calorie count in the amount that it was increased by the adjustment
        * `master_builder.R` does all the above while staying above the 2300 calorie minimum
    * `solve.R` sources in `build.R` and all scripts in `solve` to build a random menu, solve it, do a single smart swap, and test its compliance
        * `solve_it.R` uses the GNU lienar programming solver from the `Rglpk` package to minimize cost while satisfying each nutritional and calorie constraint 
            * First argument is a menu -- with either nutrients in nutrient values per 100g of food or raw gram weight of nutrients, as specified by the `df_is_per_100g` boolean flag
            * Second is a dataframe of nutritional constraints
            * Other levers to pull:
                * Should this be solved with only full portion sizes (integer coefficients on the original portion sizes provided)?
                * Upper and lower bounds for each portion size
                * Should you be told the cost and whether we arrived at a feasible solution?
         * `solve_menu.R` 
             * Take a solution (from `solve_it()`) and return a menu with the newly solved portion sizes (GmWt_1)
             * Optionally be told which food we've got the most of (largest number of portions) -- something we might want to decrease
         * `solve_nutrients.R`
             * Take a solution and get the raw values of each of the nutrients in the solved menu
             * Optionally be told which nutrient we've overshot the most on 
         * `smart_swap_single.R` loops through must restricts only once and, if we're uncompliant, uses the swapping mechanism in `smart_swap()` to find a suitable replacement

    * `score`
        * Give a given menu a score on must-restricts, positive nutrients, and a combined measure
        * Also `rank_foods()` by their score
            * This allows us to build a `naive_supermenu.R` using `build_best_menu()`

   * `simulate`
       * Two types of simulations here: simulating building and solving random menus given a minimum portion size for all ingredients and simulating scraping some menus and determining what proportion of them are bad URLs (404s)
       * Solving:
           * In `simulate_spectrum()`, which calls `get_status()`, we take a range of minimum portion sizes (say from -1 to 1), a number of intervals we want to break that range into, and the number of simulations we want to do at each interval
           * We get back a dataframe with the minimum portion size at each interval and corresponding proportion of menus that could be solved at that min portion size
           * This allows us to graph a curve of how the percent of menus that are solvable changes as we increase the minimum portion size

		* Scraping: 
		    * In `simulate_scrape()` we scrape a random percent of a vector of URLs and determine what proportion of them are Bad URLs
		    * In `simulate_scrape_on_lst()` we take a list of scraped menus (the product of `get_recipes()` before it has gone through `dfize()`) and, for a spectrum of percents of those menus, deterimine what porportion of them are bad
		    * Then we can graph how the variance of the proportion of bad URLs decreases as we increase our sample size
	* `test`
	    * `dobtools::run_tests()` provides a user-directed way to run all or some of the tests in the `testthat` directory, interactively or non-interactively 
	    * There is a test script for each of the main script directories: prep, build, score, scrape, simulate, solve
     
    * Helper functions
        * `get_raw_vals()` and `get_per_g_vals()`, which both take dataframes and a dataframe of nutrients, allow us to go back and forth between nutrients per 100g and raw weight of nutrients using the helper functions 
        * `transpose_menu()` makes foods into columns and nutrients into rows, leaving us with something that looks more like our constraint matrix and can be read left to right
     * `full_scripts` are the legacy scripts containing all building and solving functions; will likely be deprecated soon 

                 
***

* Potential future improvements
    * Implement a calorie ceiling in addition to the floor of 2300
    * Balance menus by food group
    * Spread the portion adjustment across multiple foods once we hit a certain threshold rather than increasing only the best food incrementally by 10%
    * Build three distinct meals per menu
        * Incorporate food flavor profiles to increase flavor consistency within a meal
    * Cluster analyses
        * Can we reverse-engineer food groups?

***



