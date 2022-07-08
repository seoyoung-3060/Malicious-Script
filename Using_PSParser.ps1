function Test-PSOneScript
{ 
  param
  (
    # Path to PowerShell script file
    # can be a string or any object that has a "Path" 
    # or "FullName" property:
    [String]
    [Parameter(Mandatory,ValueFromPipeline)]
    [Alias('FullName')]
    $Path
  )
  
  begin
  {
    $errors = $null
  }
  process
  {
    # create a variable to receive syntax errors:
    $errors = $null
    # tokenize PowerShell code:
    $code = Get-Content -Path $Path -Raw -Encoding Default
    
    # return the results as a custom object
    [PSCustomObject]@{
      Name = Split-Path -Path $Path -Leaf
      Path = $Path
      Tokens = [Management.Automation.PSParser]::Tokenize($code, [ref]$errors)
      Errors = $errors | Select-Object -ExpandProperty Token -Property Message
    }  
  }
}

#각 ps1파일 읽고 txt파일에 결과 저장하는
function Test-parser {
    Get-ChildItem -Path '/Users/kimseoyeong/Downloads/PowerShellCorpus/Github/0xbadjuju_WMI' -Recurse -Include *.ps1 -File |
    Test-PSOneScript |
    Foreach-Object {
       $result = $_.Tokens.Where{($_.Type -eq 'Command') -or ($_.Type -eq 'Keyword')}
       
       $file = $_.Name + ".txt"
       $result.content | Add-Content $file
    }  
    
}

<#
$FPath = '/Users/kimseoyeong/Desktop/Powershell_txt'
if(!(Test-Path $FPath)) {
         New-Item -ItemType Directory -Path '/Users/kimseoyeong/Desktop' -Name "Powershell_txt"
  }
  else {
    Test-parser
  }

#>

Test-parser
