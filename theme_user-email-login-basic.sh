#!/bin/sh
#Copyright (C) Conference Portal Theme 2024

# Title of this theme:
title="theme_conference-login"

# functions:

generate_splash_sequence() {
    name_company_login
}

header() {
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
                font-family: 'Arial', sans-serif;
            }
            
            body {
                background: #f5f5f5;
                color: #333;
            }
            
            .container {
                max-width: 600px;
                margin: 2rem auto;
                padding: 2rem;
                background: white;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            
            .header {
                text-align: center;
                margin-bottom: 2rem;
            }
            
            .header h1 {
                color: #2c3e50;
                font-size: 2rem;
                margin-bottom: 0.5rem;
            }
            
            .header p {
                color: #7f8c8d;
            }
            
            .form-group {
                margin-bottom: 1.5rem;
            }
            
            input[type=\"text\"],
            input[type=\"email\"] {
                width: 100%;
                padding: 0.8rem;
                border: 1px solid #ddd;
                border-radius: 5px;
                font-size: 1rem;
                transition: border-color 0.3s ease;
            }
            
            input[type=\"text\"]:focus,
            input[type=\"email\"]:focus {
                border-color: #3498db;
                outline: none;
            }
            
            input[type=\"submit\"] {
                width: 100%;
                padding: 1rem;
                background: #3498db;
                color: white;
                border: none;
                border-radius: 5px;
                font-size: 1rem;
                cursor: pointer;
                transition: background 0.3s ease;
            }
            
            input[type=\"submit\"]:hover {
                background: #2980b9;
            }
            
            .tos-button {
                text-align: center;
                margin-top: 1rem;
            }
            
            .tos-button input[type=\"submit\"] {
                background: #95a5a6;
                width: auto;
                padding: 0.5rem 1rem;
            }
            
            .footer {
                text-align: center;
                margin-top: 2rem;
                padding-top: 1rem;
                border-top: 1px solid #eee;
                font-size: 0.8rem;
                color: #7f8c8d;
            }
        </style>
        <title>$gatewayname</title>
        </head>
        <body>
        <div class=\"container\">
    "
}

footer() {
    year=$(date +'%Y')
    echo "
            <!-- 
            <div class=\"footer\">
                <img style=\"height:60px; width:60px;\" src=\"$imagepath\" alt=\"Conference Portal\"> 
                <p>&copy; Conference Portal $year</p>
                <p>Portal Version: $version</p>
            </div>
            -->
        </div>
        </body>
        </html>
    "
    exit 0
}

name_company_login() {
    if [ ! -z "$username" ] && [ ! -z "$position" ] && [ ! -z "$company" ] && [ ! -z "$emailaddress" ]; then
        thankyou_page
        footer
    fi

    login_form
    footer
}

login_form() {
    echo "
        <div class=\"header\">
            <h1>Welcome to the Conference!</h1>
            <p>Please sign in to access the Internet</p>
        </div>
        
        <form action=\"/opennds_preauth/\" method=\"get\">
            <input type=\"hidden\" name=\"fas\" value=\"$fas\">
            
            <div class=\"form-group\">
                <input type=\"text\" name=\"username\" value=\"$username\" 
                    autocomplete=\"on\" placeholder=\"Full Name\" required>
            </div>
            
            <div class=\"form-group\">
                <input type=\"text\" name=\"position\" value=\"$position\" 
                    autocomplete=\"on\" placeholder=\"Position\" required>
            </div>
            
            <div class=\"form-group\">
                <input type=\"text\" name=\"company\" value=\"$company\" 
                    autocomplete=\"on\" placeholder=\"Company\" required>
            </div>
            
            <div class=\"form-group\">
                <input type=\"email\" name=\"emailaddress\" value=\"$emailaddress\" 
                    autocomplete=\"on\" placeholder=\"Email Address\" required>
            </div>
            
            <input type=\"submit\" value=\"Accept Terms of Service & Connect\">
        </form>
    "

    read_terms
    footer
}

thankyou_page() {
    echo "
        <div class=\"header\">
            <h1>Thank You!</h1>
            <p>Your connection is being set up</p>
        </div>
        
        <div style=\"text-align: center; margin: 2rem 0;\">
            <h2>Welcome $username</h2>
            <p>from $company</p>
            <p style=\"color: #7f8c8d;\">You are connected to $client_zone</p>
        </div>
    "

    binauth_custom="username=$username position=$position company=$company emailaddress=$emailaddress"
    encode_custom

    if [ -z "$custom" ]; then
        customhtml=""
    else
        customhtml="<input type=\"hidden\" name=\"custom\" value=\"$custom\">"
    fi

    echo "
        <form action=\"/opennds_preauth/\" method=\"get\">
            <input type=\"hidden\" name=\"fas\" value=\"$fas\">
            <input type=\"hidden\" name=\"username\" value=\"$username\">
            <input type=\"hidden\" name=\"position\" value=\"$position\">
            <input type=\"hidden\" name=\"company\" value=\"$company\">
            <input type=\"hidden\" name=\"emailaddress\" value=\"$emailaddress\">
            $customhtml
            <input type=\"hidden\" name=\"landing\" value=\"yes\">
            <input type=\"submit\" value=\"Continue to google.com\" 
                onClick=\"window.location.href='https://google.com'; return true;\">
        </form>
    "

    read_terms
    footer
}

# Function to create JSON entry for a user
create_json_entry() {
    # Get current timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Create JSON object that matches existing log format
    json_entry="{
        \"timestamp\": \"$timestamp\",
        \"status\": \"$authstat\",
        \"mac\": \"$clientmac\",
        \"ip\": \"$clientip\",
        \"client_type\": \"$client_type\",
        \"zone\": \"$client_zone\",
        \"user_agent\": \"$user_agent\",
        \"username\": \"$username\",
        \"position\": \"$position\",
        \"company\": \"$company\",
        \"email\": \"$emailaddress\"
    }"
    
    echo "$json_entry"
}

# Function to append to JSON file
append_to_json_file() {
    local json_file="/tmp/portal_auth.json"
    local temp_file="/tmp/temp_portal_auth.json"
    
    # Create JSON file with array structure if it doesn't exist
    if [ ! -f "$json_file" ]; then
        echo '{"authentications":[]}' > "$json_file"
    fi
    
    # Get new entry
    local new_entry=$(create_json_entry)
    
    # Read existing file and insert new entry
    jq --arg entry "$new_entry" '.authentications += [$entry | fromjson]' "$json_file" > "$temp_file"
    
    # Move temp file to original
    mv "$temp_file" "$json_file"
    
    # Set appropriate permissions
    chmod 644 "$json_file"
}

# Modified auth_log function that maintains original functionality
auth_log() {
    # Original authentication logic
    rhid=$(printf "$hid$key" | sha256sum | awk -F' ' '{printf $1}')
    ndsctlcmd="auth $rhid $quotas $custom"

    do_ndsctl
    authstat=$ndsctlout
    
    # Original logging
    loginfo="$userinfo, status=$authstat, mac=$clientmac, ip=$clientip, client_type=$client_type, zone=$client_zone, ua=$user_agent"
    write_log
    
    # Additional JSON logging
    append_to_json_file
    
    # We will not remove the client id file, rather we will let openNDS delete it on deauth/timeout
}

# Modify the landing_page function to include the new logging
landing_page() {
    # Override the landing page to redirect to google.com
    originurl="https://google.com"
    
    # Add the user credentials to $userinfo for the log
    userinfo="$userinfo, user=$username, position=$position, company=$company, email=$emailaddress"

    # authenticate and write to both logs
    auth_log

    # Rest of the landing_page function remains the same
    auth_success="
        <p>
            <big-red>
                You are now logged in and have been granted access to the Internet.
            </big-red>
            <hr>
            <italic-black>
                You will be redirected to google.com momentarily...
            </italic-black>
        </p>
        <script>
            window.location.href = 'https://google.com';
        </script>
    "
    
    auth_fail="
        <p>
            <big-red>
                Something went wrong and you have failed to log in.
            </big-red>
            <hr>
        </p>
        <hr>
        <p>
            <italic-black>
                Your login attempt probably timed out.
            </italic-black>
        </p>
        <p>
            <br>
            Click or tap Continue to try again.
        </p>
        <form>
            <input type=\"button\" VALUE=\"Continue\" onClick=\"location.href='$originurl'\" >
        </form>
        <hr>
    "

    if [ "$ndsstatus" = "authenticated" ]; then
        echo "$auth_success"
    else
        echo "$auth_fail"
    fi

    read_terms
    footer
}

# Include other necessary functions from the original theme
# (read_terms, display_terms remain the same)

# Add position and company to the additional theme variables
additionalthemevars="username position company emailaddress"

fasvarlist="$fasvarlist $additionalthemevars"

# Set the custom string for logs
userinfo="$title"