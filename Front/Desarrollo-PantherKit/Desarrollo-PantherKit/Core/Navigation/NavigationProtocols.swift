//
//  NavigationProtocols.swift
//  NeuraPath
//
//  Created for Clean Architecture refactoring
//

import SwiftUI

/// Protocolo base para todos los coordinators
protocol Coordinator: ObservableObject {
    /// Inicia el flujo de navegación
    func start()
    
    /// Termina el flujo y limpia recursos
    func finish()
}

/// Protocolo para coordinators que pueden tener hijos
protocol ParentCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] { get set }
    
    /// Añade un coordinator hijo
    func addChild(_ coordinator: any Coordinator)
    
    /// Remueve un coordinator hijo
    func removeChild(_ coordinator: any Coordinator)
}

/// Eventos que puede enviar un coordinator hijo a su padre
protocol CoordinatorDelegate: AnyObject {
    func coordinatorDidFinish(_ coordinator: any Coordinator)
}

/// Estados de navegación comunes
enum NavigationState {
    case idle
    case navigating
    case loading
    case error(String)
} 