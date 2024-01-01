// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Graphql = require("rescript-graphqljs/src/Graphql.bs.js");
var Helpers = require("rescript-helpers/src/Helpers.bs.js");
var Js_dict = require("rescript/lib/js/js_dict.js");
var Js_undefined = require("rescript/lib/js/js_undefined.js");
var GraphqlRelay = require("graphql-relay");

var $$Node = {};

var Connection = {};

function connectionFromArray(arr, args) {
  return GraphqlRelay.connectionFromArray(arr, Helpers.jsUnwrapVariant(args));
}

var Internal = {};

function makeConnctionArgsFun(args) {
  return Js_dict.fromArray(Js_dict.entries(args));
}

function defaultArgs(param) {
  var args = GraphqlRelay.connectionArgs;
  return Js_dict.fromArray(Js_dict.entries(args));
}

function addArg(dict, key, value) {
  dict[key] = value;
  return dict;
}

var make = Graphql.Input.make;

var Args = {
  connectionFromArray: connectionFromArray,
  Internal: Internal,
  makeConnctionArgsFun: makeConnctionArgsFun,
  defaultArgs: defaultArgs,
  addArg: addArg,
  make: make
};

function customIdTypeCreator(obj, type_) {
  return type_ + "+" + obj.id;
}

function parseCustomIdType(id) {
  var idArr = id.split("+");
  if (idArr.length !== 2) {
    return ;
  }
  var type_ = idArr[0];
  var id$1 = idArr[1];
  return [
          type_,
          id$1
        ];
}

function parseCustomIdTypeId(id) {
  var match = parseCustomIdType(id);
  if (match !== undefined) {
    return match[1];
  }
  
}

var Id = {
  customIdTypeCreator: customIdTypeCreator,
  parseCustomIdType: parseCustomIdType,
  parseCustomIdTypeId: parseCustomIdTypeId
};

var Internal$1 = {};

function make$1(mutation) {
  return GraphqlRelay.mutationWithClientMutationId({
              name: mutation.name,
              description: Js_undefined.fromOption(mutation.description),
              deprecationReason: Js_undefined.fromOption(mutation.deprecationReason),
              inputFields: mutation.inputFields,
              outputFields: {
                message: Graphql.Field.makeField(mutation.outputFields.message),
                error: Graphql.Field.makeField(mutation.outputFields.error)
              },
              mutateAndGetPayload: mutation.mutateAndGetPayload
            });
}

var Mutation = {
  Internal: Internal$1,
  make: make$1
};

exports.$$Node = $$Node;
exports.Connection = Connection;
exports.Args = Args;
exports.Id = Id;
exports.Mutation = Mutation;
/* Graphql Not a pure module */
