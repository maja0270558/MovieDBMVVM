//
//  main.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/24.
//

import Foundation
import UIKit

let appDelegateClass: AnyClass = NSClassFromString("TestingAppDelegate") ?? AppDelegate.self

UIApplicationMain(CommandLine.argc,
                  CommandLine.unsafeArgv,
                  nil,
                  NSStringFromClass(appDelegateClass))
