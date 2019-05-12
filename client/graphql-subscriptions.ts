export class GraphqlSubscriptions {
  private webSocket: WebSocket;
  private onConnected: Promise<void>;
  private resolveConnected: (value?: void | PromiseLike<void>) => void;

  constructor(
    websocketUrl: string,
    sendPayloadToElm: (payload: any) => void,
    listenForSubscriptionFromElm: (
      callback: (subscriptionQuery: string) => void
    ) => void
  ) {
    this.onConnected = new Promise((resolve, reject) => {
      this.resolveConnected = resolve;
    });
    this.webSocket = new WebSocket(websocketUrl, "graphql-ws");
    this.addListeners(sendPayloadToElm);
    listenForSubscriptionFromElm((subscriptionQuery: string) => {
      this.addSubscription(subscriptionQuery);
    });
  }

  private async addListeners(sendSubscriptionPayload: (payload: any) => void) {
    this.webSocket.onmessage = event => {
      const data = JSON.parse(event.data);
      switch (data.type) {
        case GQL_MESSAGE_TYPE.CONNECTION_ACK: {
          console.log("ack");
          this.resolveConnected();

          break;
        }
        case GQL_MESSAGE_TYPE.CONNECTION_ERROR: {
          console.error(data.payload);
          break;
        }
        case GQL_MESSAGE_TYPE.CONNECTION_KEEP_ALIVE: {
          break;
        }
        case GQL_MESSAGE_TYPE.DATA: {
          console.log(data.id, data.payload.errors, data.payload.data);
          sendSubscriptionPayload(data.payload);
          break;
        }
        case GQL_MESSAGE_TYPE.COMPLETE: {
          console.log("completed", data.id);
          break;
        }
      }
    };

    this.webSocket.onopen = event => {
      this.webSocket.send(
        JSON.stringify({
          type: GQL_MESSAGE_TYPE.CONNECTION_INIT,
          payload: {}
        })
      );
    };
  }

  addSubscription(subscriptionQuery: string) {
    this.onConnected.then(() => {
      this.webSocket.send(
        JSON.stringify({
          type: GQL_MESSAGE_TYPE.START,
          id: "2",
          payload: { query: subscriptionQuery, variables: null }
        })
      );
    });
  }
}
const GQL_MESSAGE_TYPE = {
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
