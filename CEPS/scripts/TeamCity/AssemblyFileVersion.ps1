# Get AssemblyInfo file's contents
# $file = "..\..\src\MainAppCEPS\Properties\AssemblyInfo.cs"
$file = "CEPS\src\MainAppCEPS\Properties\AssemblyInfo.cs"
$contents = get-content $file -Raw

# Regex to get the version number from AssemblyInfo file contents
$regex = new-object System.Text.RegularExpressions.Regex ('(^\s*\[\s*assembly\s*:\s*((System\s*\.)?\s*Reflection\s*\.)?\s*AssemblyFileVersion(Attribute)?\s*\(\s*@?\")(?<version>.*?)(\"\s*\)\s*\])', [System.Text.RegularExpressions.RegexOptions]::MultiLine)

# Get the version number
$version = $regex.Match($contents).Groups["version"].Value

# Update TeamCity buildNumber parameter using stdout
echo "##teamcity[buildNumber '$($version)']"