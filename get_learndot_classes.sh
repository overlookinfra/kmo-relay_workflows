echo "Running github curl script"

TOKEN="TrainingRocket-Authorization: $ACCESS_TOKEN"


curl -H 'content-type: application/json' \
-H 'Accept: application/json' \
-H "$TOKEN" \
-d "{ \"startTime\" : [\"$START_DATE\", \"$END_DATE\"] }" \
https://learn.puppet.com/api/rest/v2/manage/course_event/search \
| jq -r '.results[] | "\(._displayName_) | \(.id)"'

RESPONSE=$(curl -H 'content-type: application/json' \
-H 'Accept: application/json' \
-H "$TOKEN" \
-d "{ \"startTime\" : [\"$START_DATE\", \"$END_DATE\"] }" \
https://learn.puppet.com/api/rest/v2/manage/course_event/search \
| jq -r '.results[] | "\(._displayName_) | \(.id)"')



if [ $RESPONSE ]
    echo "response data was: $RESPONSE"
    echo "setting response output value with ni"
    ni output set -k response -v "$RESPONSE"
    echo "setting conditional flag to TRUE"
    ni output set -k results_flag -v "TRUE"
else
    echo "No results in response: $RESPONSE"
fi



