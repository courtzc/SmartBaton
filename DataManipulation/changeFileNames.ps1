$directory = "D:\OneDrive\Documents\renameimufiles"  # Replace with the desired directory path

# Get all the files in the directory
# $files = Get-ChildItem -File -Path $directory

# # Iterate through each file
# foreach ($file in $files) {
#     $extension = $file.Extension
#     $fileNameWithoutExtension = $file.BaseName
#     $newFileName = $fileNameWithoutExtension.Substring(0, $fileNameWithoutExtension.Length - 26) + $extension
    
#     # Rename the file
#     Rename-Item -Path $file.FullName -NewName $newFileName -Force
# }

# Get all the files in the directory
$files = Get-ChildItem -File -Path $directory

# Iterate through each file
foreach ($file in $files) {
    $extension = $file.Extension
    $fileNameWithoutExtension = $file.BaseName

    # Find the first two periods in the file name
    $firstPeriodIndex = $fileNameWithoutExtension.IndexOf('.')
    $secondPeriodIndex = $fileNameWithoutExtension.IndexOf('.', $firstPeriodIndex + 1)

    # Remove the first two periods from the file name
    if ($firstPeriodIndex -ne -1 -and $secondPeriodIndex -ne -1) {
        $newFileName = $fileNameWithoutExtension.Remove($firstPeriodIndex, 1).Remove($secondPeriodIndex - 1, 1) + $extension

        # Rename the file
        Rename-Item -Path $file.FullName -NewName $newFileName -Force
    }
}