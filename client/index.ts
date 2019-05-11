// import { Elm } from "./src/Main.elm";
const { Elm } = require("./src/Main.elm");
import { GraphqlSubscriptions } from "./graphql-subscriptions";

const app = Elm.Main.init();

let pendingSubscriptions = [];

const webSocket = new WebSocket("ws://localhost:5000/graphql", "graphql-ws");
let graphqlSubscriptions = new GraphqlSubscriptions(
  "ws://localhost:5000/graphql"
);

graphqlSubscriptions.addListeners(app.ports.subscriptionPayloadReceived.send);
app.ports.startSubscription.subscribe((subscriptionQuery: string) => {
  graphqlSubscriptions.addSubscription(subscriptionQuery);
});
