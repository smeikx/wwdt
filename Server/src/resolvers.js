'use strict';

const { pool: db } = require('./database');
const { SelectionIterable: Selections } = require('./selection-iterable.js');

const inspect = (() => 
{
	const { inspect } = require('util');
	return (data) => inspect(data, { depth: Infinity, color: true });
})();


async function projects (args, context, info)
{
	console.log(inspect(info));

	const columns = ['id'];
	const sub_selections = {};

	for (const selection of new Selections({info}))
	{
		switch (selection.name)
		{
			case 'sesssions':
			case 'contributors':
				const sub_selections[selection.name] = selection.sub_selections;
				break;
			default:
				columns.push(selection.name);
		}
	}

	const rows = await db.query(`SELECT ${columns.join(', ')} FROM projects`);

	for (const row of rows)
	{
		row.sessions = [];
		row.contributors = [];
	}

	return rows;
}

async function resolve ({info, selections, fragments, descriptor, dependencies})
{
	const columns = [];
	for (const selection of new Selections({info}))
	{
		if (descriptor.nested_fields.hasOwnProperty(selection.name))
			;
		else
			//columns.push(selection.name);
	}
}


async function projectsSessions ({selections, project_ids, fragments})
{
	const columns = [];
	const sub_selections {};

	for (const selection of new Selections(selection))
	{
		switch (selection.name)
		{
			case 'id':
				columns.push('id');
				break;
			case 'title':
				columns.push('title');
				break;
			case 'description':
				columns.push('description');
				break;
			case 'contributors':
				sub_selections.contributors = selection.sub_selections;
				break;
			case 'assets': 
				sub_selections.assets = selection.sub_selections;
				break;
		}
	}
}


async function project (id)
{
}


async function session (id)
{
	const result = await db.query(`SELECT id, title, description FROM sessions WHERE id = ${id};`);
}


async function test ()
{
	return 'tested successfully';
}


module.exports =
{
	projects,
	test
};
