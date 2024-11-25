//
//  Task+Cancellable.swift
//  Steganography
//
//  Created by 김수아 on 11/24/24.
//

extension Task: Cancellable {
    func add(to bag: CancellableBag) {
        bag.append(self)
    }
}
