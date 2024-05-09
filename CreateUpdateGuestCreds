################################################
##                                            ##
##  Aruba Instant AP Guest WiFi Cred Update   ##
##              Script                        ##
##                                            ##
##  This script updates the guest WiFi        ##
##  password and emails it to the It Team     ##
##                                            ##
##  Author: Daniel Wheeler                    ##
##  Organisation: WheelsIT                    ##
##  Date: May 8, 2024                         ##
##  Version: 1.0                              ##
##                                            ##
##                                            ##
################################################



#Aruba admin creds are stored in Credential Manager and accessed as an object
#Credentials can only be accessed by the Aruba Service account arubasvc and are encrypted amd not stored in plain text in memory

$ArubaCreds = Get-StoredCredential -Target 'aruba'
$GuestUsername = 'Guest'



#Main function which calls sub functions
function Main {
    Get-RandomPass
    Connect-Aruba
    Send-Email

}



#Create random password using Rest API to word dictionary hosted at herokuapp.com
function Get-RandomPass {
    $Word = Invoke-RestMethod -Uri "https://random-word-api.herokuapp.com/word?number=1"
    $Word = (Get-Culture).TextInfo.ToTitleCase($Word)
    $Number = "{0:d3}" -f (Get-Random -Minimum 1 -Maximum 999)
    $Special = [char[]]"@#$!%&" | Get-Random
    $global:GuestPassword = $Word + $Number + $Special
    $global:GuestPassword
}

#Connect to Aruba IAP, Initiate SSH Session and supply commands to update Guest user
function Connect-Aruba {
    Import-Module -Name Posh-SSH
    $session = New-SSHSession -ComputerName 192.168.101.200 -Credential $ArubaCreds -AcceptKey -Force
    start-sleep -s 2
    # Get-SSHSession - your see ID for your session
    $SSHStream = New-SSHShellStream -Index 0
    start-sleep -s 2
    $SSHStream.WriteLine("configure")
    start-sleep -s 3
   

    $SSHStream.WriteLine("user $GuestUsername $global:GuestPassword portal")
    start-sleep -s 3


    $SSHStream.WriteLine("end")
    start-sleep -s 3

    $SSHStream.WriteLine("commit apply")
    start-sleep -s 3


    # close session
    Remove-SSHSession 0
}


#Send email with Updated Credentials to IT Team
function Send-Email {


    $Smtp = 'brandservices-com-au.mail.protection.outlook.com'
    $Date = Get-Date -Format "MMMM yyyy"
    $Subject = 'Guest Wi-Fi Password for ' + $Date
    $Body = "The Guest Wi-Fi Credentials for " + $Date + " are: `nUsername: " + $GuestUsername + "`nPassword: " + $global:GuestPassword 
    
    
    
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
