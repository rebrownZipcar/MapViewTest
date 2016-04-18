//
//  Observable.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/15/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//  From https://medium.com/proto-venture-technology/the-state-of-kvo-in-swift-aa5cb1e05cba#.xagt87f3b


import Foundation

struct Observable<T>
{
    typealias ValueType = T
    typealias SubscriptionType = Subscription<T>

    var value: ValueType
    {
        didSet
        {
            for subscription in subscriptions
            {
                let event = ValueChangeEvent(oldValue, value)
                subscription.notify(event)
            }
        }
    }

    private var subscriptions = Subscriptions<ValueType>()

    mutating func subscribe(handler: SubscriptionType.HandlerType) -> SubscriptionType
    {
        return subscriptions.add(handler)
    }

    mutating func unsubscribe(subscription: SubscriptionType)
    {
        subscriptions.remove(subscription)
    }

    init(_ value: ValueType)
    {
        self.value = value
    }
}

struct ValueChangeEvent<T>
{
    typealias ValueType = T

    let oldValue: ValueType
    let newValue: ValueType

    init(_ o: ValueType, _ n: ValueType)
    {
        oldValue = o
        newValue = n
    }
}

class Subscription<T>
{
    typealias ValueType = T
    typealias HandlerType = (oldValue: ValueType, newValue: ValueType) -> ()

    let handler: HandlerType

    init(handler: HandlerType)
    {
        self.handler = handler
    }

    func notify(event: ValueChangeEvent<ValueType>)
    {
        self.handler(oldValue: event.oldValue, newValue: event.newValue)
    }
}

struct Subscriptions<T>: SequenceType
{
    typealias ValueType = T
    typealias SubscriptionType = Subscription<T>

    private var subscriptions = Array<SubscriptionType>()

    mutating func add(handler: SubscriptionType.HandlerType) -> SubscriptionType
    {
        let subscription = Subscription(handler: handler)
        self.subscriptions.append(subscription)
        return subscription
    }

    mutating func remove(subscription: SubscriptionType)
    {
        var index = NSNotFound
        var i = 0
        
        for element in self.subscriptions as [SubscriptionType]
        {
            if element === subscription
            {
                index = i
                break
            }
            i += 1
        }

        if index != NSNotFound
        {
            self.subscriptions.removeAtIndex(index)
        }
    }

    // MARK: SequenceType protocol

    func generate() -> AnyGenerator<Subscription<ValueType>>
    {
        var nextIndex = subscriptions.count - 1

        return AnyGenerator<Subscription<ValueType>>
        {
            if (nextIndex < 0)
            {
                return nil
            }

            let retVal = self.subscriptions[ nextIndex ]
            nextIndex -= 1

            return retVal
        }
    }
}