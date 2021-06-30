const mysql = require("mysql2/promise");

const validationException = (message) => {
  return {
    statusCode: 400,
    body: JSON.stringify({ message }),
  };
};

exports.handler = async (event) => {
  // TODO implement
  const { order } = event["queryStringParameters"];

  if (order !== "ups" && order !== "num_comments") {
    return validationException("order does not have a valid value");
  }

  // Connect in DB
  const connection = await mysql.createConnection({
    host: process.env.rds_endpoint,
    user: process.env.db_username,
    password: process.env.db_password,
    multipleStatements: true,
  });

  const sql = `SELECT author_fullname FROM db.posts ORDER BY ? desc`;

  const [rows, _] = await connection.execute(sql, [order]);

  await connection.end();

  return {
    statusCode: 200,
    body: JSON.stringify(rows.map(({ author_fullname }) => author_fullname)),
  };
};

// (async () => {
//   const response = await this.handler({
//     queryStringParameters: {
//       order: "ups",
//     },
//   });
//   console.log(response);
// })();
