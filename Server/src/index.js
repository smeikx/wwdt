#!/usr/bin/env node
//'use strict';

const http = require('http');
const fs = require('fs');
const { basename } = require('path');
const parseUrl = require('url').parse;

const { query } = require('./query/query.js');
const { isLoggedIn } = require('./auth/auth.js');

const port = '8888';


http.createServer((request, response) =>
{
	// check for cookies
	const { user_id } =
		request.headers.hasOwnProperty('cookie') ?
		parseCookies(request.headers.cookie) : {};
	console.log(user_id);


	// auth || query
	const target = basename(request.url);
	console.log(target);

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
			if (body.length > 1e6) // 1e6 → 1 * Math.pow(10, 6) → ca. 1 MB
				request.connection.destroy();
		});

		request.on('end', () =>
		{
			query(body, user_id).then((resolve, reject) =>
			{
				response.writeHead(response_code).end(body);
			});
		});
		response.writeHead(response_code).end(body);
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

