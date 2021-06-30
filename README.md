# Reddit consumer

Project developed for a proof of concept

## Setup

```shell
aws configure

cd src
cd lambdaFirstEndPoint
npm run deps
cd ..
cd lambdaGetFromAPI
npm run deps
cd ..
cd lambdaSecondEndPoint
npm run deps
cd ..
cd ..

terraform init
terraform plan
terraform apply

# First invocation or wait for the first schedule
aws lambda invoke --function-name get_data_from_external_api out --log-type Tail --query 'LogResult' --output text |  base64 -d
```

## Shutdown

```shell
terraform destroy
```

## Request

```http
GET firstEndPoint/?initial_date=2017-01-01 00:00:00&final_date=2021-06-29 03:00:00&order=ups
```

| Parameter      | Type     | Description                            |
| :------------- | :------- | :------------------------------------- |
| `initial_date` | `string` | **Required**, YYYY-mm-dd hh:mm:ss |
| `final_date`   | `string` | **Required**, YYYY-mm-dd hh:mm:ss |
| `order`        | `string` | **Required**, ups or num_comments      |

```http
GET secondEndPoint/?order=ups
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `order`   | `string` | **Required**, ups or num_comments |
