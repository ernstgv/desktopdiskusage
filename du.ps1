cls

$unit = "1MB"

# setting up exluded users

#,"Administrator" used to be here  v v v v v v v v v v v v v v v v v v v v v 
$exclusion = @("Public",".NET v4.5",".NET v4.5 Classic","ADD MORE HERE AS NEEDED")



Clear-Variable -Name "targetpath"
Clear-Variable -Name "sum"
Clear-Variable -Name "perfolder"
Clear-Variable -Name "users"



# Importing the list of users
$users = @(get-childitem c:\users | Where { $exclusion -notcontains $_.Name } | select -expandproperty name)



function toplevel {

    (Get-ChildItem -Path $targetpath -ErrorAction SilentlyContinue | Where-Object {!($_.PSIsContainer)} | measure -Sum Length -ErrorAction SilentlyContinue).Sum / $unit


	}


function subdirectories {

	$sum = 0

	$directories =  Get-ChildItem -Path $targetpath -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {($_.PSIsContainer)} | Select -ExpandProperty FullName

	foreach ($directory in $directories) {

		if ($directory -ne $null ){

		$perfolder = Get-ChildItem -Path $directory -ErrorAction SilentlyContinue | Where-Object {!($_.PSIsContainer)} | measure length -Sum | select -ExpandProperty sum

		

		#write-output $directory "size " $perfolder | out-file c:\temp\duoutput.txt -Append

		$sum = $sum + $perfolder

		}

	}

	$sum /$unit
}


function allusers {

	$finalsum = 0

	$unitMB = "MB"

	$tableoutput = @()


	foreach ($user in $users) {


		$targetpath = "C:\users\$user\desktop"



		$abc = subdirectories
		$def = toplevel


		$allinall = [math]::Round(($abc + $def),2)

		$outputdata = New-Object psobject

		$outputdata | Add-Member NoteProperty -name username -value $user

		$outputdata | Add-Member NoteProperty -name size -value $allinall

		$outputdata | Add-Member noteproperty -name unit -value "MB"

		$tableoutput += $outputdata

		$finalsum += $allinall

	}

	write-output $tableoutput | Sort-Object "size" -Descending | ft | Out-File c:\temp\diskusageoutput_$env:computername.txt

	$FinalTotal = New-Object psobject

	$FinalTotal | Add-Member noteproperty -name total -Value Total:
	$FinalTotal | Add-Member noteproperty -name result -Value $finalsum
	$FinalTotal | Add-Member noteproperty -name unit -Value MB

	Write-output $FinalTotal | ft -HideTableHeaders | Out-File c:\temp\diskusageoutput_$env:computername.txt -Append

}

#this will call it
allusers
#testing