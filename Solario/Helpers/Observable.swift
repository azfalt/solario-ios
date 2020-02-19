//
//  Observable.swift
//  Solario
//
//  Created by Hermann W. on 02.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class Observable<T: Equatable> {

    typealias Handler = ((T) -> Void)

    var value: T {
        didSet {
            if oldValue != value {
                notifyObservers()
            }
        }
    }

    private var observers: [ObjectIdentifier: Handler] = [:]

    init(value: T) {
        self.value = value
    }

    deinit {
        observers.removeAll()
    }

    func addObserver(_ observer: AnyObject, handler: @escaping Handler) {
        let id = ObjectIdentifier(observer)
        observers[id] = handler
    }

    func removeObserver(_ observer: AnyObject) {
        let id = ObjectIdentifier(observer)
        observers.removeValue(forKey: id)
    }

    private func notifyObservers() {
        observers.forEach { $0.value(value) }
    }
}
