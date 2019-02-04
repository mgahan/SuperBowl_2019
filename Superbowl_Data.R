
# Bring in libraries
library(data.table)
library(gtrendsR)
setwd("/home/mgahan")

# Key companies
key_companies <- c("washington post","adp","girl power","burger king",
	"Persil ProClean","devour Foods","Doritos","BON & VIV Spiked Seltzer","Pizza Hut",
	"Colgate","coca cola","olay killer skin","the journey","pet comfort","hobbs and shaw",
	"steve carell","audi etron","yellowtail","maroon 5","spongebob","gladys knight","west point georgia",
	"telluride","jobs for veterns","escobar syndrome","trojan horse")

# Read in data
retrieve_data_func <- function(company_par) {
	
	# Current time company_par
	print(company_par)
	Current_Time <- Sys.time()
	Current_Time <- gsub("\\s+","_",gsub("[-:]","",Current_Time))
	
	# Update Company name
	Company_Name <- gsub("\\s+", "_", company_par)
	
	# Create outfiles
	out_rds <- paste0(Company_Name,"_",Current_Time,".rds")
	out_csv <- paste0(Company_Name,"_",Current_Time,".csv")
	
	# Pull data
	dat_list <- gtrends(company_par, time = "now 4-H", geo = "US") 
	
	# Organize data
	dat <- as.data.table(dat_list$interest_over_time)
	dat[, date := date-3*60*60]
	dat[, date := as.character(date)]
	fwrite(dat, out_csv)
	saveRDS(dat_list, out_rds)
	
	# Upload to S3
	upload_txt_rds <- paste0("aws s3 --profile scott mv ", out_rds, " s3://havas-data-science/Super_Bowl/",Company_Name,"/Lists/",out_rds)
	upload_txt_csv <- paste0("aws s3 --profile scott mv ", out_csv, " s3://havas-data-science/Super_Bowl/",Company_Name,"/CSVs/",out_csv)
	upload_sys_rds <- system(upload_txt_rds, intern=TRUE)
	upload_sys_csv <- system(upload_txt_csv, intern=TRUE)
	
	# Return output
	return(company_par)
	
}

# Error handling
retrieve_data_trycatch <- function(company_par_iter) {
	output_attempt <- tryCatch(
		{
			retrieve_data_func(company_par=company_par_iter)
		},
		error=function(cond) {
			return(paste0(company_par_iter," had error"))
		},
		warning=function(cond) {
		},
		finally={
			return(paste0(company_par_iter," had error"))
		}
	)
	return(output_attempt)
}


# Create loop
for (xComp  in key_companies) {
		retrieve_data_trycatch(company_par_iter=xComp)
		Sys.sleep(30)
}
print(Sys.time())

# Asis schedule
# */45 * * * *
# dat <- fread("aws s3 --profile scott cp s3://havas-data-science/Super_Bowl/capillus/CSVs/capillus_20190202_162901.csv -")
# dat[, timestamp := as.POSIXct(date, format="%Y-%m-%d %H:%M:%S")]
# library(dygraphs)
# dygraph(dat[, .(timestamp, hits)])