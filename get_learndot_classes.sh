echo "Running github curl script"

TOKEN="TrainingRocket-Authorization: $ACCESS_TOKEN"


curl -H 'content-type: application/json' \
-H 'Accept: application/json' \
-H "$TOKEN" \
-d "{ \"startTime\" : [\"$START_DATE 00:01:00\", \"$END_DATE 23:59:59\"] }" \
https://learn.puppet.com/api/rest/v2/manage/course_event/search \
| jq -r '.results[] | "\(._displayName_) | \(.id)"'

RESPONSE=$(curl -H 'content-type: application/json' \
-H 'Accept: application/json' \
-H "$TOKEN" \
-d "{ \"startTime\" : [\"$START_DATE 00:01:00\", \"$END_DATE 23:59:59\"] }" \
https://learn.puppet.com/api/rest/v2/manage/course_event/search \
| jq -r '.results[] | "\(._displayName_) | \(.id)"')



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



