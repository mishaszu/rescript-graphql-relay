open Helpers
type mapperParam = {"type": string, "id": string}

module Node = {
  type globalIdToDb<'context> = (string, 'context) => promise<Js.Null.t<Graphql.graphQlObject>>
  type dbToGraphql = Graphql.graphQlObject => Js.null<string>

  @module("graphql-relay")
  external createNodeDefinitions: (globalIdToDb<'c>, dbToGraphql) => RelayNode.nodeDefinitions =
    "nodeDefinitions"
}

module Connection = {
  type connectionConfig = {
    name: string,
    nodeType: Graphql.graphQlObject,
  }

  type connectionOutput<'t> = {connectionType: Graphql.InputTypes.t<'t>}

  @module("graphql-relay")
  external connectionDefinitions: connectionConfig => connectionOutput<'t> = "connectionDefinitions"
}

module Args = {
  @module("graphql-relay")
  external connectionFromArrayFn: ('a, 'b) => Js.Null.t<'a> = "connectionFromArray"

  let connectionFromArray = (arr: 'a, args: 'b) =>
    connectionFromArrayFn(arr, Helpers.jsUnwrapVariant(args))

  type argsInput = {
    "before": Graphql.Field.field2<string>,
    "after": Graphql.Field.field2<string>,
    "first": Graphql.Field.field2<int>,
    "last": Graphql.Field.field2<int>,
  }

  type argsOutput = {"before": string, "after": string, "first": int, "last": int}

  @module("graphql-relay") external connectionArgs: argsInput = "connectionArgs"

  let makeConnctionArgsFun: argsInput => argsInput = %raw(`
  (connectionArgs) => ({...connectionArgs})
`)

  let mergeArgs: (argsInput, 'a) => 'b = %raw(`
  (connectionArgs, args) => ({...connectionArgs, ...args})
`)

  let defaultArgs = () => makeConnctionArgsFun(connectionArgs)

  let addArg = (args, key: string, field: Graphql.Field.field2<'a>) => {
    let obj = jsCreateObj(key, field)
    Js.Obj.assign(args, obj)
  }
}

module Id = {
  @module("graphql-relay") external fromGlobalId: string => mapperParam = "fromGlobalId"
  @module("graphql-relay")
  external globalIdField: string => Graphql.InputTypes.t<string> = "globalIdField"
  @module("graphql-relay")
  external globalIdFieldUnit: unit => Graphql.InputTypes.t<string> = "globalIdField"
  @module("graphql-relay")
  external globalIdFieldCustomFetcher: (
    string,
    Graphql.graphQlObject => string,
  ) => Graphql.InputTypes.t<string> = "globalIdField"

  @get external getId: Graphql.graphQlObject => string = "id"

  let customIdTypeCreator = (obj: Graphql.graphQlObject, type_: string) =>
    type_ ++ "+" ++ getId(obj)

  type customTypeId = (string, string)

  let parseCustomIdType = (id: string): option<customTypeId> => {
    let idArr = id->Js.String2.split("+")
    switch idArr {
    | [type_, id] => Some((type_, id))
    | _ => None
    }
  }

  let parseCustomIdTypeId = (id: string) =>
    switch parseCustomIdType(id) {
    | Some((_, id)) => Some(id)
    | None => None
    }
}

module Output = {
  type fieldsDef<'a, 'b> = {
    message: Graphql.Field.field2<'a>,
    error: Graphql.Field.field2<'b>,
  }

  type fields<'source, 'args, 'ctx, 'a, 'fieldType> = {
    message: Graphql.Field.field3<'source, 'args, 'ctx, 'a, 'fieldType>,
    error: Graphql.Field.field3<'source, 'args, 'ctx, string, string>,
  }
}

module Mutation = {
  type t<'a, 'b, 'source, 'ctx, 'args, 'output, 'data, 'fieldType> = Graphql.Mutation.relayMutation<
    Output.fieldsDef<'a, 'b>,
    Output.fields<'source, 'args, 'ctx, 'data, 'fieldType>,
    'output,
    'ctx,
    'data,
  >

  @module("graphql-relay")
  external withClientMutationId: t<
    'inputDef,
    'a,
    'b,
    'source,
    'ctx,
    'args,
    'data,
    'fieldType,
  > => Graphql.graphQlObject = "mutationWithClientMutationId"
}
