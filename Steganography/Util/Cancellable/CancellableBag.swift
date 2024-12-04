//
//  CancellableBag.swift
//  Steganography
//
//  Created by 김수아 on 11/24/24.
//

final class CancellableBag: Cancellable {
    var cancellables: [Cancellable] = []
    
    func append(_ cancellable: Cancellable) {
        cancellables.append(cancellable)
    }
    
    func cancel() {
        let cancellables = self.cancellables
        self.cancellables.removeAll()
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }
    
    deinit {
        cancel()
    }
}
