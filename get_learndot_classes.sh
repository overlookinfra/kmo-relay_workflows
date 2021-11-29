echo "Running github curl script"

TOKEN="TrainingRocket-Authorization: $ACCESS_TOKEN"

RESPONSE=$(curl -H 'content-type: application/json' \
-H 'Accept: application/json' \
-H "$TOKEN" \
-d'{ "startTime" : ["2021-11-16 17:19:11", "2021-11-20 17:19:11"] }' \
https://learn.puppet.com/api/rest/v2/manage/course_event/search \
| jq -r '.results[] | "\(._displayName_) | \(.id)"')


echo "setting response output value with ni"
ni output set -k response -v $RESPONSE
