echo "Running github curl script"

TOKEN="TrainingRocket-Authorization: $ACCESS_TOKEN"


curl -H 'content-type: application/json' \
-H 'Accept: application/json' \
-H "$TOKEN" \
-d "{ \"startTime\" : [\"$START_DATE 00:01:00\", \"$END_DATE 23:59:59\"] }" \
https://learn.puppet.com/api/rest/v2/manage/course_event/search \
| jq -r '.results[] | select(.status == "CONFIRMED") | "\(._displayName_) | \(.id)"'

CURLOUTPUT=$(curl -H 'content-type: application/json' \
-H 'Accept: application/json' \
-H "$TOKEN" \
-d "{ \"startTime\" : [\"$START_DATE 00:01:00\", \"$END_DATE 23:59:59\"] }" \
https://learn.puppet.com/api/rest/v2/manage/course_event/search \
| jq -r '.results[] | select(.status == "CONFIRMED") | "\(._displayName_) | \(.id)"')

RESPONSE=`echo "$CURLOUTPUT" | while IFS= read -r line 
do 
    login_check=$(echo $line | awk -F "|" '{print $2}' | xargs -n 1 -I {} curl -sL https://class\{\}.classroom.puppet.com/ | grep "<title>");
    if [[ $login_check == *"Puppet"* ]] 
    then 
        echo "$line | Login Page Response: 200 ok";
    else 
        echo "$line | Login page not found!!!! - Possible Hydra Failure!";
    fi
done `

if [ -z "$RESPONSE" ]
then
    echo "No results in response: $RESPONSE"
    echo "Setting result flag to FALSE"
    ni output set -k results_flag -v "FALSE"
else
    echo "response data was: $RESPONSE"
    echo "setting response output value with ni"
    ni output set -k response -v "$RESPONSE"
    echo "setting conditional flag to TRUE"
    ni output set -k results_flag -v "TRUE"
fi



