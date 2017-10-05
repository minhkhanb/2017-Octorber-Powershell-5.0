Clear-Host

function Restore-CosmosDb {
    param (
        [parameter(Mandatory=$True,Position=1)] [ValidateScript({ Test-Path -PathType Leaf $_ })] [String] $FilePath,
        [parameter(Mandatory=$True)] [String] $Uri
    )
	
	# CONST 
	$CODEPAGE = "iso-8859-1" # alternatives are ASCII, UTF-8 
	
    $fileBin = [System.IO.File]::ReadAllBytes($FilePath)

    # Convert byte-array to string
	$enc = [System.Text.Encoding]::GetEncoding($CODEPAGE)
	
	$fileEnc = $enc.GetString($fileBin)

    $boundary = [System.Guid]::NewGuid().ToString()
	
    $LF = "`r`n"
	
	$uri = $Uri + "/restoreProcess"

     $bodyLines = (
                    "--$boundary",
                    "Content-Disposition: form-data; name=`"file`"; filename=`"data.zip`"",
                    "Content-Type: application/octet-stream$LF",
                    $fileEnc,
                    "--$boundary--"
                ) -join $LF
	
    try {
        Invoke-RestMethod -Uri $uri -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines
    }
    catch [System.Net.WebException] {
        Write-Error( "REST-API-Call failed for '$URL': $_" )
        throw $_
    }
}

Restore-CosmosDb -FilePath "D:\file\data.zip" -Uri "http://localhost:8757"