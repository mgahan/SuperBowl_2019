
# Bring in libraries
library(data.table)
library(dygraphs)

# List all files
all_files <- fread("aws s3 --profile scott ls s3://havas-data-science/Super_Bowl/ --recursive")
all_files <- all_files[V4 %like% ".csv"]
all_files[, Dir := basename(dirname(dirname(V4)))]

# Latest file
Latest_Files <- all_files[, .SD[.N], by=.(Dir)]

# Check out graphs
Clients_Tst <- Latest_Files[, .N, keyby=.(Dir)]$Dir

pull_data <- function(xPar) {
	print(xPar)
	Current_File <- Latest_Files[Dir==xPar, V4]
	dat <- fread(cmd=paste0("aws s3 --profile scott cp s3://havas-data-science/",Current_File," -"))
	dat[, timestamp := as.POSIXct(date, tz="America/Los_Angeles")]
	this_date <- as.Date(dat[, max(timestamp)])
	if (this_date >= as.Date("2019-02-04")) {
		dat[, timestamp := timestamp - 7*60*60]
	}
	dat[, hits := as.character(hits)]
	dat[hits=="<1", hits := "0.5"]
	dat[, hits := as.numeric(hits)]
	out_plot <- dygraph(dat[, .(timestamp, hits)], main=xPar) %>% 
		dyOptions(useDataTimezone = TRUE)	
	print(out_plot)
	dat[, File := Current_File]
	return(dat[])
}

all_dat <- lapply(Clients_Tst, pull_data)

all_dat <- rbindlist(all_dat, fill=TRUE)
saveRDS(all_dat, "commercial_data.rds")
