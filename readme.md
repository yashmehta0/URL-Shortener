- Objective: URL shortening system 

- Resources Used : 
    1. API Gateway
    2. Lambda
    3. S3
    4. IAM Roles & Policies


- Architecture: An API Gateway is created with two resources. 
    1. One resource with "shrink_url" path shortens the url and map the short url to the long url and store it in S3. Lambda is triggered in the backend which is written in python. It checks for the shorten url in the S3, if it is already created then it will create another shorten url and will keep on creating until it finds a shorten url which is not already created in S3. After successfully creating a shorten url it maps that url with the long url and store it in S3 with the redirection url.  
    2. Second resource redirects the short url to the long url. Lambda is triggered in the backend which is written in python. It will retrieve the S3 object based on the shorten url key used in path. It will give back the response to API gateway which will handle 302 statusCode and perform the redirection based on response body got back from lambda.

    IAM roles & policies are created to give specific permission to Lambdas and APIGateway to access other AWS resources