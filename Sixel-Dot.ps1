function Global:Sixel-Dot(){
	param(
		[int]$x,[int]$y,[byte]$c=255,
		[switch]$Pause,
		[switch]$VarDump
	)
	# 定数
	$ESC=[char]27;
	$DCS="${ESC}P"
	$CSI="${ESC}["
	$SIXELS="${CSI}?80l${DCS}7;1;1;q"
	$ST="${ESC}\"

	# 文字カーソル位置
	$cposx= [math]::Floor( $x / 10);
	$cposy= [math]::Floor( $y / 20);

	# エスケープシーケンス出力用文字列変数の初期化、CUPで文字カーソル位置を移動
	$outstring	= "${CSI}$(1+$cposy);$(1+$cposx)H"

	# Sixelのエスケープシーケンス開始。描画色は$cで指定
	$outstring += "${SIXELS}#${c}";

	# 文字カーソル位置からのオフセット
	$sx = $x - $cposx * 10
	$sy = $y - $cposy * 20

	# y方向のSixel行数（Sixel New Lineの数）
	$nCr=[Math]::Floor( $sy / 6)

	# Sixel New Lineの出力
	$outstring += "-" * $nCr
	
	# x方向のオフセットがゼロでなければオールゼロのSixelを必要数描画
	if($sx -gt 0) {
		$outstring += '$'+('?'*$sx)
	}

	# Sixel内の1のビットを計算
	#$nsy=$sy % 6
	$wp=[math]::Pow( 2,$sy % 6)

	# Sixel文字に変換
	$outstring +=[char]([int][char]'?'+[int]$wp)

	# ST(String Terminator)を最後に追加
	$outstring += $ST

	# デバッグ用。オプション$VarDumpが指定されていたら変数を出力し、エスケープシーケンスを16進数ダンプ
	if($VarDump){
		if( $x -lt 100 ) {$dpos=10} else {$dpos=1}
		Write-Host "`e[$dpos;1HX:$x Y:$y x:$cposx y:$cposy sx:$sx sy=$sy wp=$wp nCr=$nCr               "
		$outstring | format-hex
	}

	# エスケープシーケンスを出力
	Write-Output $outstring

	# デバッグ用。$pauseが指定されていたら、ここで一時停止
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
		Sixel-Dot -x $p1[0] -y $p1[1] -c $p1[2] -pause -VarDump
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
Box 10 10 330 330 15 | Plot-SixelArray
Line 10 10 330 330 13 | Plot-SixelArray