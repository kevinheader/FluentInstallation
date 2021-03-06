Remove-Module assemblyInfo -ErrorAction SilentlyContinue
Import-Module assemblyInfo

Remove-Module xunit -ErrorAction SilentlyContinue
Import-Module xunit

properties {
	
	$build = @{}
	$build.Configuration = "Release"
	$build.Number = if($env:BUILD_NUMBER) { $env:BUILD_NUMBER } else { "0" }
	$build.Directory = Resolve-Path .
	$build.Version = "1.0.0.0"

	$vcsRoot = @{}
	$vcsRoot.Directory = (Split-Path -Parent $build.Directory)
	
	$artifacts = @{}
	$artifacts.Directory = Join-Path $vcsRoot.Directory "artifacts" 
		
	$solution = @{}
	$solution.Directory = $vcsRoot.Directory
	$solution.File =  @(Get-ChildItem $solution.Directory  -Filter *.sln)[0].FullName
	
	$nuget = @{}
	$nuget.Directory = Join-Path $solution.Directory ".nuget" 
	$nuget.File = Join-Path $nuget.Directory "NuGet.exe" 
		
}

Task Run-CI-Build -Depends System-Information, Clean, Compile, Run-Tests, Package

Task System-Information {

	Write-Host  "Powershell version $($PSVersionTable.PSVersion)"
	Write-Host  "CLR version $($PSVersionTable.CLRVersion)"

}

Task Clean {
	Write-Host "Cleaning artifacts directory"
	Remove-Item $artifacts.Directory -Force -Recurse -ErrorAction SilentlyContinue
	New-Item $artifacts.Directory -Force -ItemType Directory
}

Task Compile -Depends Clean, Version-AssemblyInfo {

	Write-Host "Compiling solution"
	exec { C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe $($solution.File) /t:Clean /t:Build  /p:Configuration=$($build.configuration)  /v:q  /clp:ErrorsOnly /nologo }
}

Task Run-Tests {

	Get-ChildItem $solution.Directory -Recurse -Include *.unittests,*.integrationTests |
    ?{ ($_ -is [System.IO.DirectoryInfo]) -and (Test-Path "$($_.FullName)\bin\$($build.configuration)\$($_.Name).dll") } |
    %{
			$base = $_.FullName
			$name = $_.Name
			$testAssemblyFile = Join-Path $base (Join-Path "bin" (Join-Path $build.configuration "$name.dll"))
			Run-Xunit $testAssemblyFile 
		}
}

Task Version-AssemblyInfo {

	Write-Output "Writing build number [$($build.number)] to assemblyinfo"		  

	$assemblyDirectory = Join-Path (Join-Path $($solution.Directory) src) assembly
	$assemblyFile = Join-Path $assemblyDirectory SharedAssemblyInfo.cs
	$buildNumber = $build.Number
	
	if (Test-Path $assemblyFile)
	{
		$build.Version = Update-AssemblyBuildNumber -assemblyFile $assemblyFile -buildNumber $buildNumber
	}
		
	
}

Task Package {

	Get-ChildItem $solution.Directory -Recurse -Include '*.csproj' | 
	
	 	%{
			$nuspecFile = $_.FullName -replace "csproj", "nuspec";
			
			if (Test-Path($nuspecFile))
			{
				Write-Host "Packing - $($_.Name)" 
				&$nuget.File pack $nuspecFile  -Version $build.Version -OutputDirectory $artifacts.Directory -Properties Configuration=$($build.configuration)
			}
						
			
		}

}

<# 
 Exits the script when an error occurs and prints a message to the user
#> 
function Exit-Build
{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)][String]$Message
    )
 
    Write-Host $("`nExiting build because task [{0}] failed.`n->`t$Message.`n" -f $psake.context.Peek().currentTaskName) -ForegroundColor Red
 
    Exit
}






