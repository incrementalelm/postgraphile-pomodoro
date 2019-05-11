export class GraphqlSubscriptions {
  webSocket: WebSocket;
  onConnected: Promise<void>;
  resolveConnected: (value?: void | PromiseLike<void>) => void;
  constructor(websocketUrl: string) {
    this.onConnected = new Promise((resolve, reject) => {
      this.resolveConnected = resolve;
    });
    this.webSocket = new WebSocket(websocketUrl, "graphql-ws");
  }

  async addListeners(sendSubscriptionPayload: (payload: any) => void) {
    this.webSocket.onmessage = event => {
      const data = JSON.parse(event.data);
      switch (data.type) {
        case GQL.CONNECTION_ACK: {
          console.log("ack");
          this.resolveConnected();

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
          sendSubscriptionPayload(data.payload);
          break;
        }
        case GQL.COMPLETE: {
          console.log("completed", data.id);
          break;
        }
      }
    };

    this.webSocket.onopen = event => {
      this.webSocket.send(
        JSON.stringify({
          type: GQL.CONNECTION_INIT,
          payload: {}
        })
      );
    };
  }

  addSubscription(subscriptionQuery: string) {
    this.onConnected.then(() => {
      this.webSocket.send(
        JSON.stringify({
          type: GQL.START,
          id: "2",
          payload: { query: subscriptionQuery, variables: null }
        })
      );
    });
  }
}
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
