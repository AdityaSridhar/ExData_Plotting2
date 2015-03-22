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

# Subset the SCC data to only the SCC and Short Name columns.
SCCSubdata <- SCC[,c(1,3)]

# Find all instances of coal combustion-related sources by searching for coal, comb.
matches <- grep(pattern = "(.*comb.*coal)",ignore.case = T, x = SCC$Short.Name)

# Subset the matched data.
coalCombustionData <- SCCSubdata[matches,]

# Merge the NEI and coalCombustionData by the SCC column.
USCoalCombustionData <- merge(x = NEI, y = coalCombustionData, by = "SCC")

# Group the coal combustion data by year. Summarise with sum total of emissions for each year.
USCoalCombustionSummary <-summarise(group_by(USCoalCombustionData,year), sum(Emissions))

# Make the column names of the summary prettier.
colnames(USCoalCombustionSummary) <- c("Year","Total_Coal_Combustion_emissions")

# Open up a png file to write to.
png(filename = "Plot4.png")

# Create a ggplot object with the data.
g <- ggplot(USCoalCombustionSummary)

# Add points.
g <- ggplot(USCoalCombustionSummary, aes(x = Year, y = Total_Coal_Combustion_emissions))
g <- g + geom_point(size = 4, alpha = 1/2) + 
    xlab("Year") +
    ylab("Coal Combustion-related emissions") + 
    ggtitle("Coal Combustion-related emissions (total) vs Year for the U.S.")

# Print the plot to the graphic device.
print(g)

dev.off()
