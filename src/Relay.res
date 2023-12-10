type mapperParam = {"type": string, "id": string}

type globalIdToDb<'context> = (string, 'context) => promise<Js.Null.t<Graphql.graphQlObject>>
type dbToGraphql = Graphql.graphQlObject => Js.null<string>

@module("graphql-relay")
external createNodeDefinitions: (globalIdToDb<'c>, dbToGraphql) => RelayNode.nodeDefinitions =
  "nodeDefinitions"

@module("graphql-relay") external fromGlobalId: string => mapperParam = "fromGlobalId"
@module("graphql-relay") external globalIdField: string => Graphql.Field.field<'a> = "globalIdField"
@module("graphql-relay")
external globalIdFieldUnit: unit => Graphql.Field.field<'a> = "globalIdField"
@module("graphql-relay")
external globalIdFieldCustomFetcher: (
  string,
  Graphql.graphQlObject => string,
) => Graphql.Field.field<'a> = "globalIdField"

type connectionConfig = {
  name: string,
  nodeType: Graphql.graphQlObject,
}

type connectionOutput = {connectionType: Graphql.Field.t}

@module("graphql-relay")
external connectionDefinitions: connectionConfig => connectionOutput = "connectionDefinitions"
@module("graphql-relay")
external connectionFromArrayFn: ('a, 'b) => Js.Null.t<'a> = "connectionFromArray"

let connectionFromArray = (arr: 'a, args: 'b) =>
  connectionFromArrayFn(arr, Helpers.jsUnwrapVariant(args))

type argsInput = {
  "before": Graphql.Field.simpleField<string>,
  "after": Graphql.Field.simpleField<string>,
  "first": Graphql.Field.simpleField<int>,
  "last": Graphql.Field.simpleField<int>,
}

type argsOutput = {"before": string, "after": string, "first": int, "last": int}

@module("graphql-relay") external connectionArgs: argsInput = "connectionArgs"

let newConnctionArgsFun: argsInput => argsInput = %raw(`
  (connectionArgs) => ({...connectionArgs})
`)

let mergeArgs: (argsInput, 'a) => 'b = %raw(`
  (connectionArgs, args) => ({...connectionArgs, ...args})
`)

let newConnectionArgs = () => newConnctionArgsFun(connectionArgs)
let newConnectionCustomArgs = a => mergeArgs(connectionArgs, a)

@get external userId: Graphql.graphQlObject => string = "id"
let customIdTypeCreator = (obj: Graphql.graphQlObject, type_: string) => type_ ++ "+" ++ userId(obj)

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

type outputFieldsDef<'a, 'b> = {
  message: Graphql.Field.field<'a>,
  error: Graphql.Field.field<'b>,
}

type outputFields<'a, 'b> = {
  message: 'a,
  error: Js.null<'b>,
}

type mutation<'a, 'b, 'c, 'd, 'e, 'f> = {
  name: string,
  description: string,
  inputFields: 'a,
  mutateAndGetPayload: 'b => promise<outputFields<'c, 'd>>,
  outputFields: outputFieldsDef<'e, 'f>,
}

@module("graphql-relay")
external mutationWithClientMutationId: mutation<
  'a,
  'b,
  'c,
  'd,
  'e,
  'f,
> => Graphql.Field.mutationField = "mutationWithClientMutationId"
