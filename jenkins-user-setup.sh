#!/bin/bash
set -x
url=http://localhost:8080
password=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

# Hardcoded username and password
username="admin"
new_password="Entropik@2023"
fullname="admin"
email="devops@entropik.io"

# GET THE CRUMB AND COOKIE
cookie_jar="$(mktemp)"
full_crumb=$(curl -u "admin:$password" --cookie-jar "$cookie_jar" "$url/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")
only_crumb=$(echo "$full_crumb" | cut -d':' -f2)

# MAKE THE REQUEST TO CREATE AN ADMIN USER
curl -X POST -u "admin:$password" "$url/setupWizard/createAdminUser" \
    -H "Connection: keep-alive" \
    -H "Accept: application/json, text/javascript" \
    -H "X-Requested-With: XMLHttpRequest" \
    -H "$full_crumb" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --cookie "$cookie_jar" \
    --data-raw "username=$username&password1=$new_password&password2=$new_password&fullname=$fullname&email=$email&Jenkins-Crumb=$only_crumb&json=%7B%22username%22%3A%20%22$username%22%2C%20%22password1%22%3A%20%22$new_password%22%2C%20%22%24redact%22%3A%20%5B%22password1%22%2C%20%22password2%22%5D%2C%20%22password2%22%3A%20%22$new_password%22%2C%20%22fullname%22%3A%20%22$fullname%22%2C%20%22email%22%3A%20%22$email%22%2C%20%22Jenkins-Crumb%22%3A%20%22$only_crumb%22%7D&core%3Aapply=&Submit=Save"

