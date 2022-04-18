# An optional custom script to run before Hugo builds your site.
# You can delete it if you do not need it.

## load libraries
library(blogdown)

## check the site
blogdown::check_site()
blogdown::check_netlify()

blogdown::serve_site()
blogdown::stop_server()

## build the site
blogdown::build_site()
