Function Get-GitInstallDir {
    [OutputType([string])]
    [CmdletBinding()]
	Param()
    
    $p = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall";
    $gitKeys= @();
    if ($p | Test-Path -PathType:Container) {
        $gitKeys = @(Get-Item "$p\*" | ForEach-Object { @{ Key = $_; Name = $_.Name | Split-Path -Leaf } } | Where-Object { $_.Name.StartsWith("Git") });
        if ($gitKeys.Count -eq 0) {
            $p = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall";
            if ($p | Test-Path -PathType:Container) {
                $gitKeys = @(Get-Item "$p\*" | ForEach-Object { @{ Key = $_; Name = $_.Name | Split-Path -Leaf } } | Where-Object { $_.Name.StartsWith("Git") });
            }
        }
    }

    $gitInstallPath = $null;
    if ($gitKeys.Count -gt 0) { 
        $gitInstallPath = $gitKeys[0].Key.GetValue("InstallLocation");
    }

    if ($gitInstallPath -eq $null) {
        $gitInstallPath = "{$Env:SystemDrive}";
        if ($gitInstallPath.Length -eq 0) { $gitInstallPath = "C:" };
        $gitInstallPath = "$gitInstallPath\" | Join-Path -ChildPath:"Program Files (x86)\Git";
    }

    $gitExePath = $gitInstallPath | Join-Path -ChildPath:"bin\git.exe";

    if ($gitExePath | Test-Path -PathType:Leaf) { $gitInstallPath | Write-Output }
}

Function Install-SetupFile {
    [OutputType([bool])]
    [CmdletBinding()]
	Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [string]$FileName
    )
    
    Process {
        if ($FileName.Length -gt 0) {
            $srcPath = Get-Location | Join-Path -ChildPath:$FileName;
            $destPath = $Script:BinPath | Join-Path -ChildPath:$FileName;
            
            Write-Progress -Activity:"Installing" -Status:('Installing: {0}' -f $FileName);
            
            $result = $true;
            if (-not ($path | Test-Path -PathType:Leaf)) {
                ('Source file not found at: {0}.' -f $srcPath) | Write-Warning;
                $result = $false;
            } else {
                
                try {
                    Copy-Item -Path:$srcPath -Destination:$destPath -Force;
                    if (-not ($path | Test-Path -PathType:Leaf)) {
                        ('Unable to copy item to: {0}.' -f $destPath) | Write-Warning;
                        $result = $false;
                    }
                } catch {
                    $_ | Out-String | Write-Warning;
                    ('Unexpected error while copying to "{0}": {1}' -f $destPath, $_.Message) | Write-Warning;
                    $result = $false;
                }
            }
            $result | Write-Output;
        }
    }
}

Write-Progress -Activity:"Installing" -Status:'Initializing';

if ((Get-GitInstallDir) -eq $null) { Write-Warning "It does not appear that Git has been installed." }

$Script:BinPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile) | Join-Path -ChildPath:"/bin";
Write-Progress -Activity:"Installing" -Status:('Verifying: {0}' -f $Script:BinPath);
if (-not ($Script:BinPath | Test-Path -PathType:Container)) {
    if (($Script:BinPath | Test-Path -PathType:Leaf)) {
        ('Install target needs to be a folder. Cannot continue because a file of the same name exists at: {0}' -f $Script:BinPath) | Write-Error;
        Write-Progress -Activity:"Installing" -Status:"Finished with errors" -Complete;
        return;
    }
    
    New-Item -Path:$Script:BinPath -Type:Directory | Out-Null;
    if (-not ($Script:BinPath | Test-Path -PathType:Container)) {
        ('Unable to create target folder: {0}' -f $Script:BinPath) | Write-Error;
        Write-Progress -Activity:"Installing" -Status:"Finished with errors" -Complete;
        return;
    }
}

$failCount = @((@('common.inc', 'clone_github_repo.sh', 'sync_all.sh') | Install-SetupFile) | Where-Object { -not $_ }).Count;

if ($failCount -gt 0) {
    Write-Progress -Activity:"Installing" -Status:"Finished with errors" -Complete;
    "Finished with errors." | Write-Warning;
} else {
    Write-Progress -Activity:"Installing" -Status:"Finished" -Complete;
    "Finished." | Write-Host;
}