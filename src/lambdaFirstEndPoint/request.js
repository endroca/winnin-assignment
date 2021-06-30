const mysql = require("mysql2/promise");

const validationException = (message) => {
  return {
    statusCode: 400,
    body: JSON.stringify({ message }),
  };
};

exports.handler = async (event) => {
  // TODO implement
  const { initial_date, final_date, order } = event["queryStringParameters"];

  if (!initial_date || !final_date || !order) {
    return validationException(
      "initial_date, final_date and order are required"
    );
  }

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

  const sql = `SELECT * FROM db.posts WHERE 
  (created BETWEEN STR_TO_DATE(?, '%Y-%m-%d %H:%i:%s') AND STR_TO_DATE(?, '%Y-%m-%d %H:%i:%s'))
  ORDER BY ? desc`;

  const [rows, _] = await connection.execute(sql, [
    initial_date,
    final_date,
    order,
  ]);

  await connection.end();

  return {
    statusCode: 200,
    body: JSON.stringify(rows),
  };
};

// (async () => {
//   const response = await this.handler({
//     queryStringParameters: {
//       initial_date: "2017-01-01 00:00:00",
//       final_date: "2021-06-29 03:00:00",
//       order: "ups",
//     },
//   });
//   console.log(response);
// })();
