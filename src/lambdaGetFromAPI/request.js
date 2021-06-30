const https = require("https");
const mysql = require("mysql");
const fs = require("fs");

module.exports.handle = async () => {
  const connection = mysql.createConnection({
    host: process.env.rds_endpoint,
    user: process.env.db_username,
    password: process.env.db_password,
  });

  const connect = () =>
    new Promise((resolve, reject) => {
      connection.connect(function (err) {
        if (err) {
          reject("error connecting: " + err.stack);
          return;
        }

        resolve(connection.threadId);
      });
    });

  const request = (options) =>
    new Promise((resolve, reject) => {
      https
        .get(options, (resp) => {
          let data = "";

          resp.on("data", (chunk) => {
            data += chunk;
          });

          resp.on("end", () => {
            resolve(JSON.parse(data));
          });
        })
        .on("error", (err) => {
          reject("Error: " + err.message);
        });
    });

  try {
    await connect();
    const file = fs.readFileSync("schema.sql");
    connection.query(file.toString());

    // const options = {
    //   hostname: "api.reddit.com",
    //   path: "/r/artificial/hot",
    //   headers: { "User-Agent": "Mozilla/5.0" },
    // };

    // const { data } = await request(options);

    // return {
    //   statusCode: 200,
    //   body: data.children.map(({ data: dataRequest }) => {
    //     return {
    //       title: dataRequest.title,
    //       author_fullname: dataRequest.author_fullname,
    //       created: dataRequest.created,
    //       ups: dataRequest.ups,
    //       num_comments: dataRequest.num_comments,
    //     };
    //   }),
    // };
  } catch (e) {
    return e;
  }
};

(async () => {
  const call = await this.handle();
  console.log(call);
})();
