const Parser = require("../parser/parser");

const OPEN_API_SPEC = {};

function ssgToOASParser(str) {
  const parsedScript = Parser.parse(str);

  let OAS = {};

  for (const block of parsedScript.body) {
    switch (block.type) {
      case "SchemasBlockExpression":
        OPEN_API_SPEC.schemas = schemaBlockProcessor(block);
        break;
      case "RequestBodiesBlockExpression":
        OPEN_API_SPEC.requestBodies = schemaBlockProcessor(block);
        break;
      case "ParametersBlockExpression":
        OPEN_API_SPEC.parameters = schemaBlockProcessor(block);
        break;
    }
  }

  OAS = { ...OPEN_API_SPEC };

  return OAS;
}

function schemaBlockProcessor(block) {
  // if (block.type !== "SchemasBlockExpression") {
  //   throw new Error(
  //     `schemaBlockProcessor: cannot process other type ${block.type}`
  //   );
  // }

  const schemaExps = block.body;
  return schemaExps
    .map((exp) => schemaExpressionProcessor(exp))
    .reduce((allSchemas, schema) => {
      const name = Object.keys(schema)[0];
      const value = Object.values(schema)[0];

      allSchemas[name] = value;
      return allSchemas;
    }, {});
}

function schemaExpressionProcessor(exp) {
  // if (exp.type !== "SchemaExpression") {
  //   throw new Error(
  //     `schemaExpressionProcessor: cannot process other type ${exp.type}`
  //   );
  // }

  if (!exp.extend?.length) {
    return {
      [exp.name]: reduce(exp.body),
    };
  }

  return {
    [exp.name]: {
      allOf: [
        ...(exp.extend?.map((ext) => {
          return {
            $ref: `#/components/schemas/${ext}`,
          };
        }) || []),
        reduce(exp.body),
      ],
    },
  };
}

function objectExpressionProcessor(exp) {
  if (exp.type !== "ObjectExpression") {
    throw new Error(
      `objectExpressionProcessor: cannot process other type ${exp.type}`
    );
  }

  const mappedProps = exp.properties
    .map((prop) => {
      return propertyExpressionProcessor(prop);
    })
    .reduce((finalObj, prop) => {
      const propName = Object.keys(prop)[0];
      const propValue = Object.values(prop)[0];

      finalObj = {
        ...finalObj,
        [propName]: propValue,
      };
      return finalObj;
    }, {});

  return {
    type: "object",
    ...(exp.required?.length ? { required: exp.required } : {}),
    properties: mappedProps,
  };
}

function identifierExpressionProcessor(exp) {
  if (exp.type !== "IdentifierExpression") {
    throw new Error(
      `IdentifierExpressionProcessor: cannot process other type ${exp.type}`
    );
  }

  return {
    type: exp.value.name,
  };
}

function propertyExpressionProcessor(exp) {
  if (exp.type !== "Property") {
    throw new Error(
      `propertyExpressionProcessor: cannot process other type ${exp.type}`
    );
  }

  if (exp.value.repeater === "array" && exp.value.type !== "ObjectExpression") {
    return {
      [exp.key.name]: {
        type: "array",
        items: {
          type: exp.value.name,
        },
      },
    };
  } else if (
    exp.value.repeater === "array" &&
    exp.value.type === "ObjectExpression"
  ) {
    return {
      [exp.key.name]: {
        type: "array",
        items: reduce(exp.value),
      },
    };
  }

  if (exp.value.type === "ObjectExpression") {
    return {
      [exp.key.name]: reduce(exp.value),
    };
  }

  return {
    [exp.key.name]: {
      type: exp.value.name,
    },
  };
}

function reduce(exp) {
  switch (exp.type) {
    case "ObjectExpression":
      return objectExpressionProcessor(exp);
    case "IdentifierExpression":
      return identifierExpressionProcessor(exp);
    case "Property":
      return propertyExpressionProcessor(exp);
  }
}

module.exports = {
  parser: ssgToOASParser,
};
