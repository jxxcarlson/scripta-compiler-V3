(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}




var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log = F2(function(tag, value)
{
	return value;
});

var _Debug_log_UNUSED = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString(value)
{
	return '<internals>';
}

function _Debug_toString_UNUSED(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.bG.aT === region.au.aT)
	{
		return 'on line ' + region.bG.aT;
	}
	return 'on lines ' + region.bG.aT + ' through ' + region.au.aT;
}



// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**_UNUSED/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**_UNUSED/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**/
	if (typeof x.$ === 'undefined')
	//*/
	/**_UNUSED/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0 = 0;
var _Utils_Tuple0_UNUSED = { $: '#0' };

function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2_UNUSED(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3_UNUSED(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr(c) { return c; }
function _Utils_chr_UNUSED(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil = { $: 0 };
var _List_Nil_UNUSED = { $: '[]' };

function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons_UNUSED(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**_UNUSED/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (Object.prototype.hasOwnProperty.call(value, key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
function _Json_unwrap_UNUSED(value) { return value.a; }

function _Json_wrap(value) { return value; }
function _Json_unwrap(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	var unwrapped = _Json_unwrap(value);
	if (!(key === 'toJSON' && typeof unwrapped === 'function'))
	{
		object[key] = unwrapped;
	}
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.cZ,
		impl.dn,
		impl.di,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		var pair = A2(update, msg, model);
		stepper(model = pair.a, viewMetadata);
		_Platform_enqueueEffects(managers, pair.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, initPair.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});




// STRINGS


var _Parser_isSubString = F5(function(smallString, offset, row, col, bigString)
{
	var smallLength = smallString.length;
	var isGood = offset + smallLength <= bigString.length;

	for (var i = 0; isGood && i < smallLength; )
	{
		var code = bigString.charCodeAt(offset);
		isGood =
			smallString[i++] === bigString[offset++]
			&& (
				code === 0x000A /* \n */
					? ( row++, col=1 )
					: ( col++, (code & 0xF800) === 0xD800 ? smallString[i++] === bigString[offset++] : 1 )
			)
	}

	return _Utils_Tuple3(isGood ? offset : -1, row, col);
});



// CHARS


var _Parser_isSubChar = F3(function(predicate, offset, string)
{
	return (
		string.length <= offset
			? -1
			:
		(string.charCodeAt(offset) & 0xF800) === 0xD800
			? (predicate(_Utils_chr(string.substr(offset, 2))) ? offset + 2 : -1)
			:
		(predicate(_Utils_chr(string[offset]))
			? ((string[offset] === '\n') ? -2 : (offset + 1))
			: -1
		)
	);
});


var _Parser_isAsciiCode = F3(function(code, offset, string)
{
	return string.charCodeAt(offset) === code;
});



// NUMBERS


var _Parser_chompBase10 = F2(function(offset, string)
{
	for (; offset < string.length; offset++)
	{
		var code = string.charCodeAt(offset);
		if (code < 0x30 || 0x39 < code)
		{
			return offset;
		}
	}
	return offset;
});


var _Parser_consumeBase = F3(function(base, offset, string)
{
	for (var total = 0; offset < string.length; offset++)
	{
		var digit = string.charCodeAt(offset) - 0x30;
		if (digit < 0 || base <= digit) break;
		total = base * total + digit;
	}
	return _Utils_Tuple2(offset, total);
});


var _Parser_consumeBase16 = F2(function(offset, string)
{
	for (var total = 0; offset < string.length; offset++)
	{
		var code = string.charCodeAt(offset);
		if (0x30 <= code && code <= 0x39)
		{
			total = 16 * total + code - 0x30;
		}
		else if (0x41 <= code && code <= 0x46)
		{
			total = 16 * total + code - 55;
		}
		else if (0x61 <= code && code <= 0x66)
		{
			total = 16 * total + code - 87;
		}
		else
		{
			break;
		}
	}
	return _Utils_Tuple2(offset, total);
});



// FIND STRING


var _Parser_findSubString = F5(function(smallString, offset, row, col, bigString)
{
	var newOffset = bigString.indexOf(smallString, offset);
	var target = newOffset < 0 ? bigString.length : newOffset + smallString.length;

	while (offset < target)
	{
		var code = bigString.charCodeAt(offset++);
		code === 0x000A /* \n */
			? ( col=1, row++ )
			: ( col++, (code & 0xF800) === 0xD800 && offset++ )
	}

	return _Utils_Tuple3(newOffset, row, col);
});
var $elm$core$List$cons = _List_cons;
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === -2) {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Basics$EQ = 1;
var $elm$core$Basics$GT = 2;
var $elm$core$Basics$LT = 0;
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $author$project$WorkerOptimize$GotCommand = $elm$core$Basics$identity;
var $elm$core$Maybe$Nothing = {$: 1};
var $elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$core$Result$Err = function (a) {
	return {$: 1, a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 0, a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 2, a: a};
};
var $elm$core$Basics$False = 1;
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 0, a: a};
};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 0:
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 1) {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 1:
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 2:
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 1, a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.m) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.s),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.s);
		} else {
			var treeLen = builder.m * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.x) : builder.x;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.m);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.s) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.s);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{x: nodeList, m: (len / $elm$core$Array$branchFactor) | 0, s: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = 0;
var $elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $elm$json$Json$Decode$field = _Json_decodeField;
var $elm$json$Json$Decode$string = _Json_decodeString;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $author$project$WorkerOptimize$receiveCommand = _Platform_incomingPort(
	'receiveCommand',
	A2(
		$elm$json$Json$Decode$andThen,
		function (sourceText) {
			return A2(
				$elm$json$Json$Decode$andThen,
				function (command) {
					return $elm$json$Json$Decode$succeed(
						{bR: command, dg: sourceText});
				},
				A2($elm$json$Json$Decode$field, 'command', $elm$json$Json$Decode$string));
		},
		A2($elm$json$Json$Decode$field, 'sourceText', $elm$json$Json$Decode$string)));
var $author$project$V3$Types$Dark = 1;
var $author$project$V3$Types$NoFilter = 0;
var $author$project$TestData$defaultCompilerParameters = {
	cP: 0,
	bX: 0,
	F: 1,
	de: false,
	df: {cI: 14.0, cX: 2, cY: 20.0, c1: 0.0, c2: 0.0, c9: 18.0, dd: 1.0},
	dk: 1,
	$7: 600,
	dp: 600
};
var $elm$core$String$lines = _String_lines;
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3($elm$core$List$foldr, $elm$core$List$cons, ys, xs);
		}
	});
var $elm$core$List$concat = function (lists) {
	return A3($elm$core$List$foldr, $elm$core$List$append, _List_Nil, lists);
};
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$core$List$concatMap = F2(
	function (f, list) {
		return $elm$core$List$concat(
			A2($elm$core$List$map, f, list));
	});
var $maca$elm_rose_tree$RoseTree$Tree$children = function (_v0) {
	var ns = _v0.b;
	return $elm$core$Array$toList(ns);
};
var $maca$elm_rose_tree$RoseTree$Tree$value = function (_v0) {
	var a = _v0.a;
	return a;
};
var $author$project$Parser$Forest$flattenTree = function (tree) {
	return A2(
		$elm$core$List$cons,
		$maca$elm_rose_tree$RoseTree$Tree$value(tree),
		A2(
			$elm$core$List$concatMap,
			$author$project$Parser$Forest$flattenTree,
			$maca$elm_rose_tree$RoseTree$Tree$children(tree)));
};
var $elm$core$Dict$Black = 1;
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: -1, a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$Red = 0;
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === -1) && (!right.a)) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === -1) && (!left.a)) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === -1) && (!left.a)) && (left.d.$ === -1)) && (!left.d.a)) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === -2) {
			return A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1) {
				case 0:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 1:
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$fromList = function (assocs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, dict) {
				var key = _v0.a;
				var value = _v0.b;
				return A3($elm$core$Dict$insert, key, value, dict);
			}),
		$elm$core$Dict$empty,
		assocs);
};
var $author$project$Parser$Forest$buildExpressionCache = function (forest) {
	return $elm$core$Dict$fromList(
		A2(
			$elm$core$List$map,
			function (block) {
				return _Utils_Tuple2(block.A.dg, block.bO);
			},
			A2($elm$core$List$concatMap, $author$project$Parser$Forest$flattenTree, forest)));
};
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $author$project$Generic$BlockUtilities$getExpressionBlockName = function (block) {
	var _v0 = block.P;
	switch (_v0.$) {
		case 0:
			return $elm$core$Maybe$Nothing;
		case 1:
			var name = _v0.a;
			return $elm$core$Maybe$Just(name);
		default:
			var name = _v0.a;
			return $elm$core$Maybe$Just(name);
	}
};
var $author$project$Parser$Forest$filterForestOnName = F2(
	function (predicate, forest) {
		return A2(
			$elm$core$List$filter,
			function (tree) {
				return predicate(
					$author$project$Generic$BlockUtilities$getExpressionBlockName(
						$maca$elm_rose_tree$RoseTree$Tree$value(tree)));
			},
			forest);
	});
var $elm$core$Basics$neq = _Utils_notEqual;
var $author$project$Parser$Forest$filterForest = F2(
	function (filter, forest) {
		if (!filter) {
			return forest;
		} else {
			return A2(
				$author$project$Parser$Forest$filterForestOnName,
				function (name) {
					return !_Utils_eq(
						name,
						$elm$core$Maybe$Just('title'));
				},
				A2(
					$author$project$Parser$Forest$filterForestOnName,
					function (name) {
						return !_Utils_eq(
							name,
							$elm$core$Maybe$Just('document'));
					},
					forest));
		}
	});
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (!_v0.$) {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $author$project$Library$Tree$initTree = function (input) {
	return {_: input, bj: 0, aC: $elm$core$Maybe$Nothing, Y: $elm$core$Maybe$Nothing};
};
var $author$project$Tools$Loop$loop = F2(
	function (s, f) {
		loop:
		while (true) {
			var _v0 = f(s);
			if (!_v0.$) {
				var s_ = _v0.a;
				var $temp$s = s_,
					$temp$f = f;
				s = $temp$s;
				f = $temp$f;
				continue loop;
			} else {
				var b = _v0.a;
				return b;
			}
		}
	});
var $author$project$Tools$Loop$Done = function (a) {
	return {$: 1, a: a};
};
var $author$project$Tools$Loop$Loop = function (a) {
	return {$: 0, a: a};
};
var $maca$elm_rose_tree$RoseTree$Tree$Tree = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$core$Array$fromListHelp = F3(
	function (list, nodeList, nodeListSize) {
		fromListHelp:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, list);
			var jsArray = _v0.a;
			var remainingItems = _v0.b;
			if (_Utils_cmp(
				$elm$core$Elm$JsArray$length(jsArray),
				$elm$core$Array$branchFactor) < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					true,
					{x: nodeList, m: nodeListSize, s: jsArray});
			} else {
				var $temp$list = remainingItems,
					$temp$nodeList = A2(
					$elm$core$List$cons,
					$elm$core$Array$Leaf(jsArray),
					nodeList),
					$temp$nodeListSize = nodeListSize + 1;
				list = $temp$list;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue fromListHelp;
			}
		}
	});
var $elm$core$Array$fromList = function (list) {
	if (!list.b) {
		return $elm$core$Array$empty;
	} else {
		return A3($elm$core$Array$fromListHelp, list, _List_Nil, 0);
	}
};
var $maca$elm_rose_tree$RoseTree$Tree$branch = F2(
	function (a, ns) {
		return A2(
			$maca$elm_rose_tree$RoseTree$Tree$Tree,
			a,
			$elm$core$Array$fromList(ns));
	});
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $maca$elm_rose_tree$RoseTree$Tree$leaf = function (a) {
	return A2($maca$elm_rose_tree$RoseTree$Tree$Tree, a, $elm$core$Array$empty);
};
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$Maybe$map2 = F3(
	function (func, ma, mb) {
		if (ma.$ === 1) {
			return $elm$core$Maybe$Nothing;
		} else {
			var a = ma.a;
			if (mb.$ === 1) {
				return $elm$core$Maybe$Nothing;
			} else {
				var b = mb.a;
				return $elm$core$Maybe$Just(
					A2(func, a, b));
			}
		}
	});
var $elm$core$Elm$JsArray$push = _JsArray_push;
var $elm$core$Bitwise$and = _Bitwise_and;
var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var $elm$core$Array$bitMask = 4294967295 >>> (32 - $elm$core$Array$shiftStep);
var $elm$core$Basics$ge = _Utils_ge;
var $elm$core$Elm$JsArray$singleton = _JsArray_singleton;
var $elm$core$Elm$JsArray$unsafeGet = _JsArray_unsafeGet;
var $elm$core$Elm$JsArray$unsafeSet = _JsArray_unsafeSet;
var $elm$core$Array$insertTailInTree = F4(
	function (shift, index, tail, tree) {
		var pos = $elm$core$Array$bitMask & (index >>> shift);
		if (_Utils_cmp(
			pos,
			$elm$core$Elm$JsArray$length(tree)) > -1) {
			if (shift === 5) {
				return A2(
					$elm$core$Elm$JsArray$push,
					$elm$core$Array$Leaf(tail),
					tree);
			} else {
				var newSub = $elm$core$Array$SubTree(
					A4($elm$core$Array$insertTailInTree, shift - $elm$core$Array$shiftStep, index, tail, $elm$core$Elm$JsArray$empty));
				return A2($elm$core$Elm$JsArray$push, newSub, tree);
			}
		} else {
			var value = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (!value.$) {
				var subTree = value.a;
				var newSub = $elm$core$Array$SubTree(
					A4($elm$core$Array$insertTailInTree, shift - $elm$core$Array$shiftStep, index, tail, subTree));
				return A3($elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			} else {
				var newSub = $elm$core$Array$SubTree(
					A4(
						$elm$core$Array$insertTailInTree,
						shift - $elm$core$Array$shiftStep,
						index,
						tail,
						$elm$core$Elm$JsArray$singleton(value)));
				return A3($elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			}
		}
	});
var $elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var $elm$core$Array$unsafeReplaceTail = F2(
	function (newTail, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		var originalTailLen = $elm$core$Elm$JsArray$length(tail);
		var newTailLen = $elm$core$Elm$JsArray$length(newTail);
		var newArrayLen = len + (newTailLen - originalTailLen);
		if (_Utils_eq(newTailLen, $elm$core$Array$branchFactor)) {
			var overflow = _Utils_cmp(newArrayLen >>> $elm$core$Array$shiftStep, 1 << startShift) > 0;
			if (overflow) {
				var newShift = startShift + $elm$core$Array$shiftStep;
				var newTree = A4(
					$elm$core$Array$insertTailInTree,
					newShift,
					len,
					newTail,
					$elm$core$Elm$JsArray$singleton(
						$elm$core$Array$SubTree(tree)));
				return A4($elm$core$Array$Array_elm_builtin, newArrayLen, newShift, newTree, $elm$core$Elm$JsArray$empty);
			} else {
				return A4(
					$elm$core$Array$Array_elm_builtin,
					newArrayLen,
					startShift,
					A4($elm$core$Array$insertTailInTree, startShift, len, newTail, tree),
					$elm$core$Elm$JsArray$empty);
			}
		} else {
			return A4($elm$core$Array$Array_elm_builtin, newArrayLen, startShift, tree, newTail);
		}
	});
var $elm$core$Array$push = F2(
	function (a, array) {
		var tail = array.d;
		return A2(
			$elm$core$Array$unsafeReplaceTail,
			A2($elm$core$Elm$JsArray$push, a, tail),
			array);
	});
var $maca$elm_rose_tree$RoseTree$Tree$push = F2(
	function (n, _v0) {
		var a = _v0.a;
		var ns = _v0.b;
		return A2(
			$maca$elm_rose_tree$RoseTree$Tree$Tree,
			a,
			A2($elm$core$Array$push, n, ns));
	});
var $elm$core$Array$getHelp = F3(
	function (shift, index, tree) {
		getHelp:
		while (true) {
			var pos = $elm$core$Array$bitMask & (index >>> shift);
			var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (!_v0.$) {
				var subTree = _v0.a;
				var $temp$shift = shift - $elm$core$Array$shiftStep,
					$temp$index = index,
					$temp$tree = subTree;
				shift = $temp$shift;
				index = $temp$index;
				tree = $temp$tree;
				continue getHelp;
			} else {
				var values = _v0.a;
				return A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, values);
			}
		}
	});
var $elm$core$Array$tailIndex = function (len) {
	return (len >>> 5) << 5;
};
var $elm$core$Array$get = F2(
	function (index, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? $elm$core$Maybe$Nothing : ((_Utils_cmp(
			index,
			$elm$core$Array$tailIndex(len)) > -1) ? $elm$core$Maybe$Just(
			A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, tail)) : $elm$core$Maybe$Just(
			A3($elm$core$Array$getHelp, startShift, index, tree)));
	});
var $elm$core$Array$setHelp = F4(
	function (shift, index, value, tree) {
		var pos = $elm$core$Array$bitMask & (index >>> shift);
		var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
		if (!_v0.$) {
			var subTree = _v0.a;
			var newSub = A4($elm$core$Array$setHelp, shift - $elm$core$Array$shiftStep, index, value, subTree);
			return A3(
				$elm$core$Elm$JsArray$unsafeSet,
				pos,
				$elm$core$Array$SubTree(newSub),
				tree);
		} else {
			var values = _v0.a;
			var newLeaf = A3($elm$core$Elm$JsArray$unsafeSet, $elm$core$Array$bitMask & index, value, values);
			return A3(
				$elm$core$Elm$JsArray$unsafeSet,
				pos,
				$elm$core$Array$Leaf(newLeaf),
				tree);
		}
	});
var $elm$core$Array$set = F3(
	function (index, value, array) {
		var len = array.a;
		var startShift = array.b;
		var tree = array.c;
		var tail = array.d;
		return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? array : ((_Utils_cmp(
			index,
			$elm$core$Array$tailIndex(len)) > -1) ? A4(
			$elm$core$Array$Array_elm_builtin,
			len,
			startShift,
			tree,
			A3($elm$core$Elm$JsArray$unsafeSet, $elm$core$Array$bitMask & index, value, tail)) : A4(
			$elm$core$Array$Array_elm_builtin,
			len,
			startShift,
			A4($elm$core$Array$setHelp, startShift, index, value, tree),
			tail));
	});
var $elm_community$array_extra$Array$Extra$update = F2(
	function (index, alter) {
		return function (array) {
			var _v0 = A2($elm$core$Array$get, index, array);
			if (_v0.$ === 1) {
				return array;
			} else {
				var element = _v0.a;
				return A3(
					$elm$core$Array$set,
					index,
					alter(element),
					array);
			}
		};
	});
var $maca$elm_rose_tree$RoseTree$Tree$updateAtHelp = F3(
	function (path, f, _v0) {
		var a = _v0.a;
		var ns = _v0.b;
		if (path.b) {
			if (!path.b.b) {
				var idx = path.a;
				return A2(
					$maca$elm_rose_tree$RoseTree$Tree$Tree,
					a,
					A2(f, idx, ns));
			} else {
				var idx = path.a;
				var rest = path.b;
				return A2(
					$maca$elm_rose_tree$RoseTree$Tree$Tree,
					a,
					A3(
						$elm_community$array_extra$Array$Extra$update,
						idx,
						A2($maca$elm_rose_tree$RoseTree$Tree$updateAtHelp, rest, f),
						ns));
			}
		} else {
			return A2($maca$elm_rose_tree$RoseTree$Tree$Tree, a, ns);
		}
	});
var $maca$elm_rose_tree$RoseTree$Tree$updateAt = F3(
	function (path, f, tree) {
		if (!path.b) {
			return f(tree);
		} else {
			return A3(
				$maca$elm_rose_tree$RoseTree$Tree$updateAtHelp,
				path,
				function (idx) {
					return A2($elm_community$array_extra$Array$Extra$update, idx, f);
				},
				tree);
		}
	});
var $maca$elm_rose_tree$RoseTree$Tree$pushChildFor = F2(
	function (path, child) {
		return A2(
			$maca$elm_rose_tree$RoseTree$Tree$updateAt,
			path,
			$maca$elm_rose_tree$RoseTree$Tree$push(child));
	});
var $elm$core$List$takeReverse = F3(
	function (n, list, kept) {
		takeReverse:
		while (true) {
			if (n <= 0) {
				return kept;
			} else {
				if (!list.b) {
					return kept;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs,
						$temp$kept = A2($elm$core$List$cons, x, kept);
					n = $temp$n;
					list = $temp$list;
					kept = $temp$kept;
					continue takeReverse;
				}
			}
		}
	});
var $elm$core$List$takeTailRec = F2(
	function (n, list) {
		return $elm$core$List$reverse(
			A3($elm$core$List$takeReverse, n, list, _List_Nil));
	});
var $elm$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (n <= 0) {
			return _List_Nil;
		} else {
			var _v0 = _Utils_Tuple2(n, list);
			_v0$1:
			while (true) {
				_v0$5:
				while (true) {
					if (!_v0.b.b) {
						return list;
					} else {
						if (_v0.b.b.b) {
							switch (_v0.a) {
								case 1:
									break _v0$1;
								case 2:
									var _v2 = _v0.b;
									var x = _v2.a;
									var _v3 = _v2.b;
									var y = _v3.a;
									return _List_fromArray(
										[x, y]);
								case 3:
									if (_v0.b.b.b.b) {
										var _v4 = _v0.b;
										var x = _v4.a;
										var _v5 = _v4.b;
										var y = _v5.a;
										var _v6 = _v5.b;
										var z = _v6.a;
										return _List_fromArray(
											[x, y, z]);
									} else {
										break _v0$5;
									}
								default:
									if (_v0.b.b.b.b && _v0.b.b.b.b.b) {
										var _v7 = _v0.b;
										var x = _v7.a;
										var _v8 = _v7.b;
										var y = _v8.a;
										var _v9 = _v8.b;
										var z = _v9.a;
										var _v10 = _v9.b;
										var w = _v10.a;
										var tl = _v10.b;
										return (ctr > 1000) ? A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A2($elm$core$List$takeTailRec, n - 4, tl))))) : A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A3($elm$core$List$takeFast, ctr + 1, n - 4, tl)))));
									} else {
										break _v0$5;
									}
							}
						} else {
							if (_v0.a === 1) {
								break _v0$1;
							} else {
								break _v0$5;
							}
						}
					}
				}
				return list;
			}
			var _v1 = _v0.b;
			var x = _v1.a;
			return _List_fromArray(
				[x]);
		}
	});
var $elm$core$List$take = F2(
	function (n, list) {
		return A3($elm$core$List$takeFast, 0, n, list);
	});
var $author$project$Library$Tree$nextStepTree = F2(
	function (getLevel, state) {
		var _v0 = state._;
		if (!_v0.b) {
			return $author$project$Tools$Loop$Done(state.aC);
		} else {
			if (!_v0.b.b) {
				var lastItem = _v0.a;
				var _v1 = state.Y;
				if (_v1.$ === 1) {
					return $author$project$Tools$Loop$Done(
						$elm$core$Maybe$Just(
							A2($maca$elm_rose_tree$RoseTree$Tree$branch, lastItem, _List_Nil)));
				} else {
					var path = _v1.a;
					return $author$project$Tools$Loop$Done(
						A2(
							$elm$core$Maybe$map,
							A2(
								$maca$elm_rose_tree$RoseTree$Tree$pushChildFor,
								path,
								$maca$elm_rose_tree$RoseTree$Tree$leaf(lastItem)),
							state.aC));
				}
			} else {
				var currentItem = _v0.a;
				var _v2 = _v0.b;
				var nextItem = _v2.a;
				var rest = _v2.b;
				var newOutput = function () {
					var _v5 = state.Y;
					if (_v5.$ === 1) {
						return $elm$core$Maybe$Just(
							A2($maca$elm_rose_tree$RoseTree$Tree$branch, currentItem, _List_Nil));
					} else {
						var path = _v5.a;
						return A2(
							$elm$core$Maybe$map,
							A2(
								$maca$elm_rose_tree$RoseTree$Tree$pushChildFor,
								path,
								$maca$elm_rose_tree$RoseTree$Tree$leaf(currentItem)),
							state.aC);
					}
				}();
				var indexToActiveNode = A2(
					$elm$core$Maybe$map,
					A2(
						$elm$core$Basics$composeR,
						$maca$elm_rose_tree$RoseTree$Tree$children,
						A2(
							$elm$core$Basics$composeR,
							$elm$core$List$length,
							function (i) {
								return i - 1;
							})),
					newOutput);
				var dropLast = function (list) {
					return A2(
						$elm$core$List$take,
						$elm$core$List$length(list) - 1,
						list);
				};
				var append = F2(
					function (k, list) {
						return _Utils_ap(
							list,
							_List_fromArray(
								[k]));
					});
				var getNewPath = F2(
					function (currentItem_, nextItem_) {
						var _v3 = A2(
							$elm$core$Basics$compare,
							getLevel(nextItem_),
							getLevel(currentItem_));
						switch (_v3) {
							case 2:
								var _v4 = state.Y;
								if (_v4.$ === 1) {
									return $elm$core$Maybe$Just(_List_Nil);
								} else {
									return A3($elm$core$Maybe$map2, append, indexToActiveNode, state.Y);
								}
							case 1:
								return state.Y;
							default:
								return A2($elm$core$Maybe$map, dropLast, state.Y);
						}
					});
				var newPath = A2(getNewPath, currentItem, nextItem);
				return $author$project$Tools$Loop$Loop(
					{
						_: A2($elm$core$List$cons, nextItem, rest),
						bj: state.bj + 1,
						aC: newOutput,
						Y: newPath
					});
			}
		}
	});
var $author$project$Library$Tree$makeTree = F2(
	function (getLevel, input) {
		var initialState = $author$project$Library$Tree$initTree(input);
		return A2(
			$author$project$Tools$Loop$loop,
			initialState,
			$author$project$Library$Tree$nextStepTree(getLevel));
	});
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Library$Forest$init = F2(
	function (getLevel, input) {
		var _v0 = $elm$core$List$head(input);
		if (_v0.$ === 1) {
			return {aM: 0, V: _List_Nil, _: _List_Nil, aC: _List_Nil, bm: 0};
		} else {
			var item = _v0.a;
			return {
				aM: getLevel(item),
				V: _List_Nil,
				_: input,
				aC: _List_Nil,
				bm: getLevel(item)
			};
		}
	});
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $author$project$Library$Forest$nextStep = F2(
	function (getLevel, state) {
		var _v0 = state._;
		if (!_v0.b) {
			return $author$project$Tools$Loop$Done(
				$elm$core$List$reverse(
					A2(
						$elm$core$List$cons,
						$elm$core$List$reverse(state.V),
						state.aC)));
		} else {
			var x = _v0.a;
			var xs = _v0.b;
			var level = getLevel(x);
			return _Utils_eq(level, state.bm) ? $author$project$Tools$Loop$Loop(
				_Utils_update(
					state,
					{
						aM: level,
						V: _List_fromArray(
							[x]),
						_: xs,
						aC: $elm$core$List$isEmpty(state.V) ? state.aC : A2(
							$elm$core$List$cons,
							$elm$core$List$reverse(state.V),
							state.aC)
					})) : $author$project$Tools$Loop$Loop(
				_Utils_update(
					state,
					{
						aM: level,
						V: A2($elm$core$List$cons, x, state.V),
						_: xs
					}));
		}
	});
var $author$project$Library$Forest$toListList = F2(
	function (getLevel, input) {
		var initialState = A2($author$project$Library$Forest$init, getLevel, input);
		return A2(
			$author$project$Tools$Loop$loop,
			initialState,
			$author$project$Library$Forest$nextStep(getLevel));
	});
var $author$project$Library$Forest$makeForest = F2(
	function (getLevel, input) {
		return A2(
			$elm$core$List$filterMap,
			$author$project$Library$Tree$makeTree(getLevel),
			A2($author$project$Library$Forest$toListList, getLevel, input));
	});
var $author$project$Generic$ForestTransform$forestFromBlocks = F2(
	function (indentation, blocks) {
		return A2($author$project$Library$Forest$makeForest, indentation, blocks);
	});
var $author$project$Generic$Acc$initialData = {h: 0, bv: '', F: 0, bn: $elm$core$Maybe$Nothing, cx: '', aE: 4};
var $elm$core$Elm$JsArray$map = _JsArray_map;
var $elm$core$Array$map = F2(
	function (func, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = function (node) {
			if (!node.$) {
				var subTree = node.a;
				return $elm$core$Array$SubTree(
					A2($elm$core$Elm$JsArray$map, helper, subTree));
			} else {
				var values = node.a;
				return $elm$core$Array$Leaf(
					A2($elm$core$Elm$JsArray$map, func, values));
			}
		};
		return A4(
			$elm$core$Array$Array_elm_builtin,
			len,
			startShift,
			A2($elm$core$Elm$JsArray$map, helper, tree),
			A2($elm$core$Elm$JsArray$map, func, tail));
	});
var $maca$elm_rose_tree$RoseTree$Tree$mapValues = F2(
	function (f, _v0) {
		var a = _v0.a;
		var ns = _v0.b;
		return A2(
			$maca$elm_rose_tree$RoseTree$Tree$Tree,
			f(a),
			A2(
				$elm$core$Array$map,
				$maca$elm_rose_tree$RoseTree$Tree$mapValues(f),
				ns));
	});
var $author$project$Parser$Forest$mapForest = F2(
	function (f, forest) {
		return A2(
			$elm$core$List$map,
			$maca$elm_rose_tree$RoseTree$Tree$mapValues(f),
			forest);
	});
var $author$project$Parser$PrimitiveBlock$init = function (lines) {
	return {T: _List_Nil, af: 0, q: $elm$core$Maybe$Nothing, aQ: false, ax: false, bh: false, bu: 0, I: 0, E: lines, cg: 0};
};
var $author$project$V3$Types$Ordinary = function (a) {
	return {$: 1, a: a};
};
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $author$project$Parser$PrimitiveBlock$addLineToBlock = F2(
	function (line, block) {
		var meta = block.A;
		var contentToAdd = ((block.bu > 0) && (_Utils_cmp(line.bu, block.bu) > -1)) ? A2($elm$core$String$dropLeft, block.bu, line.aL) : line.aL;
		return _Utils_update(
			block,
			{
				bO: A2($elm$core$List$cons, contentToAdd, block.bO),
				A: _Utils_update(
					meta,
					{X: meta.X + 1})
			});
	});
var $author$project$Parser$PrimitiveBlock$addListLineToBlock = F2(
	function (line, block) {
		var meta = block.A;
		var contentToAdd = line.aL;
		return _Utils_update(
			block,
			{
				bO: A2($elm$core$List$cons, contentToAdd, block.bO),
				A: _Utils_update(
					meta,
					{X: meta.X + 1})
			});
	});
var $elm$core$String$trim = _String_trim;
var $author$project$Parser$PrimitiveBlock$appendToLastListItem = F2(
	function (line, block) {
		var meta = block.A;
		var contentToAdd = $elm$core$String$trim(line.aL);
		var updatedBody = function () {
			var _v0 = block.bO;
			if (_v0.b) {
				var lastItem = _v0.a;
				var rest = _v0.b;
				return A2($elm$core$List$cons, lastItem + (' ' + contentToAdd), rest);
			} else {
				return _List_fromArray(
					[contentToAdd]);
			}
		}();
		return _Utils_update(
			block,
			{
				bO: updatedBody,
				A: _Utils_update(
					meta,
					{X: meta.X + 1})
			});
	});
var $elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $author$project$Parser$PrimitiveBlock$inspectHeading = function (content) {
	var trimmed = $elm$core$String$trim(content);
	return A2($elm$core$String$startsWith, '- ', trimmed) ? $elm$core$Maybe$Just(
		$author$project$V3$Types$Ordinary('item')) : (A2($elm$core$String$startsWith, '. ', trimmed) ? $elm$core$Maybe$Just(
		$author$project$V3$Types$Ordinary('numbered')) : $elm$core$Maybe$Nothing);
};
var $elm$core$String$contains = _String_contains;
var $elm$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			if (!list.b) {
				return false;
			} else {
				var x = list.a;
				var xs = list.b;
				if (isOkay(x)) {
					return true;
				} else {
					var $temp$isOkay = isOkay,
						$temp$list = xs;
					isOkay = $temp$isOkay;
					list = $temp$list;
					continue any;
				}
			}
		}
	});
var $elm$core$List$member = F2(
	function (x, xs) {
		return A2(
			$elm$core$List$any,
			function (a) {
				return _Utils_eq(a, x);
			},
			xs);
	});
var $author$project$Parser$PrimitiveBlock$ordinaryNames = _List_fromArray(
	['section', 'theorem', 'definition', 'lemma', 'corollary', 'proposition', 'proof', 'remark', 'example', 'exercise', 'note', 'problem', 'solution', 'question', 'answer', 'abstract', 'title', 'subtitle', 'author', 'date', 'contents', 'index', 'bibliography', 'quotation', 'item', 'numbered', 'heading', 'subheading', 'document', 'endnotes', 'set-key']);
var $author$project$Parser$PrimitiveBlock$verbatimNames = _List_fromArray(
	['math', 'chem', 'compute', 'equation', 'aligned', 'array', 'textarray', 'table', 'code', 'verse', 'verbatim', 'load', 'load-data', 'load-files', 'include', 'hide', 'texComment', 'docinfo', 'mathmacros', 'textmacros', 'csvtable', 'chart', 'svg', 'quiver', 'image', 'tikz', 'setup', 'iframe', 'settings', 'book', 'article']);
var $author$project$Parser$PrimitiveBlock$isKnownBlockName = function (name) {
	return A2($elm$core$List$member, name, $author$project$Parser$PrimitiveBlock$verbatimNames) || A2($elm$core$List$member, name, $author$project$Parser$PrimitiveBlock$ordinaryNames);
};
var $elm$core$Basics$not = _Basics_not;
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $elm$core$String$words = _String_words;
var $author$project$Parser$PrimitiveBlock$isContinuationLine = function (line) {
	var trimmed = $elm$core$String$trim(line);
	if (A2($elm$core$String$startsWith, '| ', trimmed)) {
		var afterPrefix = A2($elm$core$String$dropLeft, 2, trimmed);
		var firstWord = A2(
			$elm$core$Maybe$withDefault,
			'',
			$elm$core$List$head(
				$elm$core$String$words(afterPrefix)));
		return A2($elm$core$String$contains, ':', firstWord) || (!$author$project$Parser$PrimitiveBlock$isKnownBlockName(firstWord));
	} else {
		return false;
	}
};
var $elm_community$list_extra$List$Extra$findIndexHelp = F3(
	function (index, predicate, list) {
		findIndexHelp:
		while (true) {
			if (!list.b) {
				return $elm$core$Maybe$Nothing;
			} else {
				var x = list.a;
				var xs = list.b;
				if (predicate(x)) {
					return $elm$core$Maybe$Just(index);
				} else {
					var $temp$index = index + 1,
						$temp$predicate = predicate,
						$temp$list = xs;
					index = $temp$index;
					predicate = $temp$predicate;
					list = $temp$list;
					continue findIndexHelp;
				}
			}
		}
	});
var $elm_community$list_extra$List$Extra$findIndex = $elm_community$list_extra$List$Extra$findIndexHelp(0);
var $author$project$Tools$KV$cleanArgs = function (strs) {
	var _v0 = A2(
		$elm_community$list_extra$List$Extra$findIndex,
		function (t) {
			return A2($elm$core$String$contains, ':', t);
		},
		strs);
	if (_v0.$ === 1) {
		return strs;
	} else {
		var k = _v0.a;
		return A2($elm$core$List$take, k, strs);
	}
};
var $author$project$Tools$KV$KVInKey = 0;
var $author$project$Tools$KV$KVInValue = 1;
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $elm$core$String$dropRight = F2(
	function (n, string) {
		return (n < 1) ? string : A3($elm$core$String$slice, 0, -n, string);
	});
var $elm_community$list_extra$List$Extra$uncons = function (list) {
	if (!list.b) {
		return $elm$core$Maybe$Nothing;
	} else {
		var first = list.a;
		var rest = list.b;
		return $elm$core$Maybe$Just(
			_Utils_Tuple2(first, rest));
	}
};
var $author$project$Tools$KV$nextKVStep = function (state) {
	var _v0 = $elm_community$list_extra$List$Extra$uncons(state._);
	if (_v0.$ === 1) {
		var kvList_ = function () {
			var _v2 = state.U;
			if (_v2.$ === 1) {
				return state.aa;
			} else {
				var key = _v2.a;
				return A2(
					$elm$core$List$map,
					function (_v3) {
						var k = _v3.a;
						var v = _v3.b;
						return _Utils_Tuple2(
							k,
							$elm$core$List$reverse(v));
					},
					A2(
						$elm$core$List$cons,
						_Utils_Tuple2(key, state.O),
						state.aa));
			}
		}();
		return $author$project$Tools$Loop$Done(
			$elm$core$Dict$fromList(
				A2(
					$elm$core$List$map,
					function (_v1) {
						var k = _v1.a;
						var v = _v1.b;
						return _Utils_Tuple2(
							k,
							A2($elm$core$String$join, ' ', v));
					},
					kvList_)));
	} else {
		var _v4 = _v0.a;
		var item = _v4.a;
		var rest = _v4.b;
		var _v5 = state.ai;
		if (!_v5) {
			if (A2($elm$core$String$contains, ':', item)) {
				var _v6 = state.U;
				if (_v6.$ === 1) {
					return $author$project$Tools$Loop$Loop(
						_Utils_update(
							state,
							{
								U: $elm$core$Maybe$Just(
									A2($elm$core$String$dropRight, 1, item)),
								_: rest,
								ai: 1
							}));
				} else {
					var key = _v6.a;
					return $author$project$Tools$Loop$Loop(
						{
							U: $elm$core$Maybe$Just(
								A2($elm$core$String$dropRight, 1, item)),
							O: _List_Nil,
							_: rest,
							aa: A2(
								$elm$core$List$cons,
								_Utils_Tuple2(key, state.O),
								state.aa),
							ai: 1
						});
				}
			} else {
				return $author$project$Tools$Loop$Loop(
					_Utils_update(
						state,
						{_: rest}));
			}
		} else {
			if (A2($elm$core$String$contains, ':', item)) {
				var _v7 = state.U;
				if (_v7.$ === 1) {
					return $author$project$Tools$Loop$Loop(
						_Utils_update(
							state,
							{
								U: $elm$core$Maybe$Just(
									A2($elm$core$String$dropRight, 1, item)),
								O: _List_Nil,
								_: rest,
								ai: 1
							}));
				} else {
					var key = _v7.a;
					return $author$project$Tools$Loop$Loop(
						_Utils_update(
							state,
							{
								U: $elm$core$Maybe$Just(
									A2($elm$core$String$dropRight, 1, item)),
								O: _List_Nil,
								_: rest,
								aa: A2(
									$elm$core$List$cons,
									_Utils_Tuple2(key, state.O),
									state.aa),
								ai: 1
							}));
				}
			} else {
				return $author$project$Tools$Loop$Loop(
					_Utils_update(
						state,
						{
							O: A2($elm$core$List$cons, item, state.O),
							_: rest
						}));
			}
		}
	}
};
var $author$project$Tools$KV$prepareKVData = function (data_) {
	var initialState = {U: $elm$core$Maybe$Nothing, O: _List_Nil, _: data_, aa: _List_Nil, ai: 0};
	return A2($author$project$Tools$Loop$loop, initialState, $author$project$Tools$KV$nextKVStep);
};
var $author$project$Tools$KV$explode = function (txt) {
	return A2(
		$elm$core$List$map,
		$elm$core$String$split(':'),
		txt);
};
var $author$project$Tools$KV$fix = function (strs) {
	if (strs.b) {
		if (strs.b.b) {
			var a = strs.a;
			var _v1 = strs.b;
			var b = _v1.a;
			return _List_fromArray(
				[a + ':', b]);
		} else {
			var a = strs.a;
			return _List_fromArray(
				[a]);
		}
	} else {
		return _List_Nil;
	}
};
var $author$project$Tools$KV$prepareList = function (strs) {
	return A2(
		$elm$core$List$filter,
		function (s) {
			return s !== '';
		},
		A2(
			$elm$core$List$concatMap,
			$author$project$Tools$KV$fix,
			$author$project$Tools$KV$explode(strs)));
};
var $author$project$Tools$KV$argsAndPropertiesFromList = function (words) {
	var args = $author$project$Tools$KV$cleanArgs(words);
	var namedArgs = A2(
		$elm$core$List$drop,
		$elm$core$List$length(args),
		words);
	var properties = $author$project$Tools$KV$prepareKVData(
		$author$project$Tools$KV$prepareList(namedArgs));
	return _Utils_Tuple2(args, properties);
};
var $elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === -2) {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var $elm$core$Dict$union = F2(
	function (t1, t2) {
		return A3($elm$core$Dict$foldl, $elm$core$Dict$insert, t2, t1);
	});
var $author$project$Tools$KV$mergeArgsAndProperties = F2(
	function (_v0, _v1) {
		var args1 = _v0.a;
		var props1 = _v0.b;
		var args2 = _v1.a;
		var props2 = _v1.b;
		return _Utils_Tuple2(
			_Utils_ap(args1, args2),
			A2($elm$core$Dict$union, props2, props1));
	});
var $author$project$Parser$PrimitiveBlock$mergeContinuationLine = F2(
	function (line, block) {
		var trimmed = $elm$core$String$trim(line.aL);
		var meta = block.A;
		var afterPrefix = A2($elm$core$String$dropLeft, 2, trimmed);
		var parts = $elm$core$String$words(afterPrefix);
		var _v0 = $author$project$Tools$KV$argsAndPropertiesFromList(parts);
		var newArgs = _v0.a;
		var newProps = _v0.b;
		var _v1 = A2(
			$author$project$Tools$KV$mergeArgsAndProperties,
			_Utils_Tuple2(block.cF, block.c),
			_Utils_Tuple2(newArgs, newProps));
		var mergedArgs = _v1.a;
		var mergedProps = _v1.b;
		return _Utils_update(
			block,
			{
				cF: mergedArgs,
				A: _Utils_update(
					meta,
					{bp: meta.bp + 1, X: meta.X + 1}),
				c: mergedProps
			});
	});
var $author$project$Parser$PrimitiveBlock$addCurrentLine = F2(
	function (line, state) {
		var newPosition = (state.cg + $elm$core$String$length(line.aL)) + 1;
		var isContinuation = state.ax && $author$project$Parser$PrimitiveBlock$isContinuationLine(line.aL);
		if (isContinuation) {
			return _Utils_update(
				state,
				{
					q: A2(
						$elm$core$Maybe$map,
						$author$project$Parser$PrimitiveBlock$mergeContinuationLine(line),
						state.q),
					I: state.I + 1,
					E: A2($elm$core$List$drop, 1, state.E),
					cg: newPosition
				});
		} else {
			var lineHeading = $author$project$Parser$PrimitiveBlock$inspectHeading(line.aL);
			var currentHeading = A2(
				$elm$core$Maybe$map,
				function ($) {
					return $.P;
				},
				state.q);
			var coalescedBlock = function () {
				var _v0 = _Utils_Tuple2(currentHeading, lineHeading);
				_v0$6:
				while (true) {
					if ((!_v0.a.$) && (_v0.a.a.$ === 1)) {
						if (!_v0.b.$) {
							if (_v0.b.a.$ === 1) {
								switch (_v0.b.a.a) {
									case 'item':
										switch (_v0.a.a.a) {
											case 'item':
												return A2(
													$elm$core$Maybe$map,
													$author$project$Parser$PrimitiveBlock$addListLineToBlock(line),
													A2(
														$elm$core$Maybe$map,
														function (b) {
															return _Utils_update(
																b,
																{
																	P: $author$project$V3$Types$Ordinary('itemList')
																});
														},
														state.q));
											case 'itemList':
												return A2(
													$elm$core$Maybe$map,
													$author$project$Parser$PrimitiveBlock$addListLineToBlock(line),
													state.q);
											default:
												break _v0$6;
										}
									case 'numbered':
										switch (_v0.a.a.a) {
											case 'numbered':
												return A2(
													$elm$core$Maybe$map,
													$author$project$Parser$PrimitiveBlock$addListLineToBlock(line),
													A2(
														$elm$core$Maybe$map,
														function (b) {
															return _Utils_update(
																b,
																{
																	P: $author$project$V3$Types$Ordinary('numberedList')
																});
														},
														state.q));
											case 'numberedList':
												return A2(
													$elm$core$Maybe$map,
													$author$project$Parser$PrimitiveBlock$addListLineToBlock(line),
													state.q);
											default:
												break _v0$6;
										}
									default:
										break _v0$6;
								}
							} else {
								break _v0$6;
							}
						} else {
							switch (_v0.a.a.a) {
								case 'itemList':
									var _v1 = _v0.b;
									return A2(
										$elm$core$Maybe$map,
										$author$project$Parser$PrimitiveBlock$appendToLastListItem(line),
										state.q);
								case 'numberedList':
									var _v2 = _v0.b;
									return A2(
										$elm$core$Maybe$map,
										$author$project$Parser$PrimitiveBlock$appendToLastListItem(line),
										state.q);
								default:
									break _v0$6;
							}
						}
					} else {
						break _v0$6;
					}
				}
				return A2(
					$elm$core$Maybe$map,
					$author$project$Parser$PrimitiveBlock$addLineToBlock(line),
					state.q);
			}();
			return _Utils_update(
				state,
				{
					q: coalescedBlock,
					ax: false,
					I: state.I + 1,
					E: A2($elm$core$List$drop, 1, state.E),
					cg: newPosition
				});
		}
	});
var $author$project$Parser$PrimitiveBlock$advance = F2(
	function (line, state) {
		var newPosition = (state.cg + $elm$core$String$length(line.aL)) + 1;
		return _Utils_update(
			state,
			{
				I: state.I + 1,
				E: A2($elm$core$List$drop, 1, state.E),
				cg: newPosition
			});
	});
var $elm$core$String$foldr = _String_foldr;
var $elm$core$String$toList = function (string) {
	return A3($elm$core$String$foldr, $elm$core$List$cons, _List_Nil, string);
};
var $author$project$Parser$Line$countLeadingSpaces = function (str) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (c, _v0) {
				var count = _v0.a;
				var counting = _v0.b;
				return (counting && (c === ' ')) ? _Utils_Tuple2(count + 1, true) : _Utils_Tuple2(count, false);
			}),
		_Utils_Tuple2(0, true),
		$elm$core$String$toList(str)).a;
};
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $author$project$Parser$Line$classify = F3(
	function (position, lineNumber, str) {
		var leadingSpaces = $author$project$Parser$Line$countLeadingSpaces(str);
		var prefix = A2($elm$core$String$left, leadingSpaces, str);
		var content = str;
		return {aL: content, bu: leadingSpaces, I: lineNumber, cg: position, ch: prefix};
	});
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $author$project$Parser$PrimitiveBlock$finalize = function (block) {
	var reversedBody = $elm$core$List$reverse(block.bO);
	var sourceText = $elm$core$List$isEmpty(reversedBody) ? block.cT : (block.cT + ('\n' + A2($elm$core$String$join, '\n', reversedBody)));
	var meta = block.A;
	var finalBody = function () {
		var _v0 = block.P;
		_v0$2:
		while (true) {
			switch (_v0.$) {
				case 0:
					return $elm$core$String$isEmpty(block.cT) ? reversedBody : A2($elm$core$List$cons, block.cT, reversedBody);
				case 1:
					if (_v0.a === 'section') {
						return $elm$core$String$isEmpty(block.cT) ? reversedBody : A2($elm$core$List$cons, block.cT, reversedBody);
					} else {
						break _v0$2;
					}
				default:
					break _v0$2;
			}
		}
		return reversedBody;
	}();
	return _Utils_update(
		block,
		{
			bO: finalBody,
			A: _Utils_update(
				meta,
				{dg: sourceText})
		});
};
var $author$project$Parser$PrimitiveBlock$setBlockId = F2(
	function (index, block) {
		var meta = block.A;
		var id = $elm$core$String$fromInt(meta.I) + ('-' + $elm$core$String$fromInt(index));
		return _Utils_update(
			block,
			{
				A: _Utils_update(
					meta,
					{e: id})
			});
	});
var $author$project$Parser$PrimitiveBlock$commitBlock = F2(
	function (line, state) {
		var newPosition = (state.cg + $elm$core$String$length(line.aL)) + 1;
		var committedBlocks = function () {
			var _v0 = state.q;
			if (_v0.$ === 1) {
				return state.T;
			} else {
				var block = _v0.a;
				var finalBlock = A2(
					$author$project$Parser$PrimitiveBlock$setBlockId,
					state.af,
					$author$project$Parser$PrimitiveBlock$finalize(block));
				return A2($elm$core$List$cons, finalBlock, state.T);
			}
		}();
		return _Utils_update(
			state,
			{
				T: committedBlocks,
				af: state.af + 1,
				q: $elm$core$Maybe$Nothing,
				aQ: false,
				ax: false,
				bh: false,
				I: state.I + 1,
				E: A2($elm$core$List$drop, 1, state.E),
				cg: newPosition
			});
	});
var $author$project$V3$Types$Paragraph = {$: 0};
var $author$project$V3$Types$Verbatim = function (a) {
	return {$: 2, a: a};
};
var $author$project$Parser$PrimitiveBlock$isVerbatimName = function (str) {
	return A2($elm$core$List$member, str, $author$project$Parser$PrimitiveBlock$verbatimNames);
};
var $elm$core$String$toInt = _String_toInt;
var $author$project$Parser$PrimitiveBlock$getHeading = function (line) {
	var afterPrefix = A2($elm$core$String$dropLeft, 2, line);
	var parts = $elm$core$String$words(afterPrefix);
	var name = A2(
		$elm$core$Maybe$withDefault,
		'block',
		$elm$core$List$head(parts));
	var _v0 = $author$project$Tools$KV$argsAndPropertiesFromList(
		A2($elm$core$List$drop, 1, parts));
	var args = _v0.a;
	var properties_ = _v0.b;
	var properties = function () {
		if (name !== 'section') {
			return properties_;
		} else {
			var _v1 = $elm$core$List$head(args);
			if (_v1.$ === 1) {
				return A3($elm$core$Dict$insert, 'level', '1', properties_);
			} else {
				var str = _v1.a;
				var _v2 = $elm$core$String$toInt(str);
				if (_v2.$ === 1) {
					return A3($elm$core$Dict$insert, 'level', '1', properties_);
				} else {
					return A3($elm$core$Dict$insert, 'level', str, properties_);
				}
			}
		}
	}();
	return {
		cF: args,
		cT: '',
		P: $author$project$Parser$PrimitiveBlock$isVerbatimName(name) ? $author$project$V3$Types$Verbatim(name) : $author$project$V3$Types$Ordinary(name),
		c: properties
	};
};
var $author$project$Parser$PrimitiveBlock$getVerbatimHeading = function (line) {
	var afterPrefix = A2($elm$core$String$dropLeft, 3, line);
	var parts = $elm$core$String$words(afterPrefix);
	var name = A2(
		$elm$core$Maybe$withDefault,
		'code',
		$elm$core$List$head(parts));
	var _v0 = $author$project$Tools$KV$argsAndPropertiesFromList(
		A2($elm$core$List$drop, 1, parts));
	var args = _v0.a;
	var properties = _v0.b;
	return {
		cF: args,
		cT: '',
		P: $author$project$V3$Types$Verbatim(name),
		c: properties
	};
};
var $elm$core$Dict$singleton = F2(
	function (key, value) {
		return A5($elm$core$Dict$RBNode_elm_builtin, 1, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
	});
var $author$project$Parser$PrimitiveBlock$getHeadingData = function (line) {
	var trimmed = $elm$core$String$trim(line);
	return A2($elm$core$String$startsWith, '|| ', trimmed) ? $author$project$Parser$PrimitiveBlock$getVerbatimHeading(trimmed) : (A2($elm$core$String$startsWith, '| ', trimmed) ? $author$project$Parser$PrimitiveBlock$getHeading(trimmed) : (A2($elm$core$String$startsWith, '```', trimmed) ? {
		cF: _List_Nil,
		cT: '',
		P: $author$project$V3$Types$Verbatim('code'),
		c: $elm$core$Dict$empty
	} : (A2($elm$core$String$startsWith, '$$', trimmed) ? {
		cF: _List_Nil,
		cT: '',
		P: $author$project$V3$Types$Verbatim('math'),
		c: $elm$core$Dict$empty
	} : (A2($elm$core$String$startsWith, '# ', trimmed) ? {
		cF: _List_fromArray(
			['1']),
		cT: A2($elm$core$String$dropLeft, 2, trimmed),
		P: $author$project$V3$Types$Ordinary('section'),
		c: A2($elm$core$Dict$singleton, 'level', '1')
	} : (A2($elm$core$String$startsWith, '## ', trimmed) ? {
		cF: _List_fromArray(
			['2']),
		cT: A2($elm$core$String$dropLeft, 3, trimmed),
		P: $author$project$V3$Types$Ordinary('section'),
		c: A2($elm$core$Dict$singleton, 'level', '2')
	} : (A2($elm$core$String$startsWith, '### ', trimmed) ? {
		cF: _List_fromArray(
			['3']),
		cT: A2($elm$core$String$dropLeft, 4, trimmed),
		P: $author$project$V3$Types$Ordinary('section'),
		c: A2($elm$core$Dict$singleton, 'level', '3')
	} : (A2($elm$core$String$startsWith, '- ', trimmed) ? {
		cF: _List_Nil,
		cT: trimmed,
		P: $author$project$V3$Types$Ordinary('item'),
		c: $elm$core$Dict$empty
	} : (A2($elm$core$String$startsWith, '. ', trimmed) ? {
		cF: _List_Nil,
		cT: trimmed,
		P: $author$project$V3$Types$Ordinary('numbered'),
		c: $elm$core$Dict$empty
	} : {cF: _List_Nil, cT: line, P: $author$project$V3$Types$Paragraph, c: $elm$core$Dict$empty}))))))));
};
var $author$project$Parser$PrimitiveBlock$blockFromLine = F2(
	function (line, state) {
		var headingData = $author$project$Parser$PrimitiveBlock$getHeadingData(line.aL);
		var bodyLineNumber = function () {
			var _v0 = headingData.P;
			if (!_v0.$) {
				return line.I;
			} else {
				return line.I + 1;
			}
		}();
		var meta = {bp: bodyLineNumber, cR: $elm$core$Maybe$Nothing, e: '', I: line.I, r: _List_Nil, X: 1, cg: line.cg, dg: line.aL};
		return {
			cF: headingData.cF,
			bO: _List_Nil,
			cT: headingData.cT,
			P: headingData.P,
			bu: line.bu,
			A: meta,
			c: headingData.c,
			cu: {}
		};
	});
var $author$project$Parser$PrimitiveBlock$isBlockWithHeader = function (block) {
	var _v0 = block.P;
	if (!_v0.$) {
		return false;
	} else {
		return true;
	}
};
var $author$project$Parser$PrimitiveBlock$isVerbatimLine = function (line) {
	var trimmed = $elm$core$String$trim(line);
	return A2($elm$core$String$startsWith, '|| ', trimmed) || (A2($elm$core$String$startsWith, '```', trimmed) || A2($elm$core$String$startsWith, '$$', trimmed));
};
var $author$project$Parser$PrimitiveBlock$createBlock = F2(
	function (line, state) {
		var newState = function () {
			var _v0 = state.q;
			if (_v0.$ === 1) {
				return state;
			} else {
				var block = _v0.a;
				return _Utils_update(
					state,
					{
						T: A2(
							$elm$core$List$cons,
							$author$project$Parser$PrimitiveBlock$finalize(block),
							state.T),
						af: state.af + 1
					});
			}
		}();
		var newPosition = (state.cg + $elm$core$String$length(line.aL)) + 1;
		var newBlock = A2($author$project$Parser$PrimitiveBlock$blockFromLine, line, newState);
		return _Utils_update(
			newState,
			{
				q: $elm$core$Maybe$Just(newBlock),
				aQ: true,
				ax: $author$project$Parser$PrimitiveBlock$isBlockWithHeader(newBlock),
				bh: $author$project$Parser$PrimitiveBlock$isVerbatimLine(line.aL),
				bu: line.bu,
				I: state.I + 1,
				E: A2($elm$core$List$drop, 1, state.E),
				cg: newPosition
			});
	});
var $author$project$Parser$PrimitiveBlock$nextStep = function (state) {
	var _v0 = $elm$core$List$head(state.E);
	if (_v0.$ === 1) {
		var _v1 = state.q;
		if (_v1.$ === 1) {
			return $author$project$Tools$Loop$Done(
				$elm$core$List$reverse(state.T));
		} else {
			var block = _v1.a;
			var finalBlock = $author$project$Parser$PrimitiveBlock$finalize(block);
			return $author$project$Tools$Loop$Done(
				$elm$core$List$reverse(
					A2($elm$core$List$cons, finalBlock, state.T)));
		}
	} else {
		var rawLine = _v0.a;
		var currentLine = A3($author$project$Parser$Line$classify, state.cg, state.I, rawLine);
		var isEmpty = (!currentLine.bu) && $elm$core$String$isEmpty(
			$elm$core$String$trim(currentLine.aL));
		var isNonEmptyBlank = (currentLine.bu > 0) && $elm$core$String$isEmpty(
			$elm$core$String$trim(
				A2($elm$core$String$dropLeft, currentLine.bu, currentLine.aL)));
		var _v2 = _Utils_Tuple3(state.aQ, isEmpty, isNonEmptyBlank);
		if (!_v2.a) {
			if (_v2.b) {
				return $author$project$Tools$Loop$Loop(
					A2($author$project$Parser$PrimitiveBlock$advance, currentLine, state));
			} else {
				if (_v2.c) {
					return $author$project$Tools$Loop$Loop(
						A2($author$project$Parser$PrimitiveBlock$advance, currentLine, state));
				} else {
					return $author$project$Tools$Loop$Loop(
						A2($author$project$Parser$PrimitiveBlock$createBlock, currentLine, state));
				}
			}
		} else {
			if (!_v2.b) {
				return $author$project$Tools$Loop$Loop(
					A2($author$project$Parser$PrimitiveBlock$addCurrentLine, currentLine, state));
			} else {
				return $author$project$Tools$Loop$Loop(
					A2($author$project$Parser$PrimitiveBlock$commitBlock, currentLine, state));
			}
		}
	}
};
var $author$project$Parser$PrimitiveBlock$parse = function (lines) {
	return A2(
		$author$project$Tools$Loop$loop,
		$author$project$Parser$PrimitiveBlock$init(lines),
		$author$project$Parser$PrimitiveBlock$nextStep);
};
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === -2) {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1) {
					case 0:
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 1:
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $author$project$V3$Types$ExprList = F3(
	function (a, b, c) {
		return {$: 3, a: a, b: b, c: c};
	});
var $toastal$either$Either$Left = function (a) {
	return {$: 0, a: a};
};
var $toastal$either$Either$Right = function (a) {
	return {$: 1, a: a};
};
var $author$project$Parser$Pipeline$emptyExprMeta = {aq: 0, au: 0, e: 'list', b1: 0};
var $author$project$V3$Types$Fun = F3(
	function (a, b, c) {
		return {$: 1, a: a, b: b, c: c};
	});
var $author$project$V3$Types$Text = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $author$project$Parser$Expression$fixup = function (input) {
	if (input.b) {
		if (input.a.$ === 1) {
			var _v1 = input.a;
			var name = _v1.a;
			var exprList = _v1.b;
			var meta = _v1.c;
			var rest = input.b;
			var newExprlist = function () {
				if (exprList.b && (!exprList.a.$)) {
					var _v3 = exprList.a;
					var str = _v3.a;
					var meta_ = _v3.b;
					var tail = exprList.b;
					return A2(
						$elm$core$List$cons,
						A2(
							$author$project$V3$Types$Text,
							$elm$core$String$trim(str),
							meta_),
						tail);
				} else {
					return exprList;
				}
			}();
			return A2(
				$elm$core$List$cons,
				A3($author$project$V3$Types$Fun, name, newExprlist, meta),
				$author$project$Parser$Expression$fixup(rest));
		} else {
			var other = input.a;
			var rest = input.b;
			return A2(
				$elm$core$List$cons,
				other,
				$author$project$Parser$Expression$fixup(rest));
		}
	} else {
		return _List_Nil;
	}
};
var $author$project$Parser$Expression$initWithTokens = F2(
	function (lineNumber, tokens) {
		return {
			j: _List_Nil,
			I: lineNumber,
			r: _List_Nil,
			aV: $elm$core$List$length(tokens),
			n: _List_Nil,
			bo: 0,
			J: 0,
			bK: $elm$core$List$reverse(tokens)
		};
	});
var $author$project$Parser$Expression$advanceTokenIndex = function (state) {
	return _Utils_update(
		state,
		{J: state.J + 1});
};
var $elm_community$list_extra$List$Extra$getAt = F2(
	function (idx, xs) {
		return (idx < 0) ? $elm$core$Maybe$Nothing : $elm$core$List$head(
			A2($elm$core$List$drop, idx, xs));
	});
var $author$project$Parser$Expression$getToken = function (state) {
	return A2($elm_community$list_extra$List$Extra$getAt, state.J, state.bK);
};
var $author$project$Parser$Expression$pushOnStack_ = F2(
	function (token, state) {
		return _Utils_update(
			state,
			{
				n: A2($elm$core$List$cons, token, state.n)
			});
	});
var $author$project$Parser$Expression$makeId = F2(
	function (lineNumber, tokenIndex) {
		return 'e-' + ($elm$core$String$fromInt(lineNumber) + ('.' + $elm$core$String$fromInt(tokenIndex)));
	});
var $author$project$Parser$Expression$boostMeta = F3(
	function (lineNumber, tokenIndex, _v0) {
		var begin = _v0.aq;
		var end = _v0.au;
		var index = _v0.b1;
		return {
			aq: begin,
			au: end,
			e: A2($author$project$Parser$Expression$makeId, lineNumber, tokenIndex),
			b1: index
		};
	});
var $author$project$Parser$Tokenizer$indexOf = function (token) {
	switch (token.$) {
		case 0:
			var meta = token.a;
			return meta.b1;
		case 1:
			var meta = token.a;
			return meta.b1;
		case 2:
			var meta = token.b;
			return meta.b1;
		case 3:
			var meta = token.b;
			return meta.b1;
		case 4:
			var meta = token.a;
			return meta.b1;
		case 5:
			var meta = token.a;
			return meta.b1;
		default:
			var meta = token.b;
			return meta.b1;
	}
};
var $author$project$Parser$Expression$stringTokenToExpr = F2(
	function (lineNumber, token) {
		switch (token.$) {
			case 2:
				var str = token.a;
				var loc = token.b;
				return $elm$core$Maybe$Just(
					A2(
						$author$project$V3$Types$Text,
						str,
						A3(
							$author$project$Parser$Expression$boostMeta,
							lineNumber,
							$author$project$Parser$Tokenizer$indexOf(token),
							loc)));
			case 3:
				var str = token.a;
				var loc = token.b;
				return $elm$core$Maybe$Just(
					A2(
						$author$project$V3$Types$Text,
						str,
						A3(
							$author$project$Parser$Expression$boostMeta,
							lineNumber,
							$author$project$Parser$Tokenizer$indexOf(token),
							loc)));
			default:
				return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$Parser$Expression$commit = F2(
	function (token, state) {
		var _v0 = A2($author$project$Parser$Expression$stringTokenToExpr, state.I, token);
		if (_v0.$ === 1) {
			return state;
		} else {
			var expr = _v0.a;
			return _Utils_update(
				state,
				{
					j: A2($elm$core$List$cons, expr, state.j)
				});
		}
	});
var $author$project$Parser$Expression$push = F2(
	function (token, state) {
		return _Utils_update(
			state,
			{
				n: A2($elm$core$List$cons, token, state.n)
			});
	});
var $author$project$Parser$Expression$pushOrCommit_ = F2(
	function (token, state) {
		return $elm$core$List$isEmpty(state.n) ? A2($author$project$Parser$Expression$commit, token, state) : A2($author$project$Parser$Expression$push, token, state);
	});
var $author$project$Parser$Expression$pushOrCommit = F2(
	function (token, state) {
		switch (token.$) {
			case 2:
				return A2($author$project$Parser$Expression$pushOrCommit_, token, state);
			case 3:
				return A2($author$project$Parser$Expression$pushOrCommit_, token, state);
			case 4:
				return A2($author$project$Parser$Expression$pushOnStack_, token, state);
			case 5:
				return A2($author$project$Parser$Expression$pushOnStack_, token, state);
			case 0:
				return A2($author$project$Parser$Expression$pushOnStack_, token, state);
			case 1:
				return A2($author$project$Parser$Expression$pushOnStack_, token, state);
			default:
				return A2($author$project$Parser$Expression$pushOnStack_, token, state);
		}
	});
var $author$project$Parser$Expression$dummyTokenIndex = 0;
var $author$project$Parser$Expression$dummyLocWithId = {aq: 0, au: 0, e: 'dummy', b1: $author$project$Parser$Expression$dummyTokenIndex};
var $author$project$Parser$Expression$errorMessage = function (message) {
	return A3(
		$author$project$V3$Types$Fun,
		'errorHighlight',
		_List_fromArray(
			[
				A2($author$project$V3$Types$Text, message, $author$project$Parser$Expression$dummyLocWithId)
			]),
		$author$project$Parser$Expression$dummyLocWithId);
};
var $author$project$Parser$Expression$prependMessage = F3(
	function (lineNumber, message, messages) {
		return A2(
			$elm$core$List$cons,
			message + (' (line ' + ($elm$core$String$fromInt(lineNumber) + ')')),
			A2($elm$core$List$take, 2, messages));
	});
var $author$project$Parser$Expression$recoverFromError = function (state) {
	var _v0 = $elm$core$List$reverse(state.n);
	_v0$7:
	while (true) {
		if (_v0.b) {
			switch (_v0.a.$) {
				case 0:
					if (_v0.b.b) {
						switch (_v0.b.a.$) {
							case 1:
								var _v1 = _v0.b;
								var meta = _v1.a.a;
								return $author$project$Tools$Loop$Loop(
									_Utils_update(
										state,
										{
											j: A2(
												$elm$core$List$cons,
												$author$project$Parser$Expression$errorMessage('[?]'),
												state.j),
											r: A3($author$project$Parser$Expression$prependMessage, state.I, 'Brackets must enclose something', state.r),
											n: _List_Nil,
											J: meta.b1 + 1
										}));
							case 2:
								var _v2 = _v0.b;
								var _v3 = _v2.a;
								var fName = _v3.a;
								var meta = _v3.b;
								return $author$project$Tools$Loop$Loop(
									_Utils_update(
										state,
										{
											j: A2(
												$elm$core$List$cons,
												$author$project$Parser$Expression$errorMessage('[' + (fName + ']?')),
												state.j),
											r: A3($author$project$Parser$Expression$prependMessage, state.I, 'Missing right bracket', state.r),
											n: _List_Nil,
											J: meta.b1 + 1
										}));
							case 3:
								if (_v0.b.a.a === ' ') {
									var _v4 = _v0.b;
									var _v5 = _v4.a;
									var meta = _v5.b;
									return $author$project$Tools$Loop$Loop(
										_Utils_update(
											state,
											{
												j: A2(
													$elm$core$List$cons,
													$author$project$Parser$Expression$errorMessage('[ - can\'t have space after the bracket '),
													state.j),
												r: A3($author$project$Parser$Expression$prependMessage, state.I, 'Can\'t have space after left bracket', state.r),
												n: _List_Nil,
												J: meta.b1 + 1
											}));
								} else {
									break _v0$7;
								}
							default:
								break _v0$7;
						}
					} else {
						return $author$project$Tools$Loop$Done(
							_Utils_update(
								state,
								{
									j: A2(
										$elm$core$List$cons,
										$author$project$Parser$Expression$errorMessage('[...?'),
										state.j),
									r: A3($author$project$Parser$Expression$prependMessage, state.I, 'That left bracket needs something after it', state.r),
									aV: 0,
									n: _List_Nil,
									J: 0
								}));
					}
				case 1:
					var meta = _v0.a.a;
					return $author$project$Tools$Loop$Loop(
						_Utils_update(
							state,
							{
								j: A2(
									$elm$core$List$cons,
									$author$project$Parser$Expression$errorMessage(' extra ]?'),
									state.j),
								r: A3($author$project$Parser$Expression$prependMessage, state.I, 'Extra right bracket(s)', state.r),
								n: _List_Nil,
								J: meta.b1 + 1
							}));
				case 4:
					var meta = _v0.a.a;
					return $author$project$Tools$Loop$Loop(
						_Utils_update(
							state,
							{
								j: A2(
									$elm$core$List$cons,
									$author$project$Parser$Expression$errorMessage('$?$'),
									state.j),
								r: A3($author$project$Parser$Expression$prependMessage, state.I, 'opening dollar sign needs to be matched', state.r),
								aV: 0,
								n: _List_Nil,
								J: meta.b1 + 1
							}));
				case 5:
					var meta = _v0.a.a;
					return $author$project$Tools$Loop$Loop(
						_Utils_update(
							state,
							{
								j: A2(
									$elm$core$List$cons,
									$author$project$Parser$Expression$errorMessage('`?`'),
									state.j),
								r: A3($author$project$Parser$Expression$prependMessage, state.I, 'opening backtick needs to be matched', state.r),
								aV: 0,
								n: _List_Nil,
								J: meta.b1 + 1
							}));
				default:
					break _v0$7;
			}
		} else {
			break _v0$7;
		}
	}
	return $author$project$Tools$Loop$Done(
		_Utils_update(
			state,
			{
				j: A2(
					$elm$core$List$cons,
					$author$project$Parser$Expression$errorMessage(' ?!? '),
					state.j),
				r: A3($author$project$Parser$Expression$prependMessage, state.I, 'Unknown error', state.r)
			}));
};
var $author$project$Parser$Tokenizer$S = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var $author$project$V3$Types$VFun = F3(
	function (a, b, c) {
		return {$: 2, a: a, b: b, c: c};
	});
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $author$project$Parser$Tokenizer$TLB = 0;
var $author$project$Parser$Tokenizer$TRB = 1;
var $author$project$Parser$Tokenizer$TCode = 5;
var $author$project$Parser$Tokenizer$TMath = 4;
var $author$project$Parser$Tokenizer$TS = 2;
var $author$project$Parser$Tokenizer$TTokenError = 6;
var $author$project$Parser$Tokenizer$TW = 3;
var $author$project$Parser$Tokenizer$type_ = function (token) {
	switch (token.$) {
		case 0:
			return 0;
		case 1:
			return 1;
		case 2:
			return 2;
		case 3:
			return 3;
		case 4:
			return 4;
		case 5:
			return 5;
		default:
			return 6;
	}
};
var $author$project$Parser$Expression$isExpr = function (tokens) {
	return _Utils_eq(
		A2(
			$elm$core$List$map,
			$author$project$Parser$Tokenizer$type_,
			A2($elm$core$List$take, 1, tokens)),
		_List_fromArray(
			[0])) && _Utils_eq(
		A2(
			$elm$core$List$map,
			$author$project$Parser$Tokenizer$type_,
			A2(
				$elm$core$List$take,
				1,
				$elm$core$List$reverse(tokens))),
		_List_fromArray(
			[1]));
};
var $author$project$Parser$Expression$isMathToken = function (token) {
	if (token.$ === 4) {
		return true;
	} else {
		return false;
	}
};
var $author$project$Parser$Symbol$C = 4;
var $author$project$Parser$Symbol$M = 3;
var $author$project$Parser$Match$takeWhile = F2(
	function (predicate, list) {
		if (!list.b) {
			return _List_Nil;
		} else {
			var x = list.a;
			var xs = list.b;
			return predicate(x) ? A2(
				$elm$core$List$cons,
				x,
				A2($author$project$Parser$Match$takeWhile, predicate, xs)) : _List_Nil;
		}
	});
var $author$project$Parser$Match$getSegment = F2(
	function (sym, symbols) {
		var seg_ = A2(
			$author$project$Parser$Match$takeWhile,
			function (sym_) {
				return !_Utils_eq(sym_, sym);
			},
			A2($elm$core$List$drop, 1, symbols));
		var n = $elm$core$List$length(seg_);
		var _v0 = A2($elm_community$list_extra$List$Extra$getAt, n + 1, symbols);
		if (_v0.$ === 1) {
			return A2($elm$core$List$cons, sym, seg_);
		} else {
			var last = _v0.a;
			return A2(
				$elm$core$List$cons,
				sym,
				_Utils_ap(
					seg_,
					_List_fromArray(
						[last])));
		}
	});
var $author$project$Parser$Symbol$value = function (symbol) {
	switch (symbol) {
		case 0:
			return 1;
		case 1:
			return -1;
		case 2:
			return 0;
		case 5:
			return 0;
		case 3:
			return 0;
		case 4:
			return 0;
		default:
			return 0;
	}
};
var $author$project$Parser$Match$nextStep = function (state) {
	var _v0 = $elm$core$List$head(state.a2);
	if (_v0.$ === 1) {
		return $author$project$Tools$Loop$Done($elm$core$Maybe$Nothing);
	} else {
		var sym = _v0.a;
		var brackets = state.bb + $author$project$Parser$Symbol$value(sym);
		return (brackets < 0) ? $author$project$Tools$Loop$Done($elm$core$Maybe$Nothing) : ((!brackets) ? $author$project$Tools$Loop$Done(
			$elm$core$Maybe$Just(state.b1)) : $author$project$Tools$Loop$Loop(
			{
				bb: brackets,
				b1: state.b1 + 1,
				a2: A2($elm$core$List$drop, 1, state.a2)
			}));
	}
};
var $author$project$Parser$Match$match = function (symbols) {
	var _v0 = $elm$core$List$head(symbols);
	if (_v0.$ === 1) {
		return $elm$core$Maybe$Nothing;
	} else {
		var symbol = _v0.a;
		return A2(
			$elm$core$List$member,
			symbol,
			_List_fromArray(
				[4, 3])) ? $elm$core$Maybe$Just(
			$elm$core$List$length(
				A2($author$project$Parser$Match$getSegment, symbol, symbols)) - 1) : (($author$project$Parser$Symbol$value(symbol) < 0) ? $elm$core$Maybe$Nothing : A2(
			$author$project$Tools$Loop$loop,
			{
				bb: $author$project$Parser$Symbol$value(symbol),
				b1: 1,
				a2: A2($elm$core$List$drop, 1, symbols)
			},
			$author$project$Parser$Match$nextStep));
	}
};
var $author$project$Parser$Match$splitAt = F2(
	function (k, list) {
		return _Utils_Tuple2(
			A2($elm$core$List$take, k, list),
			A2($elm$core$List$drop, k, list));
	});
var $author$project$Parser$Symbol$E = 6;
var $author$project$Parser$Symbol$L = 0;
var $author$project$Parser$Symbol$R = 1;
var $author$project$Parser$Symbol$ST = 2;
var $author$project$Parser$Symbol$WS = 5;
var $author$project$Parser$Symbol$toSymbol = function (token) {
	switch (token.$) {
		case 0:
			return 0;
		case 1:
			return 1;
		case 2:
			return 2;
		case 3:
			return 5;
		case 4:
			return 3;
		case 5:
			return 4;
		default:
			return 6;
	}
};
var $author$project$Parser$Symbol$toSymbols = function (tokens) {
	return A2($elm$core$List$map, $author$project$Parser$Symbol$toSymbol, tokens);
};
var $author$project$Parser$Expression$splitTokens = function (tokens) {
	var _v0 = $author$project$Parser$Match$match(
		$author$project$Parser$Symbol$toSymbols(tokens));
	if (_v0.$ === 1) {
		return $elm$core$Maybe$Nothing;
	} else {
		var k = _v0.a;
		return $elm$core$Maybe$Just(
			A2($author$project$Parser$Match$splitAt, k + 1, tokens));
	}
};
var $author$project$Parser$Expression$segLength = function (tokens) {
	return $elm$core$List$length(
		A2(
			$author$project$Parser$Match$getSegment,
			3,
			$author$project$Parser$Symbol$toSymbols(tokens)));
};
var $author$project$Parser$Expression$splitTokensWithSegment = function (tokens) {
	return A2(
		$author$project$Parser$Match$splitAt,
		$author$project$Parser$Expression$segLength(tokens) + 1,
		tokens);
};
var $elm_community$list_extra$List$Extra$takeWhile = function (predicate) {
	var takeWhileMemo = F2(
		function (memo, list) {
			takeWhileMemo:
			while (true) {
				if (!list.b) {
					return $elm$core$List$reverse(memo);
				} else {
					var x = list.a;
					var xs = list.b;
					if (predicate(x)) {
						var $temp$memo = A2($elm$core$List$cons, x, memo),
							$temp$list = xs;
						memo = $temp$memo;
						list = $temp$list;
						continue takeWhileMemo;
					} else {
						return $elm$core$List$reverse(memo);
					}
				}
			}
		});
	return takeWhileMemo(_List_Nil);
};
var $author$project$Parser$Expression$tokenToString = function (token) {
	switch (token.$) {
		case 2:
			var str = token.a;
			return $elm$core$Maybe$Just(str);
		case 3:
			var str = token.a;
			return $elm$core$Maybe$Just(str);
		case 0:
			return $elm$core$Maybe$Just('[');
		case 1:
			return $elm$core$Maybe$Just(']');
		default:
			return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Parser$Expression$unbracket = function (list) {
	return A2(
		$elm$core$List$drop,
		1,
		A2(
			$elm$core$List$take,
			$elm$core$List$length(list) - 1,
			list));
};
var $author$project$Parser$Expression$verbatimFunctionNames = _List_fromArray(
	['m', 'math', 'chem', 'code']);
var $author$project$Parser$Expression$reduceRestOfTokens = F2(
	function (lineNumber, tokens) {
		if (tokens.b) {
			switch (tokens.a.$) {
				case 0:
					var _v10 = $author$project$Parser$Expression$splitTokens(tokens);
					if (_v10.$ === 1) {
						return _List_fromArray(
							[
								A2($author$project$V3$Types$Text, 'error on match', $author$project$Parser$Expression$dummyLocWithId)
							]);
					} else {
						var _v11 = _v10.a;
						var a = _v11.a;
						var b = _v11.b;
						return _Utils_ap(
							A2($author$project$Parser$Expression$reduceTokens, lineNumber, a),
							A2($author$project$Parser$Expression$reduceRestOfTokens, lineNumber, b));
					}
				case 4:
					var _v12 = $author$project$Parser$Expression$splitTokensWithSegment(tokens);
					var a = _v12.a;
					var b = _v12.b;
					return _Utils_ap(
						A2($author$project$Parser$Expression$reduceTokens, lineNumber, a),
						A2($author$project$Parser$Expression$reduceRestOfTokens, lineNumber, b));
				case 5:
					var _v13 = $author$project$Parser$Expression$splitTokensWithSegment(tokens);
					var a = _v13.a;
					var b = _v13.b;
					return _Utils_ap(
						A2($author$project$Parser$Expression$reduceTokens, lineNumber, a),
						A2($author$project$Parser$Expression$reduceRestOfTokens, lineNumber, b));
				case 2:
					var _v14 = tokens.a;
					var str = _v14.a;
					var meta = _v14.b;
					return A2(
						$elm$core$List$cons,
						A2(
							$author$project$V3$Types$Text,
							str,
							A3(
								$author$project$Parser$Expression$boostMeta,
								lineNumber,
								$author$project$Parser$Tokenizer$indexOf(
									A2($author$project$Parser$Tokenizer$S, str, meta)),
								meta)),
						A2(
							$author$project$Parser$Expression$reduceRestOfTokens,
							lineNumber,
							A2($elm$core$List$drop, 1, tokens)));
				default:
					var token = tokens.a;
					var _v15 = A2($author$project$Parser$Expression$stringTokenToExpr, lineNumber, token);
					if (!_v15.$) {
						var expr = _v15.a;
						return A2(
							$elm$core$List$cons,
							expr,
							A2(
								$author$project$Parser$Expression$reduceRestOfTokens,
								lineNumber,
								A2($elm$core$List$drop, 1, tokens)));
					} else {
						return _List_fromArray(
							[
								A2($author$project$V3$Types$Text, 'error converting Token', $author$project$Parser$Expression$dummyLocWithId)
							]);
					}
			}
		} else {
			return _List_Nil;
		}
	});
var $author$project$Parser$Expression$reduceTokens = F2(
	function (lineNumber, tokens) {
		if ($author$project$Parser$Expression$isExpr(tokens)) {
			var args = $author$project$Parser$Expression$unbracket(tokens);
			if (args.b && (args.a.$ === 2)) {
				var _v1 = args.a;
				var name = _v1.a;
				var meta = _v1.b;
				var rest = args.b;
				if (A2($elm$core$List$member, name, $author$project$Parser$Expression$verbatimFunctionNames)) {
					var content = $elm$core$String$trim(
						A2(
							$elm$core$String$join,
							'',
							A2($elm$core$List$filterMap, $author$project$Parser$Expression$tokenToString, rest)));
					return _List_fromArray(
						[
							A3(
							$author$project$V3$Types$VFun,
							name,
							content,
							A3($author$project$Parser$Expression$boostMeta, lineNumber, meta.b1, meta))
						]);
				} else {
					return _List_fromArray(
						[
							A3(
							$author$project$V3$Types$Fun,
							name,
							A2(
								$author$project$Parser$Expression$reduceRestOfTokens,
								lineNumber,
								A2($elm$core$List$drop, 1, args)),
							A3($author$project$Parser$Expression$boostMeta, lineNumber, meta.b1, meta))
						]);
				}
			} else {
				return _List_fromArray(
					[
						$author$project$Parser$Expression$errorMessage('[????]')
					]);
			}
		} else {
			_v2$3:
			while (true) {
				if (tokens.b) {
					switch (tokens.a.$) {
						case 4:
							if (((tokens.b.b && (tokens.b.a.$ === 2)) && tokens.b.b.b) && (tokens.b.b.a.$ === 4)) {
								var meta = tokens.a.a;
								var _v3 = tokens.b;
								var _v4 = _v3.a;
								var str = _v4.a;
								var _v5 = _v3.b;
								var rest = _v5.b;
								return A2(
									$elm$core$List$cons,
									A3(
										$author$project$V3$Types$VFun,
										'math',
										str,
										A3($author$project$Parser$Expression$boostMeta, lineNumber, meta.b1, meta)),
									A2($author$project$Parser$Expression$reduceRestOfTokens, lineNumber, rest));
							} else {
								var meta = tokens.a.a;
								var rest = tokens.b;
								var inner = A2(
									$elm_community$list_extra$List$Extra$takeWhile,
									A2($elm$core$Basics$composeL, $elm$core$Basics$not, $author$project$Parser$Expression$isMathToken),
									rest);
								var content = A2(
									$elm$core$String$join,
									'',
									A2($elm$core$List$filterMap, $author$project$Parser$Expression$tokenToString, inner));
								var after = A2(
									$elm$core$List$drop,
									$elm$core$List$length(inner) + 1,
									rest);
								return A2(
									$elm$core$List$cons,
									A3(
										$author$project$V3$Types$VFun,
										'math',
										content,
										A3($author$project$Parser$Expression$boostMeta, lineNumber, meta.b1, meta)),
									A2($author$project$Parser$Expression$reduceRestOfTokens, lineNumber, after));
							}
						case 5:
							if (((tokens.b.b && (tokens.b.a.$ === 2)) && tokens.b.b.b) && (tokens.b.b.a.$ === 5)) {
								var meta = tokens.a.a;
								var _v6 = tokens.b;
								var _v7 = _v6.a;
								var str = _v7.a;
								var _v8 = _v6.b;
								var rest = _v8.b;
								return A2(
									$elm$core$List$cons,
									A3(
										$author$project$V3$Types$VFun,
										'code',
										str,
										A3($author$project$Parser$Expression$boostMeta, lineNumber, meta.b1, meta)),
									A2($author$project$Parser$Expression$reduceRestOfTokens, lineNumber, rest));
							} else {
								break _v2$3;
							}
						default:
							break _v2$3;
					}
				} else {
					break _v2$3;
				}
			}
			return _List_fromArray(
				[
					$author$project$Parser$Expression$errorMessage('[????]')
				]);
		}
	});
var $author$project$Parser$Expression$reduceStack = function (state) {
	return A2(
		$author$project$Parser$Expression$reduceTokens,
		state.I,
		$elm$core$List$reverse(state.n));
};
var $author$project$Parser$Match$dropLast = function (list) {
	var n = $elm$core$List$length(list);
	return A2($elm$core$List$take, n - 1, list);
};
var $author$project$Parser$Match$split = function (symbols) {
	var _v0 = $author$project$Parser$Match$match(symbols);
	if (_v0.$ === 1) {
		return $elm$core$Maybe$Nothing;
	} else {
		var k = _v0.a;
		return $elm$core$Maybe$Just(
			A2($author$project$Parser$Match$splitAt, k + 1, symbols));
	}
};
var $author$project$Parser$Match$hasReducibleArgs = function (symbols) {
	hasReducibleArgs:
	while (true) {
		if (!symbols.b) {
			return true;
		} else {
			switch (symbols.a) {
				case 0:
					var _v11 = symbols.a;
					return $author$project$Parser$Match$reducibleAux(symbols);
				case 4:
					var _v12 = symbols.a;
					return $author$project$Parser$Match$reducibleAux(symbols);
				case 3:
					var _v13 = symbols.a;
					var seg = A2($author$project$Parser$Match$getSegment, 3, symbols);
					if ($author$project$Parser$Match$isReducible(seg)) {
						var $temp$symbols = A2(
							$elm$core$List$drop,
							$elm$core$List$length(seg),
							symbols);
						symbols = $temp$symbols;
						continue hasReducibleArgs;
					} else {
						return false;
					}
				case 2:
					var _v14 = symbols.a;
					var rest = symbols.b;
					var $temp$symbols = rest;
					symbols = $temp$symbols;
					continue hasReducibleArgs;
				default:
					return false;
			}
		}
	}
};
var $author$project$Parser$Match$isReducible = function (symbols_) {
	var symbols = A2(
		$elm$core$List$filter,
		function (sym) {
			return sym !== 5;
		},
		symbols_);
	_v2$3:
	while (true) {
		if (symbols.b) {
			switch (symbols.a) {
				case 3:
					var _v3 = symbols.a;
					var rest = symbols.b;
					return _Utils_eq(
						$elm$core$List$head(
							$elm$core$List$reverse(rest)),
						$elm$core$Maybe$Just(3));
				case 4:
					var _v4 = symbols.a;
					var rest = symbols.b;
					return _Utils_eq(
						$elm$core$List$head(
							$elm$core$List$reverse(rest)),
						$elm$core$Maybe$Just(4));
				case 0:
					if (symbols.b.b && (symbols.b.a === 2)) {
						var _v5 = symbols.a;
						var _v6 = symbols.b;
						var _v7 = _v6.a;
						var rest = _v6.b;
						var _v8 = $elm$core$List$head(
							$elm$core$List$reverse(rest));
						if ((!_v8.$) && (_v8.a === 1)) {
							var _v9 = _v8.a;
							return $author$project$Parser$Match$hasReducibleArgs(
								$author$project$Parser$Match$dropLast(rest));
						} else {
							return false;
						}
					} else {
						break _v2$3;
					}
				default:
					break _v2$3;
			}
		} else {
			break _v2$3;
		}
	}
	return false;
};
var $author$project$Parser$Match$reducibleAux = function (symbols) {
	var _v0 = $author$project$Parser$Match$split(symbols);
	if (_v0.$ === 1) {
		return false;
	} else {
		var _v1 = _v0.a;
		var a = _v1.a;
		var b = _v1.b;
		return $author$project$Parser$Match$isReducible(a) && $author$project$Parser$Match$hasReducibleArgs(b);
	}
};
var $author$project$Parser$Expression$tokensAreReducible = function (state) {
	return $author$project$Parser$Match$isReducible(
		$elm$core$List$reverse(
			$author$project$Parser$Symbol$toSymbols(state.n)));
};
var $author$project$Parser$Expression$reduceState = function (state) {
	return $author$project$Parser$Expression$tokensAreReducible(state) ? _Utils_update(
		state,
		{
			j: _Utils_ap(
				$author$project$Parser$Expression$reduceStack(state),
				state.j),
			n: _List_Nil
		}) : state;
};
var $author$project$Parser$Expression$stackIsEmpty = function (state) {
	return $elm$core$List$isEmpty(state.n);
};
var $author$project$Parser$Expression$nextStep = function (state) {
	var _v0 = $author$project$Parser$Expression$getToken(state);
	if (_v0.$ === 1) {
		return $author$project$Parser$Expression$stackIsEmpty(state) ? $author$project$Tools$Loop$Done(state) : $author$project$Parser$Expression$recoverFromError(state);
	} else {
		var token = _v0.a;
		return $author$project$Tools$Loop$Loop(
			function (st) {
				return _Utils_update(
					st,
					{bo: st.bo + 1});
			}(
				$author$project$Parser$Expression$reduceState(
					A2(
						$author$project$Parser$Expression$pushOrCommit,
						token,
						$author$project$Parser$Expression$advanceTokenIndex(state)))));
	}
};
var $author$project$Parser$Expression$run = function (state) {
	return function (state_) {
		return _Utils_update(
			state_,
			{
				j: $elm$core$List$reverse(state_.j)
			});
	}(
		A2($author$project$Tools$Loop$loop, state, $author$project$Parser$Expression$nextStep));
};
var $author$project$Parser$Expression$parseTokenListToState = F2(
	function (lineNumber, tokens) {
		return $author$project$Parser$Expression$run(
			A2($author$project$Parser$Expression$initWithTokens, lineNumber, tokens));
	});
var $author$project$Parser$Tokenizer$Normal = 0;
var $author$project$Parser$Tokenizer$init = function (str) {
	return {
		ag: $elm$core$Maybe$Nothing,
		aU: 0,
		al: 0,
		bE: str,
		bF: $elm$core$String$length(str),
		J: 0,
		bK: _List_Nil
	};
};
var $author$project$Parser$Tokenizer$TokenError = F2(
	function (a, b) {
		return {$: 6, a: a, b: b};
	});
var $elm$parser$Parser$Advanced$bagToList = F2(
	function (bag, list) {
		bagToList:
		while (true) {
			switch (bag.$) {
				case 0:
					return list;
				case 1:
					var bag1 = bag.a;
					var x = bag.b;
					var $temp$bag = bag1,
						$temp$list = A2($elm$core$List$cons, x, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
				default:
					var bag1 = bag.a;
					var bag2 = bag.b;
					var $temp$bag = bag1,
						$temp$list = A2($elm$parser$Parser$Advanced$bagToList, bag2, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
			}
		}
	});
var $elm$parser$Parser$Advanced$run = F2(
	function (_v0, src) {
		var parse = _v0;
		var _v1 = parse(
			{bQ: 1, g: _List_Nil, bu: 1, b: 0, cq: 1, a: src});
		if (!_v1.$) {
			var value = _v1.b;
			return $elm$core$Result$Ok(value);
		} else {
			var bag = _v1.b;
			return $elm$core$Result$Err(
				A2($elm$parser$Parser$Advanced$bagToList, bag, _List_Nil));
		}
	});
var $author$project$Parser$Tokenizer$CodeToken = function (a) {
	return {$: 5, a: a};
};
var $elm$parser$Parser$Advanced$Bad = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$parser$Parser$Advanced$Good = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var $elm$parser$Parser$Advanced$Parser = $elm$core$Basics$identity;
var $elm$parser$Parser$Advanced$map = F2(
	function (func, _v0) {
		var parse = _v0;
		return function (s0) {
			var _v1 = parse(s0);
			if (!_v1.$) {
				var p = _v1.a;
				var a = _v1.b;
				var s1 = _v1.c;
				return A3(
					$elm$parser$Parser$Advanced$Good,
					p,
					func(a),
					s1);
			} else {
				var p = _v1.a;
				var x = _v1.b;
				return A2($elm$parser$Parser$Advanced$Bad, p, x);
			}
		};
	});
var $author$project$Tools$ParserTools$ExpectingPrefix = {$: 0};
var $elm$parser$Parser$Advanced$AddRight = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$parser$Parser$Advanced$DeadEnd = F4(
	function (row, col, problem, contextStack) {
		return {bQ: col, cM: contextStack, ci: problem, cq: row};
	});
var $elm$parser$Parser$Advanced$Empty = {$: 0};
var $elm$parser$Parser$Advanced$fromState = F2(
	function (s, x) {
		return A2(
			$elm$parser$Parser$Advanced$AddRight,
			$elm$parser$Parser$Advanced$Empty,
			A4($elm$parser$Parser$Advanced$DeadEnd, s.cq, s.bQ, x, s.g));
	});
var $elm$parser$Parser$Advanced$isSubChar = _Parser_isSubChar;
var $elm$parser$Parser$Advanced$chompIf = F2(
	function (isGood, expecting) {
		return function (s) {
			var newOffset = A3($elm$parser$Parser$Advanced$isSubChar, isGood, s.b, s.a);
			return _Utils_eq(newOffset, -1) ? A2(
				$elm$parser$Parser$Advanced$Bad,
				false,
				A2($elm$parser$Parser$Advanced$fromState, s, expecting)) : (_Utils_eq(newOffset, -2) ? A3(
				$elm$parser$Parser$Advanced$Good,
				true,
				0,
				{bQ: 1, g: s.g, bu: s.bu, b: s.b + 1, cq: s.cq + 1, a: s.a}) : A3(
				$elm$parser$Parser$Advanced$Good,
				true,
				0,
				{bQ: s.bQ + 1, g: s.g, bu: s.bu, b: newOffset, cq: s.cq, a: s.a}));
		};
	});
var $elm$parser$Parser$Advanced$chompWhileHelp = F5(
	function (isGood, offset, row, col, s0) {
		chompWhileHelp:
		while (true) {
			var newOffset = A3($elm$parser$Parser$Advanced$isSubChar, isGood, offset, s0.a);
			if (_Utils_eq(newOffset, -1)) {
				return A3(
					$elm$parser$Parser$Advanced$Good,
					_Utils_cmp(s0.b, offset) < 0,
					0,
					{bQ: col, g: s0.g, bu: s0.bu, b: offset, cq: row, a: s0.a});
			} else {
				if (_Utils_eq(newOffset, -2)) {
					var $temp$isGood = isGood,
						$temp$offset = offset + 1,
						$temp$row = row + 1,
						$temp$col = 1,
						$temp$s0 = s0;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					s0 = $temp$s0;
					continue chompWhileHelp;
				} else {
					var $temp$isGood = isGood,
						$temp$offset = newOffset,
						$temp$row = row,
						$temp$col = col + 1,
						$temp$s0 = s0;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					s0 = $temp$s0;
					continue chompWhileHelp;
				}
			}
		}
	});
var $elm$parser$Parser$Advanced$chompWhile = function (isGood) {
	return function (s) {
		return A5($elm$parser$Parser$Advanced$chompWhileHelp, isGood, s.b, s.cq, s.bQ, s);
	};
};
var $elm$parser$Parser$Advanced$getOffset = function (s) {
	return A3($elm$parser$Parser$Advanced$Good, false, s.b, s);
};
var $elm$parser$Parser$Advanced$getSource = function (s) {
	return A3($elm$parser$Parser$Advanced$Good, false, s.a, s);
};
var $elm$core$Basics$always = F2(
	function (a, _v0) {
		return a;
	});
var $elm$parser$Parser$Advanced$map2 = F3(
	function (func, _v0, _v1) {
		var parseA = _v0;
		var parseB = _v1;
		return function (s0) {
			var _v2 = parseA(s0);
			if (_v2.$ === 1) {
				var p = _v2.a;
				var x = _v2.b;
				return A2($elm$parser$Parser$Advanced$Bad, p, x);
			} else {
				var p1 = _v2.a;
				var a = _v2.b;
				var s1 = _v2.c;
				var _v3 = parseB(s1);
				if (_v3.$ === 1) {
					var p2 = _v3.a;
					var x = _v3.b;
					return A2($elm$parser$Parser$Advanced$Bad, p1 || p2, x);
				} else {
					var p2 = _v3.a;
					var b = _v3.b;
					var s2 = _v3.c;
					return A3(
						$elm$parser$Parser$Advanced$Good,
						p1 || p2,
						A2(func, a, b),
						s2);
				}
			}
		};
	});
var $elm$parser$Parser$Advanced$ignorer = F2(
	function (keepParser, ignoreParser) {
		return A3($elm$parser$Parser$Advanced$map2, $elm$core$Basics$always, keepParser, ignoreParser);
	});
var $elm$parser$Parser$Advanced$keeper = F2(
	function (parseFunc, parseArg) {
		return A3($elm$parser$Parser$Advanced$map2, $elm$core$Basics$apL, parseFunc, parseArg);
	});
var $elm$parser$Parser$Advanced$succeed = function (a) {
	return function (s) {
		return A3($elm$parser$Parser$Advanced$Good, false, a, s);
	};
};
var $author$project$Tools$ParserTools$text = F2(
	function (prefix, _continue) {
		return A2(
			$elm$parser$Parser$Advanced$keeper,
			A2(
				$elm$parser$Parser$Advanced$keeper,
				A2(
					$elm$parser$Parser$Advanced$keeper,
					$elm$parser$Parser$Advanced$succeed(
						F3(
							function (start, finish, content) {
								return {
									aq: start,
									aL: A3($elm$core$String$slice, start, finish, content),
									au: finish
								};
							})),
					A2(
						$elm$parser$Parser$Advanced$ignorer,
						A2(
							$elm$parser$Parser$Advanced$ignorer,
							$elm$parser$Parser$Advanced$getOffset,
							A2(
								$elm$parser$Parser$Advanced$chompIf,
								function (c) {
									return prefix(c);
								},
								$author$project$Tools$ParserTools$ExpectingPrefix)),
						$elm$parser$Parser$Advanced$chompWhile(
							function (c) {
								return _continue(c);
							}))),
				$elm$parser$Parser$Advanced$getOffset),
			$elm$parser$Parser$Advanced$getSource);
	});
var $author$project$Parser$Tokenizer$codeParser = F2(
	function (start, index) {
		return A2(
			$elm$parser$Parser$Advanced$map,
			function (_v1) {
				return $author$project$Parser$Tokenizer$CodeToken(
					{aq: start, au: start, b1: index});
			},
			A2(
				$author$project$Tools$ParserTools$text,
				function (c) {
					return c === '`';
				},
				function (_v0) {
					return false;
				}));
	});
var $author$project$Parser$Tokenizer$codeChars = _List_fromArray(
	['`']);
var $author$project$Parser$Tokenizer$languageChars = _List_fromArray(
	['[', ']', '`', '$', '\\']);
var $author$project$Parser$Tokenizer$codeTextParser = F2(
	function (start, index) {
		return A2(
			$elm$parser$Parser$Advanced$map,
			function (data) {
				return A2(
					$author$project$Parser$Tokenizer$S,
					data.aL,
					{aq: start, au: ((start + data.au) - data.aq) - 1, b1: index});
			},
			A2(
				$author$project$Tools$ParserTools$text,
				function (c) {
					return !A2(
						$elm$core$List$member,
						c,
						A2($elm$core$List$cons, ' ', $author$project$Parser$Tokenizer$codeChars));
				},
				function (c) {
					return !A2(
						$elm$core$List$member,
						c,
						A2($elm$core$List$cons, ' ', $author$project$Parser$Tokenizer$languageChars));
				}));
	});
var $elm$parser$Parser$Advanced$Append = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var $elm$parser$Parser$Advanced$oneOfHelp = F3(
	function (s0, bag, parsers) {
		oneOfHelp:
		while (true) {
			if (!parsers.b) {
				return A2($elm$parser$Parser$Advanced$Bad, false, bag);
			} else {
				var parse = parsers.a;
				var remainingParsers = parsers.b;
				var _v1 = parse(s0);
				if (!_v1.$) {
					var step = _v1;
					return step;
				} else {
					var step = _v1;
					var p = step.a;
					var x = step.b;
					if (p) {
						return step;
					} else {
						var $temp$s0 = s0,
							$temp$bag = A2($elm$parser$Parser$Advanced$Append, bag, x),
							$temp$parsers = remainingParsers;
						s0 = $temp$s0;
						bag = $temp$bag;
						parsers = $temp$parsers;
						continue oneOfHelp;
					}
				}
			}
		}
	});
var $elm$parser$Parser$Advanced$oneOf = function (parsers) {
	return function (s) {
		return A3($elm$parser$Parser$Advanced$oneOfHelp, s, $elm$parser$Parser$Advanced$Empty, parsers);
	};
};
var $author$project$Parser$Tokenizer$W = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $author$project$Parser$Tokenizer$whiteSpaceParser = F2(
	function (start, index) {
		return A2(
			$elm$parser$Parser$Advanced$map,
			function (data) {
				return A2(
					$author$project$Parser$Tokenizer$W,
					data.aL,
					{aq: start, au: start, b1: index});
			},
			A2(
				$author$project$Tools$ParserTools$text,
				function (c) {
					return c === ' ';
				},
				function (c) {
					return c === ' ';
				}));
	});
var $author$project$Parser$Tokenizer$codeParser_ = F2(
	function (start, index) {
		return $elm$parser$Parser$Advanced$oneOf(
			_List_fromArray(
				[
					A2($author$project$Parser$Tokenizer$codeTextParser, start, index),
					A2($author$project$Parser$Tokenizer$codeParser, start, index),
					A2($author$project$Parser$Tokenizer$whiteSpaceParser, start, index)
				]));
	});
var $author$project$Parser$Tokenizer$MathToken = function (a) {
	return {$: 4, a: a};
};
var $author$project$Parser$Tokenizer$mathParser = F2(
	function (start, index) {
		return A2(
			$elm$parser$Parser$Advanced$map,
			function (_v1) {
				return $author$project$Parser$Tokenizer$MathToken(
					{aq: start, au: start, b1: index});
			},
			A2(
				$author$project$Tools$ParserTools$text,
				function (c) {
					return c === '$';
				},
				function (_v0) {
					return false;
				}));
	});
var $author$project$Parser$Tokenizer$mathChars = _List_fromArray(
	['$']);
var $author$project$Parser$Tokenizer$mathTextParser = F2(
	function (start, index) {
		return A2(
			$elm$parser$Parser$Advanced$map,
			function (data) {
				return A2(
					$author$project$Parser$Tokenizer$S,
					data.aL,
					{aq: start, au: ((start + data.au) - data.aq) - 1, b1: index});
			},
			A2(
				$author$project$Tools$ParserTools$text,
				function (c) {
					return !A2(
						$elm$core$List$member,
						c,
						A2($elm$core$List$cons, ' ', $author$project$Parser$Tokenizer$mathChars));
				},
				function (c) {
					return !A2(
						$elm$core$List$member,
						c,
						A2($elm$core$List$cons, ' ', $author$project$Parser$Tokenizer$languageChars));
				}));
	});
var $author$project$Tools$ParserTools$ExpectingSymbol = function (a) {
	return {$: 1, a: a};
};
var $elm$parser$Parser$Advanced$Token = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$parser$Parser$Advanced$isSubString = _Parser_isSubString;
var $elm$parser$Parser$Advanced$token = function (_v0) {
	var str = _v0.a;
	var expecting = _v0.b;
	var progress = !$elm$core$String$isEmpty(str);
	return function (s) {
		var _v1 = A5($elm$parser$Parser$Advanced$isSubString, str, s.b, s.cq, s.bQ, s.a);
		var newOffset = _v1.a;
		var newRow = _v1.b;
		var newCol = _v1.c;
		return _Utils_eq(newOffset, -1) ? A2(
			$elm$parser$Parser$Advanced$Bad,
			false,
			A2($elm$parser$Parser$Advanced$fromState, s, expecting)) : A3(
			$elm$parser$Parser$Advanced$Good,
			progress,
			0,
			{bQ: newCol, g: s.g, bu: s.bu, b: newOffset, cq: newRow, a: s.a});
	};
};
var $elm$parser$Parser$Advanced$symbol = $elm$parser$Parser$Advanced$token;
var $author$project$Parser$Tokenizer$parenMathCloseParser = F2(
	function (start, index) {
		return A2(
			$elm$parser$Parser$Advanced$map,
			function (_v0) {
				return $author$project$Parser$Tokenizer$MathToken(
					{aq: start, au: start + 1, b1: index});
			},
			$elm$parser$Parser$Advanced$symbol(
				A2(
					$elm$parser$Parser$Advanced$Token,
					'\\)',
					$author$project$Tools$ParserTools$ExpectingSymbol('\\)'))));
	});
var $author$project$Parser$Tokenizer$mathParser_ = F2(
	function (start, index) {
		return $elm$parser$Parser$Advanced$oneOf(
			_List_fromArray(
				[
					A2($author$project$Parser$Tokenizer$parenMathCloseParser, start, index),
					A2($author$project$Parser$Tokenizer$mathTextParser, start, index),
					A2($author$project$Parser$Tokenizer$mathParser, start, index),
					A2($author$project$Parser$Tokenizer$whiteSpaceParser, start, index)
				]));
	});
var $author$project$Parser$Tokenizer$backslashTextParser = F2(
	function (start, index) {
		return A2(
			$elm$parser$Parser$Advanced$map,
			function (data) {
				return A2(
					$author$project$Parser$Tokenizer$S,
					data.aL,
					{aq: start, au: ((start + data.au) - data.aq) - 1, b1: index});
			},
			A2(
				$author$project$Tools$ParserTools$text,
				function (c) {
					return c === '\\';
				},
				function (c) {
					return $elm$core$Char$isAlpha(c);
				}));
	});
var $author$project$Parser$Tokenizer$LB = function (a) {
	return {$: 0, a: a};
};
var $author$project$Parser$Tokenizer$leftBracketParser = F2(
	function (start, index) {
		return A2(
			$elm$parser$Parser$Advanced$map,
			function (_v1) {
				return $author$project$Parser$Tokenizer$LB(
					{aq: start, au: start, b1: index});
			},
			A2(
				$author$project$Tools$ParserTools$text,
				function (c) {
					return c === '[';
				},
				function (_v0) {
					return false;
				}));
	});
var $author$project$Parser$Tokenizer$parenMathOpenParser = F2(
	function (start, index) {
		return A2(
			$elm$parser$Parser$Advanced$map,
			function (_v0) {
				return $author$project$Parser$Tokenizer$MathToken(
					{aq: start, au: start + 1, b1: index});
			},
			$elm$parser$Parser$Advanced$symbol(
				A2(
					$elm$parser$Parser$Advanced$Token,
					'\\(',
					$author$project$Tools$ParserTools$ExpectingSymbol('\\('))));
	});
var $author$project$Parser$Tokenizer$RB = function (a) {
	return {$: 1, a: a};
};
var $author$project$Parser$Tokenizer$rightBracketParser = F2(
	function (start, index) {
		return A2(
			$elm$parser$Parser$Advanced$map,
			function (_v1) {
				return $author$project$Parser$Tokenizer$RB(
					{aq: start, au: start, b1: index});
			},
			A2(
				$author$project$Tools$ParserTools$text,
				function (c) {
					return c === ']';
				},
				function (_v0) {
					return false;
				}));
	});
var $author$project$Parser$Tokenizer$textParser = F2(
	function (start, index) {
		return A2(
			$elm$parser$Parser$Advanced$map,
			function (data) {
				return A2(
					$author$project$Parser$Tokenizer$S,
					data.aL,
					{aq: start, au: ((start + data.au) - data.aq) - 1, b1: index});
			},
			A2(
				$author$project$Tools$ParserTools$text,
				function (c) {
					return !A2(
						$elm$core$List$member,
						c,
						A2($elm$core$List$cons, ' ', $author$project$Parser$Tokenizer$languageChars));
				},
				function (c) {
					return !A2(
						$elm$core$List$member,
						c,
						A2($elm$core$List$cons, ' ', $author$project$Parser$Tokenizer$languageChars));
				}));
	});
var $author$project$Parser$Tokenizer$tokenParser_ = F2(
	function (start, index) {
		return $elm$parser$Parser$Advanced$oneOf(
			_List_fromArray(
				[
					A2($author$project$Parser$Tokenizer$whiteSpaceParser, start, index),
					A2($author$project$Parser$Tokenizer$textParser, start, index),
					A2($author$project$Parser$Tokenizer$parenMathOpenParser, start, index),
					A2($author$project$Parser$Tokenizer$parenMathCloseParser, start, index),
					A2($author$project$Parser$Tokenizer$backslashTextParser, start, index),
					A2($author$project$Parser$Tokenizer$leftBracketParser, start, index),
					A2($author$project$Parser$Tokenizer$rightBracketParser, start, index),
					A2($author$project$Parser$Tokenizer$mathParser, start, index),
					A2($author$project$Parser$Tokenizer$codeParser, start, index)
				]));
	});
var $author$project$Parser$Tokenizer$tokenParser = F3(
	function (mode, start, index) {
		switch (mode) {
			case 0:
				return A2($author$project$Parser$Tokenizer$tokenParser_, start, index);
			case 1:
				return A2($author$project$Parser$Tokenizer$mathParser_, start, index);
			default:
				return A2($author$project$Parser$Tokenizer$codeParser_, start, index);
		}
	});
var $author$project$Parser$Tokenizer$get = F3(
	function (state, start, input) {
		var _v0 = A2(
			$elm$parser$Parser$Advanced$run,
			A3($author$project$Parser$Tokenizer$tokenParser, state.aU, start, state.J),
			input);
		if (!_v0.$) {
			var token = _v0.a;
			return token;
		} else {
			var errorList = _v0.a;
			return A2(
				$author$project$Parser$Tokenizer$TokenError,
				errorList,
				{aq: start, au: start + 1, b1: state.J});
		}
	});
var $author$project$Parser$Tokenizer$isTextToken = function (token) {
	return A2(
		$elm$core$List$member,
		$author$project$Parser$Tokenizer$type_(token),
		_List_fromArray(
			[3, 2]));
};
var $author$project$Parser$Tokenizer$getMeta = function (token) {
	switch (token.$) {
		case 0:
			var m = token.a;
			return m;
		case 1:
			var m = token.a;
			return m;
		case 2:
			var m = token.b;
			return m;
		case 3:
			var m = token.b;
			return m;
		case 4:
			var m = token.a;
			return m;
		case 5:
			var m = token.a;
			return m;
		default:
			var m = token.b;
			return m;
	}
};
var $author$project$Parser$Tokenizer$length = function (token) {
	var meta = $author$project$Parser$Tokenizer$getMeta(token);
	return meta.au - meta.aq;
};
var $author$project$Parser$Tokenizer$InCode = 2;
var $author$project$Parser$Tokenizer$InMath = 1;
var $author$project$Parser$Tokenizer$newMode = F2(
	function (token, currentMode) {
		switch (currentMode) {
			case 0:
				switch (token.$) {
					case 4:
						return 1;
					case 5:
						return 2;
					default:
						return 0;
				}
			case 1:
				if (token.$ === 4) {
					return 0;
				} else {
					return 1;
				}
			default:
				if (token.$ === 5) {
					return 0;
				} else {
					return 2;
				}
		}
	});
var $author$project$Parser$Tokenizer$setIndex = F2(
	function (k, token) {
		switch (token.$) {
			case 0:
				var meta = token.a;
				return $author$project$Parser$Tokenizer$LB(
					_Utils_update(
						meta,
						{b1: k}));
			case 1:
				var meta = token.a;
				return $author$project$Parser$Tokenizer$RB(
					_Utils_update(
						meta,
						{b1: k}));
			case 2:
				var str = token.a;
				var meta = token.b;
				return A2(
					$author$project$Parser$Tokenizer$S,
					str,
					_Utils_update(
						meta,
						{b1: k}));
			case 3:
				var str = token.a;
				var meta = token.b;
				return A2(
					$author$project$Parser$Tokenizer$W,
					str,
					_Utils_update(
						meta,
						{b1: k}));
			case 4:
				var meta = token.a;
				return $author$project$Parser$Tokenizer$MathToken(
					_Utils_update(
						meta,
						{b1: k}));
			case 5:
				var meta = token.a;
				return $author$project$Parser$Tokenizer$CodeToken(
					_Utils_update(
						meta,
						{b1: k}));
			default:
				var list = token.a;
				var meta = token.b;
				return A2(
					$author$project$Parser$Tokenizer$TokenError,
					list,
					_Utils_update(
						meta,
						{b1: k}));
		}
	});
var $author$project$Parser$Tokenizer$stringValue = function (token) {
	switch (token.$) {
		case 0:
			return '[';
		case 1:
			return ']';
		case 2:
			var str = token.a;
			return str;
		case 3:
			var str = token.a;
			return str;
		case 4:
			return '$';
		case 5:
			return '`';
		default:
			return 'tokenError';
	}
};
var $author$project$Parser$Tokenizer$mergeToken = F2(
	function (lastToken, currentToken) {
		var lastTokenMeta = $author$project$Parser$Tokenizer$getMeta(lastToken);
		var currentTokenMeta = $author$project$Parser$Tokenizer$getMeta(currentToken);
		var meta = {aq: lastTokenMeta.aq, au: currentTokenMeta.au, b1: -1};
		return A2(
			$author$project$Parser$Tokenizer$S,
			_Utils_ap(
				$author$project$Parser$Tokenizer$stringValue(lastToken),
				$author$project$Parser$Tokenizer$stringValue(currentToken)),
			meta);
	});
var $author$project$Parser$Tokenizer$updateCurrentToken = F3(
	function (index, token, currentToken) {
		if (currentToken.$ === 1) {
			return $elm$core$Maybe$Just(
				A2($author$project$Parser$Tokenizer$setIndex, index, token));
		} else {
			var token_ = currentToken.a;
			return $elm$core$Maybe$Just(
				A2(
					$author$project$Parser$Tokenizer$setIndex,
					index,
					A2($author$project$Parser$Tokenizer$mergeToken, token_, token)));
		}
	});
var $author$project$Parser$Tokenizer$nextStep = function (state) {
	if (_Utils_cmp(state.al, state.bF) > -1) {
		var _v0 = state.ag;
		if (!_v0.$) {
			var token = _v0.a;
			return $author$project$Tools$Loop$Done(
				A2($elm$core$List$cons, token, state.bK));
		} else {
			return $author$project$Tools$Loop$Done(state.bK);
		}
	} else {
		var token = A3(
			$author$project$Parser$Tokenizer$get,
			state,
			state.al,
			A2($elm$core$String$dropLeft, state.al, state.bE));
		var newScanPointer = (state.al + $author$project$Parser$Tokenizer$length(token)) + 1;
		var _v1 = function () {
			if ($author$project$Parser$Tokenizer$isTextToken(token)) {
				return _Utils_eq(
					A2(
						$elm$core$Maybe$map,
						$author$project$Parser$Tokenizer$type_,
						$elm$core$List$head(state.bK)),
					$elm$core$Maybe$Just(0)) ? _Utils_Tuple3(
					A2(
						$elm$core$List$cons,
						A2($author$project$Parser$Tokenizer$setIndex, state.J, token),
						state.bK),
					state.J + 1,
					$elm$core$Maybe$Nothing) : _Utils_Tuple3(
					state.bK,
					state.J,
					A3($author$project$Parser$Tokenizer$updateCurrentToken, state.J, token, state.ag));
			} else {
				if (!$author$project$Parser$Tokenizer$type_(token)) {
					var _v2 = state.ag;
					if (_v2.$ === 1) {
						return _Utils_Tuple3(
							A2(
								$elm$core$List$cons,
								A2($author$project$Parser$Tokenizer$setIndex, state.J, token),
								state.bK),
							state.J + 1,
							$elm$core$Maybe$Nothing);
					} else {
						var textToken = _v2.a;
						return _Utils_Tuple3(
							A2(
								$elm$core$List$cons,
								A2($author$project$Parser$Tokenizer$setIndex, state.J + 1, token),
								A2(
									$elm$core$List$cons,
									A2($author$project$Parser$Tokenizer$setIndex, state.J, textToken),
									state.bK)),
							state.J + 2,
							$elm$core$Maybe$Nothing);
					}
				} else {
					var _v3 = state.ag;
					if (_v3.$ === 1) {
						return _Utils_Tuple3(
							A2(
								$elm$core$List$cons,
								A2($author$project$Parser$Tokenizer$setIndex, state.J, token),
								state.bK),
							state.J + 1,
							$elm$core$Maybe$Nothing);
					} else {
						var textToken = _v3.a;
						return _Utils_Tuple3(
							A2(
								$elm$core$List$cons,
								A2($author$project$Parser$Tokenizer$setIndex, state.J + 1, token),
								A2($elm$core$List$cons, textToken, state.bK)),
							state.J + 2,
							$elm$core$Maybe$Nothing);
					}
				}
			}
		}();
		var tokens = _v1.a;
		var tokenIndex = _v1.b;
		var currentToken_ = _v1.c;
		var currentToken = $author$project$Parser$Tokenizer$isTextToken(token) ? currentToken_ : $elm$core$Maybe$Nothing;
		return $author$project$Tools$Loop$Loop(
			_Utils_update(
				state,
				{
					ag: currentToken,
					aU: A2($author$project$Parser$Tokenizer$newMode, token, state.aU),
					al: newScanPointer,
					J: tokenIndex,
					bK: tokens
				}));
	}
};
var $author$project$Parser$Tokenizer$run = function (source) {
	return A2(
		$author$project$Tools$Loop$loop,
		$author$project$Parser$Tokenizer$init(source),
		$author$project$Parser$Tokenizer$nextStep);
};
var $author$project$Parser$Expression$parseToState = F2(
	function (lineNumber, str) {
		return A2(
			$author$project$Parser$Expression$parseTokenListToState,
			lineNumber,
			$author$project$Parser$Tokenizer$run(str));
	});
var $author$project$Parser$Expression$parse = F2(
	function (lineNumber, str) {
		var state = A2($author$project$Parser$Expression$parseToState, lineNumber, str);
		return $author$project$Parser$Expression$fixup(state.j);
	});
var $author$project$Parser$Pipeline$parseLines = F2(
	function (lineNumber, lines) {
		return A2(
			$author$project$Parser$Expression$parse,
			lineNumber,
			A2($elm$core$String$join, '\n', lines));
	});
var $author$project$Parser$Pipeline$groupListItems = function (items) {
	return $elm$core$List$reverse(
		A3(
			$elm$core$List$foldl,
			F2(
				function (line, acc) {
					var trimmed = $elm$core$String$trim(line);
					if (A2($elm$core$String$startsWith, '- ', trimmed) || A2($elm$core$String$startsWith, '. ', trimmed)) {
						return A2($elm$core$List$cons, line, acc);
					} else {
						if (acc.b) {
							var prev = acc.a;
							var rest = acc.b;
							return A2($elm$core$List$cons, prev + (' ' + trimmed), rest);
						} else {
							return _List_fromArray(
								[line]);
						}
					}
				}),
			_List_Nil,
			items));
};
var $elm$core$String$trimLeft = _String_trimLeft;
var $author$project$Parser$Pipeline$measureIndent = function (str) {
	return $elm$core$String$length(str) - $elm$core$String$length(
		$elm$core$String$trimLeft(str));
};
var $author$project$Parser$Pipeline$stripListPrefix = function (str) {
	var trimmed = $elm$core$String$trim(str);
	return A2($elm$core$String$startsWith, '- ', trimmed) ? A2($elm$core$String$dropLeft, 2, trimmed) : (A2($elm$core$String$startsWith, '. ', trimmed) ? A2($elm$core$String$dropLeft, 2, trimmed) : trimmed);
};
var $author$project$Parser$Pipeline$parseListItems = F3(
	function (_v0, lineNumber, items) {
		return A2(
			$elm$core$List$map,
			function (item) {
				var itemIndent = $author$project$Parser$Pipeline$measureIndent(item);
				return A3(
					$author$project$V3$Types$ExprList,
					itemIndent,
					A2(
						$author$project$Parser$Expression$parse,
						lineNumber,
						$author$project$Parser$Pipeline$stripListPrefix(item)),
					$author$project$Parser$Pipeline$emptyExprMeta);
			},
			$author$project$Parser$Pipeline$groupListItems(items));
	});
var $author$project$Parser$Table$parseCell = F4(
	function (gen, row, col, str) {
		return function (exprs) {
			return A3(
				$author$project$V3$Types$ExprList,
				0,
				exprs,
				{
					aq: 0,
					au: $elm$core$String$length(str),
					e: 'cell-' + ($elm$core$String$fromInt(row) + ('-' + $elm$core$String$fromInt(col))),
					b1: 0
				});
		}(
			A2(
				$author$project$Parser$Expression$parse,
				gen,
				$elm$core$String$trim(str)));
	});
var $author$project$Parser$Table$parseRow = F3(
	function (gen, row, str) {
		return function (exprs) {
			return A3(
				$author$project$V3$Types$ExprList,
				0,
				exprs,
				{
					aq: 0,
					au: $elm$core$String$length(str),
					e: 'row-' + $elm$core$String$fromInt(row),
					b1: 0
				});
		}(
			A2(
				$elm$core$List$indexedMap,
				function (col) {
					return A3($author$project$Parser$Table$parseCell, gen, row, col);
				},
				A2($elm$core$String$split, '&', str)));
	});
var $author$project$Parser$Table$parseTable = F2(
	function (gen, rows) {
		return A2(
			$elm$core$List$indexedMap,
			function (row) {
				return A2($author$project$Parser$Table$parseRow, gen, row);
			},
			rows);
	});
var $author$project$Parser$Pipeline$parseBody = function (block) {
	var _v0 = block.P;
	switch (_v0.$) {
		case 0:
			return $toastal$either$Either$Right(
				A2($author$project$Parser$Pipeline$parseLines, block.A.I, block.bO));
		case 1:
			switch (_v0.a) {
				case 'item':
					var content = A2(
						$elm$core$String$join,
						' ',
						A2(
							$elm$core$List$cons,
							$author$project$Parser$Pipeline$stripListPrefix(block.cT),
							block.bO));
					return $toastal$either$Either$Right(
						_List_fromArray(
							[
								A3(
								$author$project$V3$Types$ExprList,
								block.bu,
								A2($author$project$Parser$Expression$parse, block.A.I, content),
								$author$project$Parser$Pipeline$emptyExprMeta)
							]));
				case 'numbered':
					var content = A2(
						$elm$core$String$join,
						' ',
						A2(
							$elm$core$List$cons,
							$author$project$Parser$Pipeline$stripListPrefix(block.cT),
							block.bO));
					return $toastal$either$Either$Right(
						_List_fromArray(
							[
								A3(
								$author$project$V3$Types$ExprList,
								block.bu,
								A2($author$project$Parser$Expression$parse, block.A.I, content),
								$author$project$Parser$Pipeline$emptyExprMeta)
							]));
				case 'itemList':
					return $toastal$either$Either$Right(
						A3(
							$author$project$Parser$Pipeline$parseListItems,
							block.bu,
							block.A.I,
							A2($elm$core$List$cons, block.cT, block.bO)));
				case 'numberedList':
					return $toastal$either$Either$Right(
						A3(
							$author$project$Parser$Pipeline$parseListItems,
							block.bu,
							block.A.I,
							A2($elm$core$List$cons, block.cT, block.bO)));
				default:
					return $toastal$either$Either$Right(
						A2($author$project$Parser$Pipeline$parseLines, block.A.I, block.bO));
			}
		default:
			if (_v0.a === 'table') {
				return $toastal$either$Either$Right(
					A2($author$project$Parser$Table$parseTable, 0, block.bO));
			} else {
				return $toastal$either$Either$Left(
					A2($elm$core$String$join, '\n', block.bO));
			}
	}
};
var $author$project$Parser$Pipeline$transformBlockHeading = function (block) {
	var _v0 = block.P;
	if ((_v0.$ === 2) && (_v0.a === 'table')) {
		return $author$project$V3$Types$Ordinary('table');
	} else {
		return block.P;
	}
};
var $author$project$Parser$Pipeline$toExpressionBlockWithBody = F2(
	function (body, block) {
		return {
			cF: block.cF,
			bO: body,
			cT: block.cT,
			P: $author$project$Parser$Pipeline$transformBlockHeading(block),
			bu: block.bu,
			A: block.A,
			c: A3($elm$core$Dict$insert, 'id', block.A.e, block.c),
			cu: block.cu
		};
	});
var $author$project$Parser$Pipeline$toExpressionBlock = function (block) {
	return A2(
		$author$project$Parser$Pipeline$toExpressionBlockWithBody,
		$author$project$Parser$Pipeline$parseBody(block),
		block);
};
var $author$project$Parser$Pipeline$toExpressionBlockCached = F2(
	function (cache, block) {
		var _v0 = A2($elm$core$Dict$get, block.A.dg, cache);
		if (!_v0.$) {
			var cachedBody = _v0.a;
			return A2($author$project$Parser$Pipeline$toExpressionBlockWithBody, cachedBody, block);
		} else {
			return $author$project$Parser$Pipeline$toExpressionBlock(block);
		}
	});
var $author$project$V3$Types$NotInList = 1;
var $elm$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (n <= 0) {
				return result;
			} else {
				var $temp$result = A2($elm$core$List$cons, value, result),
					$temp$n = n - 1,
					$temp$value = value;
				result = $temp$result;
				n = $temp$n;
				value = $temp$value;
				continue repeatHelp;
			}
		}
	});
var $elm$core$List$repeat = F2(
	function (n, value) {
		return A3($elm$core$List$repeatHelp, _List_Nil, n, value);
	});
var $author$project$Generic$Vector$init = function (k) {
	return {
		aL: A2($elm$core$List$repeat, k, 0),
		am: k
	};
};
var $author$project$Generic$Settings$numberedBlockNames = _List_fromArray(
	['q', 'axiom', 'box', 'theorem', 'definition', 'lemma', 'construction', 'principle', 'proposition', 'corollary', 'note', 'remark', 'exercise', 'question', 'problem', 'example', 'equation', 'math', 'aligned', 'quiver', 'image', 'iframe', 'chart']);
var $elm_community$list_extra$List$Extra$updateAt = F3(
	function (index, fn, list) {
		if (index < 0) {
			return list;
		} else {
			var tail = A2($elm$core$List$drop, index, list);
			if (tail.b) {
				var x = tail.a;
				var xs = tail.b;
				return _Utils_ap(
					A2($elm$core$List$take, index, list),
					A2(
						$elm$core$List$cons,
						fn(x),
						xs));
			} else {
				return list;
			}
		}
	});
var $elm_community$list_extra$List$Extra$setAt = F2(
	function (index, value) {
		return A2(
			$elm_community$list_extra$List$Extra$updateAt,
			index,
			$elm$core$Basics$always(value));
	});
var $author$project$Generic$Vector$set = F3(
	function (k, a, v) {
		return _Utils_update(
			v,
			{
				aL: A3($elm_community$list_extra$List$Extra$setAt, k, a, v.aL)
			});
	});
var $author$project$ETeX$MathMacros$MacroBody = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $author$project$ETeX$Transform$findMaxParam = function (exprs) {
	findMaxParam:
	while (true) {
		_v0$10:
		while (true) {
			if (!exprs.b) {
				return 0;
			} else {
				switch (exprs.a.$) {
					case 8:
						var n = exprs.a.a;
						var rest = exprs.b;
						return A2(
							$elm$core$Basics$max,
							n,
							$author$project$ETeX$Transform$findMaxParam(rest));
					case 3:
						var innerExprs = exprs.a.a;
						var rest = exprs.b;
						return A2(
							$elm$core$Basics$max,
							$author$project$ETeX$Transform$findMaxParam(innerExprs),
							$author$project$ETeX$Transform$findMaxParam(rest));
					case 4:
						var innerExprs = exprs.a.a;
						var rest = exprs.b;
						return A2(
							$elm$core$Basics$max,
							$author$project$ETeX$Transform$findMaxParam(innerExprs),
							$author$project$ETeX$Transform$findMaxParam(rest));
					case 5:
						var innerExprs = exprs.a.a;
						var rest = exprs.b;
						return A2(
							$elm$core$Basics$max,
							$author$project$ETeX$Transform$findMaxParam(innerExprs),
							$author$project$ETeX$Transform$findMaxParam(rest));
					case 20:
						var _v1 = exprs.a;
						var args = _v1.b;
						var rest = exprs.b;
						return A2(
							$elm$core$Basics$max,
							$author$project$ETeX$Transform$findMaxParam(args),
							$author$project$ETeX$Transform$findMaxParam(rest));
					case 21:
						var _v2 = exprs.a;
						var args = _v2.b;
						var rest = exprs.b;
						return A2(
							$elm$core$Basics$max,
							$author$project$ETeX$Transform$findMaxParam(args),
							$author$project$ETeX$Transform$findMaxParam(rest));
					case 22:
						var innerExprs = exprs.a.a;
						var rest = exprs.b;
						return A2(
							$elm$core$Basics$max,
							$author$project$ETeX$Transform$findMaxParam(innerExprs),
							$author$project$ETeX$Transform$findMaxParam(rest));
					case 6:
						if (!exprs.a.a.$) {
							var expr = exprs.a.a.a;
							var rest = exprs.b;
							return A2(
								$elm$core$Basics$max,
								$author$project$ETeX$Transform$findMaxParam(
									_List_fromArray(
										[expr])),
								$author$project$ETeX$Transform$findMaxParam(rest));
						} else {
							break _v0$10;
						}
					case 7:
						if (!exprs.a.a.$) {
							var expr = exprs.a.a.a;
							var rest = exprs.b;
							return A2(
								$elm$core$Basics$max,
								$author$project$ETeX$Transform$findMaxParam(
									_List_fromArray(
										[expr])),
								$author$project$ETeX$Transform$findMaxParam(rest));
						} else {
							break _v0$10;
						}
					default:
						break _v0$10;
				}
			}
		}
		var rest = exprs.b;
		var $temp$exprs = rest;
		exprs = $temp$exprs;
		continue findMaxParam;
	}
};
var $author$project$ETeX$Transform$makeEntry = function (newCommand_) {
	if (((((!newCommand_.$) && (newCommand_.a.a.$ === 1)) && newCommand_.a.c.b) && (newCommand_.a.c.a.$ === 3)) && (!newCommand_.a.c.b.b)) {
		var _v1 = newCommand_.a;
		var name = _v1.a.a;
		var arity = _v1.b;
		var _v2 = _v1.c;
		var body = _v2.a.a;
		var deducedArity = (arity > 0) ? arity : $author$project$ETeX$Transform$findMaxParam(body);
		return $elm$core$Maybe$Just(
			_Utils_Tuple2(
				name,
				A2($author$project$ETeX$MathMacros$MacroBody, deducedArity, body)));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $elm$parser$Parser$Advanced$backtrackable = function (_v0) {
	var parse = _v0;
	return function (s0) {
		var _v1 = parse(s0);
		if (_v1.$ === 1) {
			var x = _v1.b;
			return A2($elm$parser$Parser$Advanced$Bad, false, x);
		} else {
			var a = _v1.b;
			var s1 = _v1.c;
			return A3($elm$parser$Parser$Advanced$Good, false, a, s1);
		}
	};
};
var $author$project$ETeX$Transform$ExpectingLeftBrace = 0;
var $author$project$ETeX$Transform$ExpectingNewCommand = 20;
var $author$project$ETeX$Transform$ExpectingRightBrace = 17;
var $author$project$ETeX$MathMacros$NewCommand = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var $author$project$ETeX$Transform$ExpectingBackslash = 19;
var $author$project$ETeX$MathMacros$MacroName = function (a) {
	return {$: 1, a: a};
};
var $author$project$ETeX$Transform$ExpectingAlpha = 1;
var $author$project$ETeX$Transform$alphaNumParser_ = A2(
	$elm$parser$Parser$Advanced$keeper,
	A2(
		$elm$parser$Parser$Advanced$keeper,
		A2(
			$elm$parser$Parser$Advanced$keeper,
			$elm$parser$Parser$Advanced$succeed($elm$core$String$slice),
			A2(
				$elm$parser$Parser$Advanced$ignorer,
				A2(
					$elm$parser$Parser$Advanced$ignorer,
					$elm$parser$Parser$Advanced$getOffset,
					A2($elm$parser$Parser$Advanced$chompIf, $elm$core$Char$isAlpha, 1)),
				$elm$parser$Parser$Advanced$chompWhile($elm$core$Char$isAlphaNum))),
		$elm$parser$Parser$Advanced$getOffset),
	$elm$parser$Parser$Advanced$getSource);
var $elm$parser$Parser$Advanced$andThen = F2(
	function (callback, _v0) {
		var parseA = _v0;
		return function (s0) {
			var _v1 = parseA(s0);
			if (_v1.$ === 1) {
				var p = _v1.a;
				var x = _v1.b;
				return A2($elm$parser$Parser$Advanced$Bad, p, x);
			} else {
				var p1 = _v1.a;
				var a = _v1.b;
				var s1 = _v1.c;
				var _v2 = callback(a);
				var parseB = _v2;
				var _v3 = parseB(s1);
				if (_v3.$ === 1) {
					var p2 = _v3.a;
					var x = _v3.b;
					return A2($elm$parser$Parser$Advanced$Bad, p1 || p2, x);
				} else {
					var p2 = _v3.a;
					var b = _v3.b;
					var s2 = _v3.c;
					return A3($elm$parser$Parser$Advanced$Good, p1 || p2, b, s2);
				}
			}
		};
	});
var $author$project$ETeX$Transform$second = F2(
	function (p, q) {
		return A2(
			$elm$parser$Parser$Advanced$andThen,
			function (_v0) {
				return q;
			},
			p);
	});
var $author$project$ETeX$Transform$f0Parser = A2(
	$elm$parser$Parser$Advanced$map,
	$author$project$ETeX$MathMacros$MacroName,
	A2(
		$author$project$ETeX$Transform$second,
		$elm$parser$Parser$Advanced$symbol(
			A2($elm$parser$Parser$Advanced$Token, '\\', 19)),
		$author$project$ETeX$Transform$alphaNumParser_));
var $elm$parser$Parser$Advanced$loopHelp = F4(
	function (p, state, callback, s0) {
		loopHelp:
		while (true) {
			var _v0 = callback(state);
			var parse = _v0;
			var _v1 = parse(s0);
			if (!_v1.$) {
				var p1 = _v1.a;
				var step = _v1.b;
				var s1 = _v1.c;
				if (!step.$) {
					var newState = step.a;
					var $temp$p = p || p1,
						$temp$state = newState,
						$temp$callback = callback,
						$temp$s0 = s1;
					p = $temp$p;
					state = $temp$state;
					callback = $temp$callback;
					s0 = $temp$s0;
					continue loopHelp;
				} else {
					var result = step.a;
					return A3($elm$parser$Parser$Advanced$Good, p || p1, result, s1);
				}
			} else {
				var p1 = _v1.a;
				var x = _v1.b;
				return A2($elm$parser$Parser$Advanced$Bad, p || p1, x);
			}
		}
	});
var $elm$parser$Parser$Advanced$loop = F2(
	function (state, callback) {
		return function (s) {
			return A4($elm$parser$Parser$Advanced$loopHelp, false, state, callback, s);
		};
	});
var $elm$parser$Parser$Advanced$Done = function (a) {
	return {$: 1, a: a};
};
var $elm$parser$Parser$Advanced$Loop = function (a) {
	return {$: 0, a: a};
};
var $author$project$ETeX$Transform$manyHelp = F2(
	function (p, vs) {
		return $elm$parser$Parser$Advanced$oneOf(
			_List_fromArray(
				[
					A2(
					$elm$parser$Parser$Advanced$keeper,
					$elm$parser$Parser$Advanced$succeed(
						function (v) {
							return $elm$parser$Parser$Advanced$Loop(
								A2($elm$core$List$cons, v, vs));
						}),
					p),
					A2(
					$elm$parser$Parser$Advanced$map,
					function (_v0) {
						return $elm$parser$Parser$Advanced$Done(
							$elm$core$List$reverse(vs));
					},
					$elm$parser$Parser$Advanced$succeed(0))
				]));
	});
var $author$project$ETeX$Transform$many = function (p) {
	return A2(
		$elm$parser$Parser$Advanced$loop,
		_List_Nil,
		$author$project$ETeX$Transform$manyHelp(p));
};
var $author$project$ETeX$MathMacros$AlphaNum = function (a) {
	return {$: 0, a: a};
};
var $author$project$ETeX$MathMacros$Arg = function (a) {
	return {$: 3, a: a};
};
var $author$project$ETeX$MathMacros$DecoM = function (a) {
	return {$: 0, a: a};
};
var $author$project$ETeX$Transform$ExpectingCaret = 15;
var $author$project$ETeX$Transform$ExpectingLeftParen = 12;
var $author$project$ETeX$Transform$ExpectingRightParen = 13;
var $author$project$ETeX$Transform$ExpectingUnderscore = 14;
var $author$project$ETeX$MathMacros$FCall = F2(
	function (a, b) {
		return {$: 21, a: a, b: b};
	});
var $author$project$ETeX$MathMacros$Macro = F2(
	function (a, b) {
		return {$: 20, a: a, b: b};
	});
var $author$project$ETeX$MathMacros$PArg = function (a) {
	return {$: 4, a: a};
};
var $author$project$ETeX$MathMacros$ParenthExpr = function (a) {
	return {$: 5, a: a};
};
var $author$project$ETeX$MathMacros$Sub = function (a) {
	return {$: 6, a: a};
};
var $author$project$ETeX$MathMacros$Super = function (a) {
	return {$: 7, a: a};
};
var $author$project$ETeX$KaTeX$accents = _List_fromArray(
	['hat', 'widehat', 'check', 'widecheck', 'tilde', 'widetilde', 'acute', 'grave', 'dot', 'ddot', 'breve', 'bar', 'vec', 'mathring', 'overline', 'underline', 'overleftarrow', 'overrightarrow', 'overleftrightarrow', 'underleftarrow', 'underrightarrow', 'underleftrightarrow', 'overgroup', 'undergroup', 'overbrace', 'underbrace', 'overparen', 'underparen', 'overrightleftharpoons', 'boxed', 'underlinesegment', 'overlinesegment']);
var $author$project$ETeX$KaTeX$arrows = _List_fromArray(
	['leftarrow', 'gets', 'rightarrow', 'to', 'leftrightarrow', 'Leftarrow', 'Rightarrow', 'Leftrightarrow', 'iff', 'uparrow', 'downarrow', 'updownarrow', 'Uparrow', 'Downarrow', 'Updownarrow', 'mapsto', 'hookleftarrow', 'hookrightarrow', 'leftharpoonup', 'rightharpoonup', 'leftharpoondown', 'rightharpoondown', 'rightleftharpoons', 'longleftarrow', 'longrightarrow', 'longleftrightarrow', 'Longleftarrow', 'impliedby', 'Longrightarrow', 'implies', 'Longleftrightarrow', 'longmapsto', 'nearrow', 'searrow', 'swarrow', 'nwarrow', 'dashleftarrow', 'dashrightarrow', 'leftleftarrows', 'rightrightarrows', 'leftrightarrows', 'rightleftarrows', 'Lleftarrow', 'Rrightarrow', 'twoheadleftarrow', 'twoheadrightarrow', 'leftarrowtail', 'rightarrowtail', 'looparrowleft', 'looparrowright', 'curvearrowleft', 'curvearrowright', 'circlearrowleft', 'circlearrowright', 'multimap', 'leftrightsquigarrow', 'rightsquigarrow', 'leadsto', 'restriction']);
var $author$project$ETeX$KaTeX$bigOperators = _List_fromArray(
	['sum', 'prod', 'coprod', 'bigcup', 'bigcap', 'bigvee', 'bigwedge', 'bigoplus', 'bigotimes', 'bigodot', 'biguplus', 'bigsqcup', 'int', 'oint', 'iint', 'iiint', 'iiiint', 'intop', 'smallint']);
var $author$project$ETeX$KaTeX$binaryOperators = _List_fromArray(
	['pm', 'mp', 'times', 'div', 'cdot', 'ast', 'star', 'circ', 'bullet', 'oplus', 'ominus', 'otimes', 'oslash', 'odot', 'dagger', 'ddagger', 'vee', 'lor', 'wedge', 'land', 'cap', 'cup', 'setminus', 'smallsetminus', 'triangleleft', 'triangleright', 'bigtriangleup', 'bigtriangledown', 'lhd', 'rhd', 'unlhd', 'unrhd', 'amalg', 'uplus', 'sqcap', 'sqcup', 'boxplus', 'boxminus', 'boxtimes', 'boxdot', 'leftthreetimes', 'rightthreetimes', 'curlyvee', 'curlywedge', 'dotplus', 'divideontimes', 'doublebarwedge']);
var $author$project$ETeX$KaTeX$binomials = _List_fromArray(
	['binom', 'dbinom', 'tbinom', 'brace', 'brack']);
var $author$project$ETeX$KaTeX$delimiters = _List_fromArray(
	['lbrace', 'rbrace', 'lbrack', 'rbrack', 'langle', 'rangle', 'vert', 'Vert', 'lvert', 'rvert', 'lVert', 'rVert', 'lfloor', 'rfloor', 'lceil', 'rceil', 'lgroup', 'rgroup', 'lmoustache', 'rmoustache', 'ulcorner', 'urcorner', 'llcorner', 'lrcorner']);
var $author$project$ETeX$KaTeX$fonts = _List_fromArray(
	['mathrm', 'mathit', 'mathbf', 'boldsymbol', 'pmb', 'mathbb', 'Bbb', 'mathcal', 'cal', 'mathscr', 'scr', 'mathfrak', 'frak', 'mathsf', 'sf', 'mathtt', 'tt', 'mathnormal', 'text', 'textbf', 'textit', 'textrm', 'textsf', 'texttt', 'textnormal', 'textup', 'operatorname', 'operatorname*']);
var $author$project$ETeX$KaTeX$fractions = _List_fromArray(
	['frac', 'dfrac', 'tfrac', 'cfrac', 'genfrac', 'over', 'atop', 'choose']);
var $elm$core$Set$Set_elm_builtin = $elm$core$Basics$identity;
var $elm$core$Set$empty = $elm$core$Dict$empty;
var $elm$core$Set$insert = F2(
	function (key, _v0) {
		var dict = _v0;
		return A3($elm$core$Dict$insert, key, 0, dict);
	});
var $elm$core$Set$fromList = function (list) {
	return A3($elm$core$List$foldl, $elm$core$Set$insert, $elm$core$Set$empty, list);
};
var $author$project$ETeX$KaTeX$greekLetters = _List_fromArray(
	['alpha', 'beta', 'gamma', 'delta', 'epsilon', 'varepsilon', 'zeta', 'eta', 'theta', 'vartheta', 'iota', 'kappa', 'varkappa', 'lambda', 'mu', 'nu', 'xi', 'pi', 'varpi', 'rho', 'varrho', 'sigma', 'varsigma', 'tau', 'upsilon', 'phi', 'varphi', 'chi', 'psi', 'omega', 'Gamma', 'Delta', 'Theta', 'Lambda', 'Xi', 'Pi', 'Sigma', 'Upsilon', 'Phi', 'Psi', 'Omega', 'digamma', 'varGamma', 'varDelta', 'varTheta', 'varLambda', 'varXi', 'varPi', 'varSigma', 'varUpsilon', 'varPhi', 'varPsi', 'varOmega']);
var $author$project$ETeX$KaTeX$logicAndSetTheory = _List_fromArray(
	['forall', 'exists', 'nexists', 'complement', 'subset', 'supset', 'mid', 'nmid', 'notsubset', 'nsubset', 'nsupset', 'nsupseteq', 'nsubseteq', 'subsetneq', 'supsetneq', 'subsetneqq', 'supsetneqq', 'varsubsetneq', 'varsupsetneq', 'varsubsetneqq', 'varsupsetneqq', 'isin', 'notin', 'notni', 'niton', 'in', 'ni', 'emptyset', 'varnothing', 'setminus', 'smallsetminus', 'complement', 'neg', 'lnot']);
var $author$project$ETeX$KaTeX$mathFunctions = _List_fromArray(
	['sin', 'cos', 'tan', 'cot', 'sec', 'csc', 'sinh', 'cosh', 'tanh', 'coth', 'sech', 'csch', 'arcsin', 'arccos', 'arctan', 'arctg', 'arcctg', 'ln', 'log', 'lg', 'exp', 'deg', 'det', 'dim', 'hom', 'ker', 'lim', 'liminf', 'limsup', 'max', 'min', 'sup', 'inf', 'Pr', 'gcd', 'lcm', 'arg', 'mod', 'bmod', 'pmod', 'pod']);
var $author$project$ETeX$KaTeX$miscSymbols = _List_fromArray(
	['infty', 'aleph', 'beth', 'gimel', 'daleth', 'eth', 'hbar', 'hslash', 'Finv', 'Game', 'ell', 'wp', 'Re', 'Im', 'partial', 'nabla', 'Box', 'square', 'blacksquare', 'blacklozenge', 'lozenge', 'Diamond', 'triangle', 'triangledown', 'angle', 'measuredangle', 'sphericalangle', 'prime', 'backprime', 'degree', 'flat', 'natural', 'sharp', 'surd', 'top', 'bot', 'emptyset', 'varnothing', 'clubsuit', 'diamondsuit', 'heartsuit', 'spadesuit', 'blacktriangleright', 'blacktriangleleft', 'blacktriangledown', 'blacktriangle', 'bigstar', 'maltese', 'checkmark', 'diagup', 'diagdown', 'ddag', 'dag', 'copyright', 'circledR', 'pounds', 'yen', 'euro', 'cent', 'maltese']);
var $author$project$ETeX$KaTeX$relationSymbols = _List_fromArray(
	['leq', 'le', 'geq', 'ge', 'neq', 'ne', 'sim', 'simeq', 'approx', 'cong', 'equiv', 'prec', 'succ', 'preceq', 'succeq', 'll', 'gg', 'subset', 'supset', 'subseteq', 'supseteq', 'nsubseteq', 'nsupseteq', 'sqsubset', 'sqsupset', 'sqsubseteq', 'sqsupseteq', 'in', 'ni', 'notin', 'notni', 'propto', 'varpropto', 'perp', 'parallel', 'nparallel', 'smile', 'frown', 'doteq', 'fallingdotseq', 'risingdotseq', 'coloneq', 'eqcirc', 'circeq', 'triangleq', 'bumpeq', 'Bumpeq', 'doteqdot', 'thicksim', 'thickapprox', 'approxeq', 'backsim', 'backsimeq', 'preccurlyeq', 'succcurlyeq', 'curlyeqprec', 'curlyeqsucc', 'precsim', 'succsim', 'precapprox', 'succapprox', 'vartriangleleft', 'vartriangleright', 'trianglelefteq', 'trianglerighteq', 'between', 'pitchfork', 'shortmid', 'shortparallel', 'therefore', 'because', 'eqcolon', 'simcolon', 'approxcolon', 'colonapprox', 'colonsim', 'Colon', 'ratio']);
var $author$project$ETeX$KaTeX$roots = _List_fromArray(
	['sqrt', 'sqrtsign']);
var $author$project$ETeX$KaTeX$spacing = _List_fromArray(
	['quad', 'qquad', 'space', 'thinspace', 'medspace', 'thickspace', 'enspace', 'negspace', 'negmedspace', 'negthickspace', 'negthinspace', 'mkern', 'mskip', 'hskip', 'hspace', 'hspace*', 'kern', 'phantom', 'hphantom', 'vphantom', 'mathstrut', 'strut', '!', ':', ';', ',']);
var $author$project$ETeX$KaTeX$textOperators = _List_fromArray(
	['not', 'cancel', 'bcancel', 'xcancel', 'cancelto', 'sout', 'overline', 'underline', 'overset', 'underset', 'stackrel', 'atop', 'substack', 'sideset']);
var $author$project$ETeX$KaTeX$katexCommands = $elm$core$Set$fromList(
	$elm$core$List$concat(
		_List_fromArray(
			[$author$project$ETeX$KaTeX$greekLetters, $author$project$ETeX$KaTeX$binaryOperators, $author$project$ETeX$KaTeX$relationSymbols, $author$project$ETeX$KaTeX$arrows, $author$project$ETeX$KaTeX$delimiters, $author$project$ETeX$KaTeX$bigOperators, $author$project$ETeX$KaTeX$mathFunctions, $author$project$ETeX$KaTeX$accents, $author$project$ETeX$KaTeX$fonts, $author$project$ETeX$KaTeX$spacing, $author$project$ETeX$KaTeX$logicAndSetTheory, $author$project$ETeX$KaTeX$miscSymbols, $author$project$ETeX$KaTeX$fractions, $author$project$ETeX$KaTeX$binomials, $author$project$ETeX$KaTeX$roots, $author$project$ETeX$KaTeX$textOperators])));
var $elm$core$Dict$member = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$get, key, dict);
		if (!_v0.$) {
			return true;
		} else {
			return false;
		}
	});
var $elm$core$Set$member = F2(
	function (key, _v0) {
		var dict = _v0;
		return A2($elm$core$Dict$member, key, dict);
	});
var $author$project$ETeX$KaTeX$isKaTeX = function (command) {
	return A2($elm$core$Set$member, command, $author$project$ETeX$KaTeX$katexCommands);
};
var $author$project$ETeX$Transform$isUserDefinedMacro = F2(
	function (dict, name) {
		return A2($elm$core$Dict$member, name, dict);
	});
var $author$project$ETeX$Transform$alphaNumOrMacroParser = function (userMacroDict) {
	return A2(
		$elm$parser$Parser$Advanced$map,
		function (name) {
			return ($author$project$ETeX$KaTeX$isKaTeX(name) || A2($author$project$ETeX$Transform$isUserDefinedMacro, userMacroDict, name)) ? A2($author$project$ETeX$MathMacros$Macro, name, _List_Nil) : $author$project$ETeX$MathMacros$AlphaNum(name);
		},
		$author$project$ETeX$Transform$alphaNumParser_);
};
var $author$project$ETeX$MathMacros$Comma = {$: 17};
var $author$project$ETeX$Transform$ExpectingComma = 21;
var $author$project$ETeX$Transform$commaParser = A2(
	$elm$parser$Parser$Advanced$ignorer,
	$elm$parser$Parser$Advanced$succeed($author$project$ETeX$MathMacros$Comma),
	$elm$parser$Parser$Advanced$symbol(
		A2($elm$parser$Parser$Advanced$Token, ',', 21)));
var $author$project$ETeX$Transform$ExpectingGreekLetter = 23;
var $elm$parser$Parser$Advanced$problem = function (x) {
	return function (s) {
		return A2(
			$elm$parser$Parser$Advanced$Bad,
			false,
			A2($elm$parser$Parser$Advanced$fromState, s, x));
	};
};
var $author$project$ETeX$Transform$greekSymbolParser = A2(
	$elm$parser$Parser$Advanced$andThen,
	function (str) {
		return A2($elm$core$List$member, str, $author$project$ETeX$KaTeX$greekLetters) ? $elm$parser$Parser$Advanced$succeed(
			$author$project$ETeX$MathMacros$AlphaNum('\\' + str)) : $elm$parser$Parser$Advanced$problem(23);
	},
	A2(
		$elm$parser$Parser$Advanced$keeper,
		$elm$parser$Parser$Advanced$succeed($elm$core$Basics$identity),
		$author$project$ETeX$Transform$alphaNumParser_));
var $author$project$ETeX$Transform$isTextModeCommand = function (name) {
	return A2(
		$elm$core$List$member,
		name,
		_List_fromArray(
			['text', 'textsf', 'textbf', 'textit', 'texttt', 'textrm', 'textsc', 'mbox']));
};
var $elm$parser$Parser$Advanced$lazy = function (thunk) {
	return function (s) {
		var _v0 = thunk(0);
		var parse = _v0;
		return parse(s);
	};
};
var $author$project$ETeX$Transform$ExpectingLeftMathBrace = 10;
var $author$project$ETeX$MathMacros$LeftMathBrace = {$: 13};
var $author$project$ETeX$Transform$leftBraceParser = A2(
	$elm$parser$Parser$Advanced$ignorer,
	$elm$parser$Parser$Advanced$succeed($author$project$ETeX$MathMacros$LeftMathBrace),
	$elm$parser$Parser$Advanced$symbol(
		A2($elm$parser$Parser$Advanced$Token, '\\{', 10)));
var $author$project$ETeX$MathMacros$LeftParen = {$: 15};
var $author$project$ETeX$Transform$leftParenParser = A2(
	$elm$parser$Parser$Advanced$ignorer,
	$elm$parser$Parser$Advanced$succeed($author$project$ETeX$MathMacros$LeftParen),
	$elm$parser$Parser$Advanced$symbol(
		A2($elm$parser$Parser$Advanced$Token, '(', 12)));
var $author$project$ETeX$Transform$many1 = function (p) {
	return A2(
		$elm$parser$Parser$Advanced$keeper,
		A2(
			$elm$parser$Parser$Advanced$keeper,
			$elm$parser$Parser$Advanced$succeed($elm$core$List$cons),
			p),
		$author$project$ETeX$Transform$many(p));
};
var $author$project$ETeX$Transform$ExpectingMathMediumSpace = 6;
var $author$project$ETeX$MathMacros$MathMediumSpace = {$: 12};
var $author$project$ETeX$Transform$mathMediumSpaceParser = A2(
	$elm$parser$Parser$Advanced$ignorer,
	$elm$parser$Parser$Advanced$succeed($author$project$ETeX$MathMacros$MathMediumSpace),
	$elm$parser$Parser$Advanced$symbol(
		A2($elm$parser$Parser$Advanced$Token, '\\;', 6)));
var $author$project$ETeX$Transform$ExpectingMathSmallSpace = 5;
var $author$project$ETeX$MathMacros$MathSmallSpace = {$: 11};
var $author$project$ETeX$Transform$mathSmallSpaceParser = A2(
	$elm$parser$Parser$Advanced$ignorer,
	$elm$parser$Parser$Advanced$succeed($author$project$ETeX$MathMacros$MathSmallSpace),
	$elm$parser$Parser$Advanced$symbol(
		A2($elm$parser$Parser$Advanced$Token, '\\,', 5)));
var $author$project$ETeX$Transform$ExpectingMathSpace = 8;
var $author$project$ETeX$MathMacros$MathSpace = {$: 10};
var $author$project$ETeX$Transform$mathSpaceParser = A2(
	$elm$parser$Parser$Advanced$ignorer,
	$elm$parser$Parser$Advanced$succeed($author$project$ETeX$MathMacros$MathSpace),
	$elm$parser$Parser$Advanced$symbol(
		A2($elm$parser$Parser$Advanced$Token, '\\ ', 8)));
var $author$project$ETeX$Transform$ExpectingNotAlpha = 2;
var $author$project$ETeX$MathMacros$MathSymbols = function (a) {
	return {$: 18, a: a};
};
var $author$project$ETeX$Transform$mathSymbolsParser = A2(
	$elm$parser$Parser$Advanced$map,
	$author$project$ETeX$MathMacros$MathSymbols,
	A2(
		$elm$parser$Parser$Advanced$keeper,
		A2(
			$elm$parser$Parser$Advanced$keeper,
			A2(
				$elm$parser$Parser$Advanced$keeper,
				$elm$parser$Parser$Advanced$succeed($elm$core$String$slice),
				A2(
					$elm$parser$Parser$Advanced$ignorer,
					A2(
						$elm$parser$Parser$Advanced$ignorer,
						$elm$parser$Parser$Advanced$getOffset,
						A2(
							$elm$parser$Parser$Advanced$chompIf,
							function (c) {
								return (!$elm$core$Char$isAlpha(c)) && (!A2(
									$elm$core$List$member,
									c,
									_List_fromArray(
										['_', '^', '#', '\\', '{', '}', '(', ')', ',', '\"'])));
							},
							2)),
					$elm$parser$Parser$Advanced$chompWhile(
						function (c) {
							return (!$elm$core$Char$isAlpha(c)) && (!A2(
								$elm$core$List$member,
								c,
								_List_fromArray(
									['_', '^', '#', '\\', '{', '}', '(', ')', ',', '\"'])));
						}))),
			$elm$parser$Parser$Advanced$getOffset),
		$elm$parser$Parser$Advanced$getSource));
var $author$project$ETeX$MathMacros$DecoI = function (a) {
	return {$: 1, a: a};
};
var $author$project$ETeX$Transform$ExpectingInt = 3;
var $author$project$ETeX$Transform$InvalidNumber = 4;
var $elm$parser$Parser$Advanced$consumeBase = _Parser_consumeBase;
var $elm$parser$Parser$Advanced$consumeBase16 = _Parser_consumeBase16;
var $elm$parser$Parser$Advanced$bumpOffset = F2(
	function (newOffset, s) {
		return {bQ: s.bQ + (newOffset - s.b), g: s.g, bu: s.bu, b: newOffset, cq: s.cq, a: s.a};
	});
var $elm$parser$Parser$Advanced$chompBase10 = _Parser_chompBase10;
var $elm$parser$Parser$Advanced$isAsciiCode = _Parser_isAsciiCode;
var $elm$parser$Parser$Advanced$consumeExp = F2(
	function (offset, src) {
		if (A3($elm$parser$Parser$Advanced$isAsciiCode, 101, offset, src) || A3($elm$parser$Parser$Advanced$isAsciiCode, 69, offset, src)) {
			var eOffset = offset + 1;
			var expOffset = (A3($elm$parser$Parser$Advanced$isAsciiCode, 43, eOffset, src) || A3($elm$parser$Parser$Advanced$isAsciiCode, 45, eOffset, src)) ? (eOffset + 1) : eOffset;
			var newOffset = A2($elm$parser$Parser$Advanced$chompBase10, expOffset, src);
			return _Utils_eq(expOffset, newOffset) ? (-newOffset) : newOffset;
		} else {
			return offset;
		}
	});
var $elm$parser$Parser$Advanced$consumeDotAndExp = F2(
	function (offset, src) {
		return A3($elm$parser$Parser$Advanced$isAsciiCode, 46, offset, src) ? A2(
			$elm$parser$Parser$Advanced$consumeExp,
			A2($elm$parser$Parser$Advanced$chompBase10, offset + 1, src),
			src) : A2($elm$parser$Parser$Advanced$consumeExp, offset, src);
	});
var $elm$parser$Parser$Advanced$finalizeInt = F5(
	function (invalid, handler, startOffset, _v0, s) {
		var endOffset = _v0.a;
		var n = _v0.b;
		if (handler.$ === 1) {
			var x = handler.a;
			return A2(
				$elm$parser$Parser$Advanced$Bad,
				true,
				A2($elm$parser$Parser$Advanced$fromState, s, x));
		} else {
			var toValue = handler.a;
			return _Utils_eq(startOffset, endOffset) ? A2(
				$elm$parser$Parser$Advanced$Bad,
				_Utils_cmp(s.b, startOffset) < 0,
				A2($elm$parser$Parser$Advanced$fromState, s, invalid)) : A3(
				$elm$parser$Parser$Advanced$Good,
				true,
				toValue(n),
				A2($elm$parser$Parser$Advanced$bumpOffset, endOffset, s));
		}
	});
var $elm$parser$Parser$Advanced$fromInfo = F4(
	function (row, col, x, context) {
		return A2(
			$elm$parser$Parser$Advanced$AddRight,
			$elm$parser$Parser$Advanced$Empty,
			A4($elm$parser$Parser$Advanced$DeadEnd, row, col, x, context));
	});
var $elm$core$String$toFloat = _String_toFloat;
var $elm$parser$Parser$Advanced$finalizeFloat = F6(
	function (invalid, expecting, intSettings, floatSettings, intPair, s) {
		var intOffset = intPair.a;
		var floatOffset = A2($elm$parser$Parser$Advanced$consumeDotAndExp, intOffset, s.a);
		if (floatOffset < 0) {
			return A2(
				$elm$parser$Parser$Advanced$Bad,
				true,
				A4($elm$parser$Parser$Advanced$fromInfo, s.cq, s.bQ - (floatOffset + s.b), invalid, s.g));
		} else {
			if (_Utils_eq(s.b, floatOffset)) {
				return A2(
					$elm$parser$Parser$Advanced$Bad,
					false,
					A2($elm$parser$Parser$Advanced$fromState, s, expecting));
			} else {
				if (_Utils_eq(intOffset, floatOffset)) {
					return A5($elm$parser$Parser$Advanced$finalizeInt, invalid, intSettings, s.b, intPair, s);
				} else {
					if (floatSettings.$ === 1) {
						var x = floatSettings.a;
						return A2(
							$elm$parser$Parser$Advanced$Bad,
							true,
							A2($elm$parser$Parser$Advanced$fromState, s, invalid));
					} else {
						var toValue = floatSettings.a;
						var _v1 = $elm$core$String$toFloat(
							A3($elm$core$String$slice, s.b, floatOffset, s.a));
						if (_v1.$ === 1) {
							return A2(
								$elm$parser$Parser$Advanced$Bad,
								true,
								A2($elm$parser$Parser$Advanced$fromState, s, invalid));
						} else {
							var n = _v1.a;
							return A3(
								$elm$parser$Parser$Advanced$Good,
								true,
								toValue(n),
								A2($elm$parser$Parser$Advanced$bumpOffset, floatOffset, s));
						}
					}
				}
			}
		}
	});
var $elm$parser$Parser$Advanced$number = function (c) {
	return function (s) {
		if (A3($elm$parser$Parser$Advanced$isAsciiCode, 48, s.b, s.a)) {
			var zeroOffset = s.b + 1;
			var baseOffset = zeroOffset + 1;
			return A3($elm$parser$Parser$Advanced$isAsciiCode, 120, zeroOffset, s.a) ? A5(
				$elm$parser$Parser$Advanced$finalizeInt,
				c.c_,
				c.b$,
				baseOffset,
				A2($elm$parser$Parser$Advanced$consumeBase16, baseOffset, s.a),
				s) : (A3($elm$parser$Parser$Advanced$isAsciiCode, 111, zeroOffset, s.a) ? A5(
				$elm$parser$Parser$Advanced$finalizeInt,
				c.c_,
				c.cc,
				baseOffset,
				A3($elm$parser$Parser$Advanced$consumeBase, 8, baseOffset, s.a),
				s) : (A3($elm$parser$Parser$Advanced$isAsciiCode, 98, zeroOffset, s.a) ? A5(
				$elm$parser$Parser$Advanced$finalizeInt,
				c.c_,
				c.bN,
				baseOffset,
				A3($elm$parser$Parser$Advanced$consumeBase, 2, baseOffset, s.a),
				s) : A6(
				$elm$parser$Parser$Advanced$finalizeFloat,
				c.c_,
				c.bW,
				c.b4,
				c.bY,
				_Utils_Tuple2(zeroOffset, 0),
				s)));
		} else {
			return A6(
				$elm$parser$Parser$Advanced$finalizeFloat,
				c.c_,
				c.bW,
				c.b4,
				c.bY,
				A3($elm$parser$Parser$Advanced$consumeBase, 10, s.b, s.a),
				s);
		}
	};
};
var $elm$parser$Parser$Advanced$int = F2(
	function (expecting, invalid) {
		return $elm$parser$Parser$Advanced$number(
			{
				bN: $elm$core$Result$Err(invalid),
				bW: expecting,
				bY: $elm$core$Result$Err(invalid),
				b$: $elm$core$Result$Err(invalid),
				b4: $elm$core$Result$Ok($elm$core$Basics$identity),
				c_: invalid,
				cc: $elm$core$Result$Err(invalid)
			});
	});
var $author$project$ETeX$Transform$numericDecoParser = A2(
	$elm$parser$Parser$Advanced$map,
	$author$project$ETeX$MathMacros$DecoI,
	A2($elm$parser$Parser$Advanced$int, 3, 4));
var $author$project$ETeX$Transform$ExpectingHash = 18;
var $author$project$ETeX$MathMacros$Param = function (a) {
	return {$: 8, a: a};
};
var $author$project$ETeX$Transform$paramParser = A2(
	$elm$parser$Parser$Advanced$map,
	$author$project$ETeX$MathMacros$Param,
	A2(
		$elm$parser$Parser$Advanced$keeper,
		A2(
			$elm$parser$Parser$Advanced$ignorer,
			$elm$parser$Parser$Advanced$succeed($elm$core$Basics$identity),
			$elm$parser$Parser$Advanced$symbol(
				A2($elm$parser$Parser$Advanced$Token, '#', 18))),
		A2($elm$parser$Parser$Advanced$int, 3, 4)));
var $author$project$ETeX$Transform$chompBraceBalancedStep = function (depth) {
	return (!depth) ? $elm$parser$Parser$Advanced$oneOf(
		_List_fromArray(
			[
				A2(
				$elm$parser$Parser$Advanced$map,
				function (_v0) {
					return $elm$parser$Parser$Advanced$Loop(1);
				},
				A2(
					$elm$parser$Parser$Advanced$chompIf,
					function (c) {
						return c === '{';
					},
					0)),
				A2(
				$elm$parser$Parser$Advanced$map,
				function (_v1) {
					return $elm$parser$Parser$Advanced$Loop(0);
				},
				A2(
					$elm$parser$Parser$Advanced$chompIf,
					function (c) {
						return (c !== '{') && (c !== '}');
					},
					2)),
				$elm$parser$Parser$Advanced$succeed(
				$elm$parser$Parser$Advanced$Done(0))
			])) : $elm$parser$Parser$Advanced$oneOf(
		_List_fromArray(
			[
				A2(
				$elm$parser$Parser$Advanced$map,
				function (_v2) {
					return $elm$parser$Parser$Advanced$Loop(depth + 1);
				},
				A2(
					$elm$parser$Parser$Advanced$chompIf,
					function (c) {
						return c === '{';
					},
					0)),
				A2(
				$elm$parser$Parser$Advanced$map,
				function (_v3) {
					return $elm$parser$Parser$Advanced$Loop(depth - 1);
				},
				A2(
					$elm$parser$Parser$Advanced$chompIf,
					function (c) {
						return c === '}';
					},
					17)),
				A2(
				$elm$parser$Parser$Advanced$map,
				function (_v4) {
					return $elm$parser$Parser$Advanced$Loop(depth);
				},
				A2(
					$elm$parser$Parser$Advanced$chompIf,
					function (c) {
						return (c !== '{') && (c !== '}');
					},
					2))
			]));
};
var $author$project$ETeX$Transform$chompBraceBalanced = A2($elm$parser$Parser$Advanced$loop, 0, $author$project$ETeX$Transform$chompBraceBalancedStep);
var $author$project$ETeX$Transform$rawBraceArg = A2(
	$elm$parser$Parser$Advanced$keeper,
	A2(
		$elm$parser$Parser$Advanced$keeper,
		A2(
			$elm$parser$Parser$Advanced$keeper,
			A2(
				$elm$parser$Parser$Advanced$ignorer,
				$elm$parser$Parser$Advanced$succeed(
					F3(
						function (start, end, src) {
							return $author$project$ETeX$MathMacros$Arg(
								_List_fromArray(
									[
										$author$project$ETeX$MathMacros$AlphaNum(
										A3($elm$core$String$slice, start, end, src))
									]));
						})),
				$elm$parser$Parser$Advanced$symbol(
					A2($elm$parser$Parser$Advanced$Token, '{', 0))),
			A2($elm$parser$Parser$Advanced$ignorer, $elm$parser$Parser$Advanced$getOffset, $author$project$ETeX$Transform$chompBraceBalanced)),
		$elm$parser$Parser$Advanced$getOffset),
	A2(
		$elm$parser$Parser$Advanced$ignorer,
		$elm$parser$Parser$Advanced$getSource,
		$elm$parser$Parser$Advanced$symbol(
			A2($elm$parser$Parser$Advanced$Token, '}', 17))));
var $author$project$ETeX$Transform$ExpectingRightMathBrace = 11;
var $author$project$ETeX$MathMacros$RightMathBrace = {$: 14};
var $author$project$ETeX$Transform$rightBraceParser = A2(
	$elm$parser$Parser$Advanced$ignorer,
	$elm$parser$Parser$Advanced$succeed($author$project$ETeX$MathMacros$RightMathBrace),
	$elm$parser$Parser$Advanced$symbol(
		A2($elm$parser$Parser$Advanced$Token, '\\}', 11)));
var $author$project$ETeX$MathMacros$RightParen = {$: 16};
var $author$project$ETeX$Transform$rightParenParser = A2(
	$elm$parser$Parser$Advanced$ignorer,
	$elm$parser$Parser$Advanced$succeed($author$project$ETeX$MathMacros$RightParen),
	$elm$parser$Parser$Advanced$symbol(
		A2($elm$parser$Parser$Advanced$Token, ')', 13)));
var $author$project$ETeX$Transform$sepByCommaHelp = F2(
	function (itemParser, revItems) {
		return $elm$parser$Parser$Advanced$oneOf(
			_List_fromArray(
				[
					A2(
					$elm$parser$Parser$Advanced$keeper,
					A2(
						$elm$parser$Parser$Advanced$ignorer,
						$elm$parser$Parser$Advanced$succeed(
							function (item) {
								return $elm$parser$Parser$Advanced$Loop(
									A2(
										$elm$core$List$cons,
										item,
										A2($elm$core$List$cons, $author$project$ETeX$MathMacros$Comma, revItems)));
							}),
						$elm$parser$Parser$Advanced$symbol(
							A2($elm$parser$Parser$Advanced$Token, ',', 21))),
					itemParser),
					$elm$parser$Parser$Advanced$succeed(
					$elm$parser$Parser$Advanced$Done(
						$elm$core$List$reverse(revItems)))
				]));
	});
var $author$project$ETeX$Transform$sepByComma = function (itemParser) {
	return $elm$parser$Parser$Advanced$oneOf(
		_List_fromArray(
			[
				A2(
				$elm$parser$Parser$Advanced$andThen,
				function (firstItem) {
					return A2(
						$elm$parser$Parser$Advanced$loop,
						_List_fromArray(
							[firstItem]),
						$author$project$ETeX$Transform$sepByCommaHelp(itemParser));
				},
				itemParser),
				$elm$parser$Parser$Advanced$succeed(_List_Nil)
			]));
};
var $author$project$ETeX$Transform$ExpectingQuote = 22;
var $author$project$ETeX$MathMacros$Text = function (a) {
	return {$: 23, a: a};
};
var $elm$parser$Parser$Advanced$mapChompedString = F2(
	function (func, _v0) {
		var parse = _v0;
		return function (s0) {
			var _v1 = parse(s0);
			if (_v1.$ === 1) {
				var p = _v1.a;
				var x = _v1.b;
				return A2($elm$parser$Parser$Advanced$Bad, p, x);
			} else {
				var p = _v1.a;
				var a = _v1.b;
				var s1 = _v1.c;
				return A3(
					$elm$parser$Parser$Advanced$Good,
					p,
					A2(
						func,
						A3($elm$core$String$slice, s0.b, s1.b, s0.a),
						a),
					s1);
			}
		};
	});
var $elm$parser$Parser$Advanced$getChompedString = function (parser) {
	return A2($elm$parser$Parser$Advanced$mapChompedString, $elm$core$Basics$always, parser);
};
var $author$project$ETeX$Transform$textParser = A2(
	$elm$parser$Parser$Advanced$keeper,
	A2(
		$elm$parser$Parser$Advanced$ignorer,
		$elm$parser$Parser$Advanced$succeed($author$project$ETeX$MathMacros$Text),
		$elm$parser$Parser$Advanced$symbol(
			A2($elm$parser$Parser$Advanced$Token, '\"', 22))),
	A2(
		$elm$parser$Parser$Advanced$ignorer,
		$elm$parser$Parser$Advanced$getChompedString(
			$elm$parser$Parser$Advanced$chompWhile(
				function (c) {
					return c !== '\"';
				})),
		$elm$parser$Parser$Advanced$symbol(
			A2($elm$parser$Parser$Advanced$Token, '\"', 22))));
var $author$project$ETeX$Transform$ExpectingSpace = 16;
var $author$project$ETeX$MathMacros$WS = {$: 9};
var $author$project$ETeX$Transform$whitespaceParser = A2(
	$elm$parser$Parser$Advanced$map,
	function (_v0) {
		return $author$project$ETeX$MathMacros$WS;
	},
	$elm$parser$Parser$Advanced$symbol(
		A2($elm$parser$Parser$Advanced$Token, ' ', 16)));
var $author$project$ETeX$Transform$alphaNumWithLookaheadParser = function (userMacroDict) {
	return A2(
		$elm$parser$Parser$Advanced$andThen,
		function (name) {
			return $elm$parser$Parser$Advanced$oneOf(
				_List_fromArray(
					[
						A2(
						$elm$parser$Parser$Advanced$map,
						function (args) {
							return ($author$project$ETeX$KaTeX$isKaTeX(name) || A2($author$project$ETeX$Transform$isUserDefinedMacro, userMacroDict, name)) ? A2($author$project$ETeX$MathMacros$Macro, name, args) : A2($author$project$ETeX$MathMacros$FCall, name, args);
						},
						$elm$parser$Parser$Advanced$backtrackable(
							$author$project$ETeX$Transform$functionArgsParser(userMacroDict))),
						$elm$parser$Parser$Advanced$succeed(
						($author$project$ETeX$KaTeX$isKaTeX(name) || A2($author$project$ETeX$Transform$isUserDefinedMacro, userMacroDict, name)) ? A2($author$project$ETeX$MathMacros$Macro, name, _List_Nil) : $author$project$ETeX$MathMacros$AlphaNum(name))
					]));
		},
		A2(
			$elm$parser$Parser$Advanced$keeper,
			$elm$parser$Parser$Advanced$succeed($elm$core$Basics$identity),
			$author$project$ETeX$Transform$alphaNumParser_));
};
var $author$project$ETeX$Transform$argParser = function (userMacroDict) {
	return A2(
		$elm$parser$Parser$Advanced$map,
		$author$project$ETeX$MathMacros$Arg,
		A2(
			$elm$parser$Parser$Advanced$ignorer,
			A2(
				$elm$parser$Parser$Advanced$keeper,
				A2(
					$elm$parser$Parser$Advanced$ignorer,
					$elm$parser$Parser$Advanced$succeed($elm$core$Basics$identity),
					$elm$parser$Parser$Advanced$symbol(
						A2($elm$parser$Parser$Advanced$Token, '{', 0))),
				$elm$parser$Parser$Advanced$lazy(
					function (_v7) {
						return $author$project$ETeX$Transform$many(
							$author$project$ETeX$Transform$mathExprParser(userMacroDict));
					})),
			$elm$parser$Parser$Advanced$symbol(
				A2($elm$parser$Parser$Advanced$Token, '}', 17))));
};
var $author$project$ETeX$Transform$decoParser = function (userMacroDict) {
	return $elm$parser$Parser$Advanced$oneOf(
		_List_fromArray(
			[
				$author$project$ETeX$Transform$numericDecoParser,
				A2(
				$elm$parser$Parser$Advanced$map,
				$author$project$ETeX$MathMacros$DecoM,
				$elm$parser$Parser$Advanced$lazy(
					function (_v6) {
						return $author$project$ETeX$Transform$mathExprParser(userMacroDict);
					}))
			]));
};
var $author$project$ETeX$Transform$functionArgListParser = function (userMacroDict) {
	var argContentParser = $elm$parser$Parser$Advanced$oneOf(
		_List_fromArray(
			[
				$author$project$ETeX$Transform$textParser,
				$author$project$ETeX$Transform$mathMediumSpaceParser,
				$author$project$ETeX$Transform$mathSmallSpaceParser,
				$author$project$ETeX$Transform$mathSpaceParser,
				$author$project$ETeX$Transform$leftBraceParser,
				$author$project$ETeX$Transform$rightBraceParser,
				$author$project$ETeX$Transform$macroParser(userMacroDict),
				$author$project$ETeX$Transform$alphaNumOrMacroParser(userMacroDict),
				$author$project$ETeX$Transform$mathSymbolsParser,
				$elm$parser$Parser$Advanced$lazy(
				function (_v4) {
					return $author$project$ETeX$Transform$argParser(userMacroDict);
				}),
				$elm$parser$Parser$Advanced$lazy(
				function (_v5) {
					return $author$project$ETeX$Transform$standaloneParenthExprParser(userMacroDict);
				}),
				$author$project$ETeX$Transform$paramParser,
				$author$project$ETeX$Transform$whitespaceParser,
				$author$project$ETeX$Transform$f0Parser,
				$author$project$ETeX$Transform$subscriptParser(userMacroDict),
				$author$project$ETeX$Transform$superscriptParser(userMacroDict)
			]));
	return $author$project$ETeX$Transform$sepByComma(
		A2(
			$elm$parser$Parser$Advanced$map,
			$author$project$ETeX$MathMacros$PArg,
			$author$project$ETeX$Transform$many1(argContentParser)));
};
var $author$project$ETeX$Transform$functionArgsParser = function (userMacroDict) {
	return A2(
		$elm$parser$Parser$Advanced$keeper,
		A2(
			$elm$parser$Parser$Advanced$ignorer,
			$elm$parser$Parser$Advanced$succeed($elm$core$Basics$identity),
			$elm$parser$Parser$Advanced$symbol(
				A2($elm$parser$Parser$Advanced$Token, '(', 12))),
		A2(
			$elm$parser$Parser$Advanced$ignorer,
			$elm$parser$Parser$Advanced$lazy(
				function (_v3) {
					return $author$project$ETeX$Transform$functionArgListParser(userMacroDict);
				}),
			$elm$parser$Parser$Advanced$symbol(
				A2($elm$parser$Parser$Advanced$Token, ')', 13))));
};
var $author$project$ETeX$Transform$macroParser = function (userMacroDict) {
	return A2(
		$elm$parser$Parser$Advanced$andThen,
		function (name) {
			return $author$project$ETeX$Transform$isTextModeCommand(name) ? A2(
				$elm$parser$Parser$Advanced$map,
				function (args) {
					return A2($author$project$ETeX$MathMacros$Macro, name, args);
				},
				$author$project$ETeX$Transform$many($author$project$ETeX$Transform$rawBraceArg)) : A2(
				$elm$parser$Parser$Advanced$map,
				function (args) {
					return A2($author$project$ETeX$MathMacros$Macro, name, args);
				},
				$author$project$ETeX$Transform$many(
					$author$project$ETeX$Transform$argParser(userMacroDict)));
		},
		A2(
			$elm$parser$Parser$Advanced$keeper,
			A2(
				$elm$parser$Parser$Advanced$ignorer,
				$elm$parser$Parser$Advanced$succeed($elm$core$Basics$identity),
				$elm$parser$Parser$Advanced$symbol(
					A2($elm$parser$Parser$Advanced$Token, '\\', 19))),
			$author$project$ETeX$Transform$alphaNumParser_));
};
var $author$project$ETeX$Transform$mathExprParser = function (userMacroDict) {
	return $elm$parser$Parser$Advanced$oneOf(
		_List_fromArray(
			[
				$author$project$ETeX$Transform$textParser,
				$elm$parser$Parser$Advanced$backtrackable($author$project$ETeX$Transform$greekSymbolParser),
				$author$project$ETeX$Transform$mathMediumSpaceParser,
				$author$project$ETeX$Transform$mathSmallSpaceParser,
				$author$project$ETeX$Transform$mathSpaceParser,
				$author$project$ETeX$Transform$leftBraceParser,
				$author$project$ETeX$Transform$rightBraceParser,
				$author$project$ETeX$Transform$alphaNumWithLookaheadParser(userMacroDict),
				$author$project$ETeX$Transform$macroParser(userMacroDict),
				$elm$parser$Parser$Advanced$backtrackable(
				$elm$parser$Parser$Advanced$lazy(
					function (_v1) {
						return $author$project$ETeX$Transform$standaloneParenthExprParser(userMacroDict);
					})),
				$author$project$ETeX$Transform$leftParenParser,
				$author$project$ETeX$Transform$rightParenParser,
				$author$project$ETeX$Transform$commaParser,
				$author$project$ETeX$Transform$mathSymbolsParser,
				$elm$parser$Parser$Advanced$lazy(
				function (_v2) {
					return $author$project$ETeX$Transform$argParser(userMacroDict);
				}),
				$author$project$ETeX$Transform$paramParser,
				$author$project$ETeX$Transform$whitespaceParser,
				$author$project$ETeX$Transform$f0Parser,
				$author$project$ETeX$Transform$subscriptParser(userMacroDict),
				$author$project$ETeX$Transform$superscriptParser(userMacroDict)
			]));
};
var $author$project$ETeX$Transform$standaloneParenthExprParser = function (userMacroDict) {
	return A2(
		$elm$parser$Parser$Advanced$map,
		$author$project$ETeX$MathMacros$ParenthExpr,
		A2(
			$elm$parser$Parser$Advanced$ignorer,
			A2(
				$elm$parser$Parser$Advanced$keeper,
				A2(
					$elm$parser$Parser$Advanced$ignorer,
					$elm$parser$Parser$Advanced$succeed($elm$core$Basics$identity),
					$elm$parser$Parser$Advanced$symbol(
						A2($elm$parser$Parser$Advanced$Token, '(', 12))),
				$elm$parser$Parser$Advanced$lazy(
					function (_v0) {
						return $author$project$ETeX$Transform$many(
							$author$project$ETeX$Transform$mathExprParser(userMacroDict));
					})),
			$elm$parser$Parser$Advanced$symbol(
				A2($elm$parser$Parser$Advanced$Token, ')', 13))));
};
var $author$project$ETeX$Transform$subscriptParser = function (userMacroDict) {
	return A2(
		$elm$parser$Parser$Advanced$map,
		$author$project$ETeX$MathMacros$Sub,
		A2(
			$elm$parser$Parser$Advanced$keeper,
			A2(
				$elm$parser$Parser$Advanced$ignorer,
				$elm$parser$Parser$Advanced$succeed($elm$core$Basics$identity),
				$elm$parser$Parser$Advanced$symbol(
					A2($elm$parser$Parser$Advanced$Token, '_', 14))),
			$author$project$ETeX$Transform$decoParser(userMacroDict)));
};
var $author$project$ETeX$Transform$superscriptParser = function (userMacroDict) {
	return A2(
		$elm$parser$Parser$Advanced$map,
		$author$project$ETeX$MathMacros$Super,
		A2(
			$elm$parser$Parser$Advanced$keeper,
			A2(
				$elm$parser$Parser$Advanced$ignorer,
				$elm$parser$Parser$Advanced$succeed($elm$core$Basics$identity),
				$elm$parser$Parser$Advanced$symbol(
					A2($elm$parser$Parser$Advanced$Token, '^', 15))),
			$author$project$ETeX$Transform$decoParser(userMacroDict)));
};
var $author$project$ETeX$Transform$ExpectingLeftBracket = 7;
var $author$project$ETeX$Transform$ExpectingRightBracket = 9;
var $author$project$ETeX$Transform$optionalParamParser = A2(
	$elm$parser$Parser$Advanced$keeper,
	A2(
		$elm$parser$Parser$Advanced$ignorer,
		$elm$parser$Parser$Advanced$succeed($elm$core$Basics$identity),
		$elm$parser$Parser$Advanced$symbol(
			A2($elm$parser$Parser$Advanced$Token, '[', 7))),
	A2(
		$elm$parser$Parser$Advanced$ignorer,
		A2($elm$parser$Parser$Advanced$int, 3, 4),
		$elm$parser$Parser$Advanced$symbol(
			A2($elm$parser$Parser$Advanced$Token, ']', 9))));
var $author$project$ETeX$Transform$newCommandParser1 = function (userMacroDict) {
	return A2(
		$elm$parser$Parser$Advanced$keeper,
		A2(
			$elm$parser$Parser$Advanced$keeper,
			A2(
				$elm$parser$Parser$Advanced$keeper,
				A2(
					$elm$parser$Parser$Advanced$ignorer,
					A2(
						$elm$parser$Parser$Advanced$ignorer,
						$elm$parser$Parser$Advanced$succeed(
							F3(
								function (name, arity, body) {
									return A3($author$project$ETeX$MathMacros$NewCommand, name, arity, body);
								})),
						$elm$parser$Parser$Advanced$symbol(
							A2($elm$parser$Parser$Advanced$Token, '\\newcommand', 20))),
					$elm$parser$Parser$Advanced$symbol(
						A2($elm$parser$Parser$Advanced$Token, '{', 0))),
				A2(
					$elm$parser$Parser$Advanced$ignorer,
					$author$project$ETeX$Transform$f0Parser,
					$elm$parser$Parser$Advanced$symbol(
						A2($elm$parser$Parser$Advanced$Token, '}', 17)))),
			$author$project$ETeX$Transform$optionalParamParser),
		$author$project$ETeX$Transform$many(
			$author$project$ETeX$Transform$mathExprParser(userMacroDict)));
};
var $author$project$ETeX$Transform$newCommandParser2 = function (userMacroDict) {
	return A2(
		$elm$parser$Parser$Advanced$keeper,
		A2(
			$elm$parser$Parser$Advanced$keeper,
			A2(
				$elm$parser$Parser$Advanced$ignorer,
				A2(
					$elm$parser$Parser$Advanced$ignorer,
					$elm$parser$Parser$Advanced$succeed(
						F2(
							function (name, body) {
								return A3($author$project$ETeX$MathMacros$NewCommand, name, 0, body);
							})),
					$elm$parser$Parser$Advanced$symbol(
						A2($elm$parser$Parser$Advanced$Token, '\\newcommand', 20))),
				$elm$parser$Parser$Advanced$symbol(
					A2($elm$parser$Parser$Advanced$Token, '{', 0))),
			A2(
				$elm$parser$Parser$Advanced$ignorer,
				$author$project$ETeX$Transform$f0Parser,
				$elm$parser$Parser$Advanced$symbol(
					A2($elm$parser$Parser$Advanced$Token, '}', 17)))),
		$author$project$ETeX$Transform$many(
			$author$project$ETeX$Transform$mathExprParser(userMacroDict)));
};
var $author$project$ETeX$Transform$newCommandParser = function (userMacroDict) {
	return $elm$parser$Parser$Advanced$oneOf(
		_List_fromArray(
			[
				$elm$parser$Parser$Advanced$backtrackable(
				$author$project$ETeX$Transform$newCommandParser1(userMacroDict)),
				$author$project$ETeX$Transform$newCommandParser2(userMacroDict)
			]));
};
var $author$project$ETeX$Transform$parseNewCommand = F2(
	function (userMacroDict, str) {
		return A2(
			$elm$parser$Parser$Advanced$run,
			$author$project$ETeX$Transform$newCommandParser(userMacroDict),
			str);
	});
var $elm$core$String$concat = function (strings) {
	return A2($elm$core$String$join, '', strings);
};
var $author$project$ETeX$Transform$SimpleBrace = F2(
	function (a, b) {
		return {$: 4, a: a, b: b};
	});
var $author$project$ETeX$Transform$SimpleSpace = function (a) {
	return {$: 2, a: a};
};
var $author$project$ETeX$Transform$SimpleSymbol = function (a) {
	return {$: 3, a: a};
};
var $author$project$ETeX$Transform$SimpleWord = function (a) {
	return {$: 0, a: a};
};
var $author$project$ETeX$Transform$tokenToString = function (token) {
	switch (token.$) {
		case 0:
			var word = token.a;
			return word;
		case 1:
			return '\\';
		case 2:
			var s = token.a;
			return s;
		case 3:
			var s = token.a;
			return s;
		case 4:
			var open = token.a;
			var content = token.b;
			return open + (content + '}');
		default:
			var n = token.a;
			return '#' + $elm$core$String$fromInt(n);
	}
};
var $author$project$ETeX$Transform$convertArgsToBraces = function (args) {
	return A2(
		$elm$core$List$map,
		function (arg) {
			return A2(
				$author$project$ETeX$Transform$SimpleBrace,
				'{',
				$elm$core$String$concat(
					A2($elm$core$List$map, $author$project$ETeX$Transform$tokenToString, arg)));
		},
		args);
};
var $author$project$ETeX$Transform$extractParenArgs = F2(
	function (tokens, currentArg) {
		extractParenArgs:
		while (true) {
			_v0$3:
			while (true) {
				if (!tokens.b) {
					return $elm$core$List$isEmpty(currentArg) ? _Utils_Tuple2(_List_Nil, _List_Nil) : _Utils_Tuple2(
						_List_fromArray(
							[
								$elm$core$List$reverse(currentArg)
							]),
						_List_Nil);
				} else {
					if (tokens.a.$ === 3) {
						switch (tokens.a.a) {
							case ')':
								var rest = tokens.b;
								return $elm$core$List$isEmpty(currentArg) ? _Utils_Tuple2(_List_Nil, rest) : _Utils_Tuple2(
									_List_fromArray(
										[
											$elm$core$List$reverse(currentArg)
										]),
									rest);
							case ',':
								var rest = tokens.b;
								var _v1 = A2($author$project$ETeX$Transform$extractParenArgs, rest, _List_Nil);
								var args = _v1.a;
								var remaining = _v1.b;
								return _Utils_Tuple2(
									A2(
										$elm$core$List$cons,
										$elm$core$List$reverse(currentArg),
										args),
									remaining);
							default:
								break _v0$3;
						}
					} else {
						break _v0$3;
					}
				}
			}
			var token = tokens.a;
			var rest = tokens.b;
			var $temp$tokens = rest,
				$temp$currentArg = A2($elm$core$List$cons, token, currentArg);
			tokens = $temp$tokens;
			currentArg = $temp$currentArg;
			continue extractParenArgs;
		}
	});
var $author$project$ETeX$Transform$needsBraceConversion = function (cmd) {
	return A2(
		$elm$core$List$member,
		cmd,
		_List_fromArray(
			['frac', 'binom', 'overset', 'underset', 'stackrel', 'tfrac', 'dfrac', 'cfrac', 'dbinom', 'tbinom']));
};
var $author$project$ETeX$Transform$processTokensWithLookahead = F2(
	function (knownMacros, tokens) {
		_v0$4:
		while (true) {
			if (!tokens.b) {
				return _List_Nil;
			} else {
				if (!tokens.a.$) {
					if (tokens.b.b) {
						switch (tokens.b.a.$) {
							case 2:
								if (tokens.b.b.b && (!tokens.b.b.a.$)) {
									var word1 = tokens.a.a;
									var _v1 = tokens.b;
									var space = _v1.a.a;
									var _v2 = _v1.b;
									var word2 = _v2.a.a;
									var rest = _v2.b;
									return ((word1 === 'mathbb') && ($elm$core$String$length(word2) === 1)) ? A2(
										$elm$core$List$cons,
										$author$project$ETeX$Transform$SimpleWord('\\mathbb'),
										A2(
											$elm$core$List$cons,
											A2($author$project$ETeX$Transform$SimpleBrace, '{', word2),
											A2($author$project$ETeX$Transform$processTokensWithLookahead, knownMacros, rest))) : A2(
										$elm$core$List$cons,
										$author$project$ETeX$Transform$SimpleWord(word1),
										A2(
											$elm$core$List$cons,
											$author$project$ETeX$Transform$SimpleSpace(space),
											A2(
												$author$project$ETeX$Transform$processTokensWithLookahead,
												knownMacros,
												A2(
													$elm$core$List$cons,
													$author$project$ETeX$Transform$SimpleWord(word2),
													rest))));
								} else {
									break _v0$4;
								}
							case 3:
								switch (tokens.b.a.a) {
									case '^':
										var word = tokens.a.a;
										var _v3 = tokens.b;
										var rest = _v3.b;
										return ($author$project$ETeX$KaTeX$isKaTeX(word) || A2($elm$core$List$member, word, knownMacros)) ? A2(
											$elm$core$List$cons,
											$author$project$ETeX$Transform$SimpleWord('\\' + word),
											A2(
												$elm$core$List$cons,
												$author$project$ETeX$Transform$SimpleSymbol('^'),
												A2($author$project$ETeX$Transform$processTokensWithLookahead, knownMacros, rest))) : A2(
											$elm$core$List$cons,
											$author$project$ETeX$Transform$SimpleWord(word),
											A2(
												$elm$core$List$cons,
												$author$project$ETeX$Transform$SimpleSymbol('^'),
												A2($author$project$ETeX$Transform$processTokensWithLookahead, knownMacros, rest)));
									case '(':
										var word = tokens.a.a;
										var _v4 = tokens.b;
										var rest = _v4.b;
										if ($author$project$ETeX$KaTeX$isKaTeX(word) && $author$project$ETeX$Transform$needsBraceConversion(word)) {
											var _v5 = A2($author$project$ETeX$Transform$extractParenArgs, rest, _List_Nil);
											var args = _v5.a;
											var remaining = _v5.b;
											var processedArgs = A2(
												$elm$core$List$map,
												$author$project$ETeX$Transform$processTokensWithLookahead(knownMacros),
												args);
											return A2(
												$elm$core$List$cons,
												$author$project$ETeX$Transform$SimpleWord('\\' + word),
												_Utils_ap(
													$author$project$ETeX$Transform$convertArgsToBraces(processedArgs),
													A2($author$project$ETeX$Transform$processTokensWithLookahead, knownMacros, remaining)));
										} else {
											if ($author$project$ETeX$KaTeX$isKaTeX(word)) {
												return A2(
													$elm$core$List$cons,
													$author$project$ETeX$Transform$SimpleWord('\\' + word),
													A2(
														$elm$core$List$cons,
														$author$project$ETeX$Transform$SimpleSymbol('('),
														A2($author$project$ETeX$Transform$processTokensWithLookahead, knownMacros, rest)));
											} else {
												if (A2($elm$core$List$member, word, knownMacros)) {
													return A2(
														$elm$core$List$cons,
														$author$project$ETeX$Transform$SimpleWord('\\' + word),
														A2(
															$elm$core$List$cons,
															$author$project$ETeX$Transform$SimpleSymbol('('),
															A2($author$project$ETeX$Transform$processTokensWithLookahead, knownMacros, rest)));
												} else {
													return A2(
														$elm$core$List$cons,
														$author$project$ETeX$Transform$SimpleWord(word),
														A2(
															$elm$core$List$cons,
															$author$project$ETeX$Transform$SimpleSymbol('('),
															A2($author$project$ETeX$Transform$processTokensWithLookahead, knownMacros, rest)));
												}
											}
										}
									default:
										break _v0$4;
								}
							default:
								break _v0$4;
						}
					} else {
						break _v0$4;
					}
				} else {
					var token = tokens.a;
					var rest = tokens.b;
					return A2(
						$elm$core$List$cons,
						token,
						A2($author$project$ETeX$Transform$processTokensWithLookahead, knownMacros, rest));
				}
			}
		}
		var word = tokens.a.a;
		var rest = tokens.b;
		return ($author$project$ETeX$KaTeX$isKaTeX(word) || A2($elm$core$List$member, word, knownMacros)) ? A2(
			$elm$core$List$cons,
			$author$project$ETeX$Transform$SimpleWord('\\' + word),
			A2($author$project$ETeX$Transform$processTokensWithLookahead, knownMacros, rest)) : A2(
			$elm$core$List$cons,
			$author$project$ETeX$Transform$SimpleWord(word),
			A2($author$project$ETeX$Transform$processTokensWithLookahead, knownMacros, rest));
	});
var $author$project$ETeX$Transform$SimpleBackslash = {$: 1};
var $author$project$ETeX$Transform$SimpleParam = function (a) {
	return {$: 5, a: a};
};
var $author$project$ETeX$Transform$collectUntilCloseBrace = F3(
	function (chars, depth, acc) {
		collectUntilCloseBrace:
		while (true) {
			if (!chars.b) {
				return _Utils_Tuple2(
					$elm$core$List$reverse(acc),
					_List_Nil);
			} else {
				switch (chars.a) {
					case '{':
						var rest = chars.b;
						var $temp$chars = rest,
							$temp$depth = depth + 1,
							$temp$acc = A2($elm$core$List$cons, '{', acc);
						chars = $temp$chars;
						depth = $temp$depth;
						acc = $temp$acc;
						continue collectUntilCloseBrace;
					case '}':
						var rest = chars.b;
						if (depth === 1) {
							return _Utils_Tuple2(
								$elm$core$List$reverse(acc),
								rest);
						} else {
							var $temp$chars = rest,
								$temp$depth = depth - 1,
								$temp$acc = A2($elm$core$List$cons, '}', acc);
							chars = $temp$chars;
							depth = $temp$depth;
							acc = $temp$acc;
							continue collectUntilCloseBrace;
						}
					default:
						var c = chars.a;
						var rest = chars.b;
						var $temp$chars = rest,
							$temp$depth = depth,
							$temp$acc = A2($elm$core$List$cons, c, acc);
						chars = $temp$chars;
						depth = $temp$depth;
						acc = $temp$acc;
						continue collectUntilCloseBrace;
				}
			}
		}
	});
var $elm$core$String$cons = _String_cons;
var $elm$core$String$fromChar = function (_char) {
	return A2($elm$core$String$cons, _char, '');
};
var $elm$core$String$fromList = _String_fromList;
var $author$project$ETeX$Transform$takeAlphas = function (chars) {
	if (!chars.b) {
		return _Utils_Tuple2(_List_Nil, _List_Nil);
	} else {
		var c = chars.a;
		var rest = chars.b;
		if ($elm$core$Char$isAlpha(c)) {
			var _v1 = $author$project$ETeX$Transform$takeAlphas(rest);
			var alphas = _v1.a;
			var remaining = _v1.b;
			return _Utils_Tuple2(
				A2($elm$core$List$cons, c, alphas),
				remaining);
		} else {
			return _Utils_Tuple2(_List_Nil, chars);
		}
	}
};
var $author$project$ETeX$Transform$takeDigits = function (chars) {
	if (!chars.b) {
		return _Utils_Tuple2(_List_Nil, _List_Nil);
	} else {
		var c = chars.a;
		var rest = chars.b;
		if ($elm$core$Char$isDigit(c)) {
			var _v1 = $author$project$ETeX$Transform$takeDigits(rest);
			var digits = _v1.a;
			var remaining = _v1.b;
			return _Utils_Tuple2(
				A2($elm$core$List$cons, c, digits),
				remaining);
		} else {
			return _Utils_Tuple2(_List_Nil, chars);
		}
	}
};
var $author$project$ETeX$Transform$takeSpaces = function (chars) {
	if (!chars.b) {
		return _Utils_Tuple2(_List_Nil, _List_Nil);
	} else {
		var c = chars.a;
		var rest = chars.b;
		if ((c === ' ') || ((c === '\t') || (c === '\n'))) {
			var _v1 = $author$project$ETeX$Transform$takeSpaces(rest);
			var spaces = _v1.a;
			var remaining = _v1.b;
			return _Utils_Tuple2(
				A2($elm$core$List$cons, c, spaces),
				remaining);
		} else {
			return _Utils_Tuple2(_List_Nil, chars);
		}
	}
};
var $author$project$ETeX$Transform$tokenizeHelper = F2(
	function (chars, acc) {
		tokenizeHelper:
		while (true) {
			if (!chars.b) {
				return acc;
			} else {
				switch (chars.a) {
					case '\\':
						var rest = chars.b;
						var $temp$chars = rest,
							$temp$acc = A2($elm$core$List$cons, $author$project$ETeX$Transform$SimpleBackslash, acc);
						chars = $temp$chars;
						acc = $temp$acc;
						continue tokenizeHelper;
					case '#':
						var rest = chars.b;
						var _v1 = $author$project$ETeX$Transform$takeDigits(rest);
						var digits = _v1.a;
						var remaining = _v1.b;
						var _v2 = $elm$core$String$toInt(
							$elm$core$String$fromList(digits));
						if (!_v2.$) {
							var n = _v2.a;
							var $temp$chars = remaining,
								$temp$acc = A2(
								$elm$core$List$cons,
								$author$project$ETeX$Transform$SimpleParam(n),
								acc);
							chars = $temp$chars;
							acc = $temp$acc;
							continue tokenizeHelper;
						} else {
							var $temp$chars = rest,
								$temp$acc = A2(
								$elm$core$List$cons,
								$author$project$ETeX$Transform$SimpleSymbol('#'),
								acc);
							chars = $temp$chars;
							acc = $temp$acc;
							continue tokenizeHelper;
						}
					case '{':
						var rest = chars.b;
						var _v3 = A3($author$project$ETeX$Transform$collectUntilCloseBrace, rest, 1, _List_Nil);
						var content = _v3.a;
						var remaining = _v3.b;
						var $temp$chars = remaining,
							$temp$acc = A2(
							$elm$core$List$cons,
							A2(
								$author$project$ETeX$Transform$SimpleBrace,
								'{',
								$elm$core$String$fromList(content)),
							acc);
						chars = $temp$chars;
						acc = $temp$acc;
						continue tokenizeHelper;
					default:
						var c = chars.a;
						var rest = chars.b;
						if ($elm$core$Char$isAlpha(c)) {
							var _v4 = $author$project$ETeX$Transform$takeAlphas(
								A2($elm$core$List$cons, c, rest));
							var word = _v4.a;
							var remaining = _v4.b;
							var $temp$chars = remaining,
								$temp$acc = A2(
								$elm$core$List$cons,
								$author$project$ETeX$Transform$SimpleWord(
									$elm$core$String$fromList(word)),
								acc);
							chars = $temp$chars;
							acc = $temp$acc;
							continue tokenizeHelper;
						} else {
							if ((c === ' ') || ((c === '\t') || (c === '\n'))) {
								var _v5 = $author$project$ETeX$Transform$takeSpaces(
									A2($elm$core$List$cons, c, rest));
								var spaces = _v5.a;
								var remaining = _v5.b;
								var $temp$chars = remaining,
									$temp$acc = A2(
									$elm$core$List$cons,
									$author$project$ETeX$Transform$SimpleSpace(
										$elm$core$String$fromList(spaces)),
									acc);
								chars = $temp$chars;
								acc = $temp$acc;
								continue tokenizeHelper;
							} else {
								var $temp$chars = rest,
									$temp$acc = A2(
									$elm$core$List$cons,
									$author$project$ETeX$Transform$SimpleSymbol(
										$elm$core$String$fromChar(c)),
									acc);
								chars = $temp$chars;
								acc = $temp$acc;
								continue tokenizeHelper;
							}
						}
				}
			}
		}
	});
var $author$project$ETeX$Transform$tokenizeSimpleMacroBody = function (body) {
	return $elm$core$List$reverse(
		A2(
			$author$project$ETeX$Transform$tokenizeHelper,
			$elm$core$String$toList(body),
			_List_Nil));
};
var $author$project$ETeX$Transform$processSimpleMacroBodyWithContext = F2(
	function (knownMacros, body) {
		return $elm$core$String$concat(
			A2(
				$elm$core$List$map,
				$author$project$ETeX$Transform$tokenToString,
				A2(
					$author$project$ETeX$Transform$processTokensWithLookahead,
					knownMacros,
					$author$project$ETeX$Transform$tokenizeSimpleMacroBody(body))));
	});
var $author$project$ETeX$Transform$parseSimpleMacroWithContext = F2(
	function (knownMacros, line) {
		var _v0 = A2($elm$core$String$split, ':', line);
		if ((_v0.b && _v0.b.b) && (!_v0.b.b.b)) {
			var name = _v0.a;
			var _v1 = _v0.b;
			var body = _v1.a;
			var trimmedName = $elm$core$String$trim(name);
			var trimmedBody = $elm$core$String$trim(body);
			var processedBody = A2($author$project$ETeX$Transform$processSimpleMacroBodyWithContext, knownMacros, trimmedBody);
			var newCommandStr = '\\newcommand{\\' + (trimmedName + ('}{' + (processedBody + '}')));
			return $author$project$ETeX$Transform$makeEntry(
				A2($author$project$ETeX$Transform$parseNewCommand, $elm$core$Dict$empty, newCommandStr));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$ETeX$Transform$addMixedFormatMacro = F2(
	function (line, dict) {
		var knownMacros = $elm$core$Dict$keys(dict);
		if (A2($elm$core$String$startsWith, '\\newcommand', line)) {
			var _v0 = $author$project$ETeX$Transform$makeEntry(
				A2($author$project$ETeX$Transform$parseNewCommand, $elm$core$Dict$empty, line));
			if (!_v0.$) {
				var _v1 = _v0.a;
				var name = _v1.a;
				var body = _v1.b;
				return A3($elm$core$Dict$insert, name, body, dict);
			} else {
				return dict;
			}
		} else {
			if (A2($elm$core$String$contains, ':', line)) {
				var _v2 = A2($author$project$ETeX$Transform$parseSimpleMacroWithContext, knownMacros, line);
				if (!_v2.$) {
					var _v3 = _v2.a;
					var name = _v3.a;
					var body = _v3.b;
					return A3($elm$core$Dict$insert, name, body, dict);
				} else {
					return dict;
				}
			} else {
				return dict;
			}
		}
	});
var $author$project$ETeX$Transform$makeMacroDictFromMixedLines = function (lines) {
	return A3($elm$core$List$foldl, $author$project$ETeX$Transform$addMixedFormatMacro, $elm$core$Dict$empty, lines);
};
var $author$project$ETeX$Transform$makeMacroDict = function (str) {
	return $author$project$ETeX$Transform$makeMacroDictFromMixedLines(
		A2(
			$elm$core$List$filter,
			A2($elm$core$Basics$composeL, $elm$core$Basics$not, $elm$core$String$isEmpty),
			A2(
				$elm$core$List$map,
				$elm$core$String$trim,
				$elm$core$String$lines(
					$elm$core$String$trim(str)))));
};
var $author$project$Generic$Acc$makeMathMacroDict = function (content) {
	return $author$project$ETeX$Transform$makeMacroDict(content);
};
var $elm$core$String$replace = F3(
	function (before, after, string) {
		return A2(
			$elm$core$String$join,
			after,
			A2($elm$core$String$split, before, string));
	});
var $author$project$Generic$Acc$updateWithMathMacros = F2(
	function (content, accumulator) {
		var definitions = $elm$core$String$trim(
			function (str) {
				return str + '\nbracket: {[ #1 ]}';
			}(
				A3(
					$elm$core$String$replace,
					'end',
					'',
					A3(
						$elm$core$String$replace,
						'\\end{mathmacros}',
						'',
						A3($elm$core$String$replace, '\\begin{mathmacros}', '', content)))));
		var mathMacroDict = $author$project$Generic$Acc$makeMathMacroDict(
			$elm$core$String$trim(definitions));
		return _Utils_update(
			accumulator,
			{b9: mathMacroDict});
	});
var $author$project$Generic$Acc$init = function (data) {
	return A2(
		$author$project$Generic$Acc$updateWithMathMacros,
		data.bv,
		{
			ar: $elm$core$Dict$empty,
			N: 0,
			h: data.h,
			p: $elm$core$Dict$empty,
			bg: function () {
				var _v0 = data.bn;
				if (_v0.$ === 1) {
					return 0;
				} else {
					return 1;
				}
			}(),
			aP: $author$project$Generic$Vector$init(data.aE),
			bq: $elm$core$Dict$empty,
			br: $elm$core$Dict$empty,
			f: function () {
				var _v1 = data.bn;
				if (_v1.$ === 1) {
					return $author$project$Generic$Vector$init(data.aE);
				} else {
					var n = _v1.a;
					return A3(
						$author$project$Generic$Vector$set,
						0,
						n + 1,
						$author$project$Generic$Vector$init(data.aE));
				}
			}(),
			z: 1,
			aS: $author$project$Generic$Vector$init(data.aE),
			Q: $elm$core$Dict$empty,
			b9: $elm$core$Dict$empty,
			F: $author$project$Generic$Acc$initialData.F,
			cb: $author$project$Generic$Settings$numberedBlockNames,
			by: $elm$core$Dict$empty,
			bB: $elm$core$Dict$empty,
			bk: _List_Nil,
			aW: $elm$core$Dict$empty,
			bI: $elm$core$Dict$empty,
			bJ: $elm$core$Dict$empty
		});
};
var $author$project$Generic$Acc$mapper = F2(
	function (ast_, _v0) {
		var acc_ = _v0.a;
		var tree_ = _v0.b;
		return _Utils_Tuple2(
			acc_,
			A2($elm$core$List$cons, tree_, ast_));
	});
var $author$project$Generic$Acc$reverse = function (list) {
	return $elm$core$List$reverse(list);
};
var $author$project$Generic$Acc$mapAccumulate = F3(
	function (f, s, tree) {
		var _v0 = A2(
			f,
			s,
			$maca$elm_rose_tree$RoseTree$Tree$value(tree));
		var s_ = _v0.a;
		var value_ = _v0.b;
		var _v1 = A3(
			$elm$core$List$foldl,
			F2(
				function (child, _v2) {
					var accState = _v2.a;
					var accChildren = _v2.b;
					var _v3 = A3($author$project$Generic$Acc$mapAccumulate, f, accState, child);
					var newState = _v3.a;
					var newChild = _v3.b;
					return _Utils_Tuple2(
						newState,
						A2($elm$core$List$cons, newChild, accChildren));
				}),
			_Utils_Tuple2(s_, _List_Nil),
			$maca$elm_rose_tree$RoseTree$Tree$children(tree));
		var s__ = _v1.a;
		var children_ = _v1.b;
		return _Utils_Tuple2(
			s__,
			A2(
				$maca$elm_rose_tree$RoseTree$Tree$branch,
				value_,
				$author$project$Generic$Acc$reverse(children_)));
	});
var $author$project$Generic$ASTTools$filterExprs = F2(
	function (predicate, list) {
		return A2($elm$core$List$filter, predicate, list);
	});
var $author$project$Generic$ASTTools$isBlank = function (expr) {
	if (!expr.$) {
		var content = expr.a;
		return $elm$core$String$trim(content) === '';
	} else {
		return false;
	}
};
var $author$project$Generic$TextMacro$filterOutBlanks = $author$project$Generic$ASTTools$filterExprs(
	function (e) {
		return !$author$project$Generic$ASTTools$isBlank(e);
	});
var $author$project$Generic$TextMacro$dummy = {aq: 0, au: 0, e: 'dummyId', b1: 0};
var $author$project$Generic$TextMacro$group = function (exprs) {
	return A3($author$project$V3$Types$Fun, 'group', exprs, $author$project$Generic$TextMacro$dummy);
};
var $elm$core$List$intersperse = F2(
	function (sep, xs) {
		if (!xs.b) {
			return _List_Nil;
		} else {
			var hd = xs.a;
			var tl = xs.b;
			var step = F2(
				function (x, rest) {
					return A2(
						$elm$core$List$cons,
						sep,
						A2($elm$core$List$cons, x, rest));
				});
			var spersed = A3($elm$core$List$foldr, step, _List_Nil, tl);
			return A2($elm$core$List$cons, hd, spersed);
		}
	});
var $author$project$Generic$TextMacro$subst = F3(
	function (a, _var, body) {
		switch (body.$) {
			case 0:
				var str = body.a;
				if (_Utils_eq(
					$elm$core$String$trim(str),
					$elm$core$String$trim(_var))) {
					return a;
				} else {
					if (A2($elm$core$String$contains, _var, str)) {
						var parts = A2(
							$elm$core$List$map,
							function (s) {
								return A2($author$project$V3$Types$Text, s, $author$project$Generic$TextMacro$dummy);
							},
							A2($elm$core$String$split, _var, str));
						return $author$project$Generic$TextMacro$group(
							A2($elm$core$List$intersperse, a, parts));
					} else {
						return body;
					}
				}
			case 1:
				var name = body.a;
				var exprs = body.b;
				var meta = body.c;
				return A3(
					$author$project$V3$Types$Fun,
					name,
					A2(
						$elm$core$List$map,
						A2($author$project$Generic$TextMacro$subst, a, _var),
						exprs),
					meta);
			default:
				return body;
		}
	});
var $author$project$Generic$TextMacro$makeF = F2(
	function (a, _var) {
		return $elm$core$List$map(
			A2($author$project$Generic$TextMacro$subst, a, _var));
	});
var $author$project$Generic$TextMacro$listSubst = F3(
	function (as_, vars, exprs) {
		if (!_Utils_eq(
			$elm$core$List$length(as_),
			$elm$core$List$length(vars))) {
			return exprs;
		} else {
			var funcs = A3($elm$core$List$map2, $author$project$Generic$TextMacro$makeF, as_, vars);
			return A3(
				$elm$core$List$foldl,
				F2(
					function (func, acc) {
						return func(acc);
					}),
				exprs,
				funcs);
		}
	});
var $author$project$Generic$TextMacro$expandWithMacro = F2(
	function (macro, expr) {
		if (expr.$ === 1) {
			var name = expr.a;
			var fArgs = expr.b;
			return _Utils_eq(name, macro.M) ? $author$project$Generic$TextMacro$group(
				A3(
					$author$project$Generic$TextMacro$listSubst,
					$author$project$Generic$TextMacro$filterOutBlanks(fArgs),
					macro.ba,
					macro.bO)) : expr;
		} else {
			return expr;
		}
	});
var $author$project$Generic$TextMacro$expand = F2(
	function (dict, expr) {
		if (expr.$ === 1) {
			var name = expr.a;
			var _v1 = A2($elm$core$Dict$get, name, dict);
			if (_v1.$ === 1) {
				return expr;
			} else {
				var macro = _v1.a;
				return A2($author$project$Generic$TextMacro$expandWithMacro, macro, expr);
			}
		} else {
			return expr;
		}
	});
var $toastal$either$Either$map = F2(
	function (f, e) {
		if (e.$ === 1) {
			var b = e.a;
			return $toastal$either$Either$Right(
				f(b));
		} else {
			var a = e.a;
			return $toastal$either$Either$Left(a);
		}
	});
var $author$project$Generic$Acc$expand = F2(
	function (dict, block) {
		return _Utils_update(
			block,
			{
				bO: A2(
					$toastal$either$Either$map,
					$elm$core$List$map(
						$author$project$Generic$TextMacro$expand(dict)),
					block.bO)
			});
	});
var $author$project$Generic$Acc$getCounterAsString = F2(
	function (name, dict) {
		return A2(
			$elm$core$Maybe$withDefault,
			'',
			A2(
				$elm$core$Maybe$map,
				$elm$core$String$fromInt,
				A2($elm$core$Dict$get, name, dict)));
	});
var $author$project$Generic$Acc$getNameFromHeading = function (heading) {
	switch (heading.$) {
		case 0:
			return $elm$core$Maybe$Nothing;
		case 1:
			var name = heading.a;
			return $elm$core$Maybe$Just(name);
		default:
			var name = heading.a;
			return $elm$core$Maybe$Just(name);
	}
};
var $author$project$Generic$ASTTools$getText = function (expression) {
	switch (expression.$) {
		case 0:
			var str = expression.a;
			return $elm$core$Maybe$Just(str);
		case 2:
			var str = expression.b;
			return $elm$core$Maybe$Just(
				A3($elm$core$String$replace, '`', '', str));
		case 1:
			var expressions = expression.b;
			return $elm$core$Maybe$Just(
				A2(
					$elm$core$String$join,
					' ',
					A2($elm$core$List$filterMap, $author$project$Generic$ASTTools$getText, expressions)));
		default:
			return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Generic$Acc$itemsNotNumbered = _List_fromArray(
	['preface', 'introduction', 'appendix', 'references', 'index', 'scratch']);
var $elm$core$String$filter = _String_filter;
var $author$project$Tools$String$isSlugChar = function (c) {
	return $elm$core$Char$isAlphaNum(c) || ((c === '-') || (c === '_'));
};
var $elm$core$String$toLower = _String_toLower;
var $author$project$Tools$String$makeSlug = function (str) {
	return A2(
		$elm$core$String$filter,
		$author$project$Tools$String$isSlugChar,
		A3(
			$elm$core$String$replace,
			' ',
			'-',
			$elm$core$String$trim(
				$elm$core$String$toLower(str))));
};
var $author$project$Generic$Acc$parseKeyValueLine = function (line) {
	var _v0 = A2($elm$core$String$split, ':', line);
	if (_v0.b) {
		var key = _v0.a;
		var rest = _v0.b;
		var value = $elm$core$String$trim(
			A2($elm$core$String$join, ':', rest));
		var trimmedKey = $elm$core$String$trim(key);
		return (trimmedKey !== '') ? $elm$core$Maybe$Just(
			_Utils_Tuple2(trimmedKey, value)) : $elm$core$Maybe$Nothing;
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Generic$Acc$parseKeyValueBody = function (block) {
	var _v0 = block.bO;
	if (!_v0.$) {
		var content = _v0.a;
		return $elm$core$Dict$fromList(
			A2(
				$elm$core$List$filterMap,
				$author$project$Generic$Acc$parseKeyValueLine,
				$elm$core$String$lines(content)));
	} else {
		return $elm$core$Dict$empty;
	}
};
var $author$project$Generic$Vector$toString = function (v) {
	return A2(
		$elm$core$String$join,
		'.',
		A2(
			$elm$core$List$map,
			$elm$core$String$fromInt,
			A2(
				$elm$core$List$filter,
				function (x) {
					return x > 0;
				},
				v.aL)));
};
var $author$project$Generic$Vector$toStringWithLevel = F2(
	function (lev, v) {
		return A2(
			$elm$core$String$join,
			'.',
			A2(
				$elm$core$List$map,
				$elm$core$String$fromInt,
				A2(
					$elm$core$List$filter,
					function (x) {
						return x > 0;
					},
					A2(
						$elm$core$List$indexedMap,
						F2(
							function (idx, k) {
								return (_Utils_cmp(idx, lev) < 0) ? k : 0;
							}),
						v.aL))));
	});
var $elm_community$maybe_extra$Maybe$Extra$cons = F2(
	function (item, list) {
		if (!item.$) {
			var v = item.a;
			return A2($elm$core$List$cons, v, list);
		} else {
			return list;
		}
	});
var $elm_community$maybe_extra$Maybe$Extra$values = A2($elm$core$List$foldr, $elm_community$maybe_extra$Maybe$Extra$cons, _List_Nil);
var $author$project$Generic$Acc$transformBlock = F2(
	function (acc, block) {
		var _v0 = _Utils_Tuple2(block.P, block.cF);
		_v0$12:
		while (true) {
			switch (_v0.a.$) {
				case 1:
					switch (_v0.a.a) {
						case 'section':
							var chapterPart = (acc.h > 0) ? ($elm$core$String$fromInt(acc.h) + '.') : '';
							return _Utils_update(
								block,
								{
									c: A3(
										$elm$core$Dict$insert,
										'tag',
										$author$project$Tools$String$makeSlug(block.cT),
										A3(
											$elm$core$Dict$insert,
											'label',
											_Utils_ap(
												chapterPart,
												$author$project$Generic$Vector$toString(acc.f)),
											block.c))
								});
						case 'chapter':
							var tag = function () {
								var _v1 = block.bO;
								if (!_v1.$) {
									var str = _v1.a;
									return $author$project$Tools$String$makeSlug(str);
								} else {
									var expr = _v1.a;
									return $author$project$Tools$String$makeSlug(
										A2(
											$elm$core$String$join,
											'-',
											$elm_community$maybe_extra$Maybe$Extra$values(
												A2($elm$core$List$map, $author$project$Generic$ASTTools$getText, expr))));
								}
							}();
							return _Utils_update(
								block,
								{
									c: A3(
										$elm$core$Dict$insert,
										'level',
										'0',
										A3(
											$elm$core$Dict$insert,
											'chapter-number',
											$elm$core$String$fromInt(acc.h),
											A3(
												$elm$core$Dict$insert,
												'tag',
												tag,
												A3(
													$elm$core$Dict$insert,
													'label',
													$elm$core$String$fromInt(acc.h),
													block.c))))
								});
						case 'quiver':
							return _Utils_update(
								block,
								{
									c: A3(
										$elm$core$Dict$insert,
										'figure',
										A2($author$project$Generic$Acc$getCounterAsString, 'figure', acc.p),
										block.c)
								});
						case 'chart':
							return _Utils_update(
								block,
								{
									c: A3(
										$elm$core$Dict$insert,
										'figure',
										A2($author$project$Generic$Acc$getCounterAsString, 'figure', acc.p),
										block.c)
								});
						case 'image':
							return _Utils_update(
								block,
								{
									c: A3(
										$elm$core$Dict$insert,
										'figure',
										A2($author$project$Generic$Acc$getCounterAsString, 'figure', acc.p),
										block.c)
								});
						case 'iframe':
							return _Utils_update(
								block,
								{
									c: A3(
										$elm$core$Dict$insert,
										'figure',
										A2($author$project$Generic$Acc$getCounterAsString, 'figure', acc.p),
										block.c)
								});
						case 'document':
							var title = function () {
								var _v2 = block.bO;
								if (!_v2.$) {
									var str = _v2.a;
									return str;
								} else {
									var expr = _v2.a;
									return A2(
										$elm$core$String$join,
										' ',
										$elm_community$maybe_extra$Maybe$Extra$values(
											A2($elm$core$List$map, $author$project$Generic$ASTTools$getText, expr)));
								}
							}();
							var label = A2(
								$elm$core$List$member,
								$elm$core$String$toLower(title),
								$author$project$Generic$Acc$itemsNotNumbered) ? '' : $author$project$Generic$Vector$toString(acc.aP);
							return _Utils_update(
								block,
								{
									c: A3($elm$core$Dict$insert, 'label', label, block.c)
								});
						default:
							break _v0$12;
					}
				case 2:
					switch (_v0.a.a) {
						case 'math':
							var args = _v0.b;
							if (A2($elm$core$Dict$member, 'label', block.c)) {
								var sectionPart = A2($author$project$Generic$Vector$toStringWithLevel, acc.F, acc.f);
								var punctuation = (sectionPart !== '') ? '.' : '';
								var chapterPart = (acc.h > 0) ? ($elm$core$String$fromInt(acc.h) + '.') : '';
								var equationProp = _Utils_ap(
									chapterPart,
									_Utils_ap(
										sectionPart,
										_Utils_ap(
											punctuation,
											A2($author$project$Generic$Acc$getCounterAsString, 'equation', acc.p))));
								return _Utils_update(
									block,
									{
										c: A3($elm$core$Dict$insert, 'equation-number', equationProp, block.c)
									});
							} else {
								return block;
							}
						case 'equation':
							var args = _v0.b;
							if (A2($elm$core$Dict$member, 'label', block.c)) {
								var sectionPart = A2($author$project$Generic$Vector$toStringWithLevel, acc.F, acc.f);
								var punctuation = (sectionPart !== '') ? '.' : '';
								var chapterPart = (acc.h > 0) ? ($elm$core$String$fromInt(acc.h) + '.') : '';
								var equationProp = _Utils_ap(
									chapterPart,
									_Utils_ap(
										sectionPart,
										_Utils_ap(
											punctuation,
											A2($author$project$Generic$Acc$getCounterAsString, 'equation', acc.p))));
								return _Utils_update(
									block,
									{
										c: A3($elm$core$Dict$insert, 'equation-number', equationProp, block.c)
									});
							} else {
								return block;
							}
						case 'aligned':
							if (A2($elm$core$Dict$member, 'label', block.c)) {
								var sectionPart = A2($author$project$Generic$Vector$toStringWithLevel, acc.F, acc.f);
								var punctuation = (sectionPart !== '') ? '.' : '';
								var chapterPart = (acc.h > 0) ? ($elm$core$String$fromInt(acc.h) + '.') : '';
								var equationProp = _Utils_ap(
									chapterPart,
									_Utils_ap(
										sectionPart,
										_Utils_ap(
											punctuation,
											A2($author$project$Generic$Acc$getCounterAsString, 'equation', acc.p))));
								return _Utils_update(
									block,
									{
										c: A3($elm$core$Dict$insert, 'equation-number', equationProp, block.c)
									});
							} else {
								return block;
							}
						case 'book':
							return _Utils_update(
								block,
								{
									c: A2(
										$elm$core$Dict$union,
										$author$project$Generic$Acc$parseKeyValueBody(block),
										block.c)
								});
						case 'article':
							return _Utils_update(
								block,
								{
									c: A2(
										$elm$core$Dict$union,
										$author$project$Generic$Acc$parseKeyValueBody(block),
										block.c)
								});
						default:
							break _v0$12;
					}
				default:
					break _v0$12;
			}
		}
		var heading = _v0.a;
		var _v3 = $author$project$Generic$Acc$getNameFromHeading(heading);
		if (_v3.$ === 1) {
			return block;
		} else {
			var name = _v3.a;
			if (name === 'section') {
				var prefix = $author$project$Generic$Vector$toString(acc.f);
				var equationProp = (prefix === '') ? A2($author$project$Generic$Acc$getCounterAsString, 'equation', acc.p) : ($author$project$Generic$Vector$toString(acc.f) + ('.' + A2($author$project$Generic$Acc$getCounterAsString, 'equation', acc.p)));
				return _Utils_update(
					block,
					{
						c: A3($elm$core$Dict$insert, 'label', equationProp, block.c)
					});
			} else {
				var sectionPart = A2($author$project$Generic$Vector$toStringWithLevel, acc.F, acc.f);
				var punctuation = (sectionPart !== '') ? '.' : '';
				var chapterPart = (acc.h > 0) ? ($elm$core$String$fromInt(acc.h) + '.') : '';
				var label = _Utils_ap(
					chapterPart,
					_Utils_ap(
						sectionPart,
						_Utils_ap(
							punctuation,
							$elm$core$String$fromInt(acc.N))));
				return A2(
					$author$project$Generic$Acc$expand,
					acc.bJ,
					A2($elm$core$List$member, name, $author$project$Generic$Settings$numberedBlockNames) ? _Utils_update(
						block,
						{
							c: A3($elm$core$Dict$insert, 'label', label, block.c)
						}) : block);
			}
		}
	});
var $elm$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		if (!maybeValue.$) {
			var value = maybeValue.a;
			return callback(value);
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$Generic$Acc$getNameContentId = function (block) {
	var name = $author$project$Generic$Acc$getNameFromHeading(block.P);
	var id = $elm$core$Maybe$Just(block.A.e);
	var content = $elm$core$Maybe$Just(block.bO);
	var _v0 = _Utils_Tuple3(name, content, id);
	if (((!_v0.a.$) && (!_v0.b.$)) && (!_v0.c.$)) {
		var name_ = _v0.a.a;
		var content_ = _v0.b.a;
		var id_ = _v0.c.a;
		return $elm$core$Maybe$Just(
			{aL: content_, e: id_, M: name_});
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Generic$Acc$getNameContentIdTag = function (block) {
	var name = A2($elm$core$Dict$get, 'name', block.c);
	var id = block.A.e;
	var tag = A2(
		$elm$core$Maybe$withDefault,
		id,
		A2($elm$core$Dict$get, 'tag', block.c));
	var content = block.bO;
	if (name.$ === 1) {
		return $elm$core$Maybe$Nothing;
	} else {
		var name_ = name.a;
		return $elm$core$Maybe$Just(
			{aL: block.bO, e: id, M: name_, an: tag});
	}
};
var $author$project$Generic$Acc$getVerbatimContent = function (block) {
	var _v0 = block.bO;
	if (!_v0.$) {
		var str = _v0.a;
		return $elm$core$Maybe$Just(str);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Generic$Acc$makeReferenceDatum = F3(
	function (id, tag, numRef) {
		return {e: id, aB: numRef, an: tag};
	});
var $author$project$V3$Types$InList = 0;
var $author$project$Generic$Acc$nextInListState = F2(
	function (heading, state) {
		var _v0 = _Utils_Tuple2(state, heading);
		if (_v0.a === 1) {
			if ((_v0.b.$ === 1) && (_v0.b.a === 'numbered')) {
				var _v1 = _v0.a;
				return 0;
			} else {
				var _v2 = _v0.a;
				return 1;
			}
		} else {
			if ((_v0.b.$ === 1) && (_v0.b.a === 'numbered')) {
				var _v3 = _v0.a;
				return 0;
			} else {
				var _v4 = _v0.a;
				return 1;
			}
		}
	});
var $elm$core$Dict$values = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return A2($elm$core$List$cons, value, valueList);
			}),
		_List_Nil,
		dict);
};
var $author$project$Generic$Acc$updateBibItemBlock = F3(
	function (accumulator, args, id) {
		var _v0 = $elm$core$List$head(args);
		if (_v0.$ === 1) {
			return accumulator;
		} else {
			var label = _v0.a;
			var nextNumber = 1 + $elm$core$List$length(
				A2(
					$elm$core$List$filterMap,
					$elm$core$Basics$identity,
					$elm$core$Dict$values(accumulator.ar)));
			var newBibliography = A3(
				$elm$core$Dict$insert,
				label,
				$elm$core$Maybe$Just(nextNumber),
				accumulator.ar);
			return _Utils_update(
				accumulator,
				{
					ar: newBibliography,
					aW: A3(
						$elm$core$Dict$insert,
						label,
						{
							e: id,
							aB: $elm$core$String$fromInt(nextNumber)
						},
						accumulator.aW)
				});
		}
	});
var $author$project$Generic$Acc$updateReference = F3(
	function (headingIndex, referenceDatum, acc) {
		return (referenceDatum.an !== '') ? _Utils_update(
			acc,
			{
				aW: A3(
					$elm$core$Dict$insert,
					referenceDatum.an,
					{e: referenceDatum.e, aB: referenceDatum.aB},
					acc.aW)
			}) : acc;
	});
var $author$project$Generic$Acc$getReferenceDatum = F2(
	function (acc, block) {
		var sectionPart = A2($author$project$Generic$Vector$toStringWithLevel, acc.F, acc.f);
		var punctuation = (sectionPart !== '') ? '.' : '';
		var id = block.A.e;
		var tag = A2(
			$elm$core$Maybe$withDefault,
			id,
			A2($elm$core$Dict$get, 'tag', block.c));
		var chapterPart = (acc.h > 0) ? ($elm$core$String$fromInt(acc.h) + '.') : '';
		var numRef = _Utils_ap(
			chapterPart,
			_Utils_ap(
				sectionPart,
				_Utils_ap(
					punctuation,
					$elm$core$String$fromInt(acc.N))));
		return $elm$core$Maybe$Just(
			{e: id, aB: numRef, an: tag});
	});
var $author$project$Generic$Acc$updateReferenceWithBlock = F2(
	function (block, acc) {
		var _v0 = A2($author$project$Generic$Acc$getReferenceDatum, acc, block);
		if (!_v0.$) {
			var referenceDatum = _v0.a;
			return A3($author$project$Generic$Acc$updateReference, acc.f, referenceDatum, acc);
		} else {
			return acc;
		}
	});
var $author$project$Generic$Vector$get = F2(
	function (k, v) {
		return A2(
			$elm$core$Maybe$withDefault,
			0,
			A2($elm_community$list_extra$List$Extra$getAt, k, v.aL));
	});
var $author$project$Generic$Acc$getTag = function (block) {
	var _v0 = A2($elm$core$Dict$get, 'label', block.c);
	if (!_v0.$) {
		var label = _v0.a;
		return label;
	} else {
		var _v1 = A2($elm$core$Dict$get, 'tag', block.c);
		if (!_v1.$) {
			var tag = _v1.a;
			return tag;
		} else {
			return block.A.e;
		}
	}
};
var $author$project$Generic$Vector$resetFrom = F2(
	function (k, v) {
		var suffix = A2($elm$core$List$repeat, v.am - k, 0);
		var prefix = A2($elm$core$List$take, k, v.aL);
		return {
			aL: _Utils_ap(prefix, suffix),
			am: v.am
		};
	});
var $author$project$Generic$Vector$increment = F2(
	function (k, v) {
		return ((k < 0) || (_Utils_cmp(k, v.am) > -1)) ? v : A2(
			$author$project$Generic$Vector$resetFrom,
			k + 1,
			A3(
				$author$project$Generic$Vector$set,
				k,
				A2($author$project$Generic$Vector$get, k, v) + 1,
				v));
	});
var $author$project$Generic$Settings$indentationQuantum = 2;
var $author$project$Generic$Acc$updateWithOrdinaryBlock = F2(
	function (block, accumulator) {
		var _v0 = $author$project$Generic$BlockUtilities$getExpressionBlockName(block);
		if (!_v0.$) {
			switch (_v0.a) {
				case 'setcounter':
					var _v1 = block.bO;
					if (!_v1.$) {
						return accumulator;
					} else {
						var exprs = _v1.a;
						var ctr = function () {
							if ((exprs.b && (!exprs.a.$)) && (!exprs.b.b)) {
								var _v3 = exprs.a;
								var val = _v3.a;
								return A2(
									$elm$core$Maybe$withDefault,
									1,
									$elm$core$String$toInt(val));
							} else {
								return 1;
							}
						}();
						var headingIndex = A3(
							$author$project$Generic$Vector$set,
							0,
							ctr - 1,
							$author$project$Generic$Vector$init(accumulator.f.am));
						return _Utils_update(
							accumulator,
							{f: headingIndex});
					}
				case 'numbered':
					var level = (block.bu / $author$project$Generic$Settings$indentationQuantum) | 0;
					var itemVector = function () {
						var _v4 = accumulator.z;
						if (!_v4) {
							return A2($author$project$Generic$Vector$increment, level, accumulator.aS);
						} else {
							return A2(
								$author$project$Generic$Vector$increment,
								0,
								$author$project$Generic$Vector$init(accumulator.aS.am));
						}
					}();
					var referenceDatum = A3(
						$author$project$Generic$Acc$makeReferenceDatum,
						block.A.e,
						$author$project$Generic$Acc$getTag(block),
						$elm$core$String$fromInt(
							A2($author$project$Generic$Vector$get, level, itemVector)));
					var index = A2($author$project$Generic$Vector$get, level, itemVector);
					var numberedItemDict = A3(
						$elm$core$Dict$insert,
						block.A.e,
						{b1: index, c$: level},
						accumulator.by);
					return A3(
						$author$project$Generic$Acc$updateReference,
						accumulator.f,
						referenceDatum,
						_Utils_update(
							accumulator,
							{
								z: A2($author$project$Generic$Acc$nextInListState, block.P, accumulator.z),
								aS: itemVector,
								by: numberedItemDict
							}));
				case 'item':
					var level = (block.bu / $author$project$Generic$Settings$indentationQuantum) | 0;
					return _Utils_update(
						accumulator,
						{
							z: A2($author$project$Generic$Acc$nextInListState, block.P, accumulator.z)
						});
				default:
					var name_ = _v0.a;
					if (A2(
						$elm$core$List$member,
						name_,
						_List_fromArray(
							['title', 'contents', 'banner', 'a']))) {
						return accumulator;
					} else {
						if (A2($elm$core$List$member, name_, $author$project$Generic$Settings$numberedBlockNames)) {
							var sectionPart = A2($author$project$Generic$Vector$toStringWithLevel, accumulator.F, accumulator.f);
							var punctuation = (sectionPart !== '') ? '.' : '';
							var newBlockCounter = accumulator.N + 1;
							var chapterPart = (accumulator.h > 0) ? ($elm$core$String$fromInt(accumulator.h) + '.') : '';
							var numRef = _Utils_ap(
								chapterPart,
								_Utils_ap(
									sectionPart,
									_Utils_ap(
										punctuation,
										$elm$core$String$fromInt(newBlockCounter))));
							var referenceDatum = A3(
								$author$project$Generic$Acc$makeReferenceDatum,
								block.A.e,
								$author$project$Generic$Acc$getTag(block),
								numRef);
							return A3(
								$author$project$Generic$Acc$updateReference,
								accumulator.f,
								referenceDatum,
								_Utils_update(
									accumulator,
									{
										N: newBlockCounter,
										z: A2($author$project$Generic$Acc$nextInListState, block.P, accumulator.z)
									}));
						} else {
							return _Utils_update(
								accumulator,
								{
									z: A2($author$project$Generic$Acc$nextInListState, block.P, accumulator.z)
								});
						}
					}
			}
		} else {
			return accumulator;
		}
	});
var $author$project$Generic$Acc$updateWithOrdinaryDocumentBlock = F5(
	function (accumulator, name, content, level, id) {
		var title = function () {
			if (!content.$) {
				var str = content.a;
				return str;
			} else {
				var expr = content.a;
				return A2(
					$elm$core$String$join,
					' ',
					$elm_community$maybe_extra$Maybe$Extra$values(
						A2($elm$core$List$map, $author$project$Generic$ASTTools$getText, expr)));
			}
		}();
		var sectionTag = A3(
			$elm$core$String$replace,
			' ',
			'-',
			$elm$core$String$toLower(title));
		var documentIndex = A2(
			$elm$core$List$member,
			$elm$core$String$toLower(title),
			$author$project$Generic$Acc$itemsNotNumbered) ? accumulator.aP : A2(
			$author$project$Generic$Vector$increment,
			A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$String$toInt(level)),
			accumulator.aP);
		var referenceDatum = A2(
			$elm$core$List$member,
			$elm$core$String$toLower(title),
			$author$project$Generic$Acc$itemsNotNumbered) ? A3(
			$author$project$Generic$Acc$makeReferenceDatum,
			id,
			sectionTag,
			$author$project$Generic$Vector$toString(documentIndex)) : A3($author$project$Generic$Acc$makeReferenceDatum, id, sectionTag, '');
		return A3(
			$author$project$Generic$Acc$updateReference,
			accumulator.f,
			referenceDatum,
			_Utils_update(
				accumulator,
				{aP: documentIndex}));
	});
var $author$project$Tools$Utility$compressWhitespace = function (str) {
	return A2(
		$elm$core$String$join,
		' ',
		$elm$core$String$words(str));
};
var $author$project$Generic$Acc$updateWithOrdinarySectionBlock = F5(
	function (accumulator, name, content, level, id) {
		var titleWords = function () {
			if (!content.$) {
				var str = content.a;
				return _List_fromArray(
					[
						$author$project$Tools$Utility$compressWhitespace(str)
					]);
			} else {
				var expr = content.a;
				return A2(
					$elm$core$List$map,
					$author$project$Tools$Utility$compressWhitespace,
					$elm_community$maybe_extra$Maybe$Extra$values(
						A2($elm$core$List$map, $author$project$Generic$ASTTools$getText, expr)));
			}
		}();
		var sectionTag = $elm$core$String$concat(
			A2(
				$elm$core$List$map,
				A2(
					$elm$core$Basics$composeR,
					$elm$core$String$toLower,
					A2(
						$elm$core$Basics$composeR,
						$elm$core$String$trim,
						A2($elm$core$String$replace, ' ', '-'))),
				titleWords));
		var levelAsInt = A2(
			$elm$core$Maybe$withDefault,
			1,
			$elm$core$String$toInt(level));
		var newCounter = (_Utils_cmp(levelAsInt, accumulator.F) < 1) ? A3($elm$core$Dict$insert, 'equation', 0, accumulator.p) : accumulator.p;
		var delta = function () {
			var _v0 = A2($elm$core$Dict$get, 'has-chapters', accumulator.Q);
			if (_v0.$ === 1) {
				return 0;
			} else {
				if (_v0.a === 'yes') {
					return 1;
				} else {
					return 0;
				}
			}
		}();
		var headingIndex = A2(
			$author$project$Generic$Vector$increment,
			function (x) {
				return ((x - 1) + delta) + accumulator.bg;
			}(
				A2(
					$elm$core$Maybe$withDefault,
					1,
					$elm$core$String$toInt(level))),
			accumulator.f);
		var chapterPart = (accumulator.h > 0) ? ($elm$core$String$fromInt(accumulator.h) + '.') : '';
		var referenceDatum = A3(
			$author$project$Generic$Acc$makeReferenceDatum,
			id,
			sectionTag,
			_Utils_ap(
				chapterPart,
				$author$project$Generic$Vector$toString(headingIndex)));
		var blockCounter = (_Utils_cmp(levelAsInt, accumulator.F) < 1) ? 0 : accumulator.N;
		return A3(
			$author$project$Generic$Acc$updateReference,
			accumulator.f,
			referenceDatum,
			_Utils_update(
				accumulator,
				{N: blockCounter, p: newCounter, f: headingIndex}));
	});
var $author$project$Generic$Acc$extractCiteKey = function (expr) {
	if (((((expr.$ === 1) && (expr.a === 'cite')) && expr.b.b) && (!expr.b.a.$)) && (!expr.b.b.b)) {
		var _v1 = expr.b;
		var _v2 = _v1.a;
		var key = _v2.a;
		return $elm$core$Maybe$Just(
			$elm$core$String$trim(key));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Generic$ASTTools$getFunctionName = function (expression) {
	switch (expression.$) {
		case 1:
			var name = expression.a;
			return $elm$core$Maybe$Just(name);
		case 2:
			return $elm$core$Maybe$Nothing;
		case 0:
			return $elm$core$Maybe$Nothing;
		default:
			return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Generic$ASTTools$matchExprOnName_ = F2(
	function (name, expr) {
		return _Utils_eq(
			$author$project$Generic$ASTTools$getFunctionName(expr),
			$elm$core$Maybe$Just(name));
	});
var $author$project$Generic$ASTTools$filterExpressionsOnName_ = F2(
	function (name, exprs) {
		return A2(
			$elm$core$List$filter,
			$author$project$Generic$ASTTools$matchExprOnName_(name),
			exprs);
	});
var $author$project$Generic$Acc$getCiteKeys = function (content) {
	if (content.$ === 1) {
		var expressionList = content.a;
		return A2(
			$elm$core$List$filterMap,
			$author$project$Generic$Acc$extractCiteKey,
			A2($author$project$Generic$ASTTools$filterExpressionsOnName_, 'cite', expressionList));
	} else {
		return _List_Nil;
	}
};
var $author$project$Generic$Acc$addCitesFromContent = F2(
	function (block, dict) {
		var citeKeys = $author$project$Generic$Acc$getCiteKeys(block.bO);
		return A3(
			$elm$core$List$foldl,
			F2(
				function (key, d) {
					return A2($elm$core$Dict$member, key, d) ? d : A3($elm$core$Dict$insert, key, $elm$core$Maybe$Nothing, d);
				}),
			dict,
			citeKeys);
	});
var $author$project$Generic$Acc$addFootnote = F2(
	function (footnoteData, dict) {
		return A3($elm$core$Dict$insert, footnoteData.ao, footnoteData.ab, dict);
	});
var $elm$core$Dict$sizeHelp = F2(
	function (n, dict) {
		sizeHelp:
		while (true) {
			if (dict.$ === -2) {
				return n;
			} else {
				var left = dict.d;
				var right = dict.e;
				var $temp$n = A2($elm$core$Dict$sizeHelp, n + 1, right),
					$temp$dict = left;
				n = $temp$n;
				dict = $temp$dict;
				continue sizeHelp;
			}
		}
	});
var $elm$core$Dict$size = function (dict) {
	return A2($elm$core$Dict$sizeHelp, 0, dict);
};
var $author$project$Generic$Acc$addFootnoteLabel = F2(
	function (footnoteData, dict) {
		return A3(
			$elm$core$Dict$insert,
			footnoteData.ab.e,
			$elm$core$Dict$size(dict) + 1,
			dict);
	});
var $author$project$Generic$Acc$addFootnotes = F2(
	function (termDataList, _v0) {
		var dict1 = _v0.a;
		var dict2 = _v0.b;
		return A3(
			$elm$core$List$foldl,
			F2(
				function (data, _v1) {
					var d1 = _v1.a;
					var d2 = _v1.b;
					return _Utils_Tuple2(
						A2($author$project$Generic$Acc$addFootnote, data, d1),
						A2($author$project$Generic$Acc$addFootnoteLabel, data, d2));
				}),
			_Utils_Tuple2(dict1, dict2),
			termDataList);
	});
var $author$project$Generic$Acc$extractFootnote = F3(
	function (_v0, blockMetaId, expr) {
		if (((((expr.$ === 1) && (expr.a === 'footnote')) && expr.b.b) && (!expr.b.a.$)) && (!expr.b.b.b)) {
			var _v2 = expr.b;
			var _v3 = _v2.a;
			var content = _v3.a;
			var begin = _v3.b.aq;
			var end = _v3.b.au;
			var index = _v3.b.b1;
			var id = _v3.b.e;
			return $elm$core$Maybe$Just(
				{
					ab: {
						aq: begin,
						au: end,
						e: id,
						c0: $elm$core$Maybe$Just(blockMetaId)
					},
					ao: content
				});
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$Generic$Acc$getFootnotes = F3(
	function (mBlockId, id, content_) {
		if (content_.$ === 1) {
			var expressionList = content_.a;
			return $elm_community$maybe_extra$Maybe$Extra$values(
				A2(
					$elm$core$List$map,
					A2($author$project$Generic$Acc$extractFootnote, mBlockId, id),
					A2($author$project$Generic$ASTTools$filterExpressionsOnName_, 'footnote', expressionList)));
		} else {
			return _List_Nil;
		}
	});
var $author$project$Generic$Acc$getMeta = function (expr) {
	switch (expr.$) {
		case 1:
			var meta = expr.c;
			return meta;
		case 2:
			var meta = expr.c;
			return meta;
		case 0:
			var meta = expr.b;
			return meta;
		default:
			var meta = expr.c;
			return meta;
	}
};
var $author$project$Generic$Acc$addFootnotesFromContent = F2(
	function (block, _v0) {
		var dict1 = _v0.a;
		var dict2 = _v0.b;
		var blockId = function () {
			var _v1 = block.bO;
			if (!_v1.$) {
				return $elm$core$Maybe$Nothing;
			} else {
				var expr = _v1.a;
				return A2(
					$elm$core$Maybe$map,
					function ($) {
						return $.e;
					},
					A2(
						$elm$core$Maybe$map,
						$author$project$Generic$Acc$getMeta,
						$elm$core$List$head(expr)));
			}
		}();
		return A2(
			$author$project$Generic$Acc$addFootnotes,
			A3($author$project$Generic$Acc$getFootnotes, blockId, block.A.e, block.bO),
			_Utils_Tuple2(dict1, dict2));
	});
var $author$project$Generic$Acc$addTerm = F2(
	function (termData, dict) {
		return A3($elm$core$Dict$insert, termData.ao, termData.ab, dict);
	});
var $author$project$Generic$Acc$getTextContent = function (expr) {
	if (!expr.$) {
		var str = expr.a;
		return $elm$core$Maybe$Just(str);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Generic$Acc$getTextEnd = function (expr) {
	if (!expr.$) {
		var end = expr.b.au;
		return $elm$core$Maybe$Just(end);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Generic$Acc$parseListAs = function (text) {
	var _v0 = A2($elm$core$String$split, 'list-as:', text);
	if ((_v0.b && _v0.b.b) && (!_v0.b.b.b)) {
		var termPart = _v0.a;
		var _v1 = _v0.b;
		var displayPart = _v1.a;
		return _Utils_Tuple2(
			$elm$core$String$trim(termPart),
			$elm$core$Maybe$Just(
				$elm$core$String$trim(displayPart)));
	} else {
		return _Utils_Tuple2(text, $elm$core$Maybe$Nothing);
	}
};
var $author$project$Generic$Acc$extractTermFromArgs = F2(
	function (id, args) {
		if (args.b && (!args.a.$)) {
			if (!args.b.b) {
				var _v1 = args.a;
				var name = _v1.a;
				var begin = _v1.b.aq;
				var end = _v1.b.au;
				var _v2 = $author$project$Generic$Acc$parseListAs(name);
				var termName = _v2.a;
				var displayAs = _v2.b;
				return $elm$core$Maybe$Just(
					{
						ab: {aq: begin, bU: displayAs, au: end, e: id},
						ao: termName
					});
			} else {
				var _v3 = args.a;
				var firstWord = _v3.a;
				var begin = _v3.b.aq;
				var rest = args.b;
				var lastEnd = A2(
					$elm$core$Maybe$withDefault,
					begin,
					A2(
						$elm$core$Maybe$andThen,
						$author$project$Generic$Acc$getTextEnd,
						$elm$core$List$head(
							$elm$core$List$reverse(rest))));
				var allWords = A2(
					$elm$core$List$cons,
					firstWord,
					A2($elm$core$List$filterMap, $author$project$Generic$Acc$getTextContent, rest));
				var fullText = A2($elm$core$String$join, ' ', allWords);
				var _v4 = $author$project$Generic$Acc$parseListAs(fullText);
				var termName = _v4.a;
				var displayAs = _v4.b;
				return $elm$core$Maybe$Just(
					{
						ab: {aq: begin, bU: displayAs, au: lastEnd, e: id},
						ao: termName
					});
			}
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$Generic$Acc$extract = F2(
	function (id, expr) {
		_v0$2:
		while (true) {
			if (expr.$ === 1) {
				switch (expr.a) {
					case 'index':
						var args = expr.b;
						return A2($author$project$Generic$Acc$extractTermFromArgs, id, args);
					case 'term_':
						var args = expr.b;
						return A2($author$project$Generic$Acc$extractTermFromArgs, id, args);
					default:
						break _v0$2;
				}
			} else {
				break _v0$2;
			}
		}
		return $elm$core$Maybe$Nothing;
	});
var $author$project$Generic$Acc$getTerms = F2(
	function (id, content_) {
		if (content_.$ === 1) {
			var expressionList = content_.a;
			var termHiddenExprs = A2($author$project$Generic$ASTTools$filterExpressionsOnName_, 'term_', expressionList);
			var termExprs = A2($author$project$Generic$ASTTools$filterExpressionsOnName_, 'index', expressionList);
			return $elm_community$maybe_extra$Maybe$Extra$values(
				A2(
					$elm$core$List$map,
					$author$project$Generic$Acc$extract(id),
					_Utils_ap(termExprs, termHiddenExprs)));
		} else {
			return _List_Nil;
		}
	});
var $author$project$Generic$Acc$addTermsFromContent = F2(
	function (block_, dict) {
		var newTerms = A2($author$project$Generic$Acc$getTerms, block_.A.e, block_.bO);
		var folder = F2(
			function (termData, dict_) {
				return A2($author$project$Generic$Acc$addTerm, termData, dict_);
			});
		return A3($elm$core$List$foldl, folder, dict, newTerms);
	});
var $author$project$Generic$Acc$updateWithParagraph = F2(
	function (block, accumulator) {
		var bibliography = A2($author$project$Generic$Acc$addCitesFromContent, block, accumulator.ar);
		var _v0 = A2(
			$author$project$Generic$Acc$addFootnotesFromContent,
			block,
			_Utils_Tuple2(accumulator.br, accumulator.bq));
		var footnotes = _v0.a;
		var footnoteNumbers = _v0.b;
		return _Utils_update(
			accumulator,
			{
				ar: bibliography,
				bq: footnoteNumbers,
				br: footnotes,
				z: A2($author$project$Generic$Acc$nextInListState, block.P, accumulator.z),
				bI: A2($author$project$Generic$Acc$addTermsFromContent, block, accumulator.bI)
			});
	});
var $author$project$Generic$TextMacro$buildDictionary = function (_v0) {
	return $elm$core$Dict$empty;
};
var $author$project$Generic$Acc$normalizeLines = function (lines) {
	return A2(
		$elm$core$List$filter,
		function (line) {
			return line !== '';
		},
		A2(
			$elm$core$List$map,
			function (line) {
				return $elm$core$String$trim(line);
			},
			lines));
};
var $author$project$Generic$Acc$updateWithTextMacros = F2(
	function (content, accumulator) {
		return _Utils_update(
			accumulator,
			{
				bJ: $author$project$Generic$TextMacro$buildDictionary(
					$author$project$Generic$Acc$normalizeLines(
						$elm$core$String$lines(content)))
			});
	});
var $author$project$Generic$Acc$getCounter = F2(
	function (name, dict) {
		return A2(
			$elm$core$Maybe$withDefault,
			0,
			A2($elm$core$Dict$get, name, dict));
	});
var $author$project$Generic$Acc$incrementCounter = F2(
	function (name, dict) {
		return A3(
			$elm$core$Dict$insert,
			name,
			A2($author$project$Generic$Acc$getCounter, name, dict) + 1,
			dict);
	});
var $author$project$Generic$Acc$reduceName = function (str) {
	return A2(
		$elm$core$List$member,
		str,
		_List_fromArray(
			['equation', 'aligned', 'math'])) ? 'equation' : ((str === 'code') ? 'listing' : (A2(
		$elm$core$List$member,
		str,
		_List_fromArray(
			['quiver', 'image', 'iframe', 'chart', 'textarray', 'csvtable', 'svg', 'tikz', 'iframe'])) ? 'figure' : str));
};
var $author$project$Generic$Acc$verbatimBlockReference = F5(
	function (isSimple, headingIndex, name, newCounter, acc) {
		var sectionPart = A2($author$project$Generic$Vector$toStringWithLevel, acc.F, headingIndex);
		var punctuation = (sectionPart !== '') ? '.' : '';
		var eqNum = $elm$core$String$fromInt(
			A2(
				$author$project$Generic$Acc$getCounter,
				$author$project$Generic$Acc$reduceName(name),
				newCounter));
		var chapterPart = (acc.h > 0) ? ($elm$core$String$fromInt(acc.h) + '.') : '';
		return isSimple ? eqNum : _Utils_ap(
			chapterPart,
			_Utils_ap(
				sectionPart,
				_Utils_ap(punctuation, eqNum)));
	});
var $author$project$Generic$Acc$updateWithVerbatimBlock = F2(
	function (block, accumulator) {
		var _v0 = block.bO;
		if (_v0.$ === 1) {
			return accumulator;
		} else {
			var name = A2(
				$elm$core$Maybe$withDefault,
				'',
				$author$project$Generic$BlockUtilities$getExpressionBlockName(block));
			var isSimple = A2(
				$elm$core$List$member,
				name,
				_List_fromArray(
					['quiver', 'image']));
			var hasLabel = A2($elm$core$Dict$member, 'label', block.c);
			var newCounter = (A2($elm$core$List$member, name, accumulator.cb) && hasLabel) ? A2(
				$author$project$Generic$Acc$incrementCounter,
				$author$project$Generic$Acc$reduceName(name),
				accumulator.p) : accumulator.p;
			var updateAccumulatorWithLabel = function () {
				var _v1 = A2($elm$core$Dict$get, 'label', block.c);
				if (!_v1.$) {
					var tag = _v1.a;
					var referenceDatum = A3(
						$author$project$Generic$Acc$makeReferenceDatum,
						block.A.e,
						tag,
						A5($author$project$Generic$Acc$verbatimBlockReference, isSimple, accumulator.f, name, newCounter, accumulator));
					return function (acc) {
						return A3($author$project$Generic$Acc$updateReference, accumulator.f, referenceDatum, acc);
					};
				} else {
					return $elm$core$Basics$identity;
				}
			}();
			return updateAccumulatorWithLabel(
				_Utils_update(
					accumulator,
					{
						p: newCounter,
						z: A2($author$project$Generic$Acc$nextInListState, block.P, accumulator.z)
					}));
		}
	});
var $author$project$Generic$Acc$updateAccumulator = F2(
	function (block, accumulator) {
		var heading = block.P;
		var indent = block.bu;
		var args = block.cF;
		var body = block.bO;
		var meta = block.A;
		var properties = block.c;
		switch (heading.$) {
			case 1:
				switch (heading.a) {
					case 'q':
						return A2(
							$author$project$Generic$Acc$updateReferenceWithBlock,
							block,
							_Utils_update(
								accumulator,
								{
									N: accumulator.N + 1,
									bk: _List_fromArray(
										[
											_Utils_Tuple2(block.A.e, '??')
										])
								}));
					case 'a':
						var _v1 = $elm$core$List$head(accumulator.bk);
						if ((!_v1.$) && (_v1.a.b === '??')) {
							var _v2 = _v1.a;
							var idQ = _v2.a;
							return A2(
								$author$project$Generic$Acc$updateReferenceWithBlock,
								block,
								_Utils_update(
									accumulator,
									{
										bB: A3($elm$core$Dict$insert, idQ, block.A.e, accumulator.bB),
										bk: _List_Nil
									}));
						} else {
							return accumulator;
						}
					case 'set-key':
						if (args.b && args.b.b) {
							var key = args.a;
							var _v4 = args.b;
							var value = _v4.a;
							var rest = _v4.b;
							return _Utils_update(
								accumulator,
								{
									Q: A3($elm$core$Dict$insert, key, value, accumulator.Q)
								});
						} else {
							return accumulator;
						}
					case 'list':
						return _Utils_update(
							accumulator,
							{
								aS: $author$project$Generic$Vector$init(accumulator.f.am)
							});
					case 'chapter':
						var newChapterCounter = accumulator.h + 1;
						var chapterTag = A2(
							$elm$core$Maybe$withDefault,
							block.A.e,
							A2($elm$core$Dict$get, 'label', block.c));
						var referenceDatum = A3(
							$author$project$Generic$Acc$makeReferenceDatum,
							block.A.e,
							chapterTag,
							$elm$core$String$fromInt(newChapterCounter));
						return A3(
							$author$project$Generic$Acc$updateReference,
							accumulator.f,
							referenceDatum,
							_Utils_update(
								accumulator,
								{
									N: 0,
									h: newChapterCounter,
									p: A3($elm$core$Dict$insert, 'equation', 0, accumulator.p),
									f: $author$project$Generic$Vector$init(accumulator.f.am)
								}));
					case 'section':
						var level = A2(
							$elm$core$Maybe$withDefault,
							'1',
							A2($elm$core$Dict$get, 'level', properties));
						var _v5 = $author$project$Generic$Acc$getNameContentId(block);
						if (!_v5.$) {
							var name = _v5.a.M;
							var content = _v5.a.aL;
							var id = _v5.a.e;
							return A2(
								$author$project$Generic$Acc$updateReferenceWithBlock,
								block,
								A5(
									$author$project$Generic$Acc$updateWithOrdinarySectionBlock,
									accumulator,
									$elm$core$Maybe$Just(name),
									content,
									level,
									id));
						} else {
							return A2($author$project$Generic$Acc$updateReferenceWithBlock, block, accumulator);
						}
					case 'document':
						var level = A2(
							$elm$core$Maybe$withDefault,
							'1',
							$elm$core$List$head(args));
						var _v6 = $author$project$Generic$Acc$getNameContentId(block);
						if (!_v6.$) {
							var name = _v6.a.M;
							var content = _v6.a.aL;
							var id = _v6.a.e;
							return A5(
								$author$project$Generic$Acc$updateWithOrdinaryDocumentBlock,
								accumulator,
								$elm$core$Maybe$Just(name),
								content,
								level,
								id);
						} else {
							return accumulator;
						}
					case 'title':
						var newKeyValueDict = function () {
							var _v9 = A2($elm$core$Dict$get, 'number-to-level', block.c);
							if (!_v9.$) {
								var ntl = _v9.a;
								return A3($elm$core$Dict$insert, 'number-to-level', ntl, accumulator.Q);
							} else {
								return accumulator.Q;
							}
						}();
						if (accumulator.bg === 1) {
							return _Utils_update(
								accumulator,
								{Q: newKeyValueDict});
						} else {
							var vecSize = accumulator.f.am;
							var headingIndex = function () {
								var _v7 = A2($elm$core$Dict$get, 'first-section', block.c);
								if (_v7.$ === 1) {
									return $author$project$Generic$Vector$init(vecSize);
								} else {
									var firstSection_ = _v7.a;
									var _v8 = $elm$core$String$toInt(firstSection_);
									if (!_v8.$) {
										var n = _v8.a;
										return A3(
											$author$project$Generic$Vector$set,
											0,
											A2($elm$core$Basics$max, n - 1, 0),
											$author$project$Generic$Vector$init(vecSize));
									} else {
										return $author$project$Generic$Vector$init(vecSize);
									}
								}
							}();
							return _Utils_update(
								accumulator,
								{f: headingIndex, Q: newKeyValueDict});
						}
					case 'setcounter':
						var n = A2(
							$elm$core$Maybe$withDefault,
							1,
							A2(
								$elm$core$Maybe$andThen,
								$elm$core$String$toInt,
								$elm$core$List$head(args)));
						return _Utils_update(
							accumulator,
							{
								f: A3(
									$author$project$Generic$Vector$set,
									0,
									n,
									$author$project$Generic$Vector$init(accumulator.f.am))
							});
					case 'shiftandsetcounter':
						var n = A2(
							$elm$core$Maybe$withDefault,
							1,
							A2(
								$elm$core$Maybe$andThen,
								$elm$core$String$toInt,
								$elm$core$List$head(args)));
						return _Utils_update(
							accumulator,
							{
								bg: 1,
								f: A3(
									$author$project$Generic$Vector$set,
									0,
									n,
									$author$project$Generic$Vector$init(accumulator.f.am))
							});
					case 'bibitem':
						return A3($author$project$Generic$Acc$updateBibItemBlock, accumulator, args, block.A.e);
					default:
						return A2(
							$author$project$Generic$Acc$updateReferenceWithBlock,
							block,
							A2($author$project$Generic$Acc$updateWithOrdinaryBlock, block, accumulator));
				}
			case 2:
				switch (heading.a) {
					case 'settings':
						return _Utils_update(
							accumulator,
							{
								Q: A2($elm$core$Dict$union, properties, accumulator.Q)
							});
					case 'mathmacros':
						var _v10 = $author$project$Generic$Acc$getVerbatimContent(block);
						if (_v10.$ === 1) {
							return accumulator;
						} else {
							var str = _v10.a;
							return A2($author$project$Generic$Acc$updateWithMathMacros, str, accumulator);
						}
					case 'textmacros':
						var _v11 = $author$project$Generic$Acc$getVerbatimContent(block);
						if (_v11.$ === 1) {
							return accumulator;
						} else {
							var str = _v11.a;
							return A2($author$project$Generic$Acc$updateWithTextMacros, str, accumulator);
						}
					default:
						var name_ = heading.a;
						var _v12 = block.bO;
						if (!_v12.$) {
							var str = _v12.a;
							return A2($author$project$Generic$Acc$updateWithVerbatimBlock, block, accumulator);
						} else {
							return accumulator;
						}
				}
			default:
				var _v13 = $author$project$Generic$Acc$getNameContentIdTag(block);
				if (_v13.$ === 1) {
					return A2(
						$author$project$Generic$Acc$updateReferenceWithBlock,
						block,
						A2(
							$author$project$Generic$Acc$updateWithParagraph,
							block,
							_Utils_update(
								accumulator,
								{
									z: A2($author$project$Generic$Acc$nextInListState, block.P, accumulator.z)
								})));
				} else {
					var name = _v13.a.M;
					var content = _v13.a.aL;
					var id = _v13.a.e;
					var tag = _v13.a.an;
					return A2(
						$author$project$Generic$Acc$updateReferenceWithBlock,
						block,
						A2($author$project$Generic$Acc$updateWithParagraph, block, accumulator));
				}
		}
	});
var $author$project$Generic$Acc$transformAccumulateBlock = F2(
	function (acc_, block_) {
		var newAcc = A2($author$project$Generic$Acc$updateAccumulator, block_, acc_);
		return _Utils_Tuple2(
			newAcc,
			A2($author$project$Generic$Acc$transformBlock, newAcc, block_));
	});
var $author$project$Generic$Acc$transformAccumulateTree = F2(
	function (tree, acc) {
		return A3($author$project$Generic$Acc$mapAccumulate, $author$project$Generic$Acc$transformAccumulateBlock, acc, tree);
	});
var $author$project$Generic$Acc$transformAccumulate = F2(
	function (data, forest) {
		return function (_v1) {
			var acc_ = _v1.a;
			var ast_ = _v1.b;
			return _Utils_Tuple2(
				acc_,
				$elm$core$List$reverse(ast_));
		}(
			A3(
				$elm$core$List$foldl,
				F2(
					function (tree, _v0) {
						var acc_ = _v0.a;
						var ast_ = _v0.b;
						return A2(
							$author$project$Generic$Acc$mapper,
							ast_,
							A2($author$project$Generic$Acc$transformAccumulateTree, tree, acc_));
					}),
				_Utils_Tuple2(
					$author$project$Generic$Acc$init(data),
					_List_Nil),
				forest));
	});
var $author$project$Parser$Forest$parseIncrementally = F3(
	function (params, cache, lines) {
		var initialData_ = $author$project$Generic$Acc$initialData;
		var initialData = _Utils_update(
			initialData_,
			{F: initialData_.F});
		var exprForest = A2(
			$author$project$Parser$Forest$mapForest,
			$author$project$Parser$Pipeline$toExpressionBlockCached(cache),
			A2(
				$author$project$Generic$ForestTransform$forestFromBlocks,
				function ($) {
					return $.bu;
				},
				$author$project$Parser$PrimitiveBlock$parse(lines)));
		var _v0 = A2(
			$author$project$Generic$Acc$transformAccumulate,
			initialData,
			A2($author$project$Parser$Forest$filterForest, params.bX, exprForest));
		var acc = _v0.a;
		var finalForest = _v0.b;
		var newCache = $author$project$Parser$Forest$buildExpressionCache(finalForest);
		return _Utils_Tuple3(newCache, acc, finalForest);
	});
var $author$project$Parser$Forest$parse = function (lines) {
	return A2(
		$author$project$Parser$Forest$mapForest,
		$author$project$Parser$Pipeline$toExpressionBlock,
		A2(
			$author$project$Generic$ForestTransform$forestFromBlocks,
			function ($) {
				return $.bu;
			},
			$author$project$Parser$PrimitiveBlock$parse(lines)));
};
var $author$project$Parser$Forest$parseToForestWithAccumulator = F2(
	function (params, lines) {
		var initialData_ = $author$project$Generic$Acc$initialData;
		var initialData = _Utils_update(
			initialData_,
			{F: initialData_.F});
		return A2(
			$author$project$Generic$Acc$transformAccumulate,
			initialData,
			A2(
				$author$project$Parser$Forest$filterForest,
				params.bX,
				$author$project$Parser$Forest$parse(lines)));
	});
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$WorkerOptimize$sendResult = _Platform_outgoingPort('sendResult', $elm$json$Json$Encode$string);
var $author$project$WorkerOptimize$update = F2(
	function (msg, model) {
		var command = msg.bR;
		var sourceText = msg.dg;
		switch (command) {
			case 'fullParse':
				var params = $author$project$TestData$defaultCompilerParameters;
				var _v2 = A2(
					$author$project$Parser$Forest$parseToForestWithAccumulator,
					params,
					$elm$core$String$lines(sourceText));
				var acc = _v2.a;
				var forest = _v2.b;
				var n = $elm$core$List$length(forest);
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							aG: $elm$core$Maybe$Just(acc),
							av: forest
						}),
					$author$project$WorkerOptimize$sendResult(
						$elm$core$String$fromInt(n)));
			case 'seedCache':
				var params = $author$project$TestData$defaultCompilerParameters;
				var _v3 = A3(
					$author$project$Parser$Forest$parseIncrementally,
					params,
					model.as,
					$elm$core$String$lines(sourceText));
				var newCache = _v3.a;
				var acc = _v3.b;
				var forest = _v3.c;
				var n = $elm$core$List$length(forest);
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							aG: $elm$core$Maybe$Just(acc),
							as: newCache,
							av: forest
						}),
					$author$project$WorkerOptimize$sendResult(
						$elm$core$String$fromInt(n)));
			case 'incrementalParse':
				var params = $author$project$TestData$defaultCompilerParameters;
				var _v4 = A3(
					$author$project$Parser$Forest$parseIncrementally,
					params,
					model.as,
					$elm$core$String$lines(sourceText));
				var newCache = _v4.a;
				var acc = _v4.b;
				var forest = _v4.c;
				var n = $elm$core$List$length(forest);
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							aG: $elm$core$Maybe$Just(acc),
							as: newCache,
							av: forest
						}),
					$author$project$WorkerOptimize$sendResult(
						$elm$core$String$fromInt(n)));
			case 'cachedForest':
				var n = $elm$core$List$length(model.av);
				return _Utils_Tuple2(
					model,
					$author$project$WorkerOptimize$sendResult(
						$elm$core$String$fromInt(n)));
			default:
				return _Utils_Tuple2(
					model,
					$author$project$WorkerOptimize$sendResult('unknown command: ' + command));
		}
	});
var $elm$core$Platform$worker = _Platform_worker;
var $author$project$WorkerOptimize$main = $elm$core$Platform$worker(
	{
		cZ: function (_v0) {
			return _Utils_Tuple2(
				{aG: $elm$core$Maybe$Nothing, as: $elm$core$Dict$empty, av: _List_Nil},
				$elm$core$Platform$Cmd$none);
		},
		di: function (_v1) {
			return $author$project$WorkerOptimize$receiveCommand($elm$core$Basics$identity);
		},
		dn: $author$project$WorkerOptimize$update
	});
_Platform_export({'WorkerOptimize':{'init':$author$project$WorkerOptimize$main(
	$elm$json$Json$Decode$succeed(0))(0)}});}(this));