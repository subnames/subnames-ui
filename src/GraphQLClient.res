open Fetch

type graphqlResponse<'data> = {
  data: option<'data>,
  errors: option<array<{"message": string}>>,
}

let doQuery = async (endpoint: string, query: string, variables: option<JSON.t>) => {
  let body = switch variables {
    | Some(vars) => 
      Dict.fromArray([
        ("query", JSON.String(query)),
        ("variables", vars)
      ])
    | None =>
      Dict.fromArray([
        ("query", JSON.String(query))
      ])
  }

  let response = await fetch(endpoint, {
    method: #POST,
    headers: Headers.fromObject({
      "Content-type": "application/json",
    }),
    body: body->JSON.stringifyAny->Option.getOr("")->Body.string
  })

  let json = await response->Response.json
  json->JSON.Decode.object->Option.getOr(Dict.make())
}

// Helper function to make it easier to use with specific response types
let makeRequest = async (
  ~endpoint: string,
  ~query: string,
  ~variables: option<JSON.t>=?,
  (),
) => {
  let response = await doQuery(endpoint, query, variables)
  
  // Parse the response into your expected type
  let data = response->Dict.get("data")
  let errors = response->Dict.get("errors")

  {
    data: data->Option.flatMap(JSON.Decode.object),
    errors: errors->Option.flatMap(json => 
      json->JSON.Decode.array->Option.map(arr =>
        arr->Belt.Array.keepMap(error =>
          error->JSON.Decode.object->Option.flatMap(dict =>
            dict->Dict.get("message")->Option.flatMap(JSON.Decode.string)->Option.map(message => {
              "message": message
            })
          )
        )
      )
    ),
  }
} 