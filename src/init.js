// cache all schemas
const _schemas = {};

// cache all request bodies
const _requestBodies = {};

// cache all comments
const _comments = [];

// cache all parameters
const _parameters = {};

// cache all paths
const _paths = {};

function extractList(list, index) {
  return list.map((item) => item[index]);
}

function buildList(head, tail, index) {
  return [head].concat(extractList(tail, index));
}

function extractOptional(optional, index) {
  return optional ? optional[index] : null;
}

function optionalList(value) {
  return value !== null ? value : [];
}

function ProgramNode(body) {
  this.type = "Program";
  this.body = body;
}
