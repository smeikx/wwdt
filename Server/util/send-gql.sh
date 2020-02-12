#!/usr/bin/env dash

PORT=8080

if [ $# -gt 0 ]
then
	PORT=$1
fi

echo $PORT

curl -H "Content-Type: text/plain" localhost:$PORT -d @-

