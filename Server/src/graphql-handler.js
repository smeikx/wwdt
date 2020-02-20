'use strict';

const { parse, graphql, buildSchema } = require('graphql');
const db = require('./database').pool;

let schema;

// parse schema
try
{
	const { readFileSync } = require('fs');

	const schema_files = [
		'gql-schema/types.graphql',
		'gql-schema/query.graphql',
		'gql-schema/mutation.graphql'
	];

	let file_content = '';
	for (const file of schema_files)
		file_content += readFileSync(file, 'utf8') + '\n';

	schema = buildSchema(file_content);
}
catch (error)
{
	console.error('Trouble parsing the schema files.');
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

