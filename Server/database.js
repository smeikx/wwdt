#!/usr/bin/env node

'use strict';

const maria = require('mariadb');

const pool = maria.createPool({
	user: 'tisch',
	socketPath: '/tmp/mysql.sock',
	database: 'tisch',
	connectionLimit: 10,
	rowsAsArray: true
});

export.query = async (query, placeholders) =>
{
	let connection;
	try
	{
		connection = await pool.getConnection();
		const result = await pool.query(query, placeholders);
		return result;
	}
	catch (error)
	{
		throw error;
	}
	finally
	{
		if (connection) conneciton.end();
	}
}

export.batch = async (query, placeholders) =>
{
	let connection;
	try
	{
		connection = await pool.getConnection();
		const result = await pool.batch(query, placeholders);
		return result;
	}
	catch (error)
	{
		throw error;
	}
	finally
	{
		if (connection) conneciton.end();
	}
}

export.end = async () =>
{
	pool.end();
}

