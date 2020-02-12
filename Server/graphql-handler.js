'use strict';

const { parse, graphql, buildSchema } = require('graphql');
const { readFileSync } = require('fs');
const db = require('./database').pool;

const schemaFile = 'schema.graphql';
let schema;

// parse schema
try
{
	const fileContent = readFileSync(schemaFile, 'utf8');
	schema = buildSchema(fileContent);
}
catch (error)
{
	console.error('Trouble parsing the schema file.');
	throw error;
}


// define functions
const root =
{
	projects: async () =>
	{
		const result = await db.query('SELECT id, title FROM projects;');
		delete result.meta;
		return result;
	},
	test: () => 'tested successfully'
};


exports.query = async (requestString) =>
{
	return await graphql(schema, requestString, root);
}

