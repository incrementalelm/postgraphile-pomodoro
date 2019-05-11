import { Elm } from "./src/Main.elm";

const app = Elm.Main.init();

let pendingSubscriptions = [];

app.ports.startSubscription.subscribe(subscriptionQuery => {
  console.log("startSubscription");
  pendingSubscriptions.push(subscriptionQuery);
});

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

const id = "2";

function startPendingSubscriptions() {
  pendingSubscriptions.forEach(pendingSubscription => {
    console.log("starting subscription", pendingSubscription);
    webSocket.send(
      JSON.stringify({
        type: GQL.START,
        id,
        payload: { query: pendingSubscription, variables: null }
      })
    );
  });
}

webSocket.onmessage = event => {
  const data = JSON.parse(event.data);
  switch (data.type) {
    case GQL.CONNECTION_ACK: {
      console.log("ack");
      startPendingSubscriptions();

      break;
    }
    case GQL.CONNECTION_ERROR: {
      console.error(data.payload);
      break;
    }
    case GQL.CONNECTION_KEEP_ALIVE: {
      break;
    }
    case GQL.DATA: {
      console.log(data.id, data.payload.errors, data.payload.data);
      app.ports.subscriptionPayloadReceived.send(data.payload);
      break;
    }
    case GQL.COMPLETE: {
      console.log("completed", data.id);
      break;
    }
  }
};

webSocket.onopen = event => {
  webSocket.send(
    JSON.stringify({
      type: GQL.CONNECTION_INIT,
      payload: {}
    })
  );
};
