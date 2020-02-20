'use strict';

const { pool: db } = require('./database');
const { SelectionIterable: Selections } = require('./selection-iterable.js');

const inspect = (() => 
{
	const { inspect } = require('util');
	return (data) => inspect(data, { depth: Infinity, color: true });
})();


async function test ()
{
	return 'tested successfully';
}


module.exports =
{
	test
};
