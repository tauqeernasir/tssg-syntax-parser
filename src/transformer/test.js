const { parser } = require("./index");

const str = `

Schemas {
  User {
    [key: string]: any,
    name: string
  }
}

`;

const parsed = parser(str);

console.log(JSON.stringify(parsed, null, 2));
