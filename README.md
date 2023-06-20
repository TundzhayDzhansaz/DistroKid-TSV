# DistroKid-TSV
The code is designed to filter a DistroKid TSV (Tab-Separated Values) file based on specific criteria. It allows you to extract and analyze data from the file according to your requirements.

The code begins by specifying the path to the TSV file you want to filter. It reads the contents of the file, ensuring it is encoded as UTF-8. If the file cannot be read, an error message is displayed, and the program exits.

Next, the file contents are split into individual lines, assuming that each line represents a separate entry or record in the TSV file.

You can define the filter conditions based on the criteria you want to apply. In this example, the filter conditions include a start date and an end date range, as well as a specific store name. You can modify these values according to your needs.

The code then creates variables to store the filtered data and calculate the total earnings. The filteredData variable is an array that will hold the lines of the TSV file that match the filter conditions.

The code iterates through each line of the TSV file and checks if it meets the filter conditions. If a line matches the criteria (e.g., the reporting date falls within the specified date range and the store name matches the desired store), it is added to the filteredData array.

Additionally, if the line matches the filter conditions, the code can perform further calculations or operations. For example, you can calculate the total earnings by extracting the earnings value from each matching line and summing them up.

After filtering the data, you can access the filteredData array to retrieve the specific lines that meet the filter criteria. This data can be further processed or displayed as needed.

Overall, this DistroKid TSV file filterer provides flexibility in extracting and analyzing data based on specific criteria, such as date ranges and store names. You can customize the filter conditions and extend the functionality to suit your requirements.
