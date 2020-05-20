Start
    = ExpressionList

ExpressionList
    = head:Expression tail:(_ Expression _)* {
    	return new ProgramNode(buildList(head, tail, 1))
    }

Expression
    = SchemasBlockExpression / RequestBodiesBlockExpression

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

RequestBodiesBlockExpression
    = "RequestBodies" _ "{" _ objs:(RequestBodyExpression / ExtendableRequestBodyExpression)* _ "}" {

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


// -------- General Expressions ----------

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
	= key:Identifier _ ":" _ value:(ObjectExpression / Identifier / Literal) {
		return {
        	key,
            value
        }
    }

MultilineCommentExpression
    = "/*" txt:$(!"*/" SourceChar)* "*/" {
        return txt.trim();
    }
    
Identifier
	= iden:$([_a-zA-Z][_a-zA-Z0-9]*) {
    	return {
        	type: "IdentifierExpression",
            name: iden,
        }
    }
   
Literal
	= lit:StringLiteral {
    	return {
        	type: "Literal",
            value: lit
        }
    }
    
StringLiteral
	= '"' chars:DoubleStringChar* '"' {
    	return chars.join("");
    }
    /
    "'" chars:SingleStringChar* "'" {
    	return chars.join("");
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
