#! /usr/bin/env bash

# monitor yesterday's login via ssh, and send report email 

date=`date -d "yesterday" +"%b %e"`
yesterday_acceptedlog=`grep "${date}.*sshd.*Accepted" /var/log/auth.log | grep -v "sudo"`
fail=`grep "${date}.*sshd.*Failed" /var/log/auth.log | grep -v "sudo" | wc -l`

success=`printf "%s" "$yesterday_acceptedlog" |wc -l`

warn=""
if [ $success -gt 0 ]
then
warn="[WARN] "
fi

html="<!doctype html>
<html>
  <head><title>${warn}SSH Login Reports for `uname -n` at $date </title></head>
  <body>
    <div class=\"result\">
     <strong>Success logins:</strong> $success <br />
     <table border=\"1\" style=\"border-collapse: collapse;\">
       <tr>
         <th>Time</th>
         <th>User</th>
         <th>Login Method</th>
       </tr>
`echo $yesterday_acceptedlog | awk '{if(length !=0)printf \"<tr><td>%s</td><td>%s</td><td>%s (%s:%s)</td></tr>\n\",$3,$9,$7,$11,$13}'`
     </table>

     <strong>Failed Trys: </strong> $fail <br />
    </div>
  </body>
</html>"

case $1 in 
-d | --debug) 
    printf "Success logs: %d\n%s\nRendered Html:\n%s" $success "$yesterday_acceptedlog" "$html"
    ;;
*)
    echo $html | mail -s "${warn}SSH Login Report for `uname -n` at $date" monklof@gmail.com -r report.login_review -a "Content-type: text/html"
    ;;
esac

