{
    // NEW SCHEMA FROM TYPESCRIPT

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

  let __schemas = {};
}

Start
  = _ exps:ExpressionList _ {
  return __schemas
    return exps.body.filter((exp) => exp.type !== 'Escaped' )
  }

ExpressionList
  = head:Expression tail:(_ Expression _)* {
    return new ProgramNode(buildList(head, tail, 1))
  }

Expression
	= SchemaDecorator / SourceChar

SchemaDecorator
	= $("///" _ "@ssg-schema") _ definition:TypeSignature {
    	const name = definition.name;
        delete definition.name;
        const schema = {
        	// type: "SchemaSignature",
            [name]: { /* description: 'src/modules/users/user.somefile.ts:234', */ ...definition }
        };

        __schemas = {...__schemas, ...schema};

        // console.log({ __schemas })

    	return schema
    }

TypeSignature
	= exported:"export"? _ "type" _ name:$Identifier _ "=" _  body:(DefinitionSignature)? _ {

        // return only name and rest of properties will come from respective definition
        return {
            name,
            ...body
        }
    }

DefinitionSignature
	= sig:(UnionSignature / "{" _ PropertySignatureList _ "}") {
    	if (sig.type === 'UnionSignature') {
        	// maps names as {$refs} of all union operands
            const refs = sig.body.names.map(name => ({ $ref: '#/components/schemas/' + name }))
        	const props = sig.body.props;
            const hasProps = Object.keys(props || {}).length > 0;
            return hasProps ? { allOf: [...refs, { type: 'object', properties: props }]} : { allOf: [...refs]}
        }

        // return propertySignatureList and extract properties from index 2
        return { type: 'object', properties: sig[2] }
    }

UnionSignature
	= names:UnionOperandList _ props:("&" _ "{" _ PropertySignatureList? _ "}")? {
    	// @todo if the list is empty, which return null as properties, handle the case
        if (props === null) {
                return { type: 'UnionSignature', body: { names } }
        }
        return { type: 'UnionSignature', body: { names, props: props[4] } }
    }

UnionOperandList
	= head:$Identifier _ tail:(_ '&' _ $Identifier)+ {
    	return buildList(head, tail, 3)
    }


PropertySignatureList
	= head:PropertySignature tail:(_ ("," / ";") _ PropertySignature _)* _ ("," / ";")? {
    const listObj = buildList(head, tail, 3).reduce((obj, sig) => {
    	obj[sig.key] = sig.value;
        return obj;
    }, {})

    return listObj
}

PropertySignature
	= key:$Identifier _ ":" _ value:PropertyValueTypes {
    	return {
        	key,
            value
        }

    	return {
			type: 'PropertySignature',
            key,
            value
		}
    }

// return types from within Types so that $refs could be applied as well
PropertyValueTypes
 = AllowedTypes / RefSchemaType

RefSchemaType
 = name:$Identifier {
 	return {
    	$ref: '#/components/schemas/' + name
    }
 }

AllowedTypes
	= type:("string" / "number" / "boolean") {
    	return { type }
    }

Identifier
  = name:$([_a-zA-Z][_a-zA-Z0-9]*) {
    return {
      type: "IdentifierExpression",
      name,
    }
  }

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
 = . {
 	return {
    	type: 'Escaped'
    }
 }

_ "whitespace"
  = (
  "\t"
  / "\v"
  / "\f"
  / " "
  / "\n"
  / "\u00A0"
  / "\uFEFF")*
