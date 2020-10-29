/**
 * Generate Mongoose Schemas from given OAS3
 */

const mongooseImportTmpl = `
import { Schema, model } from 'mongoose';

`;

const mongooseSchemaTmpl = `
/**
 * @schema {{schema_name}}
 *
 */
const {{schema_name}}Schema = new mongoose.Schema({
  {{schema_props}}
});

export const {{schema_name}}Model = mongoose.model('{{schema_name}}', {{schema_name}}Schema);

// ===================
`;

const mongoosePropTmpl = `
  {{prop_name}}: {{props}},
`;

const mongooseKeyValTmpl = `
    {{key}}: {{value}},
`;

const replaceInTemplate = function (template, data) {
  const pattern = /{{\s*(\w+?)\s*}}/g; // {property}
  return template.replace(pattern, (_, token) => data[token] || "");
};

const lowerCaseFirst = (str) => {
  return str
    .split("")
    .map((char, index) => {
      if (index === 0) {
        return char.toLowerCase();
      }
      return char;
    })
    .join("");
};

// Entry point
function mongooseTransformer(spec) {
  const { schemas } = spec;

  const schemaKeys = Object.keys(schemas);

  let generatedMongooseCode = mongooseImportTmpl;
  for (const key of schemaKeys) {
    generatedMongooseCode += replaceInTemplate(mongooseSchemaTmpl, {
      schema_name: lowerCaseFirst(key),
      schema_props: processSchema(schemas[key]),
    });
  }

  return generatedMongooseCode;
}

// only proecess top-level schema
function processSchema(schema) {
  const propKeys = Object.keys(schema.properties);
  console.log("asdf", schema);

  let cachedProps = "";
  for (const propKey of propKeys) {
    const { type } = schema.properties[propKey];
    cachedProps += replaceInTemplate(mongoosePropTmpl, {
      prop_name: propKey,
      props: processProp(type, schema.properties[propKey]),
    });
  }

  return cachedProps;
}

// process only props `key: value` pair
// also handle `values` as sub-schemas to generate nested schema output
function processProp(type, schema) {
  if (type === "object") {
    return `{
      ${processSchema(schema)}
    }
    `;
  }

  if (type === "array") {
    return `[
      ${processProp(schema.items.type, schema.items)}
    ]`;
  }

  return `{
    ${replaceInTemplate(mongooseKeyValTmpl, {
      key: "type",
      value: getType(type),
    })}
}`;
}

// get primitive types
function getType(type) {
  switch (type) {
    case "string":
      return "String";
    case "integer":
    case "number":
      return "Number";
    case "boolean":
      return "Boolean";
  }
}

module.exports = mongooseTransformer;
