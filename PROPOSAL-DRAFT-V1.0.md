# TSSG
*Current Working Draft*

## Introduction
This is the specification for TSSG(The Swagger Schema Generator), which enables developers to generate OpenAPI Schema with an easy and concise syntax/grammar.

> The [OpenAPI Specification](https://swagger.io/specification/) (OAS) defines a standard, language-agnostic
> interface to RESTful APIs which allows both humans and computers to
> discover and understand the capabilities of the service without access
> to source code, documentation, or through network traffic inspection.
> When properly defined, a consumer can understand and interact with the
> remote service with a minimal amount of implementation logic.
> 

## Table of Contents
 - [Overview](#overview)
 - [Language](#language)
    - [White Spaces](#white-spaces)
    - [Line Terminators](#line-terminators)
    - [Comments](#comments)
    - [Lexical Tokens](#lexical-tokens)
      - [Number](#number)
      - [String](#string)
      - [Boolean](#boolean)
      - [Object](#object)
      - [Array](#array)
    - [Schema Block](#schema-block)
      - [Schema Expression](#schema-expression)
      - [Extendable Schema Expression](#extendable-schema-expression)
    - [RequestBodies Block](#requestbodies-block)
      - [RequestBody Expression](#requestbody-expression)
      - [Extendable RequestBody](#extendable-requestbody)
    - [Parameters Block](#parameters-block)
    - [Reference](#reference)
    - [Paths](#paths)


## Overview
Writing OpenAPI Schema can be tiresome and time wasting task if you write a lot of API Documentation. Updating existing Schema can also be cumbersome and confusing especially when project grows to hundreds of APIs. TSSG is here to help you write schema in an easy, clean and concise way. We have proposed a new and easy to understand Syntax/Grammar for this. It allows you to write less and get full OpenAPI Schema without writing and repeating same line again and again.

For example, Consider the following object Schema of User when written according to OpenAPI Specification:

```json
{
  "type": "object",
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "number"
    },
    "email": {
      "type": "string"
    },
    "address": {
      "type": "object",
      "properties": {
        "street": {
          "type": "string"
        },
        "city": {
          "type": "string"
        },
        "country": {
          "type": "string"
        },
        "zipcode": {
          "type": "string"
        }
      }
    }
  }
}
```
The above schema has a lot of repetition and if the schema is more complex that have nested object or array of object, it gets more complex to write.

On the other hand, with TSSG, above schema can be written as:
```javascript
{
    name: string,
    age: number,
    email: string,
    address: {
        street: string,
        city: string,
        country: string,
        zipcode: string,
    }
}

```



## Language
A TSSG document is defined as a syntactic grammar where terminal symbols are tokens (indivisible lexical units). These tokens are defined in a lexical grammar which matches patterns of source characters.
This sequence of lexical tokens are then scanned from left to right to produce an abstract syntax tree (AST) according to the Document syntactical grammar.


We refer to A TSSG documents as programs. A program may contain expression blocks(schemas, requestbodies, paths, parameters), lexical tokens and Ignored lexical grammars(comments, whitespaces, line terminators).

### White Spaces
White space is used to improve legibility of source text and act as separation between tokens, and any amount of white space may appear before or after any token. White space between tokens is not significant to the semantic meaning of a TSSG Document, however white space characters may appear within a String or Comment token.

### Line Terminators

Like white space, line terminators are used to improve the legibility of source text, any amount may appear before or after any other token and have no significance to the semantic meaning of a TSSG Document. Line terminators are not found within any other token.


### Comments
TSSG source documents may contain multi‐line comments, starting with the `/*` marker and ending with `*/` marker.

A comment can contain any Unicode code point in SourceCharacter except LineTerminator so a comment always consists of all code points starting with the `/*` character up to `*/`

Comments are Ignored like white space and may appear after any token, or before a LineTerminator, and have no significance to the semantic meaning of a TSSG Document.
```javascript
/* this is
multi line 
comment */
```
### Lexical Tokens
#### Number
```javascript

age: number
```
#### String
```javascript
name: string
```
#### Boolean

```javascript
isVerified: boolean
```

#### Object
```javascript

address: {
    city: string,
    country: string,
    zip: number
}
```
>Notice `address` which is an `Object` with 3 properties. 

#### Array
```javascript
profileImages: [{
    size: {
        width: number,
        height: number
    },
    url: string
}]
```
>Notice `profileImages` which is an `Array` of `Objects` with 2 properties.


### Schema Block
#### Schema Expression
Schemas block can be written as follow:

```javascript
Schemas {

    User {
        name: string,
        email: string
    }
    
}
```
#### Extendable Schema Expression
We can extend schemas using `extends` keyword
```javascript 
Schemas {

    BaseUser {
        name: string,
        email: string
    }

    Employee extends BaseUser {
        salary: number,
        department: string
    }

}
```
### RequestBodies Block
RequestBodies block can be written similarly as Schemas block:
#### RequestBody Expression

```javascript
RequestBodies {

    ListParams {
        page: number,
        limit: number,
        totalPages: number,
        filters: {
          ids: [string]
        }
    }

}
```

#### Extendable RequestBody
We can extend RequestBodies using `extends` keyword
```javascript
RequestBodies {

    BaseListParams {
        page: number,
        limit: number,
        totalPages: number
    }

    ListUsers extends BaseListParams {
        filters: {
            ids: [string]
        }
    }

}
```
### Parameters Block

Similarly parameters block can be written as:

```javascript
Parameters {

    GetUser {
        id: string
    }

}
```
### Reference

We can refer to any existing Schema, RequestBodies or any custom type:

```javascript
{
   user: Schemas.User,
   userList: [Schemas.User]
}
```
> Note: Here we are refering to existing [Schemas.User](#schema-expression).
### Paths 

```javascript
/v1-user (user) {

    post: {
        description: "description goes here",
        requestBody: RequestBodies.V1GetUser.address,
        responses: {
          200: {
            description: "",
            content@application/json: [@Schemas.V1User],
            content@text/plain: string
          }
        }
    }

    get: {
        description: "description goes here",
        requestBody: requestBody.V1GetUser,
        responses: {
          200: {
            description: "",
            content@application/json: Schemas.ArrayOfUsers,
            content@text/plain: string
          }
        }
    }

}

```