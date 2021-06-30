const mysql = require("mysql2/promise");

const validationException = (message) => {
  return {
    statusCode: 400,
    body: JSON.stringify({ message }),
  };
};

exports.handler = async (event) => {
  try {
    // TODO implement
    const { order } = event["queryStringParameters"] || {};

    if (order !== "ups" && order !== "num_comments") {
      return validationException("order does not have a valid value");
    }

    // Connect in DB
    const connection = await mysql.createConnection({
      host: process.env.rds_endpoint.replace(":3306", ""),
      user: process.env.db_username,
      password: process.env.db_password,
      multipleStatements: true,
    });

    const sql = `SELECT author_fullname FROM db.posts ORDER BY ${order} DESC`;

    const [rows, _] = await connection.query(sql);

    await connection.end();

    return {
      statusCode: 200,
      body: JSON.stringify(rows.map(({ author_fullname }) => author_fullname)),
    };
  } catch (e) {
    return {
      statusCode: 500,
      body: JSON.stringify({ message: e }),
    };
  }
};

// (async () => {
//   const response = await this.handler({
//     queryStringParameters: {
//       order: "ups",
//     },
//   });
//   console.log(response);
// })();
