# Utilities


# Transforms from wide to long dataset
tidyData <- function(data, na.rm = T) {
  # Excludes total counts
  new_data = if(na.rm) data[complete.cases(data),] else data
  formatted_data =  new_data[,c(1,3:ncol(new_data))]
  gather_(
    data=formatted_data,
    key_col="Unit Type",
    value_col="Unit Count (million)",
    gather_cols=colnames(formatted_data)[2:ncol(formatted_data)])
}


exploreTypeVsCount <- function(data,fill_column,legend_title,position="dodge") {

  ggplot(data=data,aes(x=`Unit Type`,y=`Unit Count (million)`,
                               fill=get(fill_column))) +
    geom_col(position=position) +
    guides(fill=guide_legend(title=legend_title)) +
    xlab("")
}