$response = Invoke-WebRequest -Uri "https://hooks.slack.com/services/<T ...>" `
    -Method Post `
    -ContentType "application/json" `
    -Body "{`"text`":`"Correction on hope-minion config done!`"}"