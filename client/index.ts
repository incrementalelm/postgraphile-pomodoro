const { Elm } = require("./src/Main.elm");
import { GraphqlSubscriptions } from "./graphql-subscriptions";

const app = Elm.Main.init();

let graphqlSubscriptions = new GraphqlSubscriptions(
  "ws://localhost:5000/graphql",
  app
);

app.ports.startSubscription.subscribe((subscriptionQuery: string) => {
  graphqlSubscriptions.addSubscription(subscriptionQuery);
});
