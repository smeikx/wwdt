#!/usr/bin/env node

'use strict';

const maria = require('mariadb');

exports.pool = maria.createPool({
	user: 'tisch',
	socketPath: '/tmp/mysql.sock',
	database: 'tisch',
	connectionLimit: 10,
	dateStrings: true,
	rowsAsArray: false
});

