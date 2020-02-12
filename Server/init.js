#!/usr/bin/env node

'use strict';

const http = require('http');
const gql = require('./graphql-handler');
const { inspect } = require('util');

const port = 8080;

const server = http.createServer((request, resolve) =>
{
	//console.log(request.headers);
	if (request.method == 'POST')
	{
		let body = '';

		request.on('data', (data) =>
		{
			body += data;
			const dataLimit = 1e6;
			if (body.length > dataLimit)
				request.connection.destroy();
		});

		request.on('end', () =>
		{
			console.log(`\nrequest:\n${body}`);
			gql.query(body)
				.then(result =>
				{
					console.log(`\nresult:`)
					console.log(inspect(result, {depth: Infinity, showHidden: true, colors: true}));
					resolve.writeHead(200, { 'Content-Type': 'text/plain' });
					resolve.end(JSON.stringify(result, null, 2));
				})
				.catch(error => console.error(error));
		});
	}
	else
	{
		resolve.writeHead(500, { 'Content-Type': 'text/plain' });
		resolve.end('MISSION FAILED\n');
	}
});

server.listen(port);
console.log(`Server listening on port ${port}.`);

