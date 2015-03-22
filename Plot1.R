# Load the dplyr package without warning/messages
suppressWarnings(suppressMessages(library(dplyr)))

# Name of the file containing the data. 
NEIfile <- "summarySCC_PM25.rds"

# Check if file exists on disk, otherwise download the file from the server and unzip it. 
if (!file.exists(NEIfile))
{
    download.file("https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip",
                  destfile = "NEIData.zip")
    unzip("NEIData.zip")
}

# Load the NEI and SCC data. 
NEI <- readRDS(NEIfile)
SCC <- readRDS("Source_Classification_Code.rds")

# Group the NEI data by year and summarise with sum total of emissions for each year.
emiss_by_year<-summarise(group_by(NEI,year), sum(Emissions))

# Open up a png file to write to.
png(filename = "Plot1.png")

# Generate a plot for the emissions data by year.
plot(emiss_by_year,
     xlab = "Year",
     ylab = "Total PM2.5 Emissions",
     main = "Total PM2.5 emissions for the U.S. from 1999-2008")

dev.off()