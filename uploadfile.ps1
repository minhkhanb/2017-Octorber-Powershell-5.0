Clear-Host
#$Response = Invoke-RestMethod -Method post -UseDefaultCredentials -uri "http://localhost:8757/restoreProcess"
#$Digest = $response.getcontextwebinformation.FormDigestValue
#$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
#$headers.Add("postman-token", "0ca5a1be-8e1f-0e7f-5e9a-73a287db03ca")
#$headers.Add("cache-control", "no-cache")
#$headers.Add("content-type", "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW")
#$FileContent = [IO.File]::ReadAllBytes('D:\file\data.zip');

#Invoke-RestMethod -method post -UseDefaultCredentials -uri "http://localhost:8757/restoreProcess" -infile $FileContent -headers $headers 

function Import-Portatour {
    param (
        [parameter(Mandatory=$True,Position=1)] [ValidateScript({ Test-Path -PathType Leaf $_ })] [String] $FilePath,
        [parameter(Mandatory=$False,Position=2)] [System.URI] $ResultURL
    )
	
	# CONST 
	$CODEPAGE = "iso-8859-1" # alternatives are ASCII, UTF-8 
	# We have a REST-Endpoint
	$RESTURL = "http://localhost:8757/"
	
	# Testing
	$userEmail = "minhkhanb@gmail.com"
	
	# Read file byte-by-byte
  $fileBin = [System.IO.File]::ReadAllBytes($FilePath)

  # Convert byte-array to string
	$enc = [System.Text.Encoding]::GetEncoding($CODEPAGE)
	
	$fileEnc = $enc.GetString($fileBin)
	# Read a second hardcoded file which we want to upload through the API call
	$dataFileEnc = $enc.GetString([System.IO.File]::ReadAllBytes("D:\file\data.zip"))
	
	# Create Object for Credentials
	$user = "Username"
  $pass = "Passw0rd"
	
	$secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
	$cred = New-Object System.Management.Automation.PSCredential ($user, $secpasswd)

	# We need a boundary (something random() will do best)
  $boundary = [System.Guid]::NewGuid().ToString()
	
	# Linefeed character
  $LF = "`r`n"
	
	# Build up URI for the API-call
	$uri = $RESTURL + "restoreProcess"
	
	# Build Body for our form-data manually since PS does not support multipart/form-data out of the box
    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"Import.xlsx`"",
		"Content-Type: application/octet-stream$LF",
        $fileEnc,
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"data.zip`"",
		"Content-Type: application/octet-stream$LF",
        $dataFileEnc,
        "--$boundary--$LF"
     ) -join $LF
	
    try {
        # Submit form-data with Invoke-RestMethod-Cmdlet
        Invoke-RestMethod -Uri $uri -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines -Credential $cred
    }
    # In case of emergency...
    catch [System.Net.WebException] {
        Write-Error( "REST-API-Call failed for '$URL': $_" )
        throw $_
    }
}

Import-Portatour -FilePath "D:\file\data.zip"