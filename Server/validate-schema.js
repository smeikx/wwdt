#!/usr/bin/env node

'use strict';

const { buildSchema } = require('graphql');
const fs = require('fs');

const schemaFiles = [
	'schema.graphql',
	'query.graphql',
	'mutation.graphql'
];

const requests = schemaFiles.map(
	path => new Promise((resolve, reject) =>
	{
		fs.readFile(path, 'utf8', (err, data) =>
		{
			if (err) reject(err)
			else resolve(data);
		})
	})
);

Promise.all(requests)
	.then(responses => buildSchema(responses.join('\n')))
	.catch(console.log);

