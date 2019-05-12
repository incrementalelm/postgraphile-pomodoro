const buildPlugins = require("graphile-build");
console.log("buildPlugins", buildPlugins);
const { postgraphile, makePluginHook } = require("postgraphile");
const PgOmitArchived = require("@graphile-contrib/pg-omit-archived");

module.exports = {
  options: {
    subscriptions: true,
    simpleSubscriptions: true,
    // Our unprivileged connection string
    connection: "postgres:///pomodoro2",

    watchPg: true,
    // Privileged connection string, we use this for
    // installing the watch fixtures
    ownerConnection: "graphile_example",

    // Respect database permissions
    ignoreRbac: false,

    enhanceGraphiql: true,

    appendPlugins: [
      // Install the simplify inflector for nicer field names
      require("@graphile-contrib/pg-simplify-inflector"),
      PgOmitArchived
    ],

    skipPlugins: [
      // Disable the Node interface for a smaller schema
      require("graphile-build").NodePlugin,
      buildPlugins.MutationPayloadQueryPlugin
    ]
  }
};
