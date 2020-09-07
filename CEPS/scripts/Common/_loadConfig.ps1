param($path = $(throw "You must specify a config file"))
$config = [xml](get-content -encoding utf8 $path)

foreach ($addNode in $config.configuration.appsettings.add) {
 # Scalar case
 $value = $addNode.Value
 $global:appSettings[$addNode.Key] = $value
}
