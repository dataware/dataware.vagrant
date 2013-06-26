---
layout: default
title: Dataware - the resource protocol
---

# Dataware v2 - Resource Protocol
## Introduction
This document describes the **Resource Protocol** - if you are writing a **Dataware Resource**, this is the protocol you should follow. 

## Protocol Entities
In the Resource Protocol, 3 Dataware entities are involved, taking on the following  [OAuth 2.0](http://tools.ietf.org/html/draft-ietf-oauth-v2-22) roles:

* **The Dataware User:** The person who owns the data, and is responsible for its control. In OAuth terminology, this is the _resource owner_ (an entity capable of granting access to a protected resource (e.g. end-user).
* **The Dataware Resource:** The home of the data under consideration. For the _Resource Installation_ part of the dataware protocol, this actually takes on the role of the _client_ in OAuth terminology (it is asking for authorization to link to the Catalog), although once installed it will become a resource provider.
* **The Catalog:** The server acting as the dataware user's representative. For the _Resource Installation_ part of the dataware protocol, in OAuth terminology the catalog is taking the role of both the _authorization server_ and the _resource_server_.

## Protocol Flow
There are 5 stages to the Resource Installation protocol (although the last two stages refer to processing requests rather than installation _per se_):

 1. <a href="#Resource_Registration">Resource Registration</a>
 2. <a href="#Installation_Request_Submission">Installation Request</a>
 3. <a href="#Installation_Authorization">Access Token Retrieval</a>
 4. <a href="#Processing_Request_Approval">Processing Request Approval</a>
 5. <a href="#Processing_Invocation">Processing Invocation</a>
<img src="/assets/img/resource_installation.png"/>

<div id="Resource_Registration"></div>
## 1. Resource Registration
The workflow begins with the User requesting that the resource starts the installation process (normally via some form of HTML interaction, as indicated by the "install" request in the diagram). If it has not done so in the past, the Resource must first register at the user's Catalog (which it therefore must have previously obtained the address) before taking any further steps. If the Catalog accepts the credentials that the Resource presents to it, it returns an identifying **resource_id**, that the Resource will use in the rest of the process, and indeed in all future communications.

### 1.1 Resource Registration request
To register the Client sends a GET request to the Catalog's **resource_register** endpoint, specifying the following credentials:

* **resource_name:** A unique name for the Resource. This will be presented to Dataware Users when they are presented with an installation request. Text only and limited to 128 characters. Only one resource of any given name may be registered at a catalog.

* **redirect_uri:** After completing its interaction with a Dataware User, the Resource will redirect their browser back to this URI (which may contain a query component but must not include a fragment component, as per [oauth-v2-22](http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-3.1.2)).

* **namespace:** (optional) An dataware namespace entry for the Dataware Resource that indicates the type of resource (e.g. " http://www.mydataware.info/prefstore ").

* **description:** (optional) An optional description of the Resource, its remit and its functionality. This will again be presented to Dataware users when installation requests occur. Text only and limited to 1024 characters.

* **logo_uri:** (optional) An optional URI link to a logo representing the Dataware Resource.

* **web_uri:** (optional) An optional URI link to the website representing the Resource.



For example:

    POST CATALOG/resource_register
         resource_name=example-resource&redirect_uri=https%3A%2F%2Fexample%2Ecom%2Fredirect

### 1.2 Registration success
If the Catalog decides to accept the registration request, it records the parameters specified by the Dataware Resource (hence allowing them to be cross-referenced by a dataware user against any future processing requests), and issues the newly registered Resource a **resource_id**, via a json response. For example:

    {"success":true,"resource_id":"r47bb8eqrf90hn230fua9sbn2"}

This **resource_id** a unique string representing the registration information they provided, and is used as identification by the client in subsequent processing requests to dataware user managed by the Catalog.

### 1.3 Registration failure
If the Catalog rejects the registration request, it returns an appropriate json response, denoting the **error** (**"catalog_denied"** or **"catalog_problems"**), and providing a textual description of the error via an **error_description**:

    {"success":false,"error":"catalog_denied","error_description":"A client with that name already exists in the catalog"}

<div id="Installation_Request_Submission"></div>
## 2. Installation Request 
Assuming that the Dataware Resource has been registered with the Catalog, it may then request installation to user accounts on that Catalog. If successful, this will result in the Resource receiving an **access_token** confirming installation for some User on the Catalog (this access_token also serving as a security credential for future communications between the resource and catalog for that user). 

The Resource initiates the installation by redirecting the user's browser to the Catalog's **resource_request** endpoint. The Resource includes the following parameters:

* **resource_id:** as obtained when the Dataware Resource registered, to identify the resource.

* **redirect_uri:** the URL that the resource wants the User's browser to be redirected back to, after they have accepted or reject the installation request at the Catalog. This must be the same as the one the Resource specified when it registered.

* **state:** an internal identifier that the Resource may use to keep track of their installation request.

As per the OAuth standard, there is also an implicit parameter **response_type** which has a value of "code" - the Dataware Resource need not send this parameter as it will be added by default. For example, the Resource directs the users browser to make the following HTTP request using transport-layer security (extra line breaks are for display purposes only):

    GET CATALOG/resource_request?resource_id=RESOURCE_ID
         &state=1234&redirect_uri=https%3A%2F%2Fexample%2Ecom%2Fredirect

Note that the Resource must have already obtained the user's CATALOG_URI for this redirection to be possible.

When the user's browser redirects this request to the Catalog, the Catalog subsequently validates it to ensure all required parameters are present and valid. If the request is valid, the Catalog authenticates the Dataware User and obtains an authorization decision (by asking the Dataware User directly via html interaction).

### 2.1 Installation Rejection
If the Dataware User denies the installation request, the Catalog notifies the Resource by redirecting the user’s browser (via an HTTP 302 GET) to the **redirect_uri** specified by the Dataware Resource (see §3), along with an **"access_denied"** error parameter (again taken from [oauth-v2-22](http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-4.1.2)) and an appropriate **error_description**. Also attached is the **"state"** specified by the client when it made the original request, so as that the request can be identified. An example of such a redirect is illustrated below:

     GET REDIRECT_URI?state=1234&error=access_denied&error_description=The+user+denied+your+request  

### 2.2 Installation Acceptance
If the Dataware-user accepts the Resource's installation, the Catalog issues an authorization code and delivers it to the Resource by redirecting the user's browser to the Resource's **redirect_uri**, attaching an authorization **code** along with the **state** identifier specified by the client in their submission. For example the Client could be contacted via:

     GET REDIRECT_URI?state=1234&code=HTQljz7Agfr2P1ckdPP9Lqrz4BJlNDAqHKS54QDL5cM=

<div id="Installation_Authorization"></div>
## 3. Access Token Retrieval
The Dataware Resource now has in its possession an **authorization_code**, and can proceed to the step of swapping this for the **access token** proper that confirms its installation. It does this by performing a GET request the  to the **resource_access** endpoint, attaching the **redirect_uri** it specified when registering with the Catalog (see §1.1), as well as the request's authorization **code** (see §4.2) and a **grant_type** parameter of **"authorization_code"**, again in line with [oauth-v2-22](http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-4.1.3)). For example the Resource would issue a request such as:

    GET CATALOG/resource_access?grant_type=authorization_code
      &redirect_uri=https%3A%2F%2Fexample%2Ecom%2Fredirect
      &code=HTQljz7Agfr2P1ckdPP9Lqrz4BJlNDAqHKS54QDL5cM=

### 3.1 Token Retrieval Success
If all is in order the Catalog will release the **access_token**, by answering the GET request with the following JSON response:

    {"success":true,"access_token":ACCESS_TOKEN}

This **access_token** must now be used in all communications between the Catalog and the Dataware Resource as an identity credential. 

At this point, the Dataware Resource's installation is complete.

### 3.2 Token Retrieval Failure
If there is a problem then the notification will return a JSON failure response explaining why, such as:

    {"success":false,"error":"invalid_request", "error_description":"Request is missing either the authorization code or redirect_uri"}
       
Possible error reasons are **unsupported_grant_type** (if the grant_type is incorrectly specified), **"invalid_request"** (the request is missing either the authorization code or redirect_uri), **"invalid_grant"** (the requested authorization code/redirect_uri pair is either invalid or has expired) or "server_error" (The Catalog encountered unexpected problems, preventing it from fulfilling the request).


<div id="Processing_Request_Approval"></div>
## 4. Permitting a Processing Request 
When a third party client request to process data in the Resource is authorized by the data owner, the owner's Catalog will contact the Resource in order to seek final approval. It does this via a POST request to the **permit_processor** endpoint (that all Dataware Resources **must** hence support) along with the following parameters:

 * **install_token**: this is the access_token that the resource received was installed by the user at their Catalog. This token allows the resource to identify who is the target of the third party's query.
 * **client_id**: The id given to the interested third-party client when it registered at the user's Catalog.
 * **query**: a python function called **run( parameters )**. No imports are permitted, so only libraries installed on the Resource server may be used (the Resource server should indicate it in its documentation what libraries are available in its processing module).
 * **expiry_time**: a UNIX UTC timestamp (in seconds) indicating the expiry time of the query, after which it may no longer be invoked.

Having been given with these parameters, the Resource must then decide whether it is happy (or capable) of supporting the processing request that the user has authorized.

### 4.1 Processing Request Rejection
If the Resource decides it cannot support the processing request it must reply with an appropriate error response, as follows:

    {"success":false,"error":"registration_failure","error_description":"An identical request already exists"}

The error types and messages are specific to the Dataware Resource, but may be passed on by the Catalog to the interested third-party to notify them of the reason for the failure of their processing request.

### 4.2 Processing Request Acceptance
If the Resource accepts the processing request, it must record the details of the request in preparation for invocation (see §5) and additionally generate an **access_token** that the third-party will be required to present on attempting invocation. It must then return this token (which the Catalog will pass on to the third-party) via a successful JSON response of the form:

    {"success":true, "access_token":"jf01kklNQP=Lqz7P1fzgfrDiw92d545cM8PzTQljLqz2KSDzp"}


<div id="Processing_Invocation"></div>
## 5. Processing Invocation

With a valid access token in its possession, the third-party can now query the Resource, asking it to invoke the processor it has had authorized by the user and approved by the Resource. The Client achieves this by making a GET request to the Resource's **invoke_processor** endpoint, which any Dataware Resource is mandated to support. The third-party must attach the **access_token** that the Resource delivered to the Catalog in §4.2, as well as any **parameters** that are necessary for the invocation of the python function tied to the request. Thus the Resource must support the following GET request:

    GET RESOURCE_ACCESS_URI/invoke_processor
        ?access_token=ACCESS_TOKEN&parameters=JSON_OBJECT_OF_PARAMETERS

### 5.1 Processing Invocation Failure
If the user has revoked access, the supplied access token has expired, or there are any other problems causing the invocation to be denied, the Resource provider must issue an HTTP 400, and returning the following JSON error in the body of the message:

    {
       "success":false,
       "error":"access_exception",
       "error_description":"Invalid access token." 
    }

The error messages and descriptions are designated by the specific Resource, and outside the scope of this protocol (the resource should document these).

### 5.2 Processing Invocation Success
However, if all is fine, supplied parameters must be converted from JSON into _python_ types, fed into the <font face="courier">**run**</font> function of the registered query (that the Resource has cross referenced to the supplied access token) and the processor code invoked. The code will be processed and a success message must be returned to the user (again in JSON), including the results of the processing: 

    {
        "success":true,
        "return":JSON_REPRESENTATION_OF_PROCESSOR_OUTPUT
    }

If for some reason processing fails (perhaps parameters fail invariance checks for example), an error message should be returned in the form:
    
    {
        "success":false,
        "error":"processing_exception",
        "error_description":"run-time error running the processor. Invariance checks failed." 
    }

Again individual resource providers will specify appropriate error messages for their particular implementations.