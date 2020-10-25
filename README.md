<p align="center" >
  <img src="https://raw.githubusercontent.com/DhruvGovani/DGNetworkingServices/master/ReadMeAssets/logo.png" alt="DGNetworkingServices" title="DGNetworkingServices">
</p>

![Cocoapods](https://img.shields.io/cocoapods/l/DGNetworkingServices) ![Cocoapods](https://img.shields.io/cocoapods/v/DGNetworkingServices) ![Cocoapods platforms](https://img.shields.io/cocoapods/p/DGNetworkingServices?color=green)

DGNetworkingServices is a Lightweight and Powerful networking library written in Swift Language. and builds on the top of URLSession which will help you to reduce your time and efforts given in coding of the same lines again and again for the Network API Calls for your app.

## Why DGNetworkingServices?

1. URL Configurable : 
     - Write Once and Just change the Postfix of your API.
  2.  Easy Header, Parameters, and Media Support
      - Just Provide the Dictionary with any type of value everything else will be taken care of. 

 3.  Response in Both Dictionary and Data
     - Don't You Hate to Decode Short JSON response?
     -  Don't You also hate to write long code for the large responses and long keys and water it just gets Decoded Like a Piece of cake?
     - This Function provides you the response in Both Data and Dictionary so you can easily use whatever you want for the purpose. You can cache them too.
 4.  More Specific Error
     - more Specific Error with a simple message. ready to show to your app user.

3. Logging for Better Debugging
    - yeah you rode it right You can log the Request and Response to debug the issues.
 6. Easy and Accurate Observation of Call Progress
    - Observer every single fraction of the progress made in your request.
  7. Easy To Use  
 7. Simple Success and Failure Completion Handler
    - switch the Result and modify the actions for success and failure of a call. 
 8. Multilayer Validations
    - Every Request You made will be going through a multilayer of validations before pinging the server.
 10. Pure Swift and URLSession APIs
  12. No Third Party and Easy to Understand CodeBase
# Installation

DGNetworkingServices Supports two methods of installation for now. I will soon integrate the **Carthage** and **Swift Package Manager**.

 ## Installation With Cocoapods
To integrate **DGNetworkingServices** into your **Xcode** project using **CocoaPods**: 

**Create PodFile** if you haven't, cd from your terminal to your project directory and run

> pod init

specify it in your `Podfile`:

> pod 'DGNetworkingServices'

and then run this command in the Terminal

> pod install

(Optional) To update the Current Version 0.0.3

> pod update DGNetworkingServices

 ## Installation With Source Code

Clone The Repository and Drag and Drop <a href = "https://github.com/DhruvGovani/DGNetworkingServices/tree/master/DGNetworkingServices"> DGNetworkingServices</a> folder to your project

Then import framework where you need to use the library

    import DGNetworkingServices



# Usage

Set Target of Project as "Example Project", Hit Run and Keep Eyes on the Console.

## Main Functions

### 1. Simple API Call

    DGNetworkingServices.main.MakeApiCall(Service: NetworkURL, Attachments: [Media?]?, HttpMethod: httpMethod, parameters: [String : Any]?, headers: [String : String], ResponseHandler: (Result<([String : Any], Data), NError>) -> Void)

#### Parameters Info
  **Service:**

  - Service is of Type`NetworkURL` which can be used as follows :

      - NetworkURL(withURL: "https://www.google.com")
              - using like this will directly call the whole url as specified

      - NetworkURL(withService: "users?page=2")
            - for example **DGNetworkingServiceBaseUrl** is set as : DGNetworkingServiceBaseUrl = "https://reqres.in" in <a href="https://github.com/DhruvGovani/DGNetworkingServices/blob/master/ExampleProject/AppDelegate.swift">AppDelegate.swift</a>.
            - and APIVersion is : **DGNetworkingServiceAPIVersion** =  "/api/".
             - and Service **parameter**  is "GetUserData"
              - API Going to be called will be: "https://reqres.in/api/users?page=2"

 **HttpMethod**  : HTTP method use for URL Request

 **parameters**: Parameters you wanted to pass with URL Request

**headers**: Headers you wanted to be set for the URL request

   **ResponseHandler:**

  - This Will Have two cases

      - Success: if Request is successful the response will be return in `[String : Any]` Dictionary as well as `Data` in a tuple data Format.
      
      - Failure: if Request is failed returns Error in `NEError` use the `objectOfError.rawValue`  to get the message behind the error.

### 2. API Call With Media Support

    DGNetworkingServices.main.MakeApiCall(Service: NetworkURL, HttpMethod: httpMethod, parameters: [String : Any]?, headers: [String : String]?, ResponseHandler: (Result<([String : Any], Data), NError>) -> Void)

#### **Media** 
The Media Object via Parameter can be passed by creating `[Media?]?`

- Media: Media is `struct` created to support the media passing through with minimal crashes and errors.
There are 4 different Functions by using it you can create a Media

        let Images : [Media?]? = [
    
         // special function to pass a jpeg image with image compression support
         
            Media(withJPEGImage: UIImage(named: "imageNameHere")!, forKey: "keyHere", compression: .medium),
            
        // special function to pass a png image with image
        
            Media(withPNGImage: UIImage(named: "imageName"), forKey: "keyHere"),
    
        // Special Function to pass the data of a file
        
            Media(key: "keyHere", FileData: Data(), mimeType: nil, fileExtension: "pdf"),
    
        // Special Function which will extract the data from URL provided and pass it through the params
        
            Media(withFileFrom: URL(), fileExtension: "mov", mimeType: nil, key: "keyHere")
    
        ]

    - Key: Key is the name of the parameter where your media is going to be passed as a value
    - mimeType: Leave it nil if you wanted the code to auto fetch it
    - fileExtension: extension of the file to convert or find the correct file

### 3. Download File

Downloading a file with DGNetworkingServices is Simple and Very easy to use.


    DGNetworkingServices.main.downloadFile(Service: NetworkURL, fileName: String, Extension: String, headers: [String : String]?, completion: <(Result<URL, NError>) -> Void>)

The Only Difference the Call has here is `completion`.

**completion** : 

  - This Will Have two cases

      - Success: if the Request is successful file will be downloaded and stored in a temporary location and that `URL` will return. in the handler.
      
      - Faliure: if Request is failed returns Error in `NEError` use the `objectOfError.rawValue`  to get the message behind the error.

**Note**: Download File function will check for the file first before downloading it, so if there is a file available at the location closure will simply return the location of that file and the download call won't be made.

### 4. Upload File

This function allows you to upload the file in the background.

    DGNetworkingServices.main.UploadFile(Service: NetworkURL, HttpMethod: httpMethod, fileUrl: URL, parameters: [String : Any]?, headers: [String : String]?, ResponseHandler: (Result<([String : Any], Data), NError>) -> Void)

the only Different Parameter here is fileUrl

**fileUrl**: Provide the URL of your file and the function will automatically extract the data and uploads it to the server in the background.

### 5. Call Progress Observation

We all wanted to show the users how much their process of Uplink and Downlink is done. **DGNetworkingServices** the Easiest way to get the **fraction** of the data **sent** or **received** via the **API** as a `Double` Value.

##### USAGE

set a delegate to the **DGNetworkingServices** and it will call back the Controller for every fraction progressed.

    DGNetworkingServices.main.delegate = self

Conform to `DGNetworkingServicesDelegate`

Add Protocol Stub `didProggressed`

    func didProggressed(_ ProgressDone: Double) {
    
        print(ProgressDone)
    
    }

### 6. API Loggings

**DISCLAIMER**  : *EVERY LOG OF THE REQUEST OR RESPONSE ARE DONE IN A TEMPORARY VAR. SETTING THEM TRUE WILL AND ONLY WILL LOG THE THE API. EVERY SESSION END AND START OF THE APP CYCLE WILL DESTROY THE LOGS. STORING THEM IN NON-VOLATILE STORAGE LIKE USER-DEFAULTS CAN BE INSECURE FOR THE SYSTEM. NONE OF THE LOGS ARE BEING SENT OUTSIDE OF THE APP IN ANY WAY. PLEASE TAKE SPECIAL NOTE OF THAT.*

Log Your API calls to debug the issues very easily when you can't keep track of which API is called when in a big complex System wherein single ViewController Lots of Things are happening,

to **start Logging** Your Request and Responses do as follows

    DGNetworkLogs.shared.logging = Log(logRequest: true, logResponse: true)

setting one of the true will start the logging of requests/response

**Print logs**: to print all the log till the current line use the following line

    DGNetworkLogs.shared.PrintNetworkLogs(filterByUrl: nil, filterByStatusCode: nil)

- filterByUrl: provide an API URL if you want to see all the logs of that API made during the app cycle.
- filterByStatusCode: best and Very useful when you want to know which requests failed or succeed during the app cycle via the Status Codes.


There are many other functions you will like to use...

> `DGNetworkingServices.main`

to see all the shared resources and function I have for you.

All the functions and even each var have documentation so Just hover and click over the keyword and you will get to know more about each feature,

# Example

<a href = "https://github.com/DhruvGovani/DGNetworkingServices/tree/master/ExampleProject">Example Project</a> have 8 Different Examples for API Calls i request you to check <a href="https://github.com/DhruvGovani/DGNetworkingServices/blob/master/ExampleProject/ViewController.swift">ViewController.Swift</a> to See DGNetworkingServices in real-time action.


#### 1. GET REQUEST


    DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withURL: "https://reqres.in/api/users?page=2"), HttpMethod: .get, parameters: nil, headers: nil) { (Result) in    
        switch Result{
    
            case .success((let ResponseInDict, let ResponseInData)):
    
                print(ResponseInDict)
    
            case .failure(let Error):
    
                print(Error.rawValue)
        
        }
    
    }

## License

<a href = "https://github.com/DhruvGovani/DGNetworkingServices"> DGNetworkingServices</a> is released under the MIT license. See  [LICENSE](https://github.com/DhruvGovani/DGNetworkingServices/blob/master/LICENSE)
