#!/usr/bin/env node

'use strict';

const http = require('http');
const { basename } = require('path');
const parseUrl = require('url').parse;

const gql = require('./graphql-handler');
const { isLoggedIn } = require('./auth');

const port = '8888';


http.createServer((request, response) =>
{
	let response_code, response_data;

	// check for cookies
	const { user_id } =
		request.headers.hasOwnProperty('cookie') ?
		parseCookies(request.headers.cookie) : {};


	// auth || query
	const target = basename(request.url);

	const user_logged_in = isLoggedIn(user_id);

	// request is forwarded by Nginx’ ‘auth_request’
	if (target === 'auth')
		response.writeHead(user_logged_in ? 204 : 401).end();
	
	// request is a GraphQL request
	if (target === 'query')
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
			gql.query(body)
				.then(result =>
				{
					response.setHeader('Content-Type', 'text/plain');
					response_data = JSON.stringify(result, null, 2);
				})
				.catch(error => 
				{
					response_code = 500;
					response_data = error.message;
					console.error(error)
				})
				.finally(() =>
					response.writeHead(response_code).end(response_data));
		});
	}
	else response.writeHead(400).end();
}).listen(port);

console.log(`Server running at http://127.0.0.1:${port}/`);


function parseCookies(cookie_header)
{
	const cookie_strings = cookie_header.split('; ');
	const cookies = {};

	const pattern = /\w+/g;
	for (const cookie_string of cookie_strings)
	{
		const [name, value] = cookie_string.match(pattern);
		cookies[name] = value;
	}

	return cookies;
}

