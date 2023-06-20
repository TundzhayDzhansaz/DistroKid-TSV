//
//  main.swift
//  DistroKid
//
//  Created by Tundzhay Dzhansaz on 20/06/2023.

import Foundation

// Define the path to your .tsv file
let filePath = "Enter your file path here"

// Read the contents of the file
guard let fileContents = try? String(contentsOfFile: filePath, encoding: .utf8) else {
  print("Failed to read file at path: \(filePath)")
  exit(0)
}

// Split the file contents into lines
let lines = fileContents.components(separatedBy: .newlines)

// Define the filter conditions
let startDateFilter = "2023-04-01" // Start date of the range (inclusive)
let endDateFilter = "2023-04-30" // End date of the range (inclusive)
let storeNames = ["YouTube (Ads)", "YouTube (Red)", "YouTube (ContentID)", "YouTube (Red) - Composition", "YouTube (Ads) - Composition", "YouTube (Audio)"]

// Calculate the previous two months based on the entered start and end dates
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd"

guard let startDate = dateFormatter.date(from: startDateFilter),
      let endDate = dateFormatter.date(from: endDateFilter),
      let previousStartDate = Calendar.current.date(byAdding: .month, value: 2, to: startDate),
      let previousEndDate = Calendar.current.date(byAdding: .month, value: 2, to: endDate) else {
  print("Invalid date format.")
  exit(0)
}

// Create variables to store the total earnings and total quantity, and the filtered data
var totalEarnings: Double = 0.0
var totalQuantity: Int = 0
var filteredData: [String] = []

// Iterate through each line and apply the filters
for line in lines {
  // Split the line into tab-separated values
  let values = line.components(separatedBy: "\t")
    
  // Check if the line has at least 10 values (all columns present)
  guard values.count >= 10 else {
    continue
  }
    
  // Extract the Reporting Date, Store, Earnings, and Quantity values
  let reportingDate = values[0]
  let store = values[2]
  let earnings = values[12]
  let quantity = values[7]
    
  // Check if the Reporting Date is within the previous two months range
  if isDateWithinRange(reportingDate, previousStartDate, previousEndDate) && storeNames.contains(store) {
    filteredData.append(line)
        
    // Calculate the total earnings
    if let earningsValue = Double(earnings) {
      totalEarnings += earningsValue
    }
        
    // Calculate the total quantity
    if let quantityValue = Int(quantity) {
      totalQuantity += quantityValue
    }
  }
}

// Function to check if a date is within a given range
func isDateWithinRange(_ date: String, _ startDate: Date, _ endDate: Date) -> Bool {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd"
    
  guard let dateObj = dateFormatter.date(from: date) else {
    return false
  }
  return dateObj >= startDate && dateObj <= endDate
}

// Print the filtered results
print("Filtered Data:")
for data in filteredData {
  print(data)
}

// Print the total earnings and total quantity
print("Total Earnings: \(totalEarnings)")
print("Total Quantity: \(totalQuantity)")

// Calculate RPM
let rpm = totalQuantity != 0 ? (totalEarnings / Double(totalQuantity)) * 1000 : 0.0
// Print RPM
print("RPM: \(rpm)")


