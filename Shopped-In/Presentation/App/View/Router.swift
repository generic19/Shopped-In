//
//  Router.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 30/05/2025.
//
import SwiftUI

typealias Route = Hashable

final class Router: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to route: any Route) {
        path.append(route)
    }
    
    func setRoot(route: any Route) {
        path.removeLast(path.count)
        path.append(route)
    }
}

