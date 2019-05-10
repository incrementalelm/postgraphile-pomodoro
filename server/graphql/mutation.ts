import { objectType, arg, stringArg } from "nexus";

export const Mutation = objectType({
  name: "Mutation",
  definition(t) {
    t.boolean("createUser", {
      args: {
        username: stringArg({
          required: true
        })
      },
      resolve(_, { username }, context) {
        if (context.usernames.includes(username)) {
          return Promise.resolve(false);
        } else {
          context.usernames.push(username);
          return Promise.resolve(true);
        }
      }
    });
  }
});
