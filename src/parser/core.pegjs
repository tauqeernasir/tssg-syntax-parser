Start
  = _ exps:ExpressionList _ {
    return exps
  }

ExpressionList
  = head:Expression tail:(_ Expression _)* {
    return new ProgramNode(buildList(head, tail, 1))
  }

Expression
  = SchemasBlockExpression / RequestBodiesBlockExpression / ParametersBlockExpression / PathsBlockExpression

// ------- Schemas Block Expression ---------

SchemasBlockExpression
  = _ "Schemas" _ "{" _ objs:(SchemaExpression / ExtendableSchemaExpression)* _"}" _ {
    return {
      type: "SchemasBlockExpression",
        body: objs
    }
  }


SchemaExpression
	= name:$Identifier obj:ObjectExpression {
    _schemas[name] = obj;
    ProgramNode.schemas = _schemas;

    return {
      type: "SchemaExpression",
      name,
      body: obj
    }
  }

ExtendableSchemaExpression
	= name:$Identifier " " "extends" _ extName:ExtendableSchemaList obj:ObjectExpression {
    _schemas[name] = obj;
    ProgramNode.prototype.schemas = _schemas;

    return {
      type: "SchemaExpression",
      extend: extName,
      name,
      body: obj
    }
}

ExtendableSchemaList
  = head:$Identifier tail:(_ "," _ $Identifier)* _ ","? {
    return buildList(head, tail, 3);
  }

// ------- Request Bodies Block Expression ---------

RequestBodiesBlockExpression
  = _ "RequestBodies" _ "{" _ objs:(RequestBodyExpression / ExtendableRequestBodyExpression)* _ "}" _ {

    return {
      type: "RequestBodiesBlockExpression",
      body: objs
    }
  }

RequestBodyExpression
	= name:$Identifier obj:ObjectExpression {
    _requestBodies[name] = obj;
    ProgramNode.prototype.requestBodies = _requestBodies;

    return {
      type: "RequestBodyExpression",
      name,
      body: obj
    }
  }

ExtendableRequestBodyExpression
	= name:$Identifier " " "extends" _ extName:$Identifier obj:ObjectExpression {
    _schemas[name] = obj;
    ProgramNode.prototype.schemas = _schemas;

    return {
      type: "RequestBodyExpression",
      extend: extName,
      name,
      body: obj
    }
  }

// ------- Parameters Block Expression ---------

ParametersBlockExpression
  = _ "Parameters" _ "{" _ objs:(ParameterExpression)* _ "}" _ {
    return {
      type: "ParametersBlockExpression",
      body: objs
    }
  }

ParameterExpression
  = name:$Identifier obj:ObjectExpression {
    _parameters[name] = obj;
    ProgramNode.prototype.parameters = _parameters;

    return {
      type: "ParameterExpression",
      name,
      body: obj
    }
  }

// --------- Paths Block Expression ------------

PathsBlockExpression
  = _ "Paths" _ "{" _ exps:PathExpressionList _ "}" _ {
    return {
      type: "PathsBlockExpression",
      body: exps
    }
  }

PathExpressionList
  = head:PathExpression tail:(_ PathExpression)* {
    return buildList(head, tail, 1);
  }

PathExpression
  = _ endpoint:EndpointName " " _ tag:TagName " " _ "{" _ methods:MethodExpressionList _ "}" _ {

    const method = {
      type: "PathExpression",
      endpoint,
      tag,
      methods
    }

    _paths[endpoint] = method;
    ProgramNode.prototype.paths = _paths;

    return method;
  }

MethodExpressionList
  = head:MethodExpression tail:(_ MethodExpression)* {
    return buildList(head, tail, 1);
  }

MethodExpression
  = _ name:MethodName body:MethodBody _ {
    return {
      type: "MethodExpression",
      name,
      body
    }
  }

MethodBody
  = _ "{" _ properties:MethodBodyMemberExpressionList? _ "}" _ {
    return {
      type: "MethodBodyObjectExpression",
      properties: optionalList(properties),
    }
  }

MethodBodyMemberExpressionList
  = head:MethodBodyMemberExpression tail:(_ "," MethodBodyMemberExpression)* {
    return buildList(head, tail, 2);
  }

MethodBodyMemberExpression
  = _ key:"description" _ ":" _ value:Literal _ {
    return {
      type : "Property",
      key: {
        type: "IdentifierExpression",
        name: key
      },
      value
    }
  }
  /
  _ "requestBody" _ ":" _ value:ObjectExpression _ {
    return {
      type: "MethodRequestBodyExpression",
      value
    }
  }
  /
  _ "responses" _ ":" _ value:ResponseObjectExpression {
    return {
      type: "MethodResponseExpression",
      value
    }
  }

ResponseObjectExpression
  = _ "{" _ properties:ResponseObjectMemberExpressionList? _ "}" _ {
    return {
      type: "ResponseObjectExpression",
      properties: optionalList(properties)
    }
  }

ResponseObjectMemberExpressionList
  = head:ResponseObjectMemberExpression tail:(_ "," ResponseObjectMemberExpression)* {
    return buildList(head, tail, 2);
  }

ResponseObjectMemberExpression
  = _ name:$[0-9]+ _ ":" obj:ObjectExpression {
    return {
      type: "ResponseObjectMemberExpression",
      key: {
        type: "Literal",
        name,
      },
      value: obj
    }
  }

MethodName
  = "post" / "get" / "put" / "patch" / "delete"

EndpointName
  = endpoint: $[-_a-z0-9?\/]i+ {
    return endpoint;
  }

TagName
  = "(" tag:$[a-z]i+ ")" {
    return tag;
  }

////////////////////////////////////////////
// -------- General Expressions ----------
////////////////////////////////////////////

// -------- Object Expression ----------

ObjectExpression
	= _ "{" _ props:MemberExpressionList? _ "}" _ {
    const requiredProps = props !== null && Array.isArray(props) ? props.filter((prop) => !prop.optional && !prop.allowAdditional).map((prop) => prop.key.name) : [];
    const allowAdditional = props !== null && Array.isArray(props) ? props.some((prop) => prop.allowAdditional) : false;
    return {
      type: "ObjectExpression",
      ...(requiredProps.length ? { required: requiredProps } : {}),
      ...(allowAdditional ? { allowAdditional } : {}),
      properties: optionalList(props)
    }
  }

MemberExpressionList
	= head:KeyValueExpression tail:(_ "," _ KeyValueExpression)* _ ","? {
    return buildList(head, tail, 3)
  }

KeyValueExpression
	= key:Identifier _ optional:"?"? _ ":" _ value:(ArrayExpression / RepeatExpression / ObjectExpression  / CallExpression / PropertyAccessExpression / Identifier / Literal / Number) {
    return {
        type: "Property",
        optional: optional ? true : false,
        key,
        value
      }
  }
  /
  key:("[" _ Identifier _ ":" _ Identifier _ "]") _ ":" _ value:(ArrayExpression / RepeatExpression / ObjectExpression  / CallExpression / PropertyAccessExpression / Identifier / Literal / Number) {
    return {
      type: "Property",
      allowAdditional: true,
      key: key[2],
      value
    }
  }

PropertyAccessExpression
  = _ obj:$Identifier _ keys:(_ "." _ $Identifier)+ _ ![.%^&*(@!#)] {
    return {
      type: "PropertyAccessExpression",
      list: buildList(obj, keys, 3)
    }
  }

// -------- Repeat Expression -----------

RepeatExpression
  = initialBlock:(ObjectExpression / PropertyAccessExpression / Identifier) "[]" _ {
    return {
      ...initialBlock,
      repeater: "array"
    }
  }

// -------- Array Expression ---------

ArrayExpression
  = _ "[" _ args:ArrayElementList? _ "]" _ {
    return {
      type: "ArrayExpression",
      elements: optionalList(args)
    }
  }

ArrayElementList
  = head:ArgumentType tail:(_ "," _ ArgumentType)* _ ","? {
    return buildList(head, tail, 3);
  }

ArgumentType
  = ArrayExpression / ObjectExpression / CallExpression / Identifier / Literal

// ------- Call Expression ----------

CallExpression
  = _ callee:Identifier _ "(" _ args:CallArgumentList?  _ ")" _ {
    return {
      type: "CallExpression",
      callee,
      arguments: optionalList(args)
    }
  }

CallArgumentList
  = head:ArgumentType tail:(_ "," _ ArgumentType)* _ ","? {
    return buildList(head, tail, 3);
  }

// -------- Comment Expression ----------

MultilineCommentExpression
  = "/*" comment:$(!"*/" SourceChar)* "*/" {
    _comments.push({ type: "MultilineCommentExpression", value: comment.trim(), location: location() });
    ProgramNode.prototype.comments = _comments;
  }

// --------  Identifier Expression ----------

Identifier
  = name:$([_a-zA-Z][_a-zA-Z0-9]*) {
    return {
      type: "IdentifierExpression",
      name,
    }
  }

// -------- Literal Expression ----------

Number
  = value:$[0-9]+ {
    return {
      type: "Number",
      value: Number(value)
    }
  }

Literal
	= value:StringLiteral {
    return {
      type: "Literal",
      value
    }
  }

StringLiteral
	= '"' chars:$(DoubleStringChar*) '"' {
    return chars;
  }
  /
  "'" chars:$(SingleStringChar*) "'" {
    return chars;
  }

DoubleStringChar
	= !('"' / "\\" / LineTerminator) SourceChar {
    return text();
  }

SingleStringChar
	= !("'" / "\\" / LineTerminator) SourceChar {
    return text();
  }

LineTerminator
  = [\n\r\u2028\u2029]

SourceChar
 = .

_ "whitespace"
  = (
    MultilineCommentExpression
  / "\t"
  / "\v"
  / "\f"
  / " "
  / "\n"
  / "\u00A0"
  / "\uFEFF")*
