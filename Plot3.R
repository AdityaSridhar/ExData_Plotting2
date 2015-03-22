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

# Subset the data relevant to Baltimore City
baltimoreData <- subset(NEI, NEI$fips == "24510")

# Group the Baltimore data by year and type. Summarise with sum total of emissions for each year.
baltimoreSummary <-summarise(group_by(baltimoreData,year,type), sum(Emissions))

# Make the column names of the summary prettier.
colnames(baltimoreSummary) <- c("Year","Type","Total_Emissions")

# Open up a png file to write to.
png(filename = "Plot3.png", width = 500, units = "px")

# Create a ggplot object with the data.
g <- ggplot(baltimoreSummary)

# Add points and apply a facet to get the emission data across different types.
g <- g + geom_point(aes(x = Year, y = Total_Emissions)) +
    facet_grid(.~Type) +
    xlab("Year") +
    ylab("Total Emissions") + 
    ggtitle("Total Emissions vs Year across different source types for Baltimore City")

# Print the plot to the graphic device.
print(g)

dev.off()

