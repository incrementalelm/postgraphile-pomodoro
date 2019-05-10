import { objectType, arg, stringArg } from "nexus";

export const Query = objectType({
  name: "Query",
  definition(t) {
    t.boolean("usernameAvailable", {
      args: {
        username: stringArg({
          required: true
        })
      },
      resolve(_, { username }, context) {
        if (context.usernames.includes(username)) {
          return Promise.resolve(false);
        } else {
          return Promise.resolve(true);
        }
      }
    });
  }
});

function expired(expirationDate: string, discountCode: string) {
  return new Error(
    `discountCode '${discountCode}' expired on ${expirationDate}`
  );
}

function notFound(discountCode: string) {
  return new Error(`Unrecognized discountCode '${discountCode}'!`);
}

function alreadyUsed(discountCode: string) {
  return new Error(
    `The discountCode '${discountCode}' has been used over the limit!`
  );
}
