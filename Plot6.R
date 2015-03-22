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

# Subset the data relevant to LA County and Baltimore City.
LABaltimoreData <- subset(NEI, NEI$fips == "06037" | NEI$fips == "24510")

# Find all instances of motor vehicle sources by grepping for "vehicle" in the EI.Sector column.
vehicledata <- grep("vehicle",ignore.case = T, x = SCC$EI.Sector)

# Subset the matched data.
SCCMotorVehicleData <- SCC[vehicledata,]
SCCMotorVehicleData <- SCCMotorVehicleData[,c(1,2)]

# Merge the NEI and SCCMotorVehicleData by the SCC column.
LABaltimoreMotorVehicleData <- merge(LABaltimoreData, SCCMotorVehicleData, by = "SCC")

# Group the motor vehicle data by year. Summarise with sum total of emissions for each year.
LABaltimoreSummary <-summarise(group_by(LABaltimoreMotorVehicleData,year,fips), sum(Emissions))

# Make the column names of the summary prettier.
colnames(LABaltimoreSummary) <- c("Year","County","Motor_Vehicle_Emissions")

# Make the County data into a factor.
LABaltimoreSummary$County <- as.factor(LABaltimoreSummary$County)

# Give meaningful names to the factor levels.
levels(LABaltimoreSummary$County) <- c("Los Angeles","Baltimore")

# Open up a png file to write to.
png(filename = "Plot6.png")

# Create a ggplot object with the data.
# Color the data with the County variable.
# Taking log of the emission data to facilitate easier comparison across the two counties.
g <- ggplot(LABaltimoreSummary, aes(x = Year, y = log(Motor_Vehicle_Emissions), color = County))
g <- g + geom_point(size = 4, alpha = 1/2) +
    xlab("Year") +
    ylab("log(Motor Vehicle Emissions)") +
    ggtitle("log(Motor Vehicle Emissions - Total) vs Year")

# Print the plot to the graphic device.
print(g)

dev.off()