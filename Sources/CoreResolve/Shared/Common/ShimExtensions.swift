//
//  ShimExtensions.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2018 The App Studio LLC.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//	   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

// NOTE: ONLY use these shims where you intend to use the same Swift code for multiple platforms
// NOTE: The order of these #if statements matter, in order to support all platforms + Interface Builder + deployment scenarios

#if os(iOS) || os(tvOS)

import UIKit

public typealias Application = UIApplication
public typealias Button = UIButton
public typealias CollectionView = UICollectionView
public typealias CollectionViewCell = UICollectionViewCell
public typealias Color = UIColor
//public typealias EdgeInsets = UIEdgeInsets
public typealias Font = UIFont
public typealias Image = UIImage
public typealias ImageView = UIImageView
public typealias Label = UILabel
public typealias LayoutGuide = UILayoutGuide
public typealias LayoutPriority = UILayoutPriority
//public typealias Responder = UIResponder
public typealias ScrollView = UIScrollView
public typealias Size = CGSize
public typealias StoryboardSegue = UIStoryboardSegue
public typealias TableView = UITableView
public typealias TableViewCell = UITableViewCell
public typealias TextField = UITextField
public typealias View = UIView
public typealias ViewController = UIViewController

#elseif os(watchOS)

import WatchKit

public typealias Application = WKExtension
public typealias Button = WKInterfaceButton
public typealias Label = WKInterfaceLabel
public typealias TableView = WKInterfaceTable
public typealias TableViewCell = NSObject
public typealias View = WKInterfaceObject
public typealias ViewController = WKInterfaceController

#elseif os(macOS)

import AppKit

public typealias Application = NSApplication
public typealias Button = NSButton
public typealias CollectionView = NSCollectionView
public typealias CollectionViewCell = NSCollectionViewItem
public typealias Color = NSColor
//public typealias EdgeInsets = NSEdgeInsets
public typealias Font = NSFont
public typealias Image = NSImage
public typealias ImageView = NSImageView
public typealias Label = NSTextField
public typealias LayoutGuide = NSLayoutGuide
public typealias LayoutPriority = NSLayoutConstraint.Priority
//public typealias Responder = NSResponder
public typealias ScrollView = NSScrollView
public typealias Size = NSSize
public typealias StoryboardSegue = NSStoryboardSegue
public typealias TableView = NSTableView
public typealias TableViewCell = NSTableCellView
public typealias TextField = NSTextField
public typealias View = NSView
public typealias ViewController = NSViewController

#endif
