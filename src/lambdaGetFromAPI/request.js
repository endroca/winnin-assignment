const https = require("https");
const mysql = require("mysql2/promise");
const fs = require("fs");

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

exports.handler = async (_) => {
  try {
    // Connect in DB
    const connection = await mysql.createConnection({
      host: process.env.rds_endpoint,
      user: process.env.db_username,
      password: process.env.db_password,
      multipleStatements: true,
    });

    // Create DB if it doesn't exist
    const file = fs.readFileSync("schema.sql");
    await connection.query(file.toString());

    // Init request
    const options = {
      hostname: "api.reddit.com",
      path: "/r/artificial/hot",
      headers: { "User-Agent": "Mozilla/5.0" },
    };

    // Request
    const { data } = await request(options);

    // SQL (delete and create if exists or create)
    let sql =
      "REPLACE INTO `db`.`posts` (`title`, `author_fullname`, `ups`, `num_comments`, `created`) VALUES ";

    const values = data.children.reduce((acc, { data: dataRequest }) => {
      const val = [
        ...acc,
        dataRequest.title,
        dataRequest.author_fullname,
        dataRequest.ups,
        dataRequest.num_comments,
        dataRequest.created,
      ];
      return val;
    }, []);

    sql =
      sql + data.children.map(() => "(?, ?, ?, ?, FROM_UNIXTIME(?))").join(",");

    await connection.execute(sql, values);
    await connection.end();

    return {
      statusCode: 201,
      body: JSON.stringify({}),
    };
  } catch (e) {
    return e;
  }
};

// (async () => {
//   const response = await this.handler();
//   console.log(response);
// })();
