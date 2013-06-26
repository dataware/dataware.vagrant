---
layout: default
title: Dataware - the client protocol
---
# Dataware v2 - Client Protocol

## Introduction
This document describes the **Client Protocol** - if you are writing a dataware **Client**, this is the protocol you should follow.
## Protocol Entities:
For the Client Protocol the 4 dataware entities take on the [OAuth 2.0](http://tools.ietf.org/html/draft-ietf-oauth-v2-22) roles described below:

* **The Dataware User:**  The person who owns the data, and is responsible for its control. In OAuth terminology, this is the _resource owner_ (an entity capable of granting access to a protected resource - e.g. the end-user).
* **The Dataware Resource:** The home of the data under consideration. In OAuth terminology, this is the _resource server_ (the server hosting the protected resources, accepting and responding to protected resource requests using access tokens).
* **The Client:** The third party application seeking to process the dataware user’s data. In OAuth terminology, this is also called the _client_ (an application making protected resource requests having been given authorization by the data owner).
* **The Catalog:** The server acting as the dataware user's representative. In OAuth terminology, the catalog is taking the role of the _authorization server_ (the server that issues access tokens to the Client after having successfully authenticated the dataware user and obtained authorization from them.)

## Protocol Flow:

There are 5 stages in the Dataware Client Protocol:

1. <a href="#Client_Registration">Client Registration</a>
2. <a href="#Processing_Request_Submission">Processing Request Submission</a>
3. <a href="#Processing_Request_Authorization">Processing Request Authorization</a>
4. <a href="#Access_Token_Retrieval">Access Token Retrieval</a>
5. <a href="#Processing_Invocation">Processing Invocation</a>
<img src="/assets/img/client_authorization.png"/>

<div id="Client_Registration"></div>
## 1. Client Registration
Before making any processing requests to a Dataware User, the Client first registers with the Catalog by presenting its credentials. If these credentials are accepted by the Catalog it returns a designated **client_id** to the Client.

### 1.1 Client Registration request
To register the client sends a GET request to the **client_register** endpoint, specifying its:

* **client_name:** A unique name for the Client application. This is the name that will dataware users will see when they are presented with the client's processing requests, so that they can identify the requester. Text only and limited to 128 characters.

* **redirect_uri:** After completing its interaction with a dataware user, the Catalog will redirect their browser back to this URI (which may contain a query component but must not include a fragment component, as per [oauth-v2-22](http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-3.1.2)).

* **description:** (optional) An optional description of the client application, which will again be presented to dataware users on receiving processing requests. Text only and limited to 1024 characters.

* **logo_uri:** (optional) An optional URI link to a logo representing the client application.

* **web_uri:** (optional) An optional URI link to the website representing the client application.

* **namespace:** (optional) An optional dataware namespace entry for the application (e.g. "http://www.mydataware.info/thirdpartyapp"), as provided by a trusted third party (n.b. currently unused).

For example:

    POST /client_register
         client_name=example-client&redirect_uri=https%3A%2F%2Fexample%2Ecom%2Fredirect

### 1.2 Client Registration success
If the Catalog decides to accept the registration request, it records the parameters specified by the Client (hence allowing them to be cross-referenced by a dataware user against any future processing requests), and issues the newly registered client a **client_id**, via a json response. For example:

    {"success":true,"client_id":"r47bb8eqrf90hn230fua9sbn2"}

This **client_id** a unique string representing the registration information they provided, and is used as identification by the client in subsequent processing requests to dataware user managed by the Catalog.

### 1.3 Client Registration failure
If the Catalog rejects the registration request, it returns an appropriate json response, denoting the **error** (**"catalog_denied"** or **"catalog_problems"**), and providing a textual description of the error via an **error_description**:

    {"success":false,"error":"catalog_denied","error_description":"A client with that name already exists in the catalog"}

<div id="Processing_Request_Submission"></div>
## 2. Processing Request Submission
Once a Client has been registered with the dataware Catalog, it may issue processing requests to the Catalog in the aim of obtaining an authorization grant. It does this via the **client_request** endpoint, which adheres to the OAuth authorization request standard, taking as parameters:

* **client_id:** as obtained when the client registered.

* **redirect_uri:** the URL that the dataware user's browser will be redirected to when they ultimately accept or reject the request.

* **state:** an internal identifier that the client may use to keep track of their request.

* **scope:**  which contains the request itself. 

As per the OAuth standard, there is also an implicit parameter **response_type** which has a value of "code" - the client need not send this parameter as it will be added by default.

    POST /user/<username>/client_request
         client_id=CLIENT_ID
         &state=1234
         &redirect_uri=https%3A%2F%2Fexample%2Ecom%2Fredirect
         &scope=REQUEST_JSON_OBJECT

_Note that it is the endpoint that contains the Catalog username that the processing request is targeted at, rather than it being specified as a query parameter._

The request object itself, set by the scope parameter, must be included as a JSON object string, and correspond to the following format:

    {
        "resource_name":"TARGET_RESOURCE",
        "expiry_time":UNIX_UTC_TIMESTAMP_IN_SECS,
        "query":"YOUR_PROCESSOR_CODE"
    }

The **query** part of the request object should be a definition for a python function called **run( parameters )**.  No imports are permitted, so only libraries installed on the resource server may be used (the resource server should indicate it in its documentation what libraries are available in its processing module). An example request object is illustrated below:

    {
        "resource_name":"http://www.mydataware.info/prefstore",
        "expiry_time":1312799492,
        "query":"
             def run( parameters ):
                 return 42;
        "
    }

### 2.1 Submission Success
If the Catalog accepts the processing request submission, it will store the request details ready for the dataware user to authorize or reject. The submitting client will be notified of the successful request submission via the json response:

    {"success":true}

### 2.2 Submission Failure
If there has been a problem, and the submission request has failed a JSON error message will be returned via an HTTP 400 response, along with an appropriate "error" cause and an accompanying "error_description" attribute. For example:

    {"success":false, "error":"invalid_scope", "error_description":"incorrectly formatted JSON scope"}

A number of error "reasons" can be returned (corresponding to those detailed in [oauth-v2-22](http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-4.1.2)) - **"invalid_request"** (the request is missing a required parameter, it is malformed, or the requested resource is unrecognized), **"unauthorized_client"** (the client or specified redirect_uri is unrecognized) , **"invalid_scope"** (the JSON scope object is missing or malformed) or **"server_error"** (The Catalog encountered unexpected problems, preventing it from fulfilling the request) - which the client should react to accordingly.


<div id="Processing_Request_Authorization"></div>
## 3. Processing Request Authorization
When a dataware user logs into the service they will be presented with outstanding Processing Requests that have been made from their party clients. The user must then decide whether to accept or reject the request.

### 3.1 Processing Request Rejection
The dataware user may at this point choose to reject the request. If this occurs the Catalog redirects the user’s browser (via an HTTP 302 GET) to the **redirect_uri** that was specified by the client in their processing request submission (see §3) with  an **"access_denied"** error parameter (again taken from [oauth-v2-22](http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-4.1.2)) and an appropriate **error_description**. Also attached is the **"state"** specified by the client when it made the original request, so as that the request can be identified. An example of such a redirect is illustrated below:

     GET REDIRECT_URI?state=1234&error=access_denied&error_description=The+user+denied+your+request  

### 3.2 Processing Request Acceptance
If the dataware-user accepts the client's processing request, the Catalog then notifies the specified resource provider of the processing request in order to register the processor, and obtain an access_token. Note, that the resource provider must still accept the query on their server (normally this involves confirming that the user is registered with them, that the client is acceptable and that the supplied processor has been signed correctly, compiles and is in accordance with the Dataware Resource's local security policies) and may reject the request if it deems fit.

### 3.2.1 Rejection by Resource Provider
If there is any problem at the Resource Provider's end then the whole submission will be automatically rejected. In order to notify the Client of the problem, the Catalog will then redirect the user's browser to the Client's **redirect_uri** (as specified in §2.1), with the error "access_denied" and an error_description explicating the problem. It will also attach is the **state** identifer that was specified by the Client in their submission. Fore example:

     GET REDIRECT_URI?state=1234&error=access_denied&error_description=Request+violates+resource+security. 

### 3.2.2 Clearance by Resource Provider
If it accepts the processor from the Catalog, the resource provider will return an access token to the Catalog that the Client can use to invoke the processor. However, for security purposes, the Catalog does not release this immediately to the Client. Instead it redirects the dataware user's browser to the Client's **redirect_uri** (as specified in §2.1), attaching an authorization **code** along with the **state** identifier specified by the client in their submission. For example the Client could be contacted via:

     GET REDIRECT_URI?state=1234&code=HTQljz7Agfr2P1ckdPP9Lqrz4BJlNDAqHKS54QDL5cM=


<div id="Access_Token_Retrieval"></div>
## 4. Access Token Retrieval
The Client now has an **authorization_code** in its possession, and can proceed to the step of swapping this for the **access token** proper. It does this by performing a GET request the  to the __access__ endpoint, attaching the **redirect_uri** it specified when registering with the Catalog (see §1.1), as well as the request's authorization **code** (see §3.2) and a **grant_type** parameter of **"authorization_code"**, again in line with [oauth-v2-22](http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-4.1.3)). For example the Client would issue a request such as:

    GET access?grant_type=authorization_code
      &redirect_uri=https%3A%2F%2Fexample%2Ecom%2Fredirect
      &code=HTQljz7Agfr2P1ckdPP9Lqrz4BJlNDAqHKS54QDL5cM=

### 4.1 Token Retrieval Success
If all is in order the Catalog will finally release the access_token, by answering the GET request with the following JSON response:

    {"success":true,"access_token":ACCESS_TOKEN,"resource_access_uri":RESOURCE_ACCESS_URI}

The **access_token** can now be used directly with the resource provider via the supplied **resource_access_uri**. The **state** attribute is the one specified by the Client when the processing request was made. With this data in hand, the Client's negotiation with the Catalog is now complete.

### 4.2 Token Retrieval Failure
If there is a problem then the notification will return a failure response explaining why, such as:

    {"success":false,"error":"invalid_request", "Request is missing either the authorization code or redirect_uri"}
       
Possible error reasons are **unsupported_grant_type** (if the grant_type is incorrectly specified), **"invalid_request"** (the request is missing either the authorization code or redirect_uri), **" invalid_grant"** (the requested authorization code/redirect_uri pair is either invalid or has expired) or "server_error" (The Catalog encountered unexpected problems, preventing it from fulfilling the request).


<div id="Processing_Invocation"></div>
## 5. Processing Invocation

With a valid access token in its possession, the Client can now query the resource provider, asking it to invoke the processor it has had authorized by the Catalog . The Client achieves this by making a GET request to the Dataware Resource's **invoke_processor** endpoint, using as parameters the **access_token** it obtained (see §4), as well as any **parameters** that are necessary for the invocation of the python function tied to the request. 

    GET RESOURCE_ACCESS_URI/invoke_processor
        ?access_token=ACCESS_TOKEN&parameters=JSON_OBJECT_OF_PARAMETERS

### 5.1 Processing Invocation Failure
If the user has revoked access, the supplied access token has expired, or there are any other problems the resource provider will fail the invocation, issuing an HTTP 400, and returning the following JSON error in the body of the message:

    {
       "success":false,
       "error":"invalid_grant",
       "error_description":"Error validating access token." 
    }

An exact list of error messages and descriptions are specified by the resource provider, and outside the scope of this protocol.

### 5.2 Processing Invocation Success
However, if all is fine, supplied parameters are converted from JSON into python types, fed into the run function of the registered processor (that the Dataware Resource has cross referenced to the supplied access token) and the processor code invoked. The code will be processed and a success message will be returned to the Client (again in JSON), including the results of the processing: 

    {
        "success":true,
        "return":JSON_REPRESENTATION_OF_PROCESSOR_OUTPUT
    }

If for some reason processing fails (perhaps parameters fail invaraince checks for example), an error message should be returned in the form:
    
    {
        "success":false,
        "error":"processing_exception",
        "error_description":"run-time error running the processor. Invariance checks failed." 
    }

Again individual resource providers will specify appropriate error messages for their particular implementations.