#!/bin/bash
userPoolId=$(aws cognito-idp list-user-pools --max-results 20 --query "UserPools[?name==PollyNotesPool].Id|[0]" --output text)
clientId=$( aws cognito-idp list-user-pool-clients  --user-pool-id $userPoolId --query "UserPoolClients[?ClientName=='PollyNotesAppClient'].ClientId|[0]" --output text)
apiId=$(aws apigateway get-rest-apis --query "items[?name=='PollyNotesAPI'].[id]|[0][0]" --output text)
accountId=$(aws sts get-caller-identity --query "Account" --output text)

awsRegion=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
userPoolArn="arn:aws:cognito-idp:$awsRegion:$accountId:userpool/$userPoolId"
resourceId=$(aws apigateway get-resources --rest-api-id  $apiId  --query "items[?path=='/notes'].id|[0]" --output text)
apiArn="arn:aws:execute-api:$awsRegion:$accountId:$resourceId"
apiUrl="https://$apiId.execute-api.$awsRegion.amazonaws.com/Prod"
# aws cognito-idp sign-up --client-id $clientId --username student --password Test!234 --user-attributes Name="email",Value="mores71655@regishub.com" Name="name",Value="mores"
# aws cognito-idp list-users --user-pool-id us-east-1_N5u8LQff6 --limit 20

# aws cognito-idp admin-confirm-sign-up --user-pool-id $userPoolId --username student

aws apigateway create-authorizer --rest-api-id $apiId --name 'CognitoAuthorizer' --type COGNITO_USER_POOLS --provider-arns $userPoolArn --identity-source 'method.request.header.Authorization'

aws apigateway update-method --rest-api-id $apiId --resource-id a1b2c3 --http-method GET --patch-operations op="replace",path="/authorizationType",value="CUSTOM" op="replace",path="/authorizerId",value="efg1234"

aws apigateway get-resources --rest-api-id  $apiId 

aws apigateway put-rest-api --rest-api-id $apiId --mode merge --body 'fileb:///.api/PollyNotesAPI-swagger.yaml'
roleId=$(aws iam  list-roles --query "Roles[?RoleName=='LabStack-39d389cc-6957-4afc-8129-bfd99df-lambdaRole-7MGFjKcvYJxo'].Arn|[0]" --output text)



  aws lambda add-permission --function-name dictate-function --action lambda:InvokeFunction  --statement-id dictatefunction --principal apigateway.amazonaws.com 
  
  aws lambda list-functions --query "Functions[].FunctionName"
  
  aws lambda create-event-source-mapping \
              --function-name my-function \
              --batch-size 5 \
              --event-source-arn arn:aws:sqs:us-west-2:123456789012:mySQSqueue
              
 aws lambda add-permission --function-name dictate-function --statement-id apigateway-dictate-function --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "$apiArn/*/POST/notes/{id}"


 aws lambda add-permission --function-name delete-function --statement-id apigateway-delete-function --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "$apiArn/*/DELETE/notes/{id}"
