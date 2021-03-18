# CoreResolve

A framework supporting the development of cross-Apple-platform apps using Swift.

Minimum os target versions are iOS 9, macOS 10.12, and tvOS 10, and watchOS 3

## Purpose ##

While Apple regularly provides excellent new capabilities in the latest OS's (e.g. SwiftUI), often you need to support an app across several OS versions, or even multiple platforms. This is where CoreResolve (and its 'Resolve' template) comes in to help. It provides a consistent experience regardless of the OS version or platform. Therefore, when you are only targeting the latest OS versions, feel free not to use some of the custom classes and protocols. The documentation will strive to suggest Apple alternatives where desired when this is the case.

CoreResolve does not make assumptions about the kind of apps that will be developed. Therefore it contains only app-agnostic protocols, structures, enums, and classes. Furthermore, it does not attempt to provide more capabilities than are generally needed in an app. It does, however, simplify usage of some of Apple's amazing classes, including NSFetchedResultsController

While seeming excessive, CoreResolve also provides some code that wraps existing Apple capability; for the purposes of supporting Unit Tests, as well as unifying access to current and deprecated classes so that the same code can target much older OS's. Some examples are:
 - CoreBeaconIdentityConstraint unifies both CLBeaconRegion and CLBeaconIdentityConstraint
 - CoreNotification unifies UNUserNotificationCenter and NSUserNotificationCenter

Apps that need to share code between its apps and extensions are expected to provide their own frameworks for that purpose, which may extend or abstract away elements from CoreResove, if desired.

The [Resolve](https://github.com/theappstudiollc/Resolve) project template is one example of creating a single app that supports all Apple platforms, and provides excellent guidance on how CoreResolve is meant to be used.

## Some naming conventions ##

* Service: A protocol declaring a service for use by an app and its extensions
* Manager: A concrete implementation of a Service
* Configuration: A common constructor parameter for Managers, which allows them to be app and platform agnostic as much as possible
* Core: This contains app-agnostic implementations and, in general, are extensible

## The future ##

CoreResolve is actively undergoing enhancements and has some TODO's still in the code. Priority for these updates are based on need. It can be useful for Linux environments as well. If you wish to advise or contribute to such an extension, please reach out.
