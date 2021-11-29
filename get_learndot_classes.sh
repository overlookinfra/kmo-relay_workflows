echo "Running github curl script"

echo "Running ni get test"

TOKEN="TrainingRocket-Authorization: $ACCESS_TOKEN"

curl -H 'content-type: application/json' \
-H 'Accept: application/json' \
-H "$TOKEN" \
-d'{ "startTime" : ["2021-11-16 17:19:11", "2021-11-20 17:19:11"] }' \
https://learn.puppet.com/api/rest/v2/manage/course_event/search \
| jq
