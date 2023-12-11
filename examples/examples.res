open Graphql
open Relay

type testArgsInput = {"test": Field.field2<string>, ...Args.argsInput}
type testArgsOutput = {"test": Js.undefined<string>, ...Args.argsOutput}

let args = Args.defaultArgs()->Field.addArg(
  "test",
  {
    type_: InputTypes.idType->InputTypes.required,
    description: "test input type",
  },
)

let testMutation = Mutation.withClientMutationId({
  name: "TestMutation",
  description: "test mutation"->Js.Undefined.return,
  inputFields: args->Field.argsToField,
  outputFields: {
    message: {
      type_: InputTypes.stringType,
      description: "test output type",
      resolve: (
        (obj, _args, _ctx) => {
          obj["message"]->Js.Promise.resolve
        }
      )->Js.Undefined.return,
    },
    error: {
      type_: InputTypes.stringType,
      description: "test output type",
      resolve: (
        (obj, _args, _ctx) => {
          obj["error"]->Js.Null.return->Js.Promise.resolve
        }
      )->Js.Undefined.return,
    },
  },
  mutateAndGetPayload: (args: testArgsOutput, _ctx) => {
    Js.Promise.resolve({"message": args["test"]})
  },
})
