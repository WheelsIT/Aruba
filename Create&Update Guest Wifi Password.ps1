$ArubaCreds = Get-StoredCredential -Target 'aruba'
$GuestUsername = Guest123


function Main {
    Get-RandomPass
    Connect-Aruba
    Send-Email

}


function Get-RandomPass {
    $Word = Invoke-RestMethod -Uri "https://random-word-api.herokuapp.com/word?number=1"
    $Word = (Get-Culture).TextInfo.ToTitleCase($Word)
    $Number = "{0:d3}" -f (Get-Random -Minimum 1 -Maximum 999)
    $Special = [char[]]"@#$!%&" | Get-Random
    $GuestPassword = $Word + $Number + $Special
    $GuestPassword
}


function Connect-Aruba {
    Import-Module -Name Posh-SSH
    $session = New-SSHSession -ComputerName 192.168.101.200 -Credential $ArubaCreds -AcceptKey -Force
    start-sleep -s 2
    # Get-SSHSession - your see ID for your session
    $SSHStream = New-SSHShellStream -Index 0
    start-sleep -s 2
    $SSHStream.WriteLine("configure")
    start-sleep -s 2
    $sshresult = $SSHStream.read()
    start-sleep -s 2
    $sshresult

    $SSHStream.WriteLine("user $GuestUsername $GuestPassword portal")
    start-sleep -s 2
    $sshresult = $SSHStream.read()
    start-sleep -s 2
    $sshresult
    start-sleep -s 2
    $SSHStream.WriteLine("end")
    start-sleep -s 2
    $sshresult = $SSHStream.read()
    start-sleep -s 2
    $sshresult
    start-sleep -s 2
    $SSHStream.WriteLine("commit apply")
    start-sleep -s 2
    $sshresult = $SSHStream.read()
    start-sleep -s 2
    $sshresult


    # close session
    Remove-SSHSession 0
}



function Send-Email {


    $Smtp = 'brandservices-com-au.mail.protection.outlook.com'
    $Date = Get-Date -Format "MMMM yyyy"
    $Subject = 'Guest Wi-Fi Password for ' + $Date
    $Body = "The Guest Wi-Fi Credentials for " + $Date + " are: `nUsername: " + $GuestUsername + "`nPassword: " + $GuestPassword 
    
    
    
    $sendMailMessageSplat = @{
        From       = 'Aruba Guest Wi-Fi<Aruba@brandservices.com.au>'
        To         = 'Dan <daniel.wheeler@thinksolutions.com.au>'
        Subject    = $Subject
        Body       = $Body   
        SmtpServer = $Smtp
    }
    Send-MailMessage @sendMailMessageSplat
}

Main