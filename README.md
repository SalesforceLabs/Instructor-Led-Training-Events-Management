<div>
	<img align="right" width="150" src="images/qbranch_logo.gif">
</div>

# [AppExchange Listing Name](https://appexchange.my.salesforce.com/)

#### _Catchy title about your AppExchange Offering_

#### Sub-title about your AppExchange goes here with any relevant <a href="https://developer.salesforce.com/">links..</a>

<h4 align="center">
	<a href="#features">Features</a> |
	<a href="#getting-started">Getting Started</a> |
	<a href="#usage">Usage</a> |
	<a href="#faqs">FAQs</a> |
	<a href="#documentation">Documentation</a> |
  <a href="#tests">Tests</a> |
	<a href="#contributing">Contributing</a> |
	<a href="#acknowledgements">Acknowledgements</a> 🥰
</h4>

<p align="center">
	<img src="images/silhouette_placeholder.gif">
</p>

---

## Features

Use this highly customisable component to give you a dynamic display of world time from any location in your organisation.

This clock component can be shown on any record or app page, or even place it in the utility bar. It can detect location from standard and custom fields or use the system time along with a list of additional locations if desired.

The component also allows for additional cities to be added through the design attributes to give the user ultimate flexibility.

- **Available on App/Record/Utility -** This component can be used on App Pages, Record Pages and even in the Utility Bar.
- **Field flexibility -** Use any standard or custom field on the record to get the local time, for example Billing City or Shipping City.
- **Additional times -** Add additional locations in the design attributes of the component.

## Getting Started

### Prerequisites

There are a few items you need to setup before installing:

1. You will need to [Enable Lightning Experience](https://trailhead.salesforce.com/en/content/learn/modules/lex_migration_introduction/lex_migration_introduction_administration).
2. You will need to [Enable My Domain](https://trailhead.salesforce.com/en/content/learn/modules/identity_login/identity_login_my_domain).

### Install

#### AppExchange

Please navigate to the AppExchange link below to install the component.

<p align="left">
	<a href="https://appexchange.salesforce.com/appxListingDetail?listingId=placeYourListingIDHere">
		<img width=200 src="images/available-on-appexchange.png">
	</a>
</p>

#### SFDX

Deploy the source:

1. Clone this repository:

```
git clone git@github.com:sfdc-qbranch/<REPONAME>.git
cd <REPONAME>
```

2. Authorize with your org and provide it with an alias (OrgAlias):

```
sfdx force:auth:web:login -a "OrgAlias"
```

3. Push the app to your org:

```
sfdx force:source:deploy --sourcepath force-app/main/default --json --loglevel fatal --targetusername "OrgAlias"
```

4. Open the default org:

```
sfdx force:org:open --targetusername "OrgAlias"
```

## Usage

There are 2 Lightning Components included:

- **[Sample Component 1](#sample-component-1)** - A brief brief description of what this component does.
- **[Sample Component 2](#sample-component-2)** - Another brief description of what this component does.

### Sample Component 1

#### Adding components to a App or Record Page:

Navigate to your app or record page that you want to add the component to and click the cog icon on the top right and select “Edit Page” see screenshot below.

<div>
	<img src="images/silhouette_placeholder.gif">
</div>

---

This will bring you to the App Builder for the specific page you clicked “Edit Page” from. Scroll down to the Custom - Managed section on the left hand side component list. From there you can drag the “Dynamic World Clock” component onto any section of the page as shown in the next screenshot below.

<div>
	<img src="images/silhouette_placeholder.gif">
</div>

---

As you can see after dropping the component onto the page, there are a number of configurable attributes to the component. There is an explanation of all the input values depending on which type of page you are using it on [below](#supported-options).

### Sample Component 2

#### Adding components to a Utility Bar

To add the component to the Utility bar of a console app, you will need to know the name of the console app. Once you have that, you can click the cog on the top right of any page and click “Setup”. From there, type “App Manager” in the quick find box and you should be placed on a page like the screenshot below.

<div>
	<img src="images/silhouette_placeholder.gif">
</div>

---

From this page, you will need to find the console app we noted from earlier and click the dropdown action button on the right hand side of its name and press “Edit”. This will open up the App Builder for the console app. From here we need to click “Utility Items (Desktop Only)” on the left hand vertical navigation. The resulting page should look like the screenshot below.

<div>
	<img src="images/silhouette_placeholder.gif">
</div>

---

From here, you can click on the “Add Utility Item” button. This will give you a list of all available components, but the component we are looking for is the “Dynamic World Clock” component that should be in the “Custom” section near the bottom. Once you click that, you will be presented with a list of configurable options that are split into two sections, “Utility Item Properties” & “Component Properties”. The “Component Properties” are explained in the Design Attributes screenshot above. There are default attributes in place but please feel free to customise these to suit your needs, in particular the “Hide System Time” & “Additional Time Locations” fields as they control the locations that are shown in the component. Once you’re happy with your selections. Please press the save button at the bottom of the page. Screenshot below.

<div>
	<img src="images/silhouette_placeholder.gif">
</div>

---

Once you have saved this page, you can press the “Back” button on the top right of the page which will bring you back to setup. From here use the app launcher to navigate back to your console app to see the component in action.

See the screenshot below for utility bar view of the component and note the “Start Automatically” attribute in the previous screenshot which makes the component auto pop when the page loads.

<div>
	<img src="images/silhouette_placeholder.gif">
</div>

---

### Supported options

| Option                      | Description                                                                              |
| --------------------------- | ---------------------------------------------------------------------------------------- |
| `Recipient To Addresses`    | Recipient To Addresses, Max 100, Comma Delimited                                         |
| `Recipient Cc Addresses`    | Recipient Cc Addresses, Max 25, Comma Delimited                                          |
| `Recipient Bcc Addresses`   | Recipient Bcc Addresses, Max 25, Comma Delimited                                         |
| `Email Template Id or Name` | Id, Name, or Developer Name of Email Template                                            |
| `Email Subject`             | Email Subject                                                                            |
| `Email Plain Text Body`     | Email Plain Text Body                                                                    |
| `Email Html Body`           | Email Html Body                                                                          |
| `Email Character Set`       | The character set for the email. If this value is null, the user's default value is used |
| `Attachment Ids`            | Comma delimited list of Document, ContentVersion, or Attachment Ids                      |

## Documentation

Read the [Quip][quip-url] for external documentation on the component.

## [Tests][tests-url]

To be added...

## FAQs

#### Does it work in Communities?

> Yes

#### Does it work in Mobile?

> Yes

#### Does it work with Person Accounts?

> Yes

#### Others?

## [Contributing](/CONTRIBUTING.md)

See the list of [Contributors][contributors-url] who participated in this project.

If you would like to join these awesome people, please refer to [contributing.md](/CONTRIBUTING.md) for guidelines.

## Acknowledgements

Special thanks to:

- Q Branch Dublin for your continued support.
- Everyone that has requested for, used and provided feedback on this project.

## License

[![License][license-shield]][license-url] Copyright © 2020 [Q Branch][author-url]

<!--- Images -->

[license-shield]: https://img.shields.io/badge/License-BSD%203--Clause-blue.svg

<!--- Urls -->

[repository-url]: https://github.com/sfdc-qbranch/AppExchangeTemplate
[downloads-url]: https://github.com/sfdc-qbranch/AppExchangeTemplate/releases
[issues-url]: https://github.com/sfdc-qbranch/AppExchangeTemplate/issues
[license-url]: http://opensource.org/licenses/BSD-3-Clause
[author-url]: http://github.com/matqo
[contributors-url]: https://github.com/sfdc-qbranch/AppExchangeTemplate/contributors
[tests-url]: https://github.com/sfdc-qbranch/AppExchangeTemplate/tests
[quip-url]: https://salesforce.quip.com/um8sAuXNyCnO
