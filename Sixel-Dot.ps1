function Global:Sixel-Dot(){
	param(
		[int]$x,[int]$y,[byte]$c=255,
		[switch]$Pause,
		[switch]$VarDump
	)

	$ESC=[char]27;
	$DCS="${ESC}P"
	$CSI="${ESC}["
	$SIXELS="${DCS}7;1;1;q"
	$ST="${ESC}\"
	$cposx= [math]::Floor( $x / 10);
	$cposy= [math]::Floor( $y / 20);
	$sx = $x - $cposx * 10
	$sy = $y - $cposy * 20

	$outstring	= "${CSI}$(1+$cposy);$(1+$cposx)H"
	$outstring += "${SIXELS}#${c}";

	$nCr=[Math]::Floor( $sy / 6)

	$outstring += "-" * $nCr
	
	if($sx -gt 0) {
		$outstring += '$'+('?'*$sx)
	}

	$nsy=$sy % 6
	$wp=[math]::Pow( 2,$nsy)

	$outstring +=[char]([int][char]'?'+[int]$wp)
	$outstring += $ST

	if($VarDump){
		write-output "`e[10;0HX:$x Y:$y x:$cposx y:$cposy sx:$sx sy=$sy nsy=$nsy wp=$wp nCr=$nCr               "
		$outstring | format-hex
	}
	Write-Output $outstring
	if($pause) {
		#pause
		[void][System.console]::ReadKey()
		}
}
function Global:Plot-SixelArray(){
	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    	[int[]]$p1
	)
	begin{}
	Process{
		Sixel-Dot -x $p1[0] -y $p1[1] -c $p1[2]
	}
	end{}
}
function Global:Plot-SixelArray-Debug(){
	param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    	[int[]]$p1
	)
	begin{}
	Process{
		Sixel-Dot -x $p1[0] -y $p1[1] -c $p1[2] -pause -Vardump
	}
	end{}
}


function Global:Line {
	param(
		[int]$x0,
		[int]$y0,
		[int]$x1,
		[int]$y1,
		[int]$c
	)
	$dx = [math]::Abs($x1 - $x0)
	$dy = [math]::Abs($y1-$y0)
	$sx=0
	$sy=0
	$oX0 = $x0
	$oY0 = $y0
	if($x0 -lt $x1) { $sx=1} else {$sx=-1}
	if($y0 -lt $y1) { $sy=1} else {$sy=-1}
	$err = $dx -$dy
	do{
		Write-Output (,@($oX0,$oY0,$c))
		if( ($oX0 -eq $x1) -and ($oY0 -eq $y1)) { break}
		$e2=2 * $err
		if($e2 -gt  -1*$dy) {
			$err -= $dy
			$oX0 += $sx
		}
		if($e2 -lt $dx){
			$err += $dx
			$oY0 += $sy
		}
	}
	while($true)
}
function global:Box(){
	param(
		[int]$x0,
		[int]$y0,
		[int]$x1,
		[int]$y1,
		[int]$c
	)
	Line $x0 $y0 $x1 $y0 $c
	Line $x0 $y0 $x0 $y1 $c
	Line $x0 $y1 $x1 $y1 $c
	Line $x1 $y1 $x1 $y0 $c
}
cls
#300..350 | %{ Sixel-Dot -x $_ -y $_ -c 1 -VarDump -Pause}; Write-Host "`e[40;1H"
#300..350 | %{ ,@($_,$_,1)} | Global:Plot-SixelArray; Write-Host "`e[40;1H"
#Line 300 350 400 350 15 | Plot-SixelArray
#Line 300 350 300 450 15 | Plot-SixelArray
#Line 300 450 400 450 15 | Plot-SixelArray
#Line 400 450 400 350 15 | Plot-SixelArray
Box 10 10 330 330 15 | Plot-SixelArray
Line 10 10 330 330 13 | Global:Plot-SixelArray