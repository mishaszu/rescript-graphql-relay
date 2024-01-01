type mapperParam = {"type": string, "id": string}

module Node = {
  type globalIdToDb<'context> = (string, 'context) => promise<Js.Null.t<Graphql.Types.t>>
  type dbToGraphql = Graphql.Types.t => Js.null<string>

  @module("graphql-relay")
  external createNodeDefinitions: (globalIdToDb<'c>, dbToGraphql) => RelayNode.nodeDefinitions =
    "nodeDefinitions"
}

module Connection = {
  type connectionConfig<'source, 'args, 'ctx, 'a> = {
    name: string,
    nodeType: Graphql.ModelType.m<'source, 'args, 'ctx, 'a>,
  }

  @module("graphql-relay")
  external connectionDefinitions: connectionConfig<'source, 'args, 'ctx, 'a> => Graphql.Types.t =
    "connectionDefinitions"
}

module Args = {
  type t = Js.Dict.t<Graphql.Input.m>

  @module("graphql-relay")
  external connectionFromArrayFn: ('a, 'b) => Js.Null.t<'a> = "connectionFromArray"

  let connectionFromArray = (arr: 'a, args: 'b) =>
    connectionFromArrayFn(arr, Helpers.jsUnwrapVariant(args))

  type argsOutput = {"before": string, "after": string, "first": int, "last": int}

  module Internal = {
    @module("graphql-relay") external connectionArgs: t = "connectionArgs"
  }

  let makeConnctionArgsFun = args => Js.Dict.entries(args)->Js.Dict.fromArray

  let defaultArgs = () => makeConnctionArgsFun(Internal.connectionArgs)

  let addArg = (dict: Js.Dict.t<Graphql.Input.m>, key: string, value: Graphql.Input.m) => {
    Js.Dict.set(dict, key, value)
    dict
  }

  let make = Graphql.Input.make
}

module Id = {
  @module("graphql-relay") external fromGlobalId: string => mapperParam = "fromGlobalId"
  @module("graphql-relay")
  external globalIdField: string => Graphql.Types.t = "globalIdField"
  @module("graphql-relay")
  external globalIdFieldUnit: unit => Graphql.Types.t = "globalIdField"
  @module("graphql-relay")
  external globalIdFieldCustomFetcher: (string, Graphql.Types.t => string) => Graphql.Types.t =
    "globalIdField"

  @get external getId: Graphql.Types.t => string = "id"

  let customIdTypeCreator = (obj: Graphql.Types.t, type_: string) => type_ ++ "+" ++ getId(obj)

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

module Mutation = {
  type relayOutput<'source, 'args, 'ctx> = {
    message: Graphql.Field.field<'source, 'args, 'ctx>,
    error: Graphql.Field.field<'source, 'args, 'ctx>,
  }

  type relayData<'a, 'b> = {
    message: 'a,
    error: Js.null<'b>,
  }

  type t<'source, 'args, 'ctx, 'input, 'data, 'error> = {
    name: string,
    description?: string,
    deprecationReason?: string,
    inputFields: Js.Dict.t<Graphql.Input.m>,
    outputFields: relayOutput<'source, 'args, 'ctx>,
    mutateAndGetPayload: ('input, 'ctx) => promise<relayData<'data, 'error>>,
  }

  module Internal = {
    type output_internal = {
      message: Graphql.Field.f,
      error: Graphql.Field.f,
    }
    type t__internal<'input, 'ctx, 'data, 'error> = {
      name: string,
      description: Js.undefined<string>,
      deprecationReason: Js.undefined<string>,
      inputFields: Js.Dict.t<Graphql.Input.m>,
      outputFields: output_internal,
      mutateAndGetPayload: ('input, 'ctx) => promise<relayData<'data, 'error>>,
    }

    @module("graphql-relay")
    external withClientMutationId: t__internal<'input, 'ctx, 'data, 'error> => Graphql.Model.m<
      'ctx,
    > = "mutationWithClientMutationId"
  }

  let make = (mutation: t<'source, 'args, 'ctx, 'input, 'data, 'error>) =>
    Internal.withClientMutationId({
      name: mutation.name,
      description: mutation.description->Js.Undefined.fromOption,
      deprecationReason: mutation.deprecationReason->Js.Undefined.fromOption,
      inputFields: mutation.inputFields,
      outputFields: {
        message: mutation.outputFields.message->Graphql.Field.makeField,
        error: mutation.outputFields.error->Graphql.Field.makeField,
      },
      mutateAndGetPayload: mutation.mutateAndGetPayload,
    })
}
