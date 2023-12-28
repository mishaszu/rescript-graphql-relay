@module("node:assert/strict") external equal: ('a, 'b) => unit = "equal"

open Relay

let args = Args.defaultArgs()->Args.addArg(
  "test",
  {
    type_: Graphql.Types.stringType,
    defaultValue: #String("test"),
    description: "test input type",
  }->Args.make,
)

let testMutation = Mutation.make({
  name: "TestMutation",
  description: "test mutation",
  inputFields: args,
  outputFields: {
    message: {
      type_: Graphql.Types.stringType,
      description: "test output type",
      resolve: async (obj, _args, _ctx) => {
        obj["message"]
      },
    }
    ->#Field3
    ->Graphql.Field.makeField,
    error: {
      type_: Graphql.Types.stringType,
      description: "test output type",
      resolve: async (obj, _args, _ctx) => {
        obj["error"]->Js.Null.return
      },
    }
    ->#Field3
    ->Graphql.Field.makeField,
  },
  mutateAndGetPayload: async (args, _ctx) => {
    open Mutation
    {
      message: args["test"],
      error: Js.Null.empty,
    }
  },
})

open Graphql

type testFields = {
  id: string,
  name: string,
  age: int,
}

let fields = {
  open Graphql.Field
  empty()
  ->addField(
    "id",
    {
      type_: Types.idType,
      description: "my field id",
    }->#Field2,
  )
  ->make
}

let modelType = {
  {
    name: "test",
    description: "my model",
    fields,
  }->ModelType.make
}

let model = {
  type_: modelType,
  resolve: async (_obj, _args, _ctx) =>
    {
      age: 42,
      name: "test name",
      id: "test id",
    }->Js.Null.return,
}->Model.make

let t = Js.Dict.fromArray([("test", model)])

let query = {
  open Query
  empty("test_q")->addField("testQ", model)->make
}

let mutation = {
  open Mutation
  empty("test_m")->addField("testM", testMutation)->make
}

let schema = {
  query,
  mutation,
}->Schema.make

let query = "mutation { testM(input: {}) { message error } }"

Self.make({schema, source: query})
->Js.Promise2.then(async v => {
  let value = v["data"]["testM"]["message"]

  equal(value, "test")
  Js.Promise2.resolve
})
->ignore

let query = "mutation { testM(input: {test: \"my test\"}) { message error } }"

Self.make({schema, source: query})
->Js.Promise2.then(async v => {
  let value = v["data"]["testM"]["message"]

  equal(value, "my test")
  Js.Promise2.resolve
})
->ignore
