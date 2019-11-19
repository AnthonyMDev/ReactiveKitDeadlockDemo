//
//  ReactiveKitDeadlockDemoTests.swift
//  ReactiveKitDeadlockDemoTests
//
//  Created by Anthony Miller on 11/14/19.
//  Copyright © 2019 Salesforce.Org. All rights reserved.
//

import ReactiveKit
import Nimble
import XCTest

@testable import ReactiveKitDeadlockDemo

class ReactiveKitDeadlockDemoTests: XCTestCase {

    enum Error: Swift.Error {
        case testError
    }

    func testExample() {        
        let expectedPollCount = 5
        let pollInterval: Double = 0.1
        let pollInfo = PollInfo(interval: pollInterval, repeatCount: Double(expectedPollCount))


        for i in 0...250 {
            let queue = DispatchQueue(label: "TestSignal.Queue \(i)",
                                      qos: .userInitiated,
                                      attributes: DispatchQueue.Attributes.concurrent)
            print("start loop \(i)")

            let disposeBag = DisposeBag()
            var signalCallCount = 0

            let signal = Signal<Bool, Error> { observer in
                signalCallCount += 1

                queue.async { [signalCallCount] in
                    switch signalCallCount {
                    case 4:
                        observer.receive(true)
                    default:
                        observer.receive(completion: .failure(Error.testError))
                    }
                }

                return SimpleDisposable()
            }

            waitUntil(timeout: 2.0) { done in
                signal
                    .retry(for: pollInfo)                    
                    .observeNext {
                        if $0 {
                            disposeBag.dispose()
                            print("done")
                            done()
                        }
                }
                .dispose(in: disposeBag)
            }
            print("moving on \(i) - \(signalCallCount)")
        }
    }

}
