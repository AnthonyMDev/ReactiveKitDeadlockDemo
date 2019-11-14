//
//  ReactiveKitDeadlockDemo.swift
//  ReactiveKitDeadlockDemo
//
//  Created by Anthony Miller on 11/14/19.
//

import ReactiveKit

public struct PollInfo {
    var interval: Double
    var repeatCount: Double
}

extension SignalProtocol {

    func retry(for pollInfo: PollInfo) -> Signal<Element, Error> {
        let repeatCount = Int(pollInfo.repeatCount)
        guard repeatCount > 1 else { return self.toSignal() }

        return Signal { observer in
            let subject = Signal<Int, Never>(
                sequence: 1...repeatCount - 1,
                interval: pollInfo.interval
            ).publish()
            let retryDisposable = self.retry(when: subject).observe(with: observer.on)
            let pollingDisposable = subject.connect()

            return CompositeDisposable([retryDisposable, pollingDisposable])
        }
    }
    
}
