# BlackBerry Spark SDK - Swift Sample for iOS

## Overview

This Swift application demonstrates how the BlackBerry Spark SDK for iOS can be integrated into a fictitious consumer banking application called 'Pyrite Financial' 

#### BlackBerry Spark BETA

BlackBerry Spark is a security library for iOS and Android which provides in-app protection. It performs device, software and content checks in order to protect against security vulnerabilities and detect malicious activity. The library utilizes BlackBerry's Infrastructure to assess and respond to the latest threats. 

**Note:** As of October 2020, the Spark SDK is currently available as a public beta release that is subject to further testing and changes by BlackBerry. 

For additional information, see the [Developer Guide](https://docs.blackberry.com/en/development-tools/blackberry-spark-sdk/)

## Prerequisites 

- Install Xcode 11 or later
- CocoaPods 1.7 or later

## Getting Started

BlackBerry Spark utilizes threat models and configuration from BlackBerry Cloud and therefore it is necessary to **Register with BlackBerry** your instance of the sample before it can be run on a simulator or device. Registering and developing apps is **free**, although you do need to agree to the [Terms of Service](https://www.blackberry.com/secureappsdk).

User login is implemented using **Firebase Authentication**. This sample demonstrates how an identity token from an Open ID Connect Identity Provider (i.e. Firebase) enables the runtime to authenticate with BlackBerry's Infrastructure.

Once you have cloned the sample from GitHub you'll need to perform the following configuration steps:-

1. Create Firebase Project
2. Register with BlackBerry
3. Add Firebase IDP configuration to BlackBerry MyAccount
4. Add the BlackBerry App Client ID to your app plist.

### Step 1. Create Firebase Project
1. Create a Firebase project and register your iOS application. 
    See Steps 1 to 3: [https://firebase.google.com/docs/ios/setup](https://firebase.google.com/docs/ios/setup)

  - Firebase Console Step 1: Create Firebase Project
  - Firebase Console Step 2: Register iOS Application 
  - Firebase Console Step 3: Add Firebase Configuration file
    - Download the **GoogleService-Info.plist** 
    - Move your config file into the root of the Pyrite Financial Xcode project. If prompted, select to add the config file to all targets.

2. Install pod dependencies by running `pod install` or `pod update` from the command-line within your project.

3. To configure the Firebase Identity Provider with BlackBerry you need to retrieve the project ID from the Firebase console. 

   a) From the 'Project Overview' select 'Project Settings'.

   b) Copy the 'Project ID'.

   <img src="images/Firebase-ProjectSettings.png" alt="Firebase - Project Settings" style="zoom:60%;" />

4. Enable Email/Password as a sign-in method and add a test user.

   a) Select 'Authentication' from the left hand menu in the Firebase console.

   b) On Sign-In Method tab, enable Email/Password as a sign-in method.

   c) On Users tab click 'Add User'.

   d) Enter the 'Email' and 'Password' for a test user. 

### Step 2. Register with BlackBerry

1. Goto: [https://account.blackberry.com/a/organization//applications/add](https://account.blackberry.com/a/organization//applications/add?capability=mtd)
   If you are new to BlackBerry you will need to register for a BlackBerry Online Account and agree to the Terms of Service.
2. Provide the following application information to register your instance of Pyrite Financial:
   - **Application Name:** Pyrite Financial
   - **Entitlement ID:** com.company.sample.pyritefinancial 
     - Note, you cannot use 'com.blackberry.*''
   - **Management**: Uncheck 'Application will be managed by BlackBerry UEM'. This enables you to use Firebase for authentication. 
   - **Capabilities:** Ensure 'BlackBerry Protect' is selected. This enables your application to utilize the BlackBerry Protect threat models.

### Step 3: Add IDP configuration to BlackBerry MyAccount

Use the Firebase Project ID from Step 1 to configure your IDP within BlackBerry myAccount.

1. Select the 'IDP' tab on the application you have just registered.

<img src="images/BlackBerryMyAccount-IDPConfiguration.png" alt="BlackBerry IDP Configuration" style="zoom:60%;" />

2. Enter the following 'Discovery URL' and substitute your Firebase 'Project-ID'

   `https://securetoken.google.com/{Project-ID}/.well-known/openid-configuration`

3. Add an Authorized Client ID using the Firebase Project-ID.

Once your IDP is registered a BlackBerry App Client ID will be created. 

### Step 4. Add the BlackBerry App Client ID to your app

Copy the App Client ID created in the previous step and add it to the sample applications 'info.plist' in Xcode.

```
<dict>
   <key>BlackBerrySecuritySettings</key>
   <dict>
      <key>ClientID</key>
            <string>abcdefgh-1234-1234-1234-abcdefgh</string>
     </dict>
</dict>
```

### Step 5. Run the sample

You are now ready to run the 'PyriteFinancial' sample application in the simulator or on a device. 

1. Open 'Pyrite Financial.xcworkspace' in Xcode 11.
2. Build and Run.
3. When prompted to login, use the email and password for the test user you created when setting up Firebase.
4. Click on Messages, select the message and then click on the URLs in the message to test content checking.
5. Enable and disable features on your device such as Screen Lock to test device security checking. 

## Getting Help

### Documentation

For detailed documentation on BlackBerry Spark SDK for iOS please see the [Developer Guide](https://docs.blackberry.com/en/development-tools/blackberry-spark-sdk/)

### Support

To get help from BlackBerry and other developers or to provide feedback please join the [BlackBerry Beta Community](https://ebeta.blackberry.com/key/join). 

## License

Apache 2.0 License

