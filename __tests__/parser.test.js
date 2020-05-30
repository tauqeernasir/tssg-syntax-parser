const peg = require("pegjs");
const path = require("path");
const fs = require("fs");

let parser;

beforeAll(() => {
  const grammar = fs.readFileSync(
    path.resolve(__dirname, "../src/parser-auto-gen.pegjs"),
    {
      encoding: "utf-8",
    }
  );
  parser = peg.generate(grammar);
});

describe("tests for Parameters Block", () => {
  it("given correct Parameters Block, should return correct parsed output ", () => {
    const example = `
    Parameters {
        GetUser {
            id: string,
            filter: {}
        }
    }
    `;
    const expected = {
      type: "Program",
      body: [
        {
          type: "ParametersBlockExpression",
          body: [
            {
              type: "ParameterExpression",
              name: "GetUser",
              body: {
                type: "ObjectExpression",
                properties: [
                  {
                    type: "Property",
                    key: { type: "IdentifierExpression", name: "id" },
                    value: { type: "IdentifierExpression", name: "string" },
                  },
                  {
                    type: "Property",
                    key: { type: "IdentifierExpression", name: "filter" },
                    value: { type: "ObjectExpression", properties: [] },
                  },
                ],
              },
            },
          ],
        },
      ],
    };
    expect(parser.parse(example)).toEqual(expected);
  });

  it("given empty Parameters Block, should return correct parsed output ", () => {
    const example = `
    Parameters {
    }
    `;
    const expected = {
      type: "Program",
      body: [{ type: "ParametersBlockExpression", body: [] }],
    };
    expect(parser.parse(example)).toEqual(expected);
  });

  it("given Parameters Block with more spaces, should return correct output ", () => {
    const example = `
    Parameters    {
        GetUser {
            id: string,
            filter: {}
        }
    }   
    `;
    const expected = {
      type: "Program",
      body: [
        {
          type: "ParametersBlockExpression",
          body: [
            {
              type: "ParameterExpression",
              name: "GetUser",
              body: {
                type: "ObjectExpression",
                properties: [
                  {
                    type: "Property",
                    key: { type: "IdentifierExpression", name: "id" },
                    value: { type: "IdentifierExpression", name: "string" },
                  },
                  {
                    type: "Property",
                    key: { type: "IdentifierExpression", name: "filter" },
                    value: { type: "ObjectExpression", properties: [] },
                  },
                ],
              },
            },
          ],
        },
      ],
    };
    expect(parser.parse(example)).toEqual(expected);
  });
});

describe("tests for RequestBodies Block", () => {
  it("given RequestBodies Block, should return correct parsed output ", () => {
    const example = `
    RequestBodies {
        GetUserById {
            id: string,
        }
    }
    `;
    const expected = {
      type: "Program",
      body: [
        {
          type: "RequestBodiesBlockExpression",
          body: [
            {
              type: "RequestBodyExpression",
              name: "GetUserById",
              body: {
                type: "ObjectExpression",
                properties: [
                  {
                    type: "Property",
                    key: { type: "IdentifierExpression", name: "id" },
                    value: { type: "IdentifierExpression", name: "string" },
                  },
                ],
              },
            },
          ],
        },
      ],
    };
    expect(parser.parse(example)).toEqual(expected);
  });

  it("given empty RequestBodies Block, should return correct parsed output ", () => {
    const example = `
    RequestBodies {
    }
    `;
    const expected = {
      type: "Program",
      body: [{ type: "RequestBodiesBlockExpression", body: [] }],
    };
    expect(parser.parse(example)).toEqual(expected);
  });

  it("given RequestBodies Block with more spaces, should return correct output ", () => {
    const example = `
    RequestBodies    {
        GetUser {
            id: string,
            filter: {}
        }
    }   
    `;
    const expected = {
      type: "Program",
      body: [
        {
          type: "RequestBodiesBlockExpression",
          body: [
            {
              type: "RequestBodyExpression",
              name: "GetUser",
              body: {
                type: "ObjectExpression",
                properties: [
                  {
                    type: "Property",
                    key: { type: "IdentifierExpression", name: "id" },
                    value: { type: "IdentifierExpression", name: "string" },
                  },
                  {
                    type: "Property",
                    key: { type: "IdentifierExpression", name: "filter" },
                    value: { type: "ObjectExpression", properties: [] },
                  },
                ],
              },
            },
          ],
        },
      ],
    };
    expect(parser.parse(example)).toEqual(expected);
  });
});
