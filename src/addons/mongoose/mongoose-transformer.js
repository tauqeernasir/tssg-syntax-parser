const { readFileSync } = require("fs");
const path = require("path");
const { parser } = require("../../transformer");

// const mongooseSchemaTmpl = readFileSync(
//   path.resolve(__dirname, "./mongoose-schema.tmpl"),
//   { encoding: "utf-8" }
// );

const mongooseSchemaTmpl = `
const {{schema_name}} = mongoose.Schema({
  {{schema_props}}
});
`;

const replaceInTemplate = function (template, data) {
  const pattern = /{{\s*(\w+?)\s*}}/g; // {property}
  return template.replace(pattern, (_, token) => data[token] || "");
};

const str = `
  Schemas {
    User {
      name: string,
      age: number
    }

    Employee {
      role: string,
      age: boolean,
      salary: number,
    }
  }`;

const parsedSpec = parser(str);

console.log(JSON.stringify(parsedSpec, null, 2));

mongooseTransformer(parsedSpec);

function mongooseTransformer(spec) {
  const { schemas } = spec;

  const schemaKeys = Object.keys(schemas);

  let mongooseSchemas = ``;
  for (const key of schemaKeys) {
    mongooseSchemas += replaceInTemplate(mongooseSchemaTmpl, {
      schema_name: key,
      schema_props: processSchema(schemas[key]),
    });
  }

  console.log(mongooseSchemas);
}

function processSchema(schema) {
  const propKeys = Object.keys(schema.properties);
  console.log("asdf", propKeys);

  let cachedProps = "";
  for (const propKey of propKeys) {
    const { type } = schema.properties[propKey];
    cachedProps += `
        ${propKey}: {
          type: ${getType(type)},
        },
    `;
  }

  return cachedProps;
}

function getType(type) {
  switch (type) {
    case "string":
      return "String";
    case "number":
      return "Number";
  }
}
