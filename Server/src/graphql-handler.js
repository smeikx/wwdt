'use strict';

const { parse, graphql, buildSchema } = require('graphql');
const { readFileSync } = require('fs');
const db = require('./database').pool;

const schema_file = 'schema.graphql';
let schema;

// parse schema
try
{
	const file_content = readFileSync(schema_file, 'utf8');
	schema = buildSchema(file_content);
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


exports.query = async (request_string, user_id) =>
{
	// TODO: check user permissions
	return await graphql(schema, request_string, root);
}

