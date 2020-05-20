Start
    = ExpressionList

ExpressionList
    = head:Expression tail:(_ Expression _)* {
    	return new ProgramNode(buildList(head, tail, 1))
    }

Expression
    = SchemasBlockExpression / RequestBodiesBlockExpression / ParametersBlockExpression

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
        ProgramNode.prototype.schemas = _schemas;

        return {
        	type: "SchemaExpression",
            name,
            body: obj
        }
    }
    
ExtendableSchemaExpression
	= name:$Identifier " " "extends" _ extName:$Identifier obj:ObjectExpression {        
        _schemas[name] = obj;
        ProgramNode.prototype.schemas = _schemas;
        
        return {
        	type: "SchemaExpression",
            extend: extName,
            name,
            body: obj
        }
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
        return {
            type: "ParameterExpression",
            name,
            body: obj
        }
    }

////////////////////////////////////////////
// -------- General Expressions ----------
////////////////////////////////////////////

// -------- Object Expression ----------

ObjectExpression
	= _ "{" _ props:MemberExpressionList? _ "}" _ {
    	return {
        	type: "ObjectExpression",
            properties: props || []
        }
    }

MemberExpressionList
	= head:KeyValueExpression tail:(_ "," _ KeyValueExpression)* _ ","? {
    	return buildList(head, tail, 3)
    }
    
KeyValueExpression
	= key:Identifier _ ":" _ value:(ArrayExpression / ObjectExpression / Identifier / Literal) {
		return {
        	key,
            value
        }
    }

// -------- Array Expression ---------

ArrayExpression
    = _ "[" _ args:ArrayElementList? _ "]" _ {
        return {
            type: "ArrayExpression",
            elements: args
        }
    }

ArrayElementList
    = head:ArrayArgumentType tail:(_ "," _ ArrayArgumentType)* _ ","? {
        return buildList(head, tail, 3);
    }

ArrayArgumentType
    = ObjectExpression / Identifier / Literal

// -------- Comment Expression ----------

MultilineCommentExpression
    = "/*" txt:$(!"*/" SourceChar)* "*/" {
        return txt.trim();
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
  = ("\t"
  / "\v"
  / "\f"
  / " "
  / "\n"
  / "\u00A0"
  / "\uFEFF")*
