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

# Find all instances of motor vehicle sources by grepping for "vehicle" in the EI.Sector column.
vehicledata <- grep("vehicle",ignore.case = T, x = SCC$EI.Sector)

# Subset the matched data.
SCCMotorVehicleData <- SCC[vehicledata,]
SCCMotorVehicleData <- SCCMotorVehicleData[,c(1,2)]

# Merge the NEI and SCCMotorVehicleData by the SCC column.
baltimoreMotorVehicleData <- merge(baltimoreData, SCCMotorVehicleData, by = "SCC")

# Group the motor vehicle data by year. Summarise with sum total of emissions for each year.
baltimoreMotorVehicleSummary <- summarise(group_by(baltimoreMotorVehicleData,year), sum(Emissions))

# Make the column names of the summary prettier.
colnames(baltimoreMotorVehicleSummary) <- c("year","total_motor_vehicle_emissions")

# Open up a png file to write to.
png(filename = "Plot5.png")

# Create a ggplot object with the data and add points.
g <- ggplot(baltimoreMotorVehicleSummary, aes(x = year, y = total_motor_vehicle_emissions))
g <- g + geom_point(size = 4, alpha = 1/2) + 
    xlab("Year") +
    ylab("Motor Vehicle Emissions") + 
    ggtitle("Motor Vehicle Emissions (total) vs Year for Baltimore City")

# Print the plot to the graphic device.
print(g)

dev.off()
