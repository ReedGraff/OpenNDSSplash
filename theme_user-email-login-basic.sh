#!/bin/sh
#Copyright (C) The openNDS Contributors 2004-2022
#Copyright (C) BlueWave Projects and Services 2015-2023
#This software is released under the GNU GPL license.
#
# Warning - shebang sh is for compatibliity with busybox ash (eg on OpenWrt)
# This is changed to bash automatically by Makefile for generic Linux
#

# Title of this theme:
title="theme_user-email-login-basic"



# Overwrite Logging functions:
auth_log () {
	# We are ready to authenticate the client

	rhid=$(printf "$hid$key" | sha256sum | awk -F' ' '{printf $1}')
	ndsctlcmd="auth $rhid $quotas $custom"

	do_ndsctl
	authstat=$ndsctlout
	# $authstat contains the response from do_ndsctl

	loginfo="$userinfo, status=$authstat, mac=$clientmac, ip=$clientip, client_type=$client_type, zone=$client_zone, ua=$user_agent"
	write_log
	# We will not remove the client id file, rather we will let openNDS delete it on deauth/timeout
}







# functions:
generate_splash_sequence() {
	name_email_login
}

header() {
# Define a common header html for every page served
	echo "<!DOCTYPE html>
		<html>
		<head>
		<meta http-equiv=\"Cache-Control\" content=\"no-cache, no-store, must-revalidate\">
		<meta http-equiv=\"Pragma\" content=\"no-cache\">
		<meta http-equiv=\"Expires\" content=\"0\">
		<meta charset=\"utf-8\">
		<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
		<link rel=\"shortcut icon\" href=\"/images/splash.jpg\" type=\"image/x-icon\">
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, Helvetica, Arial, sans-serif;
            }

            body {
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                padding: 20px;
            }

            .card {
                background: white;
                padding: 40px;
                border-radius: 12px;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
                width: 100%;
                max-width: 400px;
            }

            .header {
                text-align: center;
                margin-bottom: 40px;
            }

            .header h1 {
                color: #1a1a1a;
                font-size: 24px;
                margin-bottom: 10px;
            }

            .header p {
                color: #666;
                font-size: 16px;
            }

            .form-group {
                margin-bottom: 24px;
            }

            .form-group label {
                display: block;
                margin-bottom: 8px;
                color: #555;
                font-size: 14px;
                font-weight: 500;
            }

            .form-group input {
                width: 100%;
                padding: 12px;
                border: 2px solid #e1e1e1;
                border-radius: 6px;
                font-size: 16px;
                transition: border-color 0.3s ease;
            }

            .form-group input:focus {
                outline: none;
                border-color: #667eea;
            }

            button {
                width: 100%;
                padding: 14px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                border: none;
                border-radius: 6px;
                color: white;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: transform 0.2s ease;
            }

            button:hover {
                transform: translateY(-1px);
            }

            button:active {
                transform: translateY(1px);
            }
        </style>
		<title>$gatewayname</title>
		</head>
		<body>
            <div class=\"card\">
	"
}

footer() {
	# Define a common footer html for every page served
	echo "
		<hr>
		</div>
		</div>
		</body>
		</html>
	"

	exit 0
}

name_email_login() {
	# In this example, we check that both the username and email address fields have been filled in.
	# If not then serve the initial page, again if necessary.
	# We are not doing any specific validation here, but here is the place to do it if you need to.
	#
	# Note if only one of username or email address fields is entered then that value will be preserved
	# and displayed on the page when it is re-served.
	#
	# The client is required to accept the terms of service.

	if [ ! -z "$username" ] && [ ! -z "$emailaddress" ] && [ ! -z "$position" ] && [ ! -z "$company" ]; then
		thankyou_page
		footer
	fi

	login_form
	footer
}

login_form() {
	# Define a login form

	echo "
        <div class=\"header\">
            <h1>Welcome to WiFi Login</h1>
            <p>Please enter your details to connect</p>
        </div>
        <form action=\"/opennds_preauth/\" method=\"get\">
            <input type=\"hidden\" name=\"fas\" value=\"$fas\">
            
            <div class=\"form-group\">
                <label for=\"username\">Full Name</label>
                <input type=\"text\" id=\"username\" name=\"username\" autocomplete=\"on\" placeholder=\"Enter your name\" required>
            </div>
            
            <div class=\"form-group\">
                <label for=\"emailaddress\">Email Address</label>
                <input type=\"email\" id=\"emailaddress\" name=\"emailaddress\" autocomplete=\"on\" placeholder=\"Enter your email\" required>
            </div>
            
            <div class=\"form-group\">
                <label for=\"position\">Position</label>
                <input type=\"text\" id=\"position\" name=\"position\" autocomplete=\"on\" placeholder=\"Enter your position\" required>
            </div>
            
            <div class=\"form-group\">
                <label for=\"company\">Company</label>
                <input type=\"text\" id=\"company\" name=\"company\" autocomplete=\"on\" placeholder=\"Enter your company\" required>
            </div>
            
            <button type=\"submit\">Connect to WiFi</button>
        </form>
		<br>
	"

	footer
}

thankyou_page () {
	# If we got here, we have both the username and emailaddress fields as completed on the login page on the client,
	# or Continue has been clicked on the "Click to Continue" page
	# No further validation is required so we can grant access to the client. The token is not actually required.

	# We now output the "Thankyou page" with a "Continue" button.

	# This is the place to include information or advertising on this page,
	# as this page will stay open until the client user taps or clicks "Continue"

	# Be aware that many devices will close the login browser as soon as
	# the client user continues, so now is the time to deliver your message.

	binauth_custom="username=$username emailaddress=$emailaddress position=$position company=$company"
	encode_custom

	if [ -z "$custom" ]; then
		customhtml=""
	else
		customhtml="<input type=\"hidden\" name=\"custom\" value=\"$custom\">"
	fi

	# Continue to the landing page, the client is authenticated there
	echo "
        <div class=\"header\">
            <h1>Connecting you to the Internet</h1>
            <p>Please wait 10 seconds</p>
        </div>
		<form action=\"/opennds_preauth/\" method=\"get\">
			<input type=\"hidden\" name=\"fas\" value=\"$fas\">
			<input type=\"hidden\" name=\"username\" value=\"$username\">
			<input type=\"hidden\" name=\"emailaddress\" value=\"$emailaddress\">
			<input type=\"hidden\" name=\"position\" value=\"$position\">
			<input type=\"hidden\" name=\"company\" value=\"$company\">
			$customhtml
			<input type=\"hidden\" name=\"landing\" value=\"yes\">
            
            <button type=\"submit\">Connect Now</button>
        </form>

		<br>
        <script>
            setTimeout(function() {
                document.querySelector('form').submit();
            }, 500);
        </script>
	"

	# Serve the rest of the page:
	footer
}

# This is the page after connecting...
landing_page() {
	originurl=$(printf "${originurl//%/\\x}")
	gatewayurl=$(printf "${gatewayurl//%/\\x}")

	# Add the user credentials to $userinfo for the log
	userinfo="$userinfo, user=$username, email=$emailaddress, position=$position, company=$company"

	# authenticate and write to the log - returns with $ndsstatus set
	auth_log

	# output the landing page - note many CPD implementations will close as soon as Internet access is detected
	# The client may not see this page, or only see it briefly
	auth_success="
        <div class=\"header\">
            <h1>You have been granted access to the Internet.</h1>
            <p></p>
        </div>
		<hr>
	"
	auth_fail="
        <div class=\"header\">
            <h1>There was an error.</h1>
            <p></p>
        </div>
		<hr>
	"

	if [ "$ndsstatus" = "authenticated" ]; then
		echo "$auth_success"
	else
		echo "$auth_fail"
	fi

	footer
}

#### end of functions ####


#################################################
#						#
#  Start - Main entry point for this Theme	#
#						#
#  Parameters set here overide those		#
#  set in libopennds.sh			#
#						#
#################################################

# Quotas and Data Rates
#########################################
# Set length of session in minutes (eg 24 hours is 1440 minutes - if set to 0 then defaults to global sessiontimeout value):
# eg for 100 mins:
# session_length="100"
#
# eg for 20 hours:
# session_length=$((20*60))
#
# eg for 20 hours and 30 minutes:
# session_length=$((20*60+30))
session_length="0"

# Set Rate and Quota values for the client
# The session length, rate and quota values could be determined by this script, on a per client basis.
# rates are in kb/s, quotas are in kB. - if set to 0 then defaults to global value).
upload_rate="0"
download_rate="0"
upload_quota="0"
download_quota="0"

quotas="$session_length $upload_rate $download_rate $upload_quota $download_quota"

# Define the list of Parameters we expect to be sent sent from openNDS ($ndsparamlist):
# Note you can add custom parameters to the config file and to read them you must also add them here.
# Custom parameters are "Portal" information and are the same for all clients eg "admin_email" and "location" 
ndscustomparams=""
ndscustomimages=""
ndscustomfiles=""

ndsparamlist="$ndsparamlist $ndscustomparams $ndscustomimages $ndscustomfiles"

# The list of FAS Variables used in the Login Dialogue generated by this script is $fasvarlist and defined in libopennds.sh
#
# Additional custom FAS variables defined in this theme should be added to $fasvarlist here.
additionalthemevars="username emailaddress position company"

fasvarlist="$fasvarlist $additionalthemevars"

# You can choose to define a custom string. This will be b64 encoded and sent to openNDS.
# There it will be made available to be displayed in the output of ndsctl json as well as being sent
#	to the BinAuth post authentication processing script if enabled.
# Set the variable $binauth_custom to the desired value.
# Values set here can be overridden by the themespec file

#binauth_custom="This is sample text sent from \"$title\" to \"BinAuth\" for post authentication processing."

# Encode and activate the custom string
#encode_custom

# Set the user info string for logs (this can contain any useful information)
userinfo="$title"

# Customise the Logfile location. Note: the default uses the tmpfs "temporary" directory to prevent flash wear.
# Override the defaults to a custom location eg a mounted USB stick.
#mountpoint="/mylogdrivemountpoint"
#logdir="$mountpoint/ndslog/"
#logname="ndslog.log"



