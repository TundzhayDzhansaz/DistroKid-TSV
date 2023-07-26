import Foundation

// Define the path to your .tsv file
let filePath = "Enter your .tsv file path here."

// Read the contents of the file
guard let fileContents = try? String(contentsOfFile: filePath, encoding: .utf8) else {
    print("Failed to read file at path: \(filePath)")
    exit(0)
}

// Split the file contents into lines
let lines = fileContents.components(separatedBy: .newlines)

// Define the filter conditions
let startDateFilter = "2023-05-01" // Start date of the range (inclusive)
let endDateFilter = "2023-05-30" // End date of the range (inclusive)
let storeNames = ["Which stores would you like to filter separate by , (comma)"]

let applyStoreFilter = true // Set this to true or false as desired

// Calculate the previous two months based on the entered start and end dates
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd"

guard let startDate = dateFormatter.date(from: startDateFilter),
    let endDate = dateFormatter.date(from: endDateFilter),
    let previousStartDate = Calendar.current.date(byAdding: .month, value: -2, to: startDate),
    let previousEndDate = Calendar.current.date(byAdding: .month, value: -2, to: endDate) else {
        print("Invalid date format.")
        exit(0)
}

// Create a struct to store earnings and streams data
struct DataEntry {
    var totalEarnings: Double
    var totalStreams: Int
}

// Create dictionaries to store country and store data
var countryDataDict: [String: DataEntry] = [:]
var storeDataDict: [String: DataEntry] = [:]

// Function to check if a date is within a given range
func isDateWithinRange(_ date: String, _ startDate: Date, _ endDate: Date) -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    guard let dateObj = dateFormatter.date(from: date) else {
        return false
    }
    return dateObj >= startDate && dateObj <= endDate
}

// Function to calculate earnings per stream and RPM
func calculateEarningsAndRPM(_ dataEntry: DataEntry) -> (earningPerStream: Double, rpm: Double) {
    let earningPerStream = dataEntry.totalEarnings / Double(dataEntry.totalStreams)
    let rpm = earningPerStream * 1000
    return (earningPerStream, rpm)
}

// Iterate through each line and apply the filters for countries
for line in lines {
    // Split the line into tab-separated values
    let values = line.components(separatedBy: "\t")
    
    // Check if the line has at least 10 values (all columns present)
    guard values.count >= 10 else {
        continue
    }
    
    // Extract the Reporting Date, Store, Earnings, Quantity, and Country values
    let reportingDate = values[0]
    let store = values[2]
    let earnings = Double(values[12]) ?? 0.0
    let quantity = Int(values[7]) ?? 0
    let country = values[10]
    
    // Check if the Reporting Date is within the previous two months range
    guard isDateWithinRange(reportingDate, previousStartDate, previousEndDate) else {
        continue
    }
    
    // Calculate the total earnings and total streams for each country
    if let existingData = countryDataDict[country] {
        countryDataDict[country] = DataEntry(
            totalEarnings: existingData.totalEarnings + earnings,
            totalStreams: existingData.totalStreams + quantity
        )
    } else {
        countryDataDict[country] = DataEntry(
            totalEarnings: earnings,
            totalStreams: quantity
        )
    }
    
    // Check if the store is in the allowed list and calculate the total earnings and total streams for each store
    if applyStoreFilter, storeNames.contains(store) {
        if let existingData = storeDataDict[store] {
            storeDataDict[store] = DataEntry(
                totalEarnings: existingData.totalEarnings + earnings,
                totalStreams: existingData.totalStreams + quantity
            )
        } else {
            storeDataDict[store] = DataEntry(
                totalEarnings: earnings,
                totalStreams: quantity
            )
        }
    }
}

// ...

// If applyStoreFilter is false, display all stores
if !applyStoreFilter {
    let allStores = Set(lines.compactMap { line -> String? in
        let values = line.components(separatedBy: "\t")
        guard values.count >= 10 else { return nil }
        return values[2]
    })
    
    let excludedStores = Set(storeNames)
    let includedStores = allStores.subtracting(excludedStores)

    storeDataDict = includedStores.reduce(into: [String: DataEntry]()) { result, store in
        result[store] = DataEntry(totalEarnings: 0, totalStreams: 0)
    }

    // Iterate through each line and apply the filters for stores
    for line in lines {
        // Split the line into tab-separated values
        let values = line.components(separatedBy: "\t")
        
        // Check if the line has at least 10 values (all columns present)
        guard values.count >= 10 else {
            continue
        }
        
        // Extract the Reporting Date, Store, Earnings, Quantity, and Country values
        let reportingDate = values[0]
        let store = values[2]
        let earnings = Double(values[12]) ?? 0.0
        let quantity = Int(values[7]) ?? 0
        
        // Check if the Reporting Date is within the previous two months range
        guard isDateWithinRange(reportingDate, previousStartDate, previousEndDate) else {
            continue
        }
        
        // Calculate the total earnings and total streams for each store
        if let existingData = storeDataDict[store] {
            storeDataDict[store] = DataEntry(
                totalEarnings: existingData.totalEarnings + earnings,
                totalStreams: existingData.totalStreams + quantity
            )
        } else {
            storeDataDict[store] = DataEntry(
                totalEarnings: earnings,
                totalStreams: quantity
            )
        }
    }
}

// ...

// Sort the countryDataDict by RPM (highest to lowest) and then print the results
let sortedCountriesByRPM = countryDataDict.sorted(by: { calculateEarningsAndRPM($0.value).rpm > calculateEarningsAndRPM($1.value).rpm })

print("\nCountry Earnings (Sorted by RPM):")
if !sortedCountriesByRPM.isEmpty {
    // Find the maximum character count for streams to make the output dynamic
    var maxStreamCharacterCount = 1 // Default value (minimum is 1)
    // Find the maximum country name length to align the output
    var maxCountryNameLength = 1 // Default value (minimum is 1)
    for countryData in sortedCountriesByRPM {
        let streamCharacterCount = String(countryData.value.totalStreams).count
        if streamCharacterCount > maxStreamCharacterCount {
            maxStreamCharacterCount = streamCharacterCount
        }
        if countryData.key.count > maxCountryNameLength {
            maxCountryNameLength = countryData.key.count
        }
    }

    for (country, countryData) in sortedCountriesByRPM {
        // Skip countries with 0 streaming count
        if countryData.totalStreams == 0 {
            continue
        }

        let (earningPerStream, rpm) = calculateEarningsAndRPM(countryData)
        let formattedEarning = String(format: "%.8f", earningPerStream)
        let limitedFormattedEarning = String(formattedEarning.prefix(maxStreamCharacterCount + 3))

        // Align the Streams and RPM columns by padding with spaces
        let streamsString = String(format: "%\(maxStreamCharacterCount)d", countryData.totalStreams)
        let rpmString = String(format: "%4.1f", rpm)

        // Align the country name by padding with spaces
        let paddedCountryName = country.padding(toLength: maxCountryNameLength, withPad: " ", startingAt: 0)

        print("Country: \(paddedCountryName), Highest Earning: \(limitedFormattedEarning), Streams: \(streamsString), RPM: \(rpmString)")
    }
} else {
    print("No earnings data for countries.")
}

// ...

// Sort the storeDataDict by RPM (highest to lowest) and then print the results
let sortedStoresByRPM = storeDataDict.sorted(by: { calculateEarningsAndRPM($0.value).rpm > calculateEarningsAndRPM($1.value).rpm })

print("\n\nStore Earnings (Sorted by RPM):")
if !sortedStoresByRPM.isEmpty {
    // Find the maximum character count for streams to make the output dynamic
    var maxStreamCharacterCount = 1 // Default value (minimum is 1)
    // Find the maximum store name length to align the output
    var maxStoreNameLength = 1 // Default value (minimum is 1)
    for storeData in sortedStoresByRPM {
        let streamCharacterCount = String(storeData.value.totalStreams).count
        if streamCharacterCount > maxStreamCharacterCount {
            maxStreamCharacterCount = streamCharacterCount
        }
        if storeData.key.count > maxStoreNameLength {
            maxStoreNameLength = storeData.key.count
        }
    }

    for (store, storeData) in sortedStoresByRPM {
        // Skip stores with 0 earnings
        if storeData.totalEarnings == 0 {
            continue
        }

        let (earningPerStream, rpm) = calculateEarningsAndRPM(storeData)
        let formattedEarning = String(format: "%.8f", earningPerStream)
        let limitedFormattedEarning = String(formattedEarning.prefix(maxStreamCharacterCount + 3))

        // Align the Streams and RPM columns by padding with spaces
        let streamsString = String(format: "%\(maxStreamCharacterCount)d", storeData.totalStreams)
        let rpmString = String(format: "%4.1f", rpm)

        // Align the store name by padding with spaces
        let paddedStoreName = store.padding(toLength: maxStoreNameLength, withPad: " ", startingAt: 0)

        print("Store: \(paddedStoreName), Highest Earning: \(limitedFormattedEarning), Streams: \(streamsString), RPM: \(rpmString)")
    }
} else {
    print("No earnings data for stores.")
}

// ...

// Calculate the total earnings and total streams for all countries
let totalEarnings = countryDataDict.values.reduce(0.0) { $0 + $1.totalEarnings }
let totalStreams = countryDataDict.values.reduce(0) { $0 + $1.totalStreams }

// Print the total earnings and total streaming count
print("\n\nTotal Earnings: \(totalEarnings)")
print("Total Streams: \(totalStreams)")

// Calculate RPM (Revenue Per Mille) by dividing total earnings by total streams and then multiplying by 1000
let rpm = (totalEarnings / Double(totalStreams)) * 1000

// Print the RPM value
print("RPM (Revenue Per Mille): \(rpm)\n\n")
