# How to start with ADP integration


So you got in touch with ADP people and they have sent you the ADP Marketplace Partner Credentials document. This document, as the rest of ADP documentation, is a little bit overwhelming with the amount of information it carries. This article aims to ease this cognitive effort and help you with understanding the overall workflow as well as how the actual integration will work when implemented.


## What the document is all about?


There are two main things ADP onboarding document carries:
three different sets of credentials + other access info, allowing you to develop your integration using ADP sandbox environment,
rather vague description of how you can access ADP services.

One thing that made my mind blown away was lack of foreword and a high level description of the process. Why I need this document? How should I start? Do I need to do anything before I can access organization data within ADP?

## The Big Picture


We have a organization registered within some system. Now, we would like to offer integration between the system and ADP - so we could sync employees, do payroll, basically leverage any functionality that ADP offers.
To achieve that, we need the ADP marketplace application. This is kind of an entry point for our services into ADP APIs. Whenever you want to grab something from ADP APIs, you need to go through ADP Marketplace and first implement your ADP marketplace application.
When your ADP application is live in the ADP Marketplace, then ADP users are able to subscribe to it (by buying the app subscription), allowing your system to grab the data related to their ADP organisations. From this moment you can use ADP APIs on behalf of the org that subscribed to you application.
To get to this point, first you need to do two other things:
integrate with ADP Marketplace subscription mechanisms,
integrate with ADP SSO service.

This article (as well as ADP onboarding document) assumes you got those two things sorted out (by providing you pre-subscribed organization and other things which are set up for you) and explains how to approach the very consumption of ADP Data APIs. This is just to give you the idea of how you would access APIs.

## How to create your own ADP app?


To do this, we would create the App Listing while being logged into ADP Marketplace using your Developer Credentials. You won't find these within ADP Marketplace Partner Credentials document, they would rather be delivered to you with email titled ADP Generated Message: Enrolling for ADP Marketplace. 
The process of the App Listing creation is described within the document, but you wouldn't actually interact with the app just yet, this will be a part of the first step of your integration, which would be Marketplace integration.

## How to use the document?


The ADP Marketplace Partner Credentials document's purpose is to demo you how the integration would work when implemented. I had myself some difficulties to understand it fully, so I scripted it out a bit. You can find the code here.
Three sets of credentials
There are three different sets of credentials in the document.
 Partner Credentials for Marketplace,
Partner Credentials for Single Sign-On,
Partner Credentials for Data Connector.

Huh, that's a lot! All three credentials have its purpose and all use different authorization standards. Let's briefly go through them one by one.
Partner Credentials for Marketplace
As you already know, you need to start your integration with a creation of your new shiny ADP Marketplace application. These credentials would allow you to authorize against ADP Marketplace using OAuth1 authorization standard. 
Funny thing is, I never used them. When you create you App Listing you will get the proper ones generated for your app as described in the document. Don't worry about it for now, we can cover how to speak with ADP Marketplace using OAuth1 in another article.
Partner Credentials for Single Sign-On
When you already have Marketplace integration in place, that means ADP users are able to subscribe to it and allow your system to access ADP APIs on his behalf. To make it easier for him to move about between ADP and your service, you are requested to implement SSO. 
The standard used for SSO is OpenID Connect. Implementing it is Step 2 of your integration.
Partner Credentials for Data Connector
This is something we were wanting to use in the first place! Those creds are giving us access to the ADP data APIs we can consume in behalf of the subscriber.
 Although this is kind of the last stage you'd normally approach during the implementation process, ADP folks decided it's a good idea to vaguely describe the process in the document, which description I personally find insufficient to say at least and which I'll try to explain below.

## THE MEAT!


So there's a user who subscribes his organization to your app. This process can differ in details depends how you sort this out with the ADP sales team. The important thing is, you already have one org pre-subscribed to your application, given to you for testing purposes. This org is identified by organizationOID parameter which you can find in the document (search for "Sandbox OrganizationOID"). Having this subscription in place means you can start to play with ADP APIs.
Normally, right after the subscription, the user who initiated the process would be additionally asked to provide the consent so your system could grab his credentials and use them for talk to ADP APIs on his behalf.
Grab his credentials? Yes! To query the API in behalf of the organization, you first need to use your Partner Credentials for Data Connector to fetch the organization credentials and then use those to talk to ADP APIs.
This sounds complicated but it's not, really. I'll try to kind-of visualise things with some scripts.
You need a cert first!
Although there are some dead simple curl examples on ADP APIs reference website that don't include cert stuff and any authorization header (and which do work, oddly), they don't show how the actual request should be made and there's one crucial element missing in those examples: mutual ssl certificate.
You can obtain it by issuing Certificate Signing Request - log in to Marketplace (with your Developer Credentials), find Certificate Signing Request app, subscribe to it, click on it and follow instructions.
In the result of this process you will get your private key (presented to you while issuing CSR) and the signed certificate (sent to you by email). This certificate needs to be used with every API request.
**NOTE** for this demo purposes, within the email received from ADP there are different types of certs, you should download and use `Certificate (w/ chain), PEM encoded` one.
Clone the repo
I created some ready-made scripts to help you understanding the flow, you can clone it from here. There's a set of bash scripts we will be using, you should inspect them to see what is the structure of requests issued.
Set up the environment
Let's set up some environment variables that will be used by our Bash scripts.

```
# obtained from Certificate Signing Request process
export ADP_CERT_PATH=/path/to/pem/encoded/cert/file
export ADP_KEY_PATH=/path/to/private/key/file
# defined in ADP onboarding document as "Partner Credentials for Data Connector"
export ADP_PARTNER_CLIENT_ID=aaaaaaaa-48d0-dddd-cccc-3b12999934cd
export ADP_PARTNER_CLIENT_SECRET=bbbbbbbb-e912-dddd-aaaa-9799999c219c
# defined in ADP onboarding document as "Sandbox OrganizationOID"
export ADP_SANDBOX_ORGANIZATION_OID=G3DXXXX1XXX1BQRD
```

## Obtaining Partner access token with Partner Credentials

When you have the prerequisites set up correctly, now you can obtain your Partner access token to be used for API calls. This will use OAuth2 Client Credentials Grant with Basic Authorization.

```
export ADP_ACCESS_TOKEN=$(bash/oauth/token)
echo $ADP_ACCESS_TOKEN
```

This will return access token and assign it to bash variable; complete curl payload would look something like this

```
{
  "access_token":"91a260c2-bbbb-aaaa-cccc-bdbce5b5ab22",
  "token_type":"Bearer",
  "expires_in":3600,
  "scope":"api"
}
```

This access token is for the Partner APIs only so it won't allow you to fetch any data related to the organization subscribed to your app. For this, you will need this organization's credentials, which in turns you'll need to use to obtain client's OAuth2 access token (just like you did with Partner OAuth2 access token above).
Obtaining Client access token with Client Credentials
To be able to fetch client credentials, you need to provide the consent with Data Connector Consent Manager link (see ADP onboarding pdf). I mentioned before this would be one of the steps you'd normally follow when subscribing to ADP app, but as long as sandboxed organization is already subscribed to your app, this needs to be done "manually". Consult with your PDF how to do this.
To fetch client credentials you need to use partner access token obtained in the previous step along with subscriptionOrganizationOID (sandboxed organization identifier, which is subscribed to your app). 
bash/client-credentials/read $ADP_ACCESS_TOKEN
This will return just the credentials from the received payload. Full curl response will look something like this

```
{
  "events":[
    {
       "eventID":"9292be53-cdcd-4c90-8c33-e45b3d66a04c",
       "eventNameCode":{
         "codeValue":"consumer-application-subscription-credentials.read"
       },
       "effectiveDateTime":"2020-02-20T12:24:40.933Z",
       "creationDateTime":"2020-02-20T12:24:40.933Z",
       "recordDateTime":"2020-02-20T12:24:40.933Z",
       "data":{
         "output":{
           "consumerApplicationSubscriptionCredentials":[
             {
               "clientSecret":"367fdddd-bbbb-4784-b2a0-aaaa4d29bb",
               "clientID":"0d05cccc-eeee-4f2c-a12e-ffff829cffff",
               "subscriberOrganizationOID":"G3DXXXX1XXX1BQRD"
             }
           ]
         }
       },
       "eventStatusCode":{
         "codeValue":"complete",
         "shortName":"Complete"
       },
       "serviceCategoryCode":{
         "codeValue":"hr"
       },
       "actor":{
         "associateOID":"DDD4P1AQBSXXXX9D"
       },
       "originator":{
         "associateOID":"DDD4P1AQBSXXXX9D"
       }
     }
   ]
 }
 ```

What we are after is the **consumerApplicationSubscriptionCredentials** section.
Obtaining access token with client credentials
Now we need another access token so we could fetch stuff in client context - or rather in the context of specific consumer application subscription. 

```
export ADP_SUBSCRIPTION_ACCESS_TOKEN=$(bash/oauth/token <clientID> <clientSecret>)
echo $ADP_SUBSCRIPTION_ACCESS_TOKEN
```

## Fetching subscribed organization data

Finally! with this access token we can do stuff using ADP Data APIs! As an example, you can fetch workers information with 

```
bash/workers/get $ADP_SUBSCRIPTION_ACCESS_TOKEN
```

## Summary


To get hold of the organization data that is subscribed to your ADP app, you need to:

1. use your OAuth2 partner credentials to obtain the partner access token,

2. with this access token, you need to request for OAuth2 client/consumer credentials,

3. with client credentials, you'd get the client access token specifically for the organization you want to access on ADP side.

That's all!