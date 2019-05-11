import { Elm } from "./src/Main.elm";

Elm.Main.init();

const webSocket = new WebSocket("ws://localhost:5000/graphql", "graphql-ws");

const GQL = {
  CONNECTION_INIT: "connection_init",
  CONNECTION_ACK: "connection_ack",
  CONNECTION_ERROR: "connection_error",
  CONNECTION_KEEP_ALIVE: "ka",
  START: "start",
  STOP: "stop",
  CONNECTION_TERMINATE: "connection_terminate",
  DATA: "data",
  ERROR: "error",
  COMPLETE: "complete"
};

webSocket.onopen = event => {
  webSocket.send(
    JSON.stringify({
      type: GQL.CONNECTION_INIT,
      payload: {}
    })
  );
};

const id = "2";

webSocket.onMessage = event => {
  const data = JSON.parse(event.data);
  switch (data.type) {
    case GQL.CONNECTION_ACK: {
      console.log("success");
      break;
    }
    case GQL.CONNECTION_ERROR: {
      console.error(data.payload);
      break;
    }
    case GQL.CONNECTION_KEEP_ALIVE: {
      break;
    }
  }
};

const query = `subscription {
  listen(topic: "timer") {
    query {
      activeTimer {
        kind
        id
        createdAt
      }
    }
  }
}
`;

// webSocket.send(
//   JSON.stringify({
//     type: GQL.START,
//     id,
//     payload: { query, variables: null }
//   })
// );

// webSocket.send(JSON.stringify({
//   type: GQL.START,
//   id,
//   payload: { query, variables, operationName }
// }))
// webSocket.onMessage = event => {
//   const data = JSON.parse(event.data)
//   switch (data.type) {
//     case GQL.CONNECTION_ACK: {
//       console.log('success')
//       break
//     }
//     case GQL.CONNECTION_ERROR: {
//       console.error(data.payload)
//       break
//     }
//     case GQL.CONNECTION_KEEP_ALIVE: {
//       break
//     }
//     case GQL.DATA: {
//       console.log(data.id, data.payload.errors, data.payload.data)
//       break
//     }
//     case GQL.COMPLETE: {
//       console.log('completed', data.id)
//       break
//     }
//   }
// }
//
// webSocket.send(JSON.stringify({
//   type: GQL.START,
//   id,
//   payload: { query, variables: null }
// }))
